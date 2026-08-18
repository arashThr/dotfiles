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
      (kill-this-buffer)
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
  :config (setq completion-styles '(orderless basic)))

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
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 3))

;; Cape: completion sources
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

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
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator)))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Edit grep results directly
(use-package wgrep)

;; ======================================================
;; 7. LSP, LANGUAGES, & TREESITTER
;; ======================================================

;; For new languages, you need to manually install the Tree-sitter grammar
;; M-x treesit-install-language-grammar RET typescript RET
(use-package go-mode :mode "\\.go\\'")
(use-package json-mode :mode "\\.json\\'")
(use-package typescript-ts-mode :mode ("\\.ts\\'" "\\.tsx\\'"))

;; Formatting Hook
(defun my-eglot-format-and-organize ()
  "Format buffer on save."
  (when (eglot-managed-p)
    (eglot-format-buffer)
    (eglot-code-action-organize-imports)))

(use-package eglot
  :hook ((go-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (js-mode . eglot-ensure)
	 (c-mode . eglot-ensure)
	 (python-mode . eglot-ensure)
	 (c++-mode-hook . eglot-ensure)
	 (c-or-c++-mode-hook . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
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
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))

;; Indentation Hooks
;; Go: tabs, width 4
(add-hook 'go-mode-hook (lambda () (setq tab-width 4 indent-tabs-mode t)))
;; JSON: spaces, width 2
(add-hook 'json-mode-hook (lambda () (setq tab-width 2 indent-tabs-mode nil js-indent-level 2)))

;; LISP
(load (expand-file-name "~/.quicklisp/slime-helper.el"))
;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "sbcl")


;; ======================================================
;; 8. GIT, ORG, COPILOT & MISC TOOLS
;; ======================================================

;; Built-in project.el
;; C-x p f: find file in project
;; C-x p g: grep in project
;; C-x p p: switch project
(require 'project)

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
      org-log-done 'time)  ; Timestamp on TODO completion
(global-set-key (kbd "C-c a") #'org-agenda)

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
                           (setq indent-tabs-mode nil tab-width 2)
                           (turn-on-gfm-multimarkdown-mode)))
  :bind (:map markdown-mode-map
              ("M-<up>"   . markdown-move-up)
              ("M-<down>" . markdown-move-down)))

;; Better Ibuffer categories
(use-package ibuffer
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
(global-set-key (kbd "<f1>") #'shell)
(setq shell-command-prompt-show-cwd t)
(setq world-clock-list '(("Europe/Stockholm" "Stockholm")))

;; Mouse definition jump
(when (display-graphic-p)
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ansible beacon breadcrumb caddyfile-mode cape claude-code-ide
	     copilot corfu-terminal diff-hl docker docker-compose-mode
	     doom-themes dracula-theme emacsql embark-consult
	     everlasting-scratch exec-path-from-shell expand-region
	     github-browse-file go-scratch graphql-mode iedit
	     json-mode kind-icon kotlin-mode kotlin-ts-mode
	     lsp-treemacs magit marginalia minimap multiple-cursors
	     muse nerd-icons-dired orderless org-journal
	     persistent-scratch racket-mode reformatter scratch-plus
	     standard-themes super-save tree-sitter-langs
	     treemacs-all-the-icons treemacs-icons-dired
	     treemacs-nerd-icons typescript-mode undo-tree verb
	     vertico vimrc-mode vimscript-ts-mode vterm wgrep
	     writegood-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
