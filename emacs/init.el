;;; init.el --- Emacs Config: Go + Eglot + Modern Completion

(require 'package) ;; Emacs builtin
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; initialize built-in package management
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


;; From https://blog.sumtypeofway.com/posts/emacs-config.html
(setq
 ;; No need to see GNU agitprop.
 inhibit-startup-screen t
 ;; No need to remind me what a scratch buffer is.
 initial-scratch-message nil
 ;; Double-spaces after periods is morally wrong.
 sentence-end-double-space nil
 ;; Never ding at me, ever.
 ring-bell-function 'ignore
 ;; Save existing clipboard text into the kill ring before replacing it.
 save-interprogram-paste-before-kill t
 ;; Prompts should go in the minibuffer, not in a GUI.
 use-dialog-box nil
 ;; Fix undo in commands affecting the mark.
 mark-even-if-inactive nil
 ;; Let C-k delete the whole line.
 kill-whole-line t
 ;; search should be case-sensitive by default
 case-fold-search nil
 ;; no need to prompt for the read command _every_ time
 compilation-read-command nil
 ;; scroll to first error
 compilation-scroll-output 'first-error
 ;; accept 'y' or 'n' instead of yes/no
 ;; the documentation advises against setting this variable
 ;; the documentation can get bent imo
 use-short-answers t
 ;; my source directory
 default-directory "~/Documents/workspace/"
 ;; eke out a little more scrolling performance
 fast-but-imprecise-scrolling t
 ;; prefer newer elisp files
 load-prefer-newer t
 ;; when I say to quit, I mean quit
 confirm-kill-processes nil
 ;; if native-comp is having trouble, there's not very much I can do
 native-comp-async-report-warnings-errors 'silent
 ;; unicode ellipses are better
 truncate-string-ellipsis "…"
 )

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)

(column-number-mode)

(require 'hl-line)
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'text-mode-hook #'hl-line-mode)

;; ======================================================
;; EXTERNAL DEPENDENCIES (install these first!)
;; ======================================================
;; go install golang.org/x/tools/gopls@latest
;; npm install -g vscode-json-languageserver typescript-language-server
;; brew install ripgrep (search tool)
;; Install NERD fonts and IBM Plex Mono
;; sudo apt install aspell (spell checking)

;; ======================================================
;; BASIC UI & BEHAVIOR
;; ======================================================

;; Spacegray theme comes from this package
(use-package doom-themes)

;; Clean UI
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 120)
  (set-frame-font "-*-IBM Plex Mono-medium-normal-normal-*-15-*-*-*-m-0-iso10646-1")
  (setq-default line-spacing 4)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (load-theme 'doom-nord-light t))

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

;; Better defaults
(delete-selection-mode 1)          ; Typing replaces selection
(global-auto-revert-mode 1)        ; Auto-reload changed files
(recentf-mode 1)                   ; Track recent files
(setq recentf-max-saved-items 200)

;; ======================================================
;; FILE MANAGEMENT
;; ======================================================

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

;; ======================================================
;; INDENTATION & FORMATTING
;; ======================================================

;; Go: tabs, width 4
(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 4
                  indent-tabs-mode t)))

;; JSON: spaces, width 2
(add-hook 'json-mode-hook
          (lambda ()
            (setq tab-width 2
                  indent-tabs-mode nil
                  js-indent-level 2)))

;; Line numbers (optional - commented out)
;; (add-hook 'prog-mode-hook 'display-line-numbers-mode)
;; (setq display-line-numbers-type 'relative)

;; ======================================================
;; NAVIGATION & EDITING
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

;; Undo/Redo with visualization
(use-package undo-tree
  :init
  (global-undo-tree-mode)
  :config
  (setq undo-tree-auto-save-history nil))
;; C-/: undo
;; C-?: redo
;; C-x u: visualize undo tree

;; Jump navigation
;; M-.: go to definition
;; M-,: go back
;; C-u C-SPC: jump to previous mark (same buffer)
;; C-x C-SPC: jump across buffers
(setq set-mark-command-repeat-pop t)  ; Keep popping marks with C-u C-SPC

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
  :config
  (breadcrumb-mode 1))

;; ======================================================
;; COMPLETION (Vertico + Consult + Corfu)
;; ======================================================

;; Vertico: vertical completion UI
(use-package vertico
  :init
  (setq vertico-cycle t)
  (vertico-mode))

