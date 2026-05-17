# Progress

Append a short note after each step. Format:

```
## Step NN — <title> — YYYY-MM-DD
- What changed
- Anything the next step needs to know (gotchas, decisions, deferred items)
```

---

## Step 06 — SQLite FTS5 wiki index — 2026-05-17
- **Scope change vs original prompt:** dropped sqlite-vec / embeddings; replaced with SQLite FTS5 (BM25). Rationale documented in revised `steps/06-index.prompt.md` under "Why not embeddings (yet)". Tags + small curated corpus + lexical FTS cover the directed-Q&A use case without CGO or an Ollama embedding dependency on every index run. Schema is forward-compatible if a `vec_chunks` table is layered on later.
- Dep: `modernc.org/sqlite` v1.50.1 (pure-Go, ships with FTS5). Required `go 1.25.0` (bumped from 1.22).
- `internal/index`:
  - `Open(path)` creates `chunks` table + `chunks_fts` (`content='chunks'`, `tokenize='porter unicode61'`) + triggers (`chunks_ai`, `chunks_ad`) that keep FTS in sync on INSERT/DELETE.
  - `IndexFile`: delete-then-insert within a tx; `chunk_hash` UNIQUE (sha256 of file+heading_path+content).
  - `IndexAll(root)`: walks `.md` under root; skips files whose mtime matches the max recorded mtime for that file; calls `pruneMissing` to drop rows for deleted files.
  - `Search(ctx, q, k, tagFilter)`: FTS5 MATCH ordered by `bm25(chunks_fts)`; over-fetches when filtering and post-filters tags in Go (corpus is small).
  - `Rebuild`: drops triggers + tables, re-applies schema.
- `internal/index/chunk.go`: ATX heading split (H1/H2/H3 own a section; H4+ flow into current). Frontmatter stripped; supports flow (`[a, b]`) and block list tags. Oversized sections (>2000 chars) paragraph-split with ~200-char tail overlap.
- **FTS5 query sanitization:** `sanitizeFTS` quotes each whitespace-separated token so user input like `tri-color` isn't parsed as `tri NOT color`. Caught by `TestIndexRoundTrip` on first run.
- CLI: `brain index [--rebuild] [--stats] [--file PATH] [--search Q] [--limit N]`. Stats and search emit JSON on stdout. `--search` is a debug helper; the real `ask` flow lands in step 09.
- `cmd/brain/main.go` updated dispatch + usage line.
- Tests (7): heading split, hash stability, oversize split, FTS round-trip + tag filter, incremental skip (touched mtime, no churn), rebuild clears, prune missing files. All pass; `go vet` and `gofmt` clean.
- E2E verified per prompt's verify block against a temp `$HOME/notes/wiki/...`: rebuild → 1 file/2 chunks; second run unchanged; touched mtime re-indexes with same chunk count; `--search "tri-color"` returns the Tri-color chunk.
- Reused tag regex inline in `chunk.go` rather than exporting from `internal/parse` to keep packages decoupled. If a third consumer appears, lift it into a shared `internal/tags` package.


- `config.Ollama` (`Host`, `TimeoutSeconds`) + `config.Models` (`Curator`, `Embedder`) structs; `DefaultOllama()` → `http://127.0.0.1:11434`, 600 s; `DefaultModels()` → `gemma4:26b` / `nomic-embed-text`
- TOML parsing deferred — config structs use hardcoded defaults for now; will revisit when a step needs to read/mutate the file
- `internal/llm`: `Client` with `Chat`, `ChatJSON` (format:"json" + JSON decode), `Embed`; `post` retries up to 3× with exponential backoff (1 s, 2 s) on 5xx/connection errors; no retry on 4xx; `sleep` field injectable for fast tests; slog debug logging gated by `BRAIN_DEBUG=1`
- `internal/prompts`: `//go:embed templates/*.tmpl`; `Render(name, data)` executes Go template; `EnsurePromptDir()` copies embedded templates to `~/notes/.brain/prompts/` only if absent; user overrides at that path take precedence over embedded; `userPromptsDirOverride` package var for test injection
- `internal/prompts/templates/ping.tmpl`: minimal liveness-check prompt — asks model to reply with "pong from <model>"
- `brain ping` subcommand: renders ping.tmpl, calls `Chat`, prints response, exits non-zero if response doesn't contain "pong"
- All tests pass (7 packages); build and vet clean; gofmt clean
- Committed as `fbfa534` "feat: ollama client and prompt template loader"

