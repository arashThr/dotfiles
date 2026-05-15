# Step 11 — Polish

## Read first
- `brain-plan/00-overview.md`
- `brain-plan/PROGRESS.md`

## Goal
Round off rough edges. After this step the v1 system is usable daily.

## Tasks

1. `brain doctor` extended:
   - Verifies `sqlite-vec` extension loads.
   - Verifies `~/notes/.brain/index.db` exists; suggests `brain index --rebuild` if not.
   - Reports last successful digest date.
   - Reports tag-similarity warnings (e.g. `td-api` vs `tdapi`) — Levenshtein ≤ 2, frequency ≥ 3.
2. `brain --help` and per-subcommand `--help` are complete and accurate.
3. Error messages: every failure mode prints actionable next step.
4. `brain.el`:
   - `brain-show-last-digest` opens the most recent staging branch in magit.
   - Modeline shows `[brain⏳]` while async ops run.
5. README.md at repo root: install, configure, daily workflow, troubleshooting.
6. CI-light: a `Makefile` `check` target that runs `gofmt -l .` (fail on any output), `go vet`, `staticcheck`, `go test ./...`.
7. Tag the release: `v0.1.0`.

## Verify

```sh
make check
brain doctor                         # all green or actionable warnings
brain --help                         # lists all subcommands
brain digest --help                  # full options
M-x brain-show-last-digest           # opens magit diff of last branch
```

## Out of scope
- Web view, promo reports — explicit v2 candidates.

## Commit
`chore: v0.1.0 polish` then `git tag v0.1.0`.
