# Step 08 — Digest apply (staging branch)

## Read first
- `brain-plan/00-overview.md` (Digest pipeline)
- `brain-plan/PROGRESS.md`

## Goal
Materialize the plan from step 07 onto a `brain/digest-YYYY-MM-DD` git branch in `~/notes`.

## Tasks

1. New package `internal/gitops/` (small wrapper using `os/exec` around `git`):
   - `EnsureClean(repo string) error` — fail if working tree dirty.
   - `Checkout(repo, branch string, createFromMain bool) error`
   - `CommitAll(repo, msg string) error`
   - `CurrentBranch(repo string) (string, error)`
   - `ReturnTo(repo, branch string) error`
2. Digest apply flow (when `--dry-run` not passed):
   1. Acquire `~/notes/.brain/digest.lock` (file lock; fail fast if held).
   2. `EnsureClean`. If dirty, refuse with a clear message ("commit or stash first").
   3. Remember current branch.
   4. Checkout new branch `brain/digest-YYYY-MM-DD-HHMMSS` from `main` (or `master`, detect).
   5. Apply patches: write each `Patch.NewContent` to `Patch.TargetPath`. Create directories as needed.
   6. `git add -A && git commit -m "digest: <date> (<n> patches)"` with a body listing each decision.
   7. Re-index changed files: call `index.IndexFile` for each.
   8. Switch back to original branch.
   9. Release lock.
   10. Print:
       ```
       Digest applied to branch brain/digest-2026-05-15-080312
       Review:  git -C ~/notes diff main..brain/digest-2026-05-15-080312
       Or:      M-x magit-status (then 'l a' to log all branches)
       ```
3. Update `brain.el`'s `brain-digest`: on success, in `~/notes` run `magit-diff-range main..<branch-name>`. Need to capture branch from CLI output (last line `BRANCH=...`).
4. Failure modes that must be handled cleanly:
   - Lock held → exit 11.
   - Dirty tree → exit 12.
   - LLM error mid-flight → restore original branch, exit 13.
   - Git command fails → restore, exit 14.

## Verify

```sh
brain digest --date 2026-05-15
git -C ~/notes branch         # shows brain/digest-...
git -C ~/notes log brain/digest-2026-05-15-* --oneline
git -C ~/notes diff main..brain/digest-2026-05-15-*

# in emacs:
M-x brain-digest              # async, then opens magit diff
```

Tests:
- `gitops` table-tests against a temp repo created in test setup.
- Failure-path test: simulated LLM error leaves repo on original branch with no new commits.

## Out of scope
- Auto-merging (always manual).
- Page splitting.

## Commit
`feat: digest apply on staging branch with rollback`
