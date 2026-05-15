---
title: Brain — Design Overview
status: draft
---

# Brain

A personal capture-and-curate system. You dump tagged notes into a daily file; a
local LLM curates them into a self-organizing markdown wiki you can query.

## Non-negotiables

- **Local-only.** Ollama on the workstation. Nothing leaves the machine.
- **Human-in-the-loop wiki writes.** LLM proposes; you merge via `magit`.
- **Append-only journal.** The day file is sacred input. The LLM never edits it.
- **You handle redaction.** No automated PII pass in v1.

## Components

```
┌──────────────────┐     shells out      ┌──────────────────┐
│ brain.el (Emacs) │ ──────────────────► │  brain (Go CLI)  │
└──────────────────┘                     └────────┬─────────┘
                                                  │ HTTP
                                         ┌────────▼─────────┐
                                         │  Ollama (local)  │
                                         │  gemma4:26b      │
                                         │  nomic-embed-text│
                                         └──────────────────┘
                                                  │
                                         ┌────────▼─────────┐
                                         │ ~/notes (git)    │
                                         │  journal/        │
                                         │  wiki/           │
                                         │  .brain/index.db │
                                         └──────────────────┘
```

- **`brain.el`** — thin elisp. Commands: `brain-today`, `brain-digest`, `brain-ask`. No business logic; just shells out and shows buffers.
- **`brain` (Go binary)** — all logic. Subcommands below. Single static binary, fast startup, easy distribution.
- **Ollama** — `gemma4:26b` for curation/Q&A, `nomic-embed-text` for embeddings. Configurable.
- **`~/notes`** — git repo. Journal is the source of truth; wiki is regenerable.
- **`.brain/index.db`** — SQLite with `sqlite-vec` extension. Embeddings + chunk metadata.

## Note format

Markdown with YAML frontmatter. Tags are inline `:tag:` tokens (Org-style, but parsed by us). Multi-level tags use `:` separator: `:market:se:`.

```markdown
---
date: 2026-05-15
---

# 2026-05-15

## morning
- pushed PR #421 :work:td-api:tasks:
- read https://example.com/gc-go :source:learnings:go:
  - mark-sweep + tri-color :go:gc:
- :messages: pinged @alice on slack about market rollout :market:se:

## todo
- [ ] write design doc for v2 endpoint :td-api:todo:
- [x] reply to procurement email

## achieve
- :achieve: shipped beta of TD-API webhook to staging :td-api:
```

Rules:
- Tags: `:[a-z0-9][a-z0-9:_-]*:` — colon-delimited, lowercase.
- A line "owns" all `:tags:` it contains.
- Indented bullets inherit parent tags + add their own.
- `## todo` section is special: items there are tracked for carry-over.
- `## achieve` items feed promo reports later.
- The frontmatter `date:` is the only required structure.

## Directory layout

```
~/notes/
  .brain/
    index.db                 # sqlite-vec
    config.toml              # model names, paths
    prompts/                 # versioned prompt templates
  journal/
    2026/
      05/
        2026-05-15.md
  wiki/
    programming/
      go/
        index.md
        garbage-collection.md
      rust/
    work/
      td-api/
        index.md
        webhooks.md
      market/
        se.md
    people/
      alice.md
    .meta/
      links.json             # backlinks index
```

Wiki pages are vanilla markdown with YAML frontmatter:

```markdown
---
title: Go Garbage Collection
tags: [go, gc, programming]
sources:
  - journal: 2026-05-15
    span: lines 7-9
    excerpt: "mark-sweep + tri-color"
  - url: https://example.com/gc-go
last_curated: 2026-05-16T08:00:00Z
---

# Go Garbage Collection

Tri-color mark-sweep collector...
```

`sources` is the audit trail — every claim traces back to a journal entry. Lets
you verify the LLM didn't hallucinate.

## CLI surface

```
brain today                  # open today's journal file (creates if missing,
                             #   triggers digest of yesterday if new day)
brain digest [--date YYYY-MM-DD] [--dry-run]
                             # parse journal, propose wiki edits on staging branch
brain ask "question"         # RAG Q&A over wiki
brain index [--rebuild]      # (re)build embeddings
brain carryover              # copy unfinished :todo: from last journal to today
brain doctor                 # check ollama, models, db, git
```

