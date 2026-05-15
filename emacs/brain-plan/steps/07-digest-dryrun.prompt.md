# Step 07 — Digest pipeline (dry-run only)

## Read first
- `brain-plan/00-overview.md` (Digest pipeline section)
- `brain-plan/PROGRESS.md`

## Goal
Plan the wiki edits for one journal day. **Don't write anything yet** — just print the plan.

## Tasks

1. New package `internal/digest/`:
   ```go
   type Decision string
   const (
       DecisionAppend Decision = "APPEND"
       DecisionCreate Decision = "CREATE"
       DecisionSplit  Decision = "SPLIT"
       DecisionSkip   Decision = "SKIP"
   )

   type Patch struct {
       Decision    Decision
       TargetPath  string         // existing or new wiki path
       NewContent  string         // full new file content
       Reason      string
       SourceItems []parse.Item   // journal items that drove this
   }

   type Plan struct {
       Date    time.Time
       Patches []Patch
   }

   func BuildPlan(ctx context.Context, j *parse.Journal, idx *index.Index, llm *llm.Client) (*Plan, error)
   ```

2. Algorithm:
   1. Group journal items by tag-cluster: items sharing the longest common tag prefix (drop trivial like `:work:` if it dominates everything).
   2. For each group:
      - Embed a synthesized query (e.g. concatenation of item texts).
      - Retrieve top-5 wiki pages (sum chunk scores per file).
      - Call LLM with a **decision prompt** (`templates/digest_decide.tmpl`): given items + candidate pages, return JSON `{decision, target_path, reason}`.
      - If `APPEND` or `CREATE`: call **content prompt** (`templates/digest_content.tmpl`) to produce full new file content. For APPEND, current page contents are included; LLM returns the merged document.
      - If `SPLIT` proposed at this stage: defer to step 10 — for now treat as `APPEND` and log a `would-split` note.
   3. Collect into `Plan`.

3. Prompts (in `internal/prompts/templates/`):
   - `digest_decide.tmpl` — strict JSON output. Include schema in the prompt and use `ChatJSON`.
   - `digest_content.tmpl` — output a fenced markdown block `\`\`\`md ... \`\`\`` so we can robustly extract.
   - Both must require: cite journal source as `sources:` frontmatter entry referencing the journal date and line range.

4. Subcommand: `brain digest --date YYYY-MM-DD --dry-run` (default: yesterday). Prints a human-readable plan:
   ```
   PLAN for 2026-05-15
   ─────────────────────────────────────
   [1] APPEND  wiki/programming/go/garbage-collection.md
       reason: existing page covers GC; new sources expand tri-color section
       items:  3 (lines 7-9)
   [2] CREATE  wiki/work/td-api/webhooks.md
       reason: no existing page on td-api webhooks
       items:  2 (lines 12, 18)
   ─────────────────────────────────────
   ```
   `--json` flag for machine consumption.

5. Concurrency: process groups in parallel (bounded, e.g. 2 at a time — Ollama is single-stream).

## Verify

```sh
# seed a small journal + a couple wiki pages
brain digest --date 2026-05-15 --dry-run
# inspect output: decisions look sensible, no files written
git -C ~/notes status     # clean
```

Tests:
- Mock LLM returning canned decisions.
- Group-by-tag-cluster unit tests.
- Full pipeline integration test gated `BRAIN_E2E=1`.

## Out of scope
- Actually writing files.
- Page splitting.
- Branch / git operations.

## Commit
`feat: digest planner (dry-run only)`
