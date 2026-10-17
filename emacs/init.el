;;; init.el --- Emacs Config: Go + Python + Eglot + Modern Completion -*- lexical-binding: t; -*-

;; ======================================================
;; EXTERNAL DEPENDENCIES (install these first!)
;; ======================================================
;; go install golang.org/x/tools/gopls@latest
;; npm install -g vscode-json-languageserver typescript-language-server
;; brew install ripgrep fd (search tools)
;; Install NERD fonts and JetBrains Mono

;; ======================================================
;; 1. PACKAGE MANAGEMENT & BOOTSTRAP
;; ======================================================

(require 'package)
;; Only MELPA (not melpa-stable): mixing both causes version conflicts
;; and was the source of the random load errors.
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-quickstart t                 ;; precompiled autoloads = faster startup
      package-install-upgrade-built-in t)  ;; allow real `compat' over Emacs' stub
(package-initialize)

;; Bootstrap 'use-package'
(with-eval-after-load 'gnutls
  (add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(require 'bind-key)
(setq use-package-always-ensure t
      use-package-always-defer t)  ;; load packages lazily (big startup win)

(use-package compat :demand t)

;; Set Custom output file to keep this file intact when install packages manually
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil t))

;; ======================================================
;; 2. CORE SETTINGS & SANE DEFAULTS
;; ======================================================

(setq
 inhibit-startup-screen t          ;; No need to see GNU agitprop.
 initial-scratch-message nil       ;; No need to remind me what a scratch buffer is.
 sentence-end-double-space nil     ;; Double-spaces after periods is morally wrong.
 ring-bell-function 'ignore        ;; Never ding at me, ever.
 save-interprogram-paste-before-kill t ;; Save existing clipboard text before replacing it.
 use-dialog-box nil                ;; Prompts should go in the minibuffer, not in a GUI.
 mark-even-if-inactive nil         ;; Fix undo in commands affecting the mark.
 kill-whole-line t                 ;; Let C-k delete the whole line.
 case-fold-search nil              ;; search should be case-sensitive by default
 compilation-read-command nil      ;; no need to prompt for the read command _every_ time
 compilation-scroll-output 'first-error ;; scroll to first error
 use-short-answers t               ;; accept 'y' or 'n' instead of yes/no
 default-directory "~/Documents/workspace/"
 fast-but-imprecise-scrolling t    ;; eke out a little more scrolling performance
 redisplay-skip-fontification-on-input t ;; snappier typing in big buffers
 load-prefer-newer t               ;; prefer newer elisp files
 confirm-kill-processes nil        ;; when I say to quit, I mean quit
 read-process-output-max (* 1024 1024) ;; 1MB reads: much faster LSP
 native-comp-async-report-warnings-errors 'silent
 truncate-string-ellipsis "…")     ;; unicode ellipses are better

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)
(column-number-mode)

;; Better defaults
(delete-selection-mode 1)          ; Typing replaces selection
(global-auto-revert-mode 1)        ; Auto-reload changed files

;; File Management
(setq create-lockfiles nil
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2)

;; Auto-save on idle/switch
(use-package super-save
  :demand t
  :diminish
  :config
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 3
        super-save-remote-files nil
        super-save-exclude '(".gpg"))
  (add-to-list 'super-save-triggers 'consult-buffer)
  (add-to-list 'super-save-triggers 'magit-status)
  (super-save-mode +1))

(use-package persistent-scratch
  :hook (after-init . persistent-scratch-setup-default))

;; ======================================================
;; 3. UI & THEMING
;; ======================================================

;; tango is built in, so no theme package is needed.
;; (For Spacegray etc: (use-package doom-themes :demand t) and load-theme it.)
(load-theme 'tango t)

;; Clean UI
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 140)
  (set-frame-font "-*-Menlo-regular-normal-normal-*-14-*-*-*-m-0-iso10646-1" nil t)
  (setq-default line-spacing 8)
  (add-to-list 'default-frame-alist '(fullscreen . maximized)))

;; Mouse support in terminal
(xterm-mouse-mode 1)

;; Get PATH from shell (macOS fix). Non-interactive shell = faster.
(use-package exec-path-from-shell
  :if (display-graphic-p)
  :demand t
  :config
  (setq exec-path-from-shell-arguments '("-l")
        exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOBIN"))
  (exec-path-from-shell-initialize))

;; Smooth scrolling
(pixel-scroll-precision-mode 1)

(defun scroll-half-page-down ()
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

  (define-key pixel-scroll-precision-mode-map (kbd "<prior>") 'scroll-half-page-down)
  (define-key pixel-scroll-precision-mode-map (kbd "<next>") 'scroll-half-page-up)

;; ======================================================
;; 4. PROJECT TREE (Treemacs)
;; ======================================================

(use-package nerd-icons)

(use-package treemacs
  :bind
  (("C-c t t" . treemacs)
   ("C-c t f" . treemacs-find-file)) ;; Manually sync tree to current file
  ;; :hook
  ;; (emacs-startup . treemacs)
  :config
  (setq treemacs-position 'left
        treemacs-is-never-other-window t
        treemacs-width 35)

  ;; Follow mode is explicitly disabled here.
  ;; When enabled, jumping to Go stdlib/dependencies forces Treemacs out of your project.
  ;; Use 'C-c t f' to manually focus the tree on your current file instead.
  ;; (treemacs-follow-mode nil)
  ;; (treemacs-project-follow-mode nil)

  (treemacs-filewatch-mode t) ;; Watch for external file changes
  (when (and (executable-find "git") (executable-find "python3"))
    (treemacs-git-mode 'deferred)))

(use-package treemacs-nerd-icons
  :after treemacs
  :demand t
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; dired
(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode)   ;; toggle back with (
  :bind (:map dired-mode-map ("C-c C-r" . dired-do-rename))
  :config
  (setq dired-dwim-target t              ;; split window = default copy/move target
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        delete-by-moving-to-trash t      ;; D and x go to trash, not oblivion
        dired-listing-switches "-alh --group-directories-first"))
;; macOS `ls' lacks --group-directories-first; use GNU ls if available.
(when (and (eq system-type 'darwin) (executable-find "gls"))
  (setq insert-directory-program "gls"))

;; ======================================================
;; 5. NAVIGATION, WINDOWS & EDITING
;; ======================================================

;; Key concepts:
;; - Point: cursor position
;; - Mark: selection start (C-SPC to set)
;; - Region: text between mark and point
;; - Kill ring: clipboard history

;; Basic movement
;; C-f/b/n/p: forward/back/next/previous char/line
;; M-f/b: forward/back word
;; C-a/e: beginning/end of line
;; M-a/e: beginning/end of sentence
;; M-m: Back to indentation (first char of the line)
;; M-</>: beginning/end of buffer
;; M-/: Auto-complete text

;; Selection & killing
;; C-SPC: set mark (start selection)
;; C-w: kill (cut) region
;; M-w: copy region
;; C-y: yank (paste)
;; M-y: cycle through kill ring
;; C-x h: select all

(setq set-mark-command-repeat-pop t) ; Keep popping marks with C-u C-SPC

;; --- WINDOW MANAGEMENT ---
;; Window concepts:
;; - Frame: OS window (entire Emacs window)
;; - Window: pane within frame (split)
;; - Buffer: file content (can be shown in multiple windows)

;; Quick window actions
(global-set-key (kbd "M-o") #'other-window)          ; Navigate windows

;; Smart close: close window or kill buffer if last window
(defun my/delete-window-or-kill-buffer ()
  "Delete window; if only one window, kill buffer instead."
  (interactive)
  (if (one-window-p)
      (kill-current-buffer)
    (delete-window)))
(global-set-key (kbd "M-0") #'my/delete-window-or-kill-buffer)

;; Undo/redo window changes
(winner-mode 1)
(global-set-key (kbd "C-c <left>") #'winner-undo)
(global-set-key (kbd "C-c <right>") #'winner-redo)

;; --- BUFFER MANAGEMENT ---
;; Ctrl-Tab: switch to last buffer (like Alt-Tab)
(defun my/switch-to-previous-buffer ()
  "Switch to previously used buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))
(global-set-key (kbd "C-<tab>") #'my/switch-to-previous-buffer)
(global-set-key (kbd "C-S-<tab>") #'previous-buffer)
(global-set-key (kbd "<C-iso-lefttab>") #'previous-buffer)

;; --- EDITING TOOLS ---
;; Undo/Redo with visualization
;; C-/: undo | C-?: redo | C-x u: visualize undo tree
(use-package undo-tree
  :demand t
  :config
  (setq undo-tree-auto-save-history nil)
  (global-undo-tree-mode))

;; Fast jumping with avy
(use-package avy
  :bind (("M-j" . avy-goto-char-in-line)
         ("M-J" . avy-goto-char-timer)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g c" . avy-goto-char)))

;; Expand selection incrementally
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; Multiple cursors (VS Code style)
(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-c C-S-c" . mc/edit-lines)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;; Edit all occurrences of symbol
(use-package iedit
  :bind ("C-c ;" . iedit-mode))

;; Show function breadcrumb in header
(use-package breadcrumb
  :demand t
  :config (breadcrumb-mode 1))

;; ======================================================
;; 6. COMPLETION (Vertico, Consult, Corfu)
;; ======================================================

;; Vertico: vertical completion UI
(use-package vertico
  :demand t
  :config
  (setq vertico-cycle t)
  (vertico-mode))

;; Marginalia: show annotations
(use-package marginalia
  :demand t
  :config (marginalia-mode))

;; Orderless: flexible matching (space-separated terms)
(use-package orderless
  :demand t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides
        '((file (styles basic partial-completion))
          (eglot (styles orderless))
          (eglot-capf (styles orderless)))))

;; Consult: enhanced search/navigation
(use-package consult
  :bind (;; Buffer/file switching
         ("C-x b" . consult-buffer)
         ("C-<return>" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x p b" . consult-project-buffer)

         ;; Search
         ("M-s l" . consult-line)          ; Search current buffer
         ("M-s L" . consult-line-multi)    ; Search all buffers
         ("M-s p" . consult-fd)            ; Find file by name
         ("M-s g" . consult-grep)          ; Grep in directory
         ("M-s r" . consult-ripgrep)       ; Ripgrep (faster)

         ;; Navigation
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)         ; Jump to function/class
         ("M-g m" . consult-mark)          ; Jump to mark
         ("M-g f" . consult-flymake)       ; Jump to diagnostic

         ;; Yank history & Registers
         ("M-y" . consult-yank-pop)
         ("<f6>" . consult-register-load)
         ("C-<f6>" . consult-register-store)
         ("M-<f6>" . consult-register)

         :map isearch-mode-map
         ("M-s l" . consult-line))
  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (setq consult-narrow-key "<"
        consult-fd-args '("fd" "--hidden" "--exclude" ".git" "--color=never" "-i" "-t" "f"))
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any)))

;; Corfu: popup completion (like VS Code)
(use-package corfu
  :demand t
  :bind (:map corfu-map
              ;; RET should ALWAYS insert a newline, never complete.
              ("RET" . nil)
              ("<return>" . nil)
              ;; TAB is the only accept key.
              ("TAB" . corfu-insert)
              ("<tab>" . corfu-insert)
              ;; Don't steal the arrow keys either — use C-n/C-p to pick.
              ("<up>" . nil)
              ("<down>" . nil))
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 3
        corfu-cycle t
        corfu-preselect 'prompt      ;; nothing is preselected → TAB is safe too
        corfu-preview-current nil    ;; no inline ghost text in the buffer
        corfu-quit-no-match 'separator
        corfu-quit-at-boundary 'separator
        corfu-on-exact-match nil     ;; never auto-insert an exact match
        corfu-popupinfo-delay '(0.5 . 0.2))
  (global-corfu-mode)
  (corfu-popupinfo-mode 1))          ;; docs popup next to candidates

;; Disable auto-popup in case you find it intrusive
;(add-hook 'text-mode-hook (lambda () (setq-local corfu-auto nil)))
;(add-hook 'org-mode-hook  (lambda () (setq-local corfu-auto nil)))

;; Cape: completion sources
(use-package cape
  :demand t
  :init
  ;; Depth 90 = near the end of the list, so eglot/elisp capfs win first.
  (add-hook 'completion-at-point-functions #'cape-file 10)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

;; Pretty icons in completion
(use-package kind-icon
  :if (display-graphic-p)
  :after corfu
  :demand t
  :config (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Show keybinding help
(use-package which-key
  :demand t
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

;; Embark: context actions (like right-click menu)
(use-package embark
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-e" . embark-export))
  :config
  (setq embark-indicators
        '(embark-highlight-indicator
          embark-isearch-highlight-indicator)))

(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Edit grep results directly
(use-package wgrep)

;; Persistent history
(use-package savehist
  :ensure nil
  :demand t
  :config
  (setq history-length 200
        savehist-additional-variables '(search-ring regexp-search-ring kill-ring))
  (savehist-mode))

;; ======================================================
;; 7. LSP, LANGUAGES, & TREESITTER
;; ======================================================

;; For new languages, you need to manually install the Tree-sitter grammar
;; M-x treesit-install-language-grammar RET typescript RET
;; (or M-x my/treesit-install-all to install every missing one)
(use-package go-mode :mode "\\.go\\'")
(use-package json-mode :mode "\\.json\\'")
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.gohtml\\'" . html-mode))

;; Tree-sitter Setup (Emacs 29+)
(when (treesit-available-p)
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (cmake "https://github.com/uyha/tree-sitter-cmake")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (make "https://github.com/alemuller/tree-sitter-make")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml"))))

(defun my/treesit-install-all ()
  "Install every missing grammar in `treesit-language-source-alist'."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

;; Formatting Hook (organize-imports wrapped: some servers lack it)
(defun my-eglot-format-and-organize ()
  "Format buffer on save."
  (when (eglot-managed-p)
    (eglot-format-buffer)
    (ignore-errors (eglot-code-action-organize-imports (point-min) (point-max)))))

(use-package eglot
  :ensure nil
  :hook ((go-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (yaml-ts-mode . eglot-ensure)
         (html-mode . eglot-ensure)
         (css-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (c-or-c++-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
        eglot-report-progress t
        eglot-extend-to-xref t
        eglot-autoreconnect t
        eglot-connect-timeout 60
        eglot-sync-connect nil
        eglot-events-buffer-config '(:size 0 :format full)) ;; no event log = faster
  ;; Go: enable test tags
  (setq-default eglot-workspace-configuration
                '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  ;; Python: basedpyright
  (add-to-list 'eglot-server-programs
               '((python-ts-mode python-mode) . ("basedpyright-langserver" "--stdio"))))

(add-hook 'go-mode-hook
          (lambda () (add-hook 'before-save-hook #'my-eglot-format-and-organize nil t)))

;; Eglot keybindings
;; M-.: go to definition | M-,: go back
(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "M-'") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l i") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") #'eglot-find-typeDefinition)
  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l d") #'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-action-organize-imports))

;; Go: tabs, width 4
(add-hook 'go-mode-hook (lambda () (setq tab-width 4 indent-tabs-mode t)))
;; JSON: spaces, width 2
(add-hook 'json-mode-hook (lambda () (setq tab-width 2 indent-tabs-mode nil js-indent-level 2)))

;; --- PYTHON ---
;; Format on save with ruff (isort + format)
(use-package apheleia
  :hook (python-ts-mode . apheleia-mode)
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

;; Per-project env via .envrc (uses the project's .venv for LSP/REPL/compile)
(use-package envrc
  :hook (after-init . envrc-global-mode))

(defun my/python-run-file ()
  "Run current file with `uv run' (interactive, so input() works)."
  (interactive)
  (save-buffer)
  (compile (concat "uv run " (shell-quote-argument buffer-file-name)) t))

(defun my/python-test ()
  "Run pytest from the project root."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (compile "uv run pytest -q" t)))

(defun my/python-scratch ()
  "Open a new throwaway script in ~/Documents/workspace/scratch/."
  (interactive)
  (let ((dir (expand-file-name "~/Documents/workspace/scratch/")))
    (make-directory dir t)
    (find-file (expand-file-name (format-time-string "%Y%m%d-%H%M%S.py") dir))
    (when (= (buffer-size) 0)
      (insert "# /// script\n# requires-python = \">=3.12\"\n# dependencies = []\n# ///\n\n"))))
(global-set-key (kbd "C-c n p") #'my/python-scratch)

(with-eval-after-load 'python
  (define-key python-ts-mode-map (kbd "C-c C-k") #'my/python-run-file)
  (define-key python-ts-mode-map (kbd "C-c C-t") #'my/python-test)
  (setq python-shell-interpreter "python3"
        python-indent-guess-indent-offset-verbose nil))

;; Diagnostics & Spell Check
(defun my/flymake-toggle-diagnostics ()
  (interactive)
  (let ((diag-buffer (get-buffer (format "*Flymake diagnostics for `%s'*" (buffer-name)))))
    (if (and diag-buffer (get-buffer-window diag-buffer))
        (delete-windows-on diag-buffer)
      (flymake-show-buffer-diagnostics))))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(global-set-key (kbd "<f8>") #'my/flymake-toggle-diagnostics)
(global-set-key (kbd "<S-f8>") #'flymake-show-project-diagnostics)

;; Spell check: jinx (fast, async) if enchant is installed, else flyspell.
(if (executable-find "enchant-2")
    (use-package jinx
      :hook ((text-mode prog-mode conf-mode) . jinx-mode)
      :bind (("M-$" . jinx-correct)
             ("C-M-$" . jinx-languages)))
  (add-hook 'prog-mode-hook #'flyspell-prog-mode)  ; Comments/strings only
  (add-hook 'text-mode-hook #'flyspell-mode))

;; ======================================================
;; 8. GIT, ORG, COPILOT & MISC TOOLS
;; ======================================================

;; Built-in project.el
;; C-x p f: find file in project
;; C-x p g: grep in project
;; C-x p p: switch project
(with-eval-after-load 'project
  ;; C-x p p <project> RET gives Dired, C-x p p <project> f still goes to find-file.
  (setq project-switch-commands #'project-dired
        project-switch-use-entire-map t
        ;; Treat any dir with these markers as a project root, not just VC roots.
        project-vc-extra-root-markers '("go.mod" "package.json" "pyproject.toml")
        ;; C-x p k kills project buffers without asking about each one.
        project-kill-buffers-display-buffer-list t))

;; Git (Magit)
(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-c g b" . magit-blame-addition)
         ("C-c g l" . magit-log-buffer-file))
  :hook (magit-process-mode . goto-address-mode) ;; Clickable links in magit
  :config
  (setq magit-bury-buffer-function #'magit-restore-window-configuration
        magit-diff-refine-hunk t            ;; word-level diff highlighting
        magit-save-repository-buffers 'dontask
        magit-ediff-dwim-show-on-hunks t))

;; Show git changes in fringe
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (conf-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (diff-hl-flydiff-mode 1))   ;; update without saving

;; Ediff settings: side by side, single frame, restore layout after quitting
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)
(add-hook 'ediff-after-quit-hook-internal #'winner-undo)

;; Text comparison
(defun my/diff-buffers (a b)
  "Ediff two buffers."
  (interactive (list (read-buffer "Buffer A: " (current-buffer))
                     (read-buffer "Buffer B: " (other-buffer))))
  (ediff-buffers a b))
(global-set-key (kbd "C-c d b") #'my/diff-buffers)
(global-set-key (kbd "C-c d f") #'ediff-files)
(global-set-key (kbd "C-c d r") #'ediff-regions-wordwise)

;; Org Mode
(setq org-agenda-files '("~/todo.org")
      org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time          ;; Timestamp on TODO completion
      org-log-into-drawer t)      ;; keep CLOSED/state-change notes tidy in the LOGBOOK drawer

;; Interruptions template
(setq org-capture-templates
      '(("b" "Backlog item" entry
         (file+headline "~/todo.org" "BACKLOG")
         "* TODO %?\n%U")
        ("i" "Interrupt task" entry
         (file+headline "~/todo.org" "INTERRUPTIONS")
         "* TODO %?\n%U")
        ("l" "Learning" entry
         (file+headline "~/todo.org" "LEARNING")
         "* %?\n%U")))

;; Persist the clock across Emacs restarts (survives quitting mid-task)
(setq org-clock-persist 'history)
(with-eval-after-load 'org
  (org-clock-persistence-insinuate))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; todo-mode is built in; F12 autoloads it (no `require' at startup)
(global-set-key (kbd "<f12>") #'todo-show)

;; Copilot
;;(use-package copilot
;;  :vc (:url "https://github.com/copilot-emacs/copilot.el" :branch "main")
;;  :ensure t
;;  :hook (prog-mode . copilot-mode)
;;  :bind (:map copilot-mode-map
;;              ("C-c c \\" . copilot-complete)
;;              ("C-c c n" . copilot-next-completion)
;;              ("C-c c p" . copilot-previous-completion)
;;              ("C-g" . copilot-clear-overlay)
;;              ("<tab>" . copilot-accept-completion)
;;              ("TAB" . copilot-accept-completion))
;;  :config
;;  (setq copilot-idle-delay nil)) ; Manual trigger only

;; Markdown
(use-package markdown-mode
  :mode ("\\.md\\'" . gfm-mode)
  :hook (markdown-mode . (lambda () (setq indent-tabs-mode nil tab-width 2)))
  :bind (:map markdown-mode-map
              ("M-<up>"   . markdown-move-up)
              ("M-<down>" . markdown-move-down))
  :config
  (setq markdown-hide-markup t
        markdown-header-scaling t                ;; headers with varying heights, like org
        markdown-fontify-code-blocks-natively t)) ;; syntax highlighting inside ```lang blocks

;; Align tables nicely as you type
(use-package valign
  :hook (markdown-mode . valign-mode))

;; Better Ibuffer categories
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer)
  :hook (ibuffer-mode . (lambda () (ibuffer-switch-to-saved-filter-groups "default")))
  :config
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("TRAMP" (filename . "^/\\(ssh\\|sudo\\):"))
           ("Org" (mode . org-mode))
           ("Programming" (derived-mode . prog-mode))
           ("Magit" (name . "^magit"))
           ("Dired" (mode . dired-mode))
           ("Emacs" (or (name . "^\\*scratch\\*$") (name . "^\\*Messages\\*$")))))))

;; Utilities
;; verb: bind its map only once both org and verb are loaded (fixes init error)
(use-package verb
  :after org
  :demand t
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;; Shell in F1: vterm if installed, otherwise built-in eshell (no void-function error)
(use-package vterm
  :if (and module-file-suffix (executable-find "cmake"))
  :commands vterm)
(global-set-key (kbd "<f1>")
                (lambda () (interactive)
                  (if (fboundp 'vterm) (vterm) (eshell))))

(setq shell-command-prompt-show-cwd t)
(setq world-clock-list '(("Europe/Stockholm" "Stockholm")))

;; Mouse definition jump
(when (display-graphic-p)
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions))
