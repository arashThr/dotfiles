# Step 01 — Scaffold

## Read first
- `brain-plan/00-overview.md`
- `brain-plan/AGENTS.md`

## Goal
Create the Go project, directory layout, and a working `brain doctor` command.

## Tasks

1. Ask user for the repo path (suggest `~/code/brain`) and Go module name (suggest `github.com/<their-gh>/brain`).
2. Create the repo with this layout:
   ```
   brain/
     go.mod
     cmd/brain/main.go
     internal/
       config/
       cli/
     emacs/
       brain.el           # placeholder, just (provide 'brain) for now
     prompts/templates/   # empty, populated in later steps
     .gitignore           # ignore *.db, .brain/*.lock
     README.md
     Makefile             # build, test, lint, install
   ```
3. `cmd/brain/main.go`: dispatches to subcommands. Implement only `doctor` and `version`.
4. `brain doctor` checks:
   - Go binary version (informational).
   - Ollama reachable at `http://127.0.0.1:11434/api/tags` (HTTP GET).
   - Required models present: `gemma4:26b`, `nomic-embed-text` (warn if missing, don't fail).
   - `~/notes/` exists and is a git repo (offer to `git init` if missing — prompt).
   - `~/notes/.brain/config.toml` exists (create with defaults if missing).
5. Default `config.toml`:
   ```toml
   [models]
   curator = "gemma4:26b"
   embedder = "nomic-embed-text"

   [paths]
   notes_root = "~/notes"

   [ollama]
   host = "http://127.0.0.1:11434"
   timeout_seconds = 600

   [digest]
   auto_split_enabled = true
   split_min_tokens = 1500
   split_cooldown_days = 14
   ```
6. `Makefile` targets: `build`, `test`, `lint` (gofmt + vet), `install` (copies binary to `$GOBIN` and `brain.el` to `~/.config/emacs/lisp/` — ask user to confirm path).

## Verify

```sh
make build && make test
./brain version           # prints something
./brain doctor            # exits 0; reports ollama + models + notes dir
ls ~/notes/.brain/        # config.toml exists
```

## Out of scope
- Any LLM call beyond the GET /api/tags reachability check.
- Any actual journal/wiki logic.

## Commit
`feat: scaffold brain CLI with doctor command`