## Step 04 — brain.el Emacs frontend — 2026-05-16
- Replaced placeholder `emacs/brain.el` with full implementation
- Customization group `brain`: `brain-executable` (default `"brain"`), `brain-notes-directory` (default `"~/notes"`)
- `brain-today` — sync `call-process`, opens path in buffer, jumps to end of `## notes`
- `brain-doctor` — sync `call-process`, output in `*brain-doctor*`
- `brain-ask` — async `make-process` into `*brain-ask*` (markdown-mode when available); sentinel scrolls to top on finish; fails gracefully until step 09
- `brain-digest` — async `make-process` into `*brain-digest*`; blocks second run with `user-error`; sentinel resets `brain--running`, optionally calls `magit-status` when Magit is loaded
- Mode-line indicator `[brain⚙]` via `global-mode-string` conditional; updated by `force-mode-line-update`
- `brain-command-map` (`defvar-keymap`): `t`→today, `a`→ask, `d`→digest, `?`→doctor
- Section headers follow `;;; ===...=== ;;; NAME` convention from AGENTS.md
- Byte-compile clean: zero warnings under `emacs -Q --batch -f batch-byte-compile brain.el`
- `make install` copies both binary and `brain.el` to configured paths (unchanged from step 01)

## Step 03 — Tag parser & journal model — 2026-05-16
- New package `internal/parse`: `Item`, `Journal`, `ParseFile`, `ParseBytes`
- Tag regex `:([a-z0-9][a-z0-9_-]*(?::[a-z0-9][a-z0-9_-]*)*):` — multi-segment tags (`:market:se:`) matched as one token; space between tags prevents merging
- Section detection: `## todo` / `## notes` / `## achieve` → `Section`; unknown H2 → `Section=""`
- Tag inheritance via tree build from flat list + indent-based parent stack; `mergeTags` deduplicates
- Code fences (` ``` `) toggle parsing off — tags inside fences excluded
- `LineStart`/`LineEnd` computed per item; `LineEnd` propagated up from children
- Frontmatter parsed with simple `key: value` scanner; `date:` → `time.Time`
- `internal/cli/parse.go`: `Parse(args)` — default human-readable tree output; `--json` marshals full `Journal` to JSON
- `main.go`: `parse` subcommand added
- 14 tests in `parse_test.go` covering all spec cases: multi-segment tags, inheritance (2 & 3 levels), dedup, `[x]`/`[ ]`, frontmatter, code-fence exclusion, emoji + tag, line numbers, section assignment, unknown section, no frontmatter
- All pass: build/vet/test/gofmt clean

## Step 02 — brain today + carry-over — 2026-05-16
- Added `internal/journal` package: `Path`, `EnsureToday`, `MostRecentBefore`, `ExtractOpenTodos`, `CoreText`
- Day template rendered via `text/template`; written to `<root>/journal/YYYY/MM/YYYY-MM-DD.md`
- Carry-over injects `- [ ] ... (carried from YYYY-MM-DD)` under `## todo` on file creation
- `internal/cli/today.go`: `Today(args)` + `Carryover(args)`, both accept `--date YYYY-MM-DD`
- `Today` supports `--no-carryover` flag; `Carryover` is idempotent (deduplicates by `CoreText`)
- `main.go` updated: `today` and `carryover` subcommands registered
- `journal_test.go`: 11 tests covering path, extraction (basic/nested/mixed/cross-section), most-recent finder (incl. empty months, none), EnsureToday idempotency + template content + carryover, CoreText
- All pass: `go build ./...`, `go vet ./...`, `go test ./...`, `gofmt -l .`
- `notesRoot()` and `parseDate()` are package-private helpers in `cli/today.go`; no TOML parsing yet (deferred until a step that reads config values)

## Step 01 — Scaffold — 2026-05-16
- Created `go-brain/` (module `github.com/arashThr/brain`) at `./go-brain` relative to this dotfiles workspace
- Layout: `cmd/brain/main.go`, `internal/config/`, `internal/cli/`, `emacs/brain.el`, `prompts/templates/`, `Makefile`, `.gitignore`, `README.md`
- `brain version` and `brain doctor` fully implemented (stdlib only, no external deps)
- `doctor` checks: Go version, Ollama GET /api/tags, required models `gemma4:26b` + `nomic-embed-text` (warns, doesn't fail), `~/notes/` git repo (offers `git init`), `~/notes/.brain/config.toml` (creates with defaults if absent)
- All lint/test/vet pass: `go build`, `go test ./...`, `gofmt -l .`, `go vet ./...`
- Config is written as a raw TOML string — no TOML parser needed until a step that reads/mutates values
- `internal/cli/doctor.go` has no tests; IO-heavy, will benefit from an interface seam when mocking is worthwhile
- `emacs/brain.el` is a placeholder `(provide 'brain)` — full implementation in step 04
