# Step 09 — `brain ask` (RAG Q&A)

## Read first
- `brain-plan/00-overview.md` (RAG for `ask`)
- `brain-plan/PROGRESS.md`

## Goal
Answer questions over the wiki with citations.

## Tasks

1. New package `internal/ask/`:
   ```go
   type Answer struct {
       Text      string
       Citations []Citation
       UsedChunks []ChunkRef
   }

   type Citation struct {
       File    string
       Heading string
       Excerpt string
   }

   func Answer(ctx context.Context, q string, idx *index.Index, llm *llm.Client) (*Answer, error)
   ```
2. Pipeline:
   1. Embed query.
   2. Retrieve top-20 chunks via `index.Search`.
   3. Optionally re-rank by recency (use `file_mtime`) — small boost, not dominant.
   4. Take top-8.
   5. Render `templates/ask.tmpl` with chunks formatted as:
      ```
      [#1] file: wiki/programming/go/garbage-collection.md
            heading: Go GC > Tri-color
            content: <chunk text>
      ```
   6. System rule in prompt:
      - Cite sources by `[#N]` inline.
      - If insufficient info, reply exactly `INSUFFICIENT: <what's missing>`.
   7. Parse response, map `[#N]` back to chunks for the `Citations` field.

3. Subcommand `brain ask "question"`:
   - Default: human-readable output with citations footnotes.
   - `--json`: machine-readable.
   - `--k 8` to override top-k.
   - `--tag work` to constrain retrieval (passes tag filter to `Search`).

4. Update `brain.el`'s `brain-ask` to render the answer in markdown-mode and make `[#N]` clickable (button that jumps to the citation file).

## Verify

```sh
brain ask "what do I know about go garbage collection?"
# returns answer + citations pointing at the seeded wiki page

brain ask "what's my opinion on pineapple pizza?"
# returns INSUFFICIENT
```

Tests:
- Citation parsing handles missing/invalid `[#N]`.
- Mock LLM returning known answers; assert citations populated.

## Out of scope
- Conversation memory / multi-turn (v1: stateless).
- Streaming.

## Commit
`feat: brain ask with cited RAG answers`
