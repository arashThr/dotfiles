# Step 02 — `brain today` + carry-over

## Read first
- `brain-plan/00-overview.md` (sections: Note format, Carry-over)
- `brain-plan/PROGRESS.md`

## Goal
`brain today` creates today's journal file (idempotent), carries over unfinished todos from the most recent prior journal, and prints the file path.

## Tasks

1. New package `internal/journal/`:
   - `Path(root string, date time.Time) string` → `<root>/journal/YYYY/MM/YYYY-MM-DD.md`
   - `EnsureToday(root string, now time.Time) (path string, created bool, err error)`
   - `MostRecentBefore(root string, date time.Time) (path string, err error)` — walks `journal/` to find latest file before `date`.
   - `ExtractOpenTodos(content string) []TodoItem` — parses `## todo` section, returns lines matching `- [ ] ...`. Preserve original tags.
2. New journal template (when creating):
   ```markdown
   ---
   date: {{.Date}}
   ---

   # {{.Date}}

   ## todo

   ## notes

   ## achieve
   ```
3. When `EnsureToday` creates a new file, also call carry-over: prepend each open todo under `## todo` with `(carried from YYYY-MM-DD)` appended after the existing tags.
4. Subcommand `brain today`:
   - Calls `EnsureToday`.
   - Prints the absolute path to stdout (Emacs reads this).
   - `--no-carryover` flag to skip.
5. Subcommand `brain carryover` (standalone, idempotent — won't duplicate a todo already present in today's file; match by trimmed text).

## Verify

```sh
brain today                            # creates ~/notes/journal/2026/05/2026-05-15.md, prints path
cat $(brain today)                     # shows template
echo '- [ ] test :foo:' >> $(brain today)
# next day (or fake by editing date):
brain today --date 2026-05-16          # new file with carried todo
grep "carried from" ~/notes/journal/2026/05/2026-05-16.md
brain today                            # second call same day = no duplicate todos
```

Tests:
- `journal_test.go` covers: path generation, todo extraction (incl. nested bullets, mixed checked/unchecked), most-recent finder skipping empty months.

## Out of scope
- Tag parsing beyond `[ ]` / `[x]` detection.
- Any LLM/digest behavior.

## Commit
`feat: brain today with carry-over of open todos`