Exit codes are meaningful (elisp checks them). All commands accept `--json`.

## Digest pipeline

Triggered when `brain today` detects a new day, or run manually.

1. **Lock** `~/notes/.brain/digest.lock` (single-flight).
2. **Parse** yesterday's journal → list of `Item{text, tags, line_range, parent_tags}`.
3. **Group** items by primary tag-cluster (heuristic: longest shared tag prefix).
4. For each group:
   - **Retrieve** top-k existing wiki pages by embedding similarity + tag overlap.
   - **Classify** with LLM: `APPEND` to existing page, `CREATE` new page, or `SPLIT` an existing page that's grown too large.
   - **Generate** the patch (full new file content for the affected file(s)).
5. **Apply** all patches to a `brain/digest-YYYY-MM-DD` git branch.
6. **Re-embed** changed wiki files; update `.brain/index.db`.
7. **Notify** Emacs; `brain.el` opens `magit-diff` against `main`.
8. You review, edit, merge (or discard) — normal git workflow.

## Page-split heuristic

Avoid thrashing. Only split when **all** are true:
- Page > 1500 tokens.
- LLM identifies ≥ 2 distinct subtopics each with > 300 tokens of content.
- Page hasn't been split in the last 14 days (tracked in frontmatter).

When splitting: parent page becomes an index with brief sections + links to children.

## RAG for `ask`

- Chunk wiki pages by H2/H3 headings, ~512 tokens, 64-token overlap.
- Embed with `nomic-embed-text` (768d).
- `sqlite-vec` for ANN.
- Hybrid: vector top-20 + tag-filter + reorder by recency.
- Stuff top-8 chunks into prompt with citations (file path + heading).
- LLM answer must cite — if it can't, say "not in wiki".

## Carry-over

`brain today` on a new day:
1. Read most recent prior journal file.
2. Extract `- [ ] ...` lines under `## todo`.
3. Prepend a `## todo` section to today's file with those items.
4. Optionally annotate with `(carried from YYYY-MM-DD)`.

## Known limitations / risks

- **Local 27B model latency:** digest of a busy day = 1–5 min. Run async, post a
  notification buffer in Emacs; don't block.
- **Tag taxonomy drift:** without governance, `:td-api:` and `:tdapi:` become
  separate. Mitigation: `brain doctor` warns on near-duplicate tags; keep an
  optional `~/.brain/tags.txt` allowlist (lint-only, not enforced).
- **Cold start:** empty wiki → no retrieval signal → LLM mostly creates pages.
  First 2 weeks expect noise; hand-curate aggressively.
- **Auto-split stability:** the riskiest behavior. Heuristic above is conservative.
  Make it disable-able via config flag.
- **Embedding staleness:** any wiki change triggers re-embed of that file only.
  Full rebuild via `brain index --rebuild`.
- **Single-machine:** no sync. Use git remote (private) if you want backup.
  Journal may contain secrets — push at your own risk; consider keeping the git
  remote off and rsync-ing to an encrypted volume.

## Out of scope (v1)

- Web view (mkdocs/quartz). Wiki is browsable in Emacs / any markdown viewer.
- Promo report generator. Add later as `brain report`.
- Automated secret redaction. You handle it.
- Multi-user / sync.
- Mobile capture.

## Tech choices — quick justifications

| Choice | Why |
|---|---|
| Go CLI | Single static binary, fast startup (elisp shells out often), great concurrency for parallel LLM calls, good sqlite-vec bindings via `mattn/go-sqlite3` + extension load. |
| Markdown | Ubiquitous, every tool reads it, no lock-in. |
| sqlite-vec | One file, no daemon. Survives `~/notes` being a git repo (db is gitignored). |
| Ollama | You have it. HTTP API is trivial. |
| Git staging branch | Free undo. `magit` is already in your config. |
| gemma4:26b | Strong instruction following, good structured output. |
