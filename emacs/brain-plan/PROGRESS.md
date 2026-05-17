# Progress

Append a short note after each step. Format:

```
## Step NN — <title> — YYYY-MM-DD
- What changed
- Anything the next step needs to know (gotchas, decisions, deferred items)
```

---

## Step 10 — Auto page-split with cooldown — 2026-05-17
- New `config.DigestConfig` struct (`AutoSplitEnabled`, `SplitMinTokens`, `SplitCooldownDays`) + `DefaultDigestConfig()` added to `internal/config`.
- `BuildPlan` signature extended with `cfg config.DigestConfig`; all call sites updated.
- `processGroup` now returns `[]Patch` (previously single `Patch`) to accommodate parent+children output.
- Split heuristic (`splitHeuristic`): fires when `auto_split_enabled=true`, post-append token count (char/4) exceeds `split_min_tokens`, and `last_split` in frontmatter is absent or older than `split_cooldown_days`.
- `parseFrontmatterLastSplit` / `injectLastSplit`: minimal YAML frontmatter string helpers; no external dep.
- `executeSplit`: renders `digest_split.tmpl` → calls `lc.ChatJSON` → validates ≥2 children with >300 tokens each → returns `[SPLIT parent] + [CREATE child…]` patches. Falls back (logged to stderr) to APPEND on validation failure.
- Parent patch: `DecisionSplit`, content is a fresh index page with `last_split:` injected. Children written at `<parent_dir>/<parent_slug>/<child_slug>.md`.
- New template `internal/prompts/templates/digest_split.tmpl` instructs LLM to output JSON `{parent, children[]}`.
- `cli/digest.go`: passes `config.DefaultDigestConfig()` to `BuildPlan`.
- Tests (7 new, 11 updated): `TestSplitHeuristic_UnderThreshold`, `OverButCooldown`, `OverPastCooldown`, `DisabledFlag`; `TestExecuteSplit_ValidationFallback`, `WritesParentAndChildren`; `TestBuildPlan_AutoSplit` (integration: fat file on disk → heuristic fires → 3 patches). All 17 digest tests pass; full suite green.

## Step 09 — brain ask (RAG Q&A) — 2026-05-17
- New package `internal/ask`: `ChunkRef`, `Citation`, `Answer` types; `Ask(ctx, q, idx, lc, topK, tagFilter)` runs the full RAG pipeline.
- Pipeline: over-fetch (topK×3 or 20, whichever is larger) from `idx.Search` → recency re-rank (0.85 BM25 relevance + 0.15 file_mtime recency, each normalised to [0,1]) → take top-k → render `ask.tmpl` → `lc.Chat` → parse `[#N]` citations from response.
- `buildAnswer` deduplicates `[#N]` references and maps them back to `index.Hit`; out-of-range/invalid refs are silently dropped.
- `excerpt(s, n)` trims to word boundary and appends `…`.
- `internal/index.Hit` gained `FileMTime int64` field; `Search` query updated to `SELECT ... c.file_mtime` and scan updated to 7 variables.
- New prompt template `internal/prompts/templates/ask.tmpl` instructs the LLM to cite `[#N]` inline or reply `INSUFFICIENT: <what's missing>`.
- `InsufficientPrefix` constant exported for callers.
- `internal/cli/ask.go`: `brain ask [--json] [--k N] [--tag TAG] <question>`. Human-readable output prints text + footnote-style citations; `--json` emits `Answer` JSON.
- `cmd/brain/main.go`: `ask` case added; usage string updated.
- `emacs/brain.el`:
  - `brain-ask` rewritten: collects JSON to a scratch buffer (` *brain-ask-raw*`), kills it on finish, calls `brain--ask-render`.
  - `brain--ask-render`: parses JSON with `json-parse-string` (Emacs 29 built-in), renders **Q:** header + answer text + Citations section with clickable file buttons; falls back to raw dump on parse error.
  - `brain--insert-citation-button`: creates a `find-file` button relative to `brain-notes-directory`.
  - `brain--buttonize-citation-refs`: post-processes buffer after `markdown-mode`, replaces `[#N]` spans with buttons that jump to the `**[#N]**` footnote.
