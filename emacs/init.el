;;; init.el --- Emacs Config: Go + Eglot + Modern Completion

;; ======================================================
;; EXTERNAL DEPENDENCIES (install these first!)
;; ======================================================
;; go install golang.org/x/tools/gopls@latest
;; npm install -g vscode-json-languageserver typescript-language-server
;; brew install ripgrep (search tool)
;; Install NERD fonts and JetBrains Mono
;; sudo apt install aspell (spell checking)

;; ======================================================
;; 1. PACKAGE MANAGEMENT & BOOTSTRAP
;; ======================================================

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Bootstrap 'use-package'
(eval-after-load 'gnutls
  '(add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)

;; Set Custom output file to keep this file intact when install packages manually
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

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
 load-prefer-newer t               ;; prefer newer elisp files
 confirm-kill-processes nil        ;; when I say to quit, I mean quit
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
  :diminish
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 3
        super-save-remote-files nil
        super-save-exclude '(".gpg"))
  (add-to-list 'super-save-triggers 'consult-buffer)
  (add-to-list 'super-save-triggers 'magit-status))

(use-package persistent-scratch
  :config
  (persistent-scratch-setup-default))

;; ======================================================
;; 3. UI & THEMING
;; ======================================================

;; Spacegray theme comes from this package
(use-package doom-themes
  :config
  (load-theme 'tango t))

;; Clean UI
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 140)
  (set-frame-font "-*-Menlo-regular-normal-normal-*-14-*-*-*-m-0-iso10646-1")
  (setq-default line-spacing 8)
  (add-to-list 'default-frame-alist '(fullscreen . maximized)))

;; Mouse support in terminal
(xterm-mouse-mode 1)

;; Get PATH from shell (macOS fix)
(use-package exec-path-from-shell
  :if (display-graphic-p)
  :config
  (exec-path-from-shell-initialize))

;; Smooth scrolling
(pixel-scroll-precision-mode 1)