; Not in Melpa
;(use-package vertico-directory
;  :after vertico
;  :bind (:map vertico-map
;              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: show annotations
(use-package marginalia
  :config
  (marginalia-mode))

;; Orderless: flexible matching (space-separated terms)
(use-package orderless
  :config
  (setq completion-styles '(orderless)))

;; Consult: enhanced search/navigation
(use-package consult
  :bind (;; Buffer/file switching
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x p b" . consult-project-buffer)
         ("C-x C-r" . consult-recent-file)
         
         ;; Search
         ("M-s l" . consult-line)           ; Search current buffer
         ("M-s L" . consult-line-multi)     ; Search all buffers
         ("M-s d" . consult-fd)             ; Find file by name
         ("M-s g" . consult-grep)           ; Grep in directory
         ("M-s r" . consult-ripgrep)        ; Ripgrep (faster)
         
         ;; Navigation
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)          ; Jump to function/class
         ("M-g m" . consult-mark)           ; Jump to mark
         
         ;; Yank history
         ("M-y" . consult-yank-pop)
         
         ;; Registers
         ("<f6>" . consult-register-load)
         ("C-<f6>" . consult-register-store)
         ("M-<f6>" . consult-register)
         
         :map isearch-mode-map
         ("M-s l" . consult-line))
  
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   :preview-key '(:debounce 0.4 any))
  
  (setq consult-narrow-key "<"))

;; Smart buffer switching
(defun my/smart-jump ()
  "Show project buffers if in project, else all buffers."
  (interactive)
  (call-interactively
   ;; Actually, I don't use project buffer very much
   ;; (if (project-current)
   ;;     'consult-project-buffer
   ;;   'consult-buffer)
   'consult-buffer
   ))
(global-set-key (kbd "C-<return>") #'my/smart-jump)

;; Corfu: popup completion (like VS Code)
(use-package corfu
  :init
  (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 3))

; Not available in Melpa
;(use-package corfu-terminal
;  :if (not (display-graphic-p))
;  :config
;  (corfu-terminal-mode))

;; Cape: completion sources
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Pretty icons in completion
(use-package kind-icon
  :if (display-graphic-p)
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

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
;; LSP (Eglot)
;; ======================================================

(use-package go-mode
  :mode "\\.go\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package typescript-mode)

(defun my-eglot-format-and-organize ()
  "Format buffer on save."
  (when (eglot-managed-p)
    (eglot-format-buffer)))

(use-package eglot
  :hook ((go-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (js-mode . eglot-ensure)
	 (c-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
        eglot-sync-connect nil)
  
  ;; Go: enable test tags
  (setq-default eglot-workspace-configuration
                '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  
  ;; Format on save
  (add-hook 'go-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'my-eglot-format-and-organize nil t))))

;; Eglot keybindings
;; M-.: go to definition
;; M-,: go back
;; M-': find implementation
(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "M-'") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l i") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") #'eglot-find-typeDefinition)
  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l d") #'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-action-organize-imports))

;; Error navigation
(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(defun my/flymake-toggle-diagnostics ()
  "Toggle flymake diagnostics buffer."
  (interactive)
  (let ((diag-buffer (get-buffer "*Flymake diagnostics*")))
    (if (and diag-buffer (get-buffer-window diag-buffer))
        (delete-windows-on diag-buffer)
      (flymake-show-buffer-diagnostics))))

(global-set-key (kbd "<f8>") #'my/flymake-toggle-diagnostics)
(global-set-key (kbd "<S-f8>") #'flymake-show-project-diagnostics)

;; Spell checking
(add-hook 'prog-mode-hook #'flyspell-prog-mode)  ; Comments/strings only
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'org-mode-hook #'flyspell-mode)

;; ======================================================
;; PROJECT MANAGEMENT
;; ======================================================

;; Built-in project.el
;; C-x p f: find file in project
;; C-x p g: grep in project
;; C-x p p: switch project
(require 'project)

;; ======================================================
;; GIT (Magit)
;; ======================================================

(use-package magit
  :bind ("C-x g" . magit-status))

;; Clickable links in magit output
(add-hook 'magit-process-mode-hook 'goto-address-mode)

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

;; Custom git sidebar
; (load "~/.config/emacs/git-sidebar.el")
; (global-set-key (kbd "C-c g c") #'my-git-changes-sidebar)

;; ======================================================
;; FILE TREE
;; ======================================================

(use-package treemacs
  :bind ("C-c t" . treemacs))

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

;; ======================================================
;; WINDOW MANAGEMENT
;; ======================================================

;; Window concepts:
;; - Frame: OS window (entire Emacs window)
;; - Window: pane within frame (split)
;; - Buffer: file content (can be shown in multiple windows)

;; Quick window actions
(global-set-key (kbd "M-1") #'delete-other-windows)  ; Keep only current
(global-set-key (kbd "M-2") #'split-window-right)    ; Split vertical
(global-set-key (kbd "M-3") #'split-window-below)    ; Split horizontal

;; Navigate windows
(global-set-key (kbd "M-o") #'other-window)

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

;; ======================================================
;; BUFFER MANAGEMENT
;; ======================================================

;; Ctrl-Tab: switch to last buffer (like Alt-Tab)
(defun my/switch-to-previous-buffer ()
  "Switch to previously used buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(global-set-key (kbd "C-<tab>") #'my/switch-to-previous-buffer)
(global-set-key (kbd "C-S-<tab>") #'previous-buffer)
(global-set-key (kbd "<C-iso-lefttab>") #'previous-buffer)

;; Better buffer list
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; ======================================================
;; ORG MODE
;; ======================================================

(setq org-agenda-files '("~/todo.org")
      org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time)  ; Timestamp on TODO completion

(global-set-key (kbd "C-c a") #'org-agenda)

;; ======================================================
;; COPILOT
;; ======================================================

(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :branch "main")
  :bind (:map copilot-mode-map
              ("C-c c \\" . copilot-complete)
              ("C-c c n" . copilot-next-completion)
              ("C-c c p" . copilot-previous-completion)
              ("C-g" . copilot-clear-overlay)
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion))
  :config
  (setq copilot-idle-delay nil))  ; Manual trigger only

;; ======================================================
;; MISCELLANEOUS
;; ======================================================

;; Show keybinding help
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

;; Shell in F1
(global-set-key (kbd "<f1>") #'shell)

;; .env files as config
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))

;; World clock
(setq world-clock-list
      '(("Europe/Stockholm" "Stockholm")))

;; Better shell behavior
(setq shell-command-prompt-show-cwd t)

(use-package verb)
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;; Markdown mode
(add-hook 'markdown-mode-hook
          (lambda ()
            (define-key markdown-mode-map (kbd "M-<up>") 'markdown-move-up)
	    (define-key markdown-mode-map (kbd "M-<down>") 'markdown-move-down)
	    (setq indent-tabs-mode nil)
	    (setq tab-width 2)))

;; Tree-sitter (Emacs 29+)
(when (treesit-available-p)
  ;; Language grammar sources
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

(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-ts-mode))

;; Mouse: Cmd+Click = go to definition
(when (display-graphic-p)
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions))
