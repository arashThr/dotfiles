;;; init.el --- Emacs Config: Go + Python + Eglot + Modern Completion -*- lexical-binding: t; -*-

;; ======================================================
;; EXTERNAL DEPENDENCIES
;; ======================================================
;; CLI tools (rg, fd, gopls, ruff, uv, ...) are declared per package with
;; `:ensure-system-package' and installed on first use. Prerequisites:
;; brew (macOS) or dnf (Fedora), plus go and npm for the language servers.
;; Fonts: brew install --cask font-jetbrains-mono font-symbols-only-nerd-font

;; ======================================================
;; LOAD MODULES (emacs/lisp/init-*.el)
;; ======================================================

;; init.el is symlinked into ~/.config/emacs, so resolve the real path
;; to find the lisp/ directory next to it in the dotfiles repo.
(add-to-list 'load-path
             (expand-file-name "lisp" (file-name-directory (file-truename load-file-name))))

(require 'init-packages)
(require 'init-core)
(require 'init-ui)
(require 'init-filetree)
(require 'init-editing)
(require 'init-completion)
(require 'init-lang)
(require 'init-python)
(require 'init-git)
(require 'init-tools)
(require 'init-ai)

;;; init.el ends here
