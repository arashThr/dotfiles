# Step 03 — Tag parser & journal model

## Read first
- `brain-plan/00-overview.md` (Note format section)
- `brain-plan/PROGRESS.md`

## Goal
Parse a journal markdown file into structured `Item`s with inherited tags, ready for the digest pipeline.

## Tasks

1. New package `internal/parse/`:
   ```go
   type Item struct {
       Text       string   // bullet text minus tags
       RawText    string   // original line
       Tags       []string // resolved tags incl. inherited
       OwnTags    []string // tags on this line only
       LineStart  int
       LineEnd    int
       Section    string   // "todo" | "notes" | "achieve" | "" (top-level)
       Indent     int
       IsTodo     bool
       Done       bool     // for [x] items
       Children   []*Item
   }

   type Journal struct {
       Date       time.Time
       Path       string
       Items      []*Item   // top-level only; tree via Children
       Frontmatter map[string]any
   }

   func ParseFile(path string) (*Journal, error)
   func ParseBytes(data []byte) (*Journal, error)
   ```
2. Tag regex: `:([a-z0-9][a-z0-9:_-]*?):` — non-greedy, lowercase. Strip from `Text`, keep in `OwnTags`. Multi-segment tag like `:market:se:` is **one** tag (parser must not split it into `:market:` and `:se:`).
   - Implementation: scan for `:WORD(:WORD)*:` runs.
3. Section detection by H2 (`## todo`, `## achieve`, `## notes`). Anything else → `Section = ""`.
4. Tag inheritance: a child bullet's `Tags = parent.Tags ∪ OwnTags` recursively.
5. CLI: `brain parse <file> [--json]` prints the tree (human-readable default).
6. Tests in `parse/parse_test.go`:
   - Multi-segment tags
   - Nested bullets across multiple indent levels
   - `[x]` vs `[ ]` items
   - Frontmatter parsing
   - Edge: tag-like text in code fences must NOT be parsed as tags (e.g. `:hover:` inside a fenced block)
   - Edge: emojis adjacent to tags

## Verify

```sh
cat > /tmp/sample.md <<'EOF'
---
date: 2026-05-15
---
# 2026-05-15
## notes
- pushed PR :work: :td-api:
  - added retry logic :td-api:
- read GC paper :learnings: :go: :gc:
## todo
- [ ] write doc :td-api: :todo:
- [x] reply email
EOF

brain parse /tmp/sample.md --json | jq '.items[] | {text, tags}'
```

Expected: nested item inherits `:work:` `:td-api:` and adds nothing new own;
GC item has `:learnings: :go: :gc:`; todo done/undone parsed correctly.

## Out of scope
- Wiki parsing (different schema, separate step).
- LLM anything.

## Commit
`feat: tag parser with inheritance`
