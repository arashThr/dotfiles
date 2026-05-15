# Step 04 — Emacs plugin (`brain.el`)

## Read first
- `brain-plan/00-overview.md`
- `brain-plan/PROGRESS.md`
- `~/Documents/workspace/personal/dotfiles/emacs/AGENTS.md` for the user's emacs conventions.

## Goal
Thin elisp wrapper around the `brain` binary. No business logic.

## Tasks

1. `emacs/brain.el` — proper `;;; brain.el --- ...` header, package conventions, `(provide 'brain)`.
2. Customization group `brain` with:
   - `brain-executable` (default `"brain"`)
   - `brain-notes-directory` (default `"~/notes"`)
3. Commands:
   - `brain-today` — runs `brain today`, opens the printed path in a buffer, jumps to end of `## notes`.
   - `brain-ask` — prompts for a question, runs `brain ask --json "Q"` async, shows answer + citations in `*brain-ask*` buffer (markdown-mode).
   - `brain-digest` — runs `brain digest` async (it can take minutes); on success runs `magit-status` in `~/notes` (only if `magit` is loaded).
   - `brain-doctor` — runs `brain doctor`, shows output in `*brain-doctor*`.
4. Async: use `make-process` with sentinels. Show a modeline indicator while digest is running (e.g. via a small `brain--running` variable + `mode-line-process`).
5. Suggested keymap on prefix `C-c b`:
   - `C-c b t` → `brain-today`
   - `C-c b a` → `brain-ask`
   - `C-c b d` → `brain-digest`
   - `C-c b ?` → `brain-doctor`
6. No `:ensure t` issues — ship as a local file. Document `use-package` snippet for the user's `init.el`:
   ```elisp
   (use-package brain
     :load-path "~/.config/emacs/lisp/"
     :ensure nil
     :bind-keymap ("C-c b" . brain-command-map))
   ```
7. Byte-compile clean: no warnings under `emacs -Q --batch -f batch-byte-compile brain.el`.

## Verify

1. `make install` (from step 01) copies `brain.el` to the configured path.
2. Restart Emacs, `M-x brain-today` opens today's journal.
3. `M-x brain-doctor` shows output.
4. `M-x brain-ask` prompts (will fail gracefully until step 09 is done — verify it shows a clear error, not a stack trace).

## Out of scope
- Any LLM logic in elisp.
- Auto-mode or syntax highlighting for journal files (markdown-mode is fine).

## Commit
`feat: brain.el — emacs frontend`
