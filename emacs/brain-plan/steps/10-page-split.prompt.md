# Step 10 — Auto page-split

## Read first
- `brain-plan/00-overview.md` (Page-split heuristic)
- `brain-plan/PROGRESS.md`

## Goal
Promote the deferred `would-split` cases from step 07 into real splits when the heuristic permits.

## Tasks

1. Add to wiki page frontmatter:
   ```yaml
   last_split: 2026-05-15T00:00:00Z
   ```
2. In `internal/digest/`, before calling content prompt for an `APPEND`:
   - Estimate post-append token count (use a cheap tokenizer: rough char/4 estimate is fine).
   - If `> split_min_tokens` AND `last_split` older than `split_cooldown_days`: invoke split flow.
3. Split flow:
   - Render `templates/digest_split.tmpl`: input is the current page + new items. Required output (JSON):
     ```json
     {
       "parent": {
         "title": "...",
         "summary_with_links": "..."
       },
       "children": [
         {"title": "...", "slug": "tri-color", "content": "..."},
         {"title": "...", "slug": "write-barriers", "content": "..."}
       ]
     }
     ```
   - Validate ≥ 2 children, each with > 300-token content.
   - Write parent as the original path, becoming an index page.
   - Children written under `<parent_dir>/<parent_slug>/<child_slug>.md`.
   - Set `last_split` on parent.
4. All splits go into the same digest staging branch; commit message lists them.
5. Config flag `[digest] auto_split_enabled = false` short-circuits to plain APPEND.

## Verify

```sh
# create a fat seed page (2000+ tokens) and a fresh journal that adds to it
brain digest --date 2026-05-15
git -C ~/notes diff main..brain/digest-* -- 'wiki/programming/go/*'
# expect parent page reduced to index + new child files
```

Tests:
- Heuristic decisions: under threshold → no split; over but cooldown → no split; over + past cooldown → split.
- Validation: LLM returning < 2 children → fall back to APPEND with warning.

## Out of scope
- Splitting non-LLM-driven (manual `brain split <file>` could come later).
- Merging (collapsing children back).

## Commit
`feat: auto page-split with cooldown`