- Tests (11 in `internal/ask`): `buildAnswer` citation extraction/dedup/invalid-ref/INSUFFICIENT; `excerpt` short/truncate; `rerank` top-k/empty/k-larger-than-hits; integration `TestAsk_CitationsFromMockLLM` (httptest mock, real SQLite, asserts citations populated); `TestAsk_InsufficientWhenNoRelevantChunks` (empty index). All pass.
- Test query uses `"tri-color mark-and-sweep"` (literal in content) rather than "go garbage collection" to avoid porter-stemmer uncertainty on "collector" vs "collection".

## Step 08 — Digest apply (staging branch) — 2026-05-17
- New package `internal/gitops`: thin `os/exec` wrapper around git. Exports `EnsureClean`, `CurrentBranch`, `DefaultBranch`, `Checkout`, `CommitAll`, `ReturnTo`, `AcquireLock`.
- `AcquireLock` uses `syscall.Flock(LOCK_EX|LOCK_NB)` — non-blocking; lock auto-released by OS on process exit (handles crashes without stale lock files).
- `DefaultBranch` prefers "main" over "master"; falls back to "main" if neither found.
- Apply flow in `cli/digest.go` (`applyPlan`): lock → EnsureClean → CurrentBranch → Checkout (`brain/digest-YYYY-MM-DD-HHMMSS`) → write files → CommitAll → re-index (non-fatal) → ReturnTo. Named return `retErr` drives deferred rollback.
- `--dry-run` default changed from `true` to `false`; `brain digest` now applies by default.
- `ExitError{Code, Message}` in `internal/cli` carries specific exit codes: 11 lock held, 12 dirty tree, 13 LLM error, 14 git error. `main.go` uses `errors.As` to propagate them.
- Commit message format: `digest: YYYY-MM-DD (N patches)\n- DECISION path: reason`.
- Output last line `BRANCH=<name>` for `brain.el` to capture.
- `brain.el` updates:
  - `brain--capture-branch`: scans process buffer for `^BRANCH=(.+)$`.
  - `brain--digest-sentinel` (renamed param from `_proc` to `proc`): on success calls `magit-diff-range "main..<branch>"` when branch captured and Magit available; falls back to `magit-status` otherwise.
  - Removed duplicate `(provide 'brain)` / footer that had accumulated from step 04.
- Tests (10 in `gitops`): `CurrentBranch`, `EnsureClean` clean/dirty, `DefaultBranch`, `Checkout` create/nonexistent, `CommitAll`, `ReturnTo`, `AcquireLock` exclusive, `ApplyRollbackOnError`. All pass; build/vet/gofmt clean.

## Step 07 — Digest planner (dry-run only) — 2026-05-17
- New package `internal/digest`: `Decision`, `Patch`, `Plan` types + `BuildPlan(ctx, *parse.Journal, *index.Index, *llm.Client) (*Plan, error)`.
- Tag-cluster algorithm: count tag-prefix frequencies across all items; tags in >70% of items are "trivial/dominant"; each item's cluster key = most-specific non-trivial tag (depth by colon-count), falling back to first trivial tag or "other".
- FTS index used for candidate retrieval (top-5 files by summed BM25 score); graceful no-op when index is empty or query produces no hits.
- Decision call uses `ChatJSON` + `digest_decide.tmpl` (strict JSON schema: `{decision, target_path, reason}`).
- Content call uses `Chat` + `digest_content.tmpl`; response extracted from fenced code block (`\`\`\`md`, `\`\`\`markdown`, `\`\`\``, `~~~md`, `~~~`).
- SPLIT decision deferred: treated as APPEND with `WouldSplit: true` flag surfaced in both JSON output and human-readable plan.
- Concurrency: semaphore of 2 goroutines; context cancellation handled before acquiring semaphore.
- `internal/cli/digest.go`: `brain digest [--date YYYY-MM-DD] [--dry-run] [--json]`; default date = yesterday.
- Prompts registered in `internal/prompts/templates/`; automatically embedded and copied to user prompts dir.
- `cmd/brain/main.go`: `digest` subcommand added.
- Tests (11): cluster-by-tag, empty/all-trivial/no-tag cluster, extract-fenced-markdown (7 subtests: backtick/tilde/bare/no fence), lineRange, BuildPlan mock (CREATE, SKIP, SPLIT→APPEND), empty journal. All pass; `go vet` and `gofmt` clean.
- E2E test gated `BRAIN_E2E=1`.

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

## Step 05 — Ollama client and prompt template loader — 2026-05-16
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
