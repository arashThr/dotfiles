# Emacs Dotfiles — Agent Instructions

## File Overview

| File | Purpose |
|---|---|
| `init.el` | Full workstation config — primary file to edit |
| `server.el` | Lightweight config for SSH/headless servers |
| `mini-emacs.el` | Truly minimal config (based on [Emfy](https://github.com/susam/emfy)) |

## Conventions

- All packages declared with `use-package`; `:ensure t` is implied globally (`use-package-always-ensure t`)
- Section headers use `;;; ===...=== ;;; SECTION NAME` style dividers
- File header format: `;;; filename.el --- Description`
- Commented-out code is intentional (disabled options, not dead code)

## Package Sources

MELPA + MELPA Stable. VC-installed packages (not on MELPA) use `:vc (:url "..." :branch "...")` inside `use-package`.

## Key Stack Decisions

- **LSP:** Eglot (built-in, Emacs 29+) — do **not** suggest `lsp-mode`
- **Completion UI:** Vertico + Consult + Corfu + Marginalia + Orderless — do **not** suggest Helm or Ivy
- **Git:** Magit + diff-hl
- **Theme:** `doom-themes` (`doom-material`)
- **Navigation:** avy, expand-region, multiple-cursors, iedit
- **AI:** `copilot.el` (GitHub Copilot, manual trigger via `C-c c \`) + `claude-code-ide`

## Indentation Rules

| Language | Style |
|---|---|
| Go | Tabs, width 4 |
| JavaScript / CSS / JSON | Spaces, width 2 |
| Emacs Lisp | Default (2-space, no tabs) |

## External Dependencies

These must be installed separately before the config works fully:

```sh
go install golang.org/x/tools/gopls@latest
npm install -g vscode-json-languageserver typescript-language-server
brew install ripgrep aspell
# Fonts: JetBrains Mono (or IBM Plex Mono), any Nerd Font
```

## Adding New Packages

Use `use-package` with appropriate keywords. Example pattern:

```elisp
(use-package some-pkg
  :hook (some-mode . some-pkg-mode)
  :bind ("C-c s" . some-pkg-command)
  :config
  (setq some-pkg-option t))
```

Place new package blocks under the relevant section header in `init.el`.

## What Goes Where

- **`init.el`**: All GUI-capable, full-featured config changes
- **`server.el`**: Changes needed on headless servers (keep minimal; avoid GUI-only packages)
- **`mini-emacs.el`**: Do not extend — it's intentionally minimal/reference