(defun scroll-half-page-down ()
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

(with-eval-after-load 'pixel-scroll
  (define-key pixel-scroll-precision-mode-map (kbd "<prior>") 'scroll-half-page-down)
  (define-key pixel-scroll-precision-mode-map (kbd "<next>") 'scroll-half-page-up))

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
  (pcase (cons (not (null (executable-find "git")))
               (not (null (executable-find "python3"))))
    (`(t . t)
     (treemacs-git-mode 'deferred))))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; dired
(use-package dired
  :ensure nil
  :bind (:map dired-mode-map ("C-c C-r" . dired-do-rename))
  :config
  (setq dired-dwim-target t              ;; split window = default copy/move target
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        delete-by-moving-to-trash t      ;; D and x go to trash, not oblivion
        dired-listing-switches "-alh --group-directories-first"))

(add-hook 'dired-mode-hook #'dired-hide-details-mode)  ;; toggle back with (

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
  :init (global-undo-tree-mode)
  :config (setq undo-tree-auto-save-history nil))

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
  :config (breadcrumb-mode 1))

;; ======================================================
;; 6. COMPLETION (Vertico, Consult, Corfu)
;; ======================================================

;; Vertico: vertical completion UI
(use-package vertico
  :init
  (setq vertico-cycle t)
  (vertico-mode))

;; Marginalia: show annotations
(use-package marginalia
  :config (marginalia-mode))

;; Orderless: flexible matching (space-separated terms)
(use-package orderless
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
         
         ;; Yank history & Registers
         ("M-y" . consult-yank-pop)
         ("<f6>" . consult-register-load)
         ("C-<f6>" . consult-register-store)
         ("M-<f6>" . consult-register)
         
         :map isearch-mode-map
         ("M-s l" . consult-line))
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref
        consult-narrow-key "<"
        consult-fd-args '("fd" "--hidden" "--exclude" ".git" "--color=never" "-i" "-t" "f"))
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any)))

(global-set-key (kbd "C-<return>") #'consult-buffer)

;; Corfu: popup completion (like VS Code)
(use-package corfu
  :init (global-corfu-mode)
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
        corfu-on-exact-match nil))   ;; never auto-insert an exact match

;; Disable auto-popup in case you find it intrusive
;(add-hook 'text-mode-hook (lambda () (setq-local corfu-auto nil)))
;(add-hook 'org-mode-hook  (lambda () (setq-local corfu-auto nil)))

;; Cape: completion sources
(use-package cape
  :init
  ;; Depth 90 = near the end of the list, so eglot/elisp capfs win first.
  (add-hook 'completion-at-point-functions #'cape-file 10)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))
;; Only enable dabbrev in text mode
;(add-hook 'text-mode-hook
;          (lambda () (add-hook 'completion-at-point-functions #'cape-dabbrev 90 t)))

;; Pretty icons in completion
(use-package kind-icon
  :if (display-graphic-p)
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Show keybinding help
(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.5))

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
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Edit grep results directly
(use-package wgrep)

;; Persistent history
(use-package savehist
  :ensure nil
  :init (savehist-mode)
  :config
  (setq history-length 200
        savehist-additional-variables '(search-ring regexp-search-ring kill-ring)))

;; ======================================================
;; 7. LSP, LANGUAGES, & TREESITTER
;; ======================================================

;; For new languages, you need to manually install the Tree-sitter grammar
;; M-x treesit-install-language-grammar RET typescript RET
(use-package go-mode :mode "\\.go\\'")
(use-package json-mode :mode "\\.json\\'")
(use-package typescript-ts-mode
  :ensure nil
  :mode ("\\.ts\\'" "\\.tsx\\'"))

;; Formatting Hook
(defun my-eglot-format-and-organize ()
  "Format buffer on save."
  (when (eglot-managed-p)
    (eglot-format-buffer)
    (eglot-code-action-organize-imports)))

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
	 (python-mode . eglot-ensure)
	 (c++-mode . eglot-ensure)
	 (c-or-c++-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
	eglot-report-progress t
	eglot-extend-to-xref t
	eglot-autoreconnect t
	eglot-connect-timeout 60
        eglot-sync-connect nil)
  
  ;; Go: enable test tags
  (setq eglot-workspace-configuration '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  (add-hook 'go-mode-hook
            (lambda () (add-hook 'before-save-hook 'my-eglot-format-and-organize nil t))))

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

;; Diagnostics & Spell Check
(defun my/flymake-toggle-diagnostics ()
  (interactive)
  (let ((diag-buffer (get-buffer "*Flymake diagnostics*")))
    (if (and diag-buffer (get-buffer-window diag-buffer))
        (delete-windows-on diag-buffer)
      (flymake-show-buffer-diagnostics))))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(global-set-key (kbd "<f8>") #'my/flymake-toggle-diagnostics)
(global-set-key (kbd "<S-f8>") #'flymake-show-project-diagnostics)

(add-hook 'prog-mode-hook #'flyspell-prog-mode)  ; Comments/strings only
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'org-mode-hook #'flyspell-mode)

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

(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.gohtml\\'" . html-mode))

;; Indentation Hooks
;; Go: tabs, width 4
(add-hook 'go-mode-hook (lambda () (setq tab-width 4 indent-tabs-mode t)))
;; JSON: spaces, width 2
(add-hook 'json-mode-hook (lambda () (setq tab-width 2 indent-tabs-mode nil js-indent-level 2)))

;; ======================================================
;; 8. GIT, ORG, COPILOT & MISC TOOLS
;; ======================================================

;; Built-in project.el
;; C-x p f: find file in project
;; C-x p g: grep in project
;; C-x p p: switch project
(require 'project)

;; Open dired for the project
;; C-x p p <project> RET gives Dired, while C-x p p <project> f still goes to find-file.
(setq project-switch-commands #'project-dired
      project-switch-use-entire-map t)

;; Treat any dir with these markers as a project root, not just VC roots.
(setq project-vc-extra-root-markers '("go.mod" "package.json"))

;; C-x p k kills project buffers without asking about each one.
(setq project-kill-buffers-display-buffer-list t)

;; Git (Magit)
(use-package magit
  :bind ("C-x g" . magit-status))
(add-hook 'magit-process-mode-hook 'goto-address-mode) ;; Clickable links in magit

;; Show git changes in fringe
(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

;; Ediff settings
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain
      magit-ediff-dwim-show-on-hunks t)

;; Org Mode
(setq org-agenda-files '("~/todo.org")
      org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time          ;; Timestamp on TODO completion
      org-log-into-drawer t)      ;; keep CLOSED/state-change notes tidy in the LOGBOOK drawer

;; Interruptions template
(setq org-capture-templates
      '(
	("b" "Backlog item" entry
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
(org-clock-persistence-insinuate)

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)  ;; handy once you start adding tasks quickly

(require 'todo-mode)
(bind-key "<f12>" 'todo-show)

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
;;

;; Markdown
(use-package markdown-mode
  :hook (markdown-mode . (lambda ()
                           (setq indent-tabs-mode nil tab-width 2)))
  :mode ("\\.md\\'" . gfm-mode)
  :config
  (setq markdown-hide-markup t)
  ;; Make headers look nicer with varying heights, like org-mode
  (setq markdown-header-scaling t)
  :bind (:map markdown-mode-map
              ("M-<up>"   . markdown-move-up)
              ("M-<down>" . markdown-move-down)))

;; Fontify code blocks using the actual language's mode (syntax highlighting inside ```lang blocks)
(setq markdown-fontify-code-blocks-natively t)

;; Align tables nicely as you type (needs the `valign` package for proportional fonts)
(use-package valign
  :ensure t
  :hook (markdown-mode . valign-mode))

;; Better Ibuffer categories
(use-package ibuffer
  :ensure nil
  :bind ("C-x C-b" . ibuffer)
  :config
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("SSH" (filename . "/ssh:"))
           ("TRAMP" (filename . "/sudo:\\|/ssh:"))
           ("Org" (mode . org-mode))
           ("Programming" (or (mode . python-mode) (mode . go-mode) (mode . emacs-lisp-mode)))
           ("Dired" (mode . dired-mode))
           ("Emacs" (or (name . "^\\*scratch\\*$") (name . "^\\*Messages\\*$")))))))
(add-hook 'ibuffer-mode-hook (lambda () (ibuffer-switch-to-saved-filter-groups "default")))

;; Utilities
(use-package verb)
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;; Shell in F1
(global-set-key (kbd "<f1>") #'vterm)
(setq shell-command-prompt-show-cwd t)
(setq world-clock-list '(("Europe/Stockholm" "Stockholm")))

;; Mouse definition jump
(when (display-graphic-p)
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions))
