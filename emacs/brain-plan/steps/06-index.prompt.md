# Step 06 — sqlite-vec index + embeddings

## Read first
- `brain-plan/00-overview.md` (RAG for `ask` section)
- sqlite-vec docs: https://github.com/asg017/sqlite-vec

## Goal
Build & maintain an embedding index of wiki pages. Step 09 will query it.

## Tasks

1. New package `internal/index/`:
   - `Open(path string) (*Index, error)` — opens sqlite, loads `vec0` extension. Creates schema if missing:
     ```sql
     CREATE TABLE IF NOT EXISTS chunks (
       id INTEGER PRIMARY KEY,
       file TEXT NOT NULL,
       heading TEXT,
       content TEXT NOT NULL,
       tags TEXT,        -- JSON array
       file_mtime INTEGER NOT NULL,
       chunk_hash TEXT NOT NULL UNIQUE
     );
     CREATE INDEX IF NOT EXISTS idx_chunks_file ON chunks(file);
     CREATE VIRTUAL TABLE IF NOT EXISTS vec_chunks USING vec0(
       embedding float[768]   -- nomic-embed-text dimension; make configurable
     );
     ```
   - `IndexFile(path string) error` — re-chunks and re-embeds one wiki file (delete existing rows for that file first).
   - `IndexAll(root string) (Stats, error)` — walks `wiki/`, indexes changed files (compare mtime).
   - `Search(ctx, queryEmbedding []float32, k int, tagFilter []string) ([]Hit, error)` — vector top-k, optional tag overlap filter post-hoc.
   - `Stats() (Stats, error)`.
2. Chunking strategy:
   - Strip frontmatter.
   - Split by H2/H3 headings.
   - If a section > 512 tokens (rough: ~2000 chars), further split by paragraphs with 64-token overlap.
   - Each chunk carries its heading path (e.g. `Go > Garbage Collection > Tri-color`).
3. Tag extraction for chunks: union of frontmatter `tags:` + any inline `:tags:` in the chunk.
4. `chunk_hash`: sha256 of (file + heading + content). Lets us skip re-embedding unchanged chunks even when other parts of the file change.
5. Subcommands:
   - `brain index` — incremental.
   - `brain index --rebuild` — drops tables, redoes everything.
   - `brain index --stats` — files indexed, chunks, total tokens (estimated), DB size.
   - `brain index --file <path>` — single file.

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
brain index --stats        # shows 1 file, 2+ chunks
brain index                # second run: 0 changed
touch ~/notes/wiki/programming/go/garbage-collection.md
brain index                # 1 file re-indexed, 0 chunks changed (hash match)
```

Tests:
- `index_test.go`: chunking, hash stability, incremental skip, vector round-trip.
- Use a tiny mock embedder that returns deterministic vectors (don't hit Ollama in unit tests; integration test gated by `BRAIN_E2E=1`).

## Out of scope
- Querying / `ask` command (step 09).
- Re-indexing on wiki write (step 08).

## Commit
`feat: sqlite-vec wiki index with incremental updates`
