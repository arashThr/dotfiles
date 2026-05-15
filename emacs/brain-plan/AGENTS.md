# Brain — Agent Instructions

You are implementing the **brain** project per [00-overview.md](00-overview.md).
Steps live in [steps/](steps/) and are executed **one prompt per session**.

## Ground rules

- **Read [00-overview.md](00-overview.md) first** at the start of every session. It's the source of truth.
- **Read the previous step's output** (committed code) before starting the next.
- **One step per session.** Don't bleed work forward. Each step ends in a verifiable state.
- **Verifiability is mandatory.** Every step must end with a concrete check the user can run (a command, a buffer, a file). The step file lists these.
- **Ask before deviating.** If the design doc is wrong or unclear, ask the user; don't silently improvise.

## Repo conventions

- Project root: `~/code/brain/` (Go module `github.com/<user>/brain`, ask user for the actual path).
- Go: standard layout — `cmd/brain/` for the binary, `internal/` for packages.
- Lint: `gofmt`, `go vet`, `staticcheck`. Run before declaring done.
- Tests: `go test ./...` must pass. Table-driven tests preferred.
- Elisp: lives in `emacs/brain.el` inside the same repo. Lint with `byte-compile`.
- Commits: conventional commits (`feat:`, `fix:`, `chore:`). One commit per step minimum.

## Tech stack — fixed

- Go 1.22+, no frameworks. Stdlib + `net/http` for Ollama client.
- `mattn/go-sqlite3` + `sqlite-vec` extension (load at runtime).
- YAML: `gopkg.in/yaml.v3`.
- CLI: `flag` (stdlib) or `spf13/cobra` if subcommand tree gets complex.
- No LangChain-equivalent. We write the prompts ourselves; they live in `~/notes/.brain/prompts/` and are versioned.

## Prompts

- All LLM prompts are external files in `internal/prompts/templates/*.tmpl`, embedded via `//go:embed`.
- Copied to `~/notes/.brain/prompts/` on first run so the user can edit.
- User-edited prompts override embedded ones.

## What NOT to do

- Don't add a web server in v1.
- Don't add automated secret redaction.
- Don't auto-commit to `main`. Always staging branch.
- Don't introduce a new vector DB. sqlite-vec is the choice.
- Don't add LangChain, llama-index, or any LLM framework.
- Don't write tests for trivial getters; do write tests for parsers, prompt rendering, and the digest decision logic.

## Definition of done (per step)

1. Code compiles (`go build ./...`).
2. Tests pass (`go test ./...`).
3. The step's "verify" section runs cleanly on the user's machine.
4. Committed with a conventional-commit message.
5. Brief note appended to `brain-plan/PROGRESS.md` (create if missing) — what changed, what to know for next step.
