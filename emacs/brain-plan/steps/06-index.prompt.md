# Step 06 — SQLite FTS5 wiki index

> **Revised from the original sqlite-vec plan.** See "Why not embeddings (yet)"
> at the bottom for rationale.

## Read first
- `brain-plan/00-overview.md` (RAG-for-`ask` section — now FTS-for-`ask`)

## Goal
Build & maintain a searchable index of wiki pages. Step 09 (`ask`) will query
it via tag filter + FTS5 BM25 ranking. The schema is designed so a vector
column can be layered on later without a rewrite.

## Tasks

1. New package `internal/index/`:
   - Use `modernc.org/sqlite` (pure-Go, no CGO, ships with FTS5).
   - `Open(path string) (*Index, error)` — opens sqlite, applies schema:
     ```sql
     CREATE TABLE IF NOT EXISTS chunks (
       id           INTEGER PRIMARY KEY,
       file         TEXT NOT NULL,
       heading_path TEXT,           -- e.g. "Go > GC > Tri-color"
       content      TEXT NOT NULL,
       tags         TEXT NOT NULL,  -- JSON array, lowercased
       file_mtime   INTEGER NOT NULL,
       chunk_hash   TEXT NOT NULL UNIQUE
     );
     CREATE INDEX IF NOT EXISTS idx_chunks_file ON chunks(file);

     CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
       heading_path, content, tags,
       content='chunks', content_rowid='id',
       tokenize = 'porter unicode61'
     );

     -- Triggers to keep FTS in sync.
     CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
       INSERT INTO chunks_fts(rowid, heading_path, content, tags)
         VALUES (new.id, new.heading_path, new.content, new.tags);
     END;
     CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
       INSERT INTO chunks_fts(chunks_fts, rowid, heading_path, content, tags)
         VALUES ('delete', old.id, old.heading_path, old.content, old.tags);
     END;

     CREATE TABLE IF NOT EXISTS meta (
       key TEXT PRIMARY KEY, value TEXT NOT NULL
     );
     ```
   - `IndexFile(path string) error` — re-chunks a single wiki file
     (delete existing rows for that file first, then insert).
   - `IndexAll(root string) (Stats, error)` — walks `wiki/`, indexes files
     whose mtime ≠ recorded mtime. Skips files where all chunk hashes already
     present.
   - `Search(ctx, query string, k int, tagFilter []string) ([]Hit, error)` —
     BM25-ranked FTS5 query. `tagFilter` is applied as an `AND` over a
     JSON-tag overlap check (post-filter in Go is fine; corpus is small).
   - `Stats() (Stats, error)` — files indexed, chunks, db size.
   - `Close() error`.

2. Chunking (`internal/index/chunk.go`):
   - Strip YAML frontmatter.
   - Split by H2/H3 headings; if no headings, whole body is one chunk.
   - If a section > ~2000 chars, split by paragraph with ~200-char overlap.
   - Each chunk carries `heading_path` (joined with " > ").

3. Tag extraction for chunks:
   - Union of frontmatter `tags:` + inline `:tag:` tokens in chunk body
     (reuse the regex from `internal/parse`).
   - Store as JSON array, lowercased, deduped, sorted.

4. `chunk_hash`: sha256 of `file + "\n" + heading_path + "\n" + content`.
   `UNIQUE` constraint means re-indexing an unchanged chunk is a no-op
   (use `INSERT OR IGNORE`, then prune orphans for that file).

5. CLI (`internal/cli/index.go`):
   - `brain index` — incremental.
   - `brain index --rebuild` — drops tables, redoes everything.
   - `brain index --stats` — files / chunks / DB size.
   - `brain index --file <path>` — single file.

6. Wire into `cmd/brain/main.go` usage + dispatch.

## Verify

```sh
mkdir -p ~/notes/wiki/programming/go
cat > ~/notes/wiki/programming/go/garbage-collection.md <<'EOF'
---
title: Go GC
tags: [go, gc]
---
# Go GC
## Tri-color
Mark and sweep with three colors...
## Write barriers
Dijkstra-style write barriers...
EOF

brain index --rebuild
brain index --stats        # 1 file, 2+ chunks
brain index                # second run: 0 changed
touch ~/notes/wiki/programming/go/garbage-collection.md
brain index                # mtime bumped, 0 chunks changed (hashes match)
```

Tests (`internal/index/index_test.go`):
- chunking (heading split, oversize split)
- hash stability across runs
- incremental skip (same content, bumped mtime → no churn)
- FTS round-trip (insert, search, BM25 ordering sane)
- tag filter post-hoc
- `--rebuild` clears state

Use a temp dir + in-process sqlite file. No Ollama needed — pure-Go driver.

## Out of scope
- `ask` command (step 09).
- Auto re-indexing on wiki write (step 08 wires that).
- Vector / semantic retrieval (deferred; see below).

## Why not embeddings (yet)

The original plan called for `sqlite-vec` + `nomic-embed-text`. Decided against
it for v1:

- Corpus is small (curated personal wiki, low thousands of pages max).
- Tags are a hand-built semantic index — more reliable than cosine similarity
  on personal shorthand.
- FTS5 with BM25 + tag filter covers the directed-Q&A use case for `ask`.
- Avoids CGO, an Ollama embedding dependency on every `index`, and chunk-hash
  vs vector-staleness bookkeeping.
- The `chunks` schema is compatible with a future `vec_chunks` table; can be
  added without migrating existing data when a real need shows up.

Revisit when: corpus grows past ~10k chunks, or `ask` quality is poor on real
usage after a few weeks of dogfooding.

## Commit
`feat: sqlite FTS5 wiki index with incremental updates`
