;;; init.el --- Minimal Emacs: Go + Eglot + Treemacs + Vertico/Consult + Corfu

;; ======================================================
;; External Dependencies
;; ======================================================
;; This config requires the following external tools:
;;   - gopls:  go install golang.org/x/tools/gopls@latest
;;   - npm install -g vscode-json-languageserver
;;   - brew install ripgrep (or apt install ripgrep)
;;   - npm i -g typescript-languagep-server
;;   - Install the NERD fonts and IBM Plex Mono
;;   - sudo apt install aspell for spell checking
;;   - Tree-sitter: M-x treesit-install-language-grammar RET yaml to install the YAML grammar
;; Make sure these are installed and in your PATH!
;; ======================================================

;; ======================================================
;; Shortkeys
;; ======================================================
;; m-x eval-buffer (while in init.el)

;; ## modes
;; M-x goto-address-mode
;; M-x Json pretty print for formatting json 

;; ## Navigation & Editing:

;; C-SPC - set mark (start selection)
;; C-u C-SPC          ; Jump back (same buffer)
;; C-x C-SPC          ; Jump back (across buffers)
;; C-f/b/n/p - forward/back/next/previous char/line
;; C-w - kill (cut), M-w - copy, C-y - yank (paste)
;; C-x SPC - rectangle select (vertical), C-x r t - insert text in rectangle
;; C-x h - Select all
;; s-n: Create a new frame

;; ## Commands
;; ### occur
;; M-x occur → type the string or regexp. Emacs creates a persistent Occur buffer listing all matches.
;; In Occur:
;; n / p: next/prev match
;; o: visit match (other window)
;; e: toggle occur-edit-mode to edit matches directly in the Occur buffer
;; C-c C-c: apply edits back to the original buffer
;; C-c C-k: abort edits
;; Tip: from an isearch, press M-s o to send the current search to Occur.
;; ### flush-line

;; ## Buffers & Files:

;; C-x b - switch buffer
;; C-x C-f - find file
;; C-x C-s - save
;; C-x C-c - quit Emacs

;; ## Project.el:

;; C-x p f - find file in project
;; C-x p g - grep in project
;; C-x p p - Select the project
;; Directories to ignore in all project operations
;; (with-eval-after-load 'project
;;   (add-to-list 'project-vc-ignores "node_modules"))

;; ## Grep search
;; Exclude dirs from search:
;; (add-to-list 'grep-find-ignored-directories "node_modules")
;; (add-to-list 'grep-find-ignored-directories "vendor")

;; ## Code Navigation (Eglot):

;; M-. - go to definition
;; M-, - go back
;; M-i - find implementation
;; M-n/p - next/prev error (flymake)

;; Jump Navigation:

;; C-, - go back (xref-go-back)
;; C-. - go forward (xref-go-forward)
;; M-, - go back from definition (xref-pop-marker-stack)
;; C-SPC C-SPC - set mark without selecting
;; C-u C-SPC - jump to previous mark in buffer
;; C-x C-SPC - jump through global marks (across files)

;; Completion (Corfu):

;; M-TAB - force completion popup
;; C-n/p - navigate popup
;; RET/TAB - accept

;; Help & Debug:

;; C-h v - describe variable
;; C-h e - view messages
;; C-x C-e - eval expression
;; M-x - run command


;; ## Mouse:
;; Cmd + Click - Go to definition

;; C-M-\ - Generic indent and formatting
;; M-m     move to first non-space char of line

;; ## Undo
;; C-/ - Undo changes
;; C-? - Redo changes
;; C-x u - Visualize the undo tree


;; C-= - Expand region
;; M-@ - Mark word
;; M-; - Comment/uncomment region
;; C-x C-; - Comment line
;; Ctrl-0 Ctrl-k - Delete from point to beginning of line
;; M-\ - delete-horizontal-space
;; M-^ or C-u M-^ - Join lines
;; Shift-Ctrl-Backspace - Delete entire line the point is on

;; ## Markers

;; C-x r SPC a - save position to register a
;; C-x r SPC b - save position to register b

;; Jump to marker:
;; C-x r j a - jump to register a
;; C-x r w - Save the current window

;; Mnemonic:
;; C-x r = registers
;; SPC = save point (position)
;; j = jump

;; ## Git
;; C-x v ...
;; C-c C-c - finalize commit
;; C-c C-k - cancel commit
;; P p - push to remote

;; ------------------------------------------------------
;; Org mode
;; ------------------------------------------------------
(setq org-agenda-files '("~/todo.org"))
(global-set-key (kbd "C-c o a") #'org-agenda)
(global-set-key (kbd "C-c o c") #'org-capture)
(setq org-capture-templates
      '(("t" "Todo" entry (file "~/todo.org")
         "* TODO %?\n  SCHEDULED: %t\n" :prepend t)))
(setq org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time)  ;; timestamp when completing tasks

;; ------------------------------------------------------
;; UI cleanup
;; ------------------------------------------------------
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 150)
  (set-frame-font "-*-IBM Plex Mono-medium-normal-normal-*-15-*-*-*-m-0-iso10646-1")
  (setq-default line-spacing 4)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions)
  (load-theme 'doom-spacegrey t))

(setq inhibit-startup-screen t)
(xterm-mouse-mode 1)

(use-package exec-path-from-shell
  :if (display-graphic-p)
  :config
  (exec-path-from-shell-initialize))

;; F1: Open shell (overrides help, but C-h still works)
(global-set-key (kbd "<f1>") #'shell)

;; Enable smooth scrolling
(pixel-scroll-precision-mode 1)

;; Half-page scroll functions
(defun scroll-half-page-down ()
  "Scroll down half a page."
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
  "Scroll up half a page."
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

;; Disable pixel-scroll bindings and use your own
(with-eval-after-load 'pixel-scroll
  (define-key pixel-scroll-precision-mode-map (kbd "<prior>") 'scroll-half-page-down)
  (define-key pixel-scroll-precision-mode-map (kbd "<next>") 'scroll-half-page-up))

;; Theme
(use-package standard-themes)

;; Disable audio bell
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;; Delete the selected textwhen typing
(delete-selection-mode 1)

;; ------------------------------------------------------
;; File Management
;; ------------------------------------------------------
;; Disable lock files (if you work solo or use version control)
(setq create-lockfiles nil)

;; Move backups and auto-saves to temp directory
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Better backup behavior
(setq backup-by-copying t
      version-control t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2)

;; ------------------------------------------------------
;; Auto save
;; ------------------------------------------------------
(use-package super-save
  :ensure t
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t)
  (setq super-save-idle-duration 3)
  (setq super-save-remote-files nil)
  (setq super-save-exclude '(".  gpg"))
  (add-to-list 'super-save-triggers 'consult-buffer)
  (add-to-list 'super-save-triggers 'magit-status))

;; ------------------------------------------------------
;; Tabs / indentation / Lines
;; ------------------------------------------------------
;; Go mode - use tabs with width 4
(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 4)
            (setq indent-tabs-mode t)))

;; Line number appearance
;; (add-hook 'prog-mode-hook 'display-line-numbers-mode)
;; (setq display-line-numbers-type 'relative)

(setq display-line-numbers-width 3)           ; Reserve space for 3 digits
(setq display-line-numbers-grow-only t)       ; Don't shrink line number width
(setq display-line-numbers-width-start t)     ; Minimum width based on buffer
;; (global-hl-line-mode 1)

;; ------------------------------------------------------
;; Motion aids
;; ------------------------------------------------------
(use-package avy
  :ensure t
  :demand t
  :bind (("<f2>" . avy-goto-char-in-line)   ;; Fast, scoped to line
         ("M-<f2>" . avy-goto-char-timer)     ;; Whole buffer search
         ("M-g l" . avy-goto-line)         ;; Line navigation
         ("M-g w" . avy-goto-word-1)       ;; Word navigation
         ("M-g c" . avy-goto-char)))       ;; Bonus: single-char jump

(use-package expand-region
  :bind ("C-=" . er/expand-region))  ;; keep pressing to expand selection

(use-package breadcrumb
  :ensure t
  :config
  (breadcrumb-mode 1))

;;; ============================================================
;;; Ctrl-Tab with MRU (Most Recently Used) Order
;;; ============================================================

(defun my/switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently used buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

;; Ctrl-Tab → most recent buffer (like VS Code)
(global-set-key (kbd "C-<tab>") #'my/switch-to-previous-buffer)

;; Ctrl-Shift-Tab → cycle backwards (optional)
(global-set-key (kbd "C-S-<tab>") #'previous-buffer)
(global-set-key (kbd "<C-iso-lefttab>") #'previous-buffer)

;; ------------------------------------------------------
;; Multiple cursors
;; ------------------------------------------------------
(use-package multiple-cursors
  :ensure t
  :bind (
         ;; Add/remove cursors by repeating
         ("C->"       . mc/mark-next-like-this)
         ("C-<"       . mc/mark-previous-like-this)
         ("C-c C-<"   . mc/mark-all-like-this)
         ;; Make a cursor on each selected line (great for struct fields/imports)
         ("C-S-c C-S-c" . mc/edit-lines)
         ;; Add a cursor with the mouse (hold Ctrl+Shift and click)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click))

;; Optional: iedit is great when you want “edit all occurrences of symbol at point”
(use-package iedit
  :ensure t
  :bind (("C-c ;" . iedit-mode)))

;; ------------------------------------------------------
;; Undo tree
;; ------------------------------------------------------
(use-package undo-tree
  :init
  (global-undo-tree-mode)
  :config
  (setq undo-tree-auto-save-history nil))  ;; don't clutter with history files

;; ------------------------------------------------------
;; Fuzzy finder: Vertico + Consult + Orderless + Marginalia
;; ------------------------------------------------------

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  :config
  ;; Wrap around when reaching top/bottom
  (setq vertico-cycle t)
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)))

(recentf-mode 1)
(setq recentf-max-saved-items 200)

(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("<f6>" . consult-register-load)
         ("C-<f6>" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("M-<f6>" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)                  ;; Alternative: consult-find - fd excludes defaults
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history)                ;; orig. previous-matching-history-element

	 ;; Personal additions
	 ("C-x C-r" . consult-recent-file))

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

;; Alternative: Make it even smarter
(defun my/smart-jump ()
  "Smart navigation:  buffer, file, or project search."
  (interactive)
  (call-interactively
   (if (project-current)
       'consult-project-buffer  ; In project:  show project buffers
     'consult-buffer)))          ; Outside:  show all buffers
(global-set-key (kbd "C-<return>") #'my/smart-jump)

;; ------------------------------------------------------
;; Ediff
;; ------------------------------------------------------
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq magit-ediff-dwim-show-on-hunks t) ;; Show only 2 window

;; ------------------------------------------------------
;; Completion: Corfu (minimal, no company)
;; ------------------------------------------------------
;; Corfu: Popup completion-at-point
(use-package corfu
  :init
  (global-corfu-mode)
  (setq corfu-auto t
	corfu-auto-delay 0.1
	corfu-auto-prefix 3))

;; Make corfu popup come up in terminal overlay
(use-package corfu-terminal
  :if (not (display-graphic-p))
  :ensure t
  :config
  (corfu-terminal-mode))

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev) ; Complete word from current buffers
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Pretty icons for corfu
(use-package kind-icon
  :if (display-graphic-p)
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; ------------------------------------------------------
;; Project management (built-in)
;; ------------------------------------------------------
;; C-x p f - find file in project
;; C-x p g - grep in project
(require 'project)

;; ------------------------------------------------------
;; Eglot LSP
;; ------------------------------------------------------
(use-package go-mode
  :mode "\\.go\\'")

(use-package json-mode
  :ensure t
  :mode "\\.json\\'"
  :config
  (add-hook 'json-mode-hook
            (lambda ()
              (setq tab-width 2)
              (setq indent-tabs-mode nil)
              (setq js-indent-level 2))))

(use-package typescript-mode)

(defun my-eglot-format-and-organize ()
  "Format and organize imports, ignoring errors."
  (when (eglot-managed-p)
    ;; Try organize imports, ignore if not available
    ;; (ignore-errors
      ;; (eglot-code-action-organize-imports))
    ;; Always format
    (eglot-format-buffer)))

(use-package eglot
  :hook (
	 (go-mode . eglot-ensure)
         (json-mode .  eglot-ensure)
         (js-mode . eglot-ensure)
         (typescript-mode .  eglot-ensure)
         (tsx-ts-mode . eglot-ensure)
	 )
  :config
  (setq eglot-autoshutdown t
        eglot-sync-connect nil)

  (setq-default eglot-workspace-configuration
                '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  (add-hook 'go-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'my-eglot-format-and-organize nil t))))

;; ------------------------------------------------------
;; Directory tree
;; ------------------------------------------------------
(use-package treemacs
  :bind (("C-c t" . treemacs)))

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

;; ------------------------------------------------------
;; Git
;; ------------------------------------------------------
(use-package magit
  :bind (("<f10>" . magit-status)))

;; TODO: Check if they are not taken
;; Quick access to magit commands (bonus)
;; (global-set-key (kbd "C-x g") #'magit-status)         ; Alternative binding
;; (global-set-key (kbd "C-c g") #'magit-file-dispatch)  ; File-specific git commands

;; C-h v -> major-mode to get the mode
(add-hook 'magit-process-mode-hook 'goto-address-mode)

(use-package diff-hl
  :config
  (global-diff-hl-mode 1)  ;; Enable everywhere
  :hook ((prog-mode . diff-hl-mode)
	 ;; (yaml-mode . diff-hl-mode)
	 ;; (conf-mode . diff-hl-mode)
	 (magit-pre-refresh . diff-hl-magit-pre-refresh)
	 (magit-post-refresh . diff-hl-magit-post-refresh)))

;; ------------------------------------------------------
;; Keybinding help (optional but helpful)
;; ------------------------------------------------------
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

;; ------------------------------------------------------
;; Shortkeys
;; ------------------------------------------------------
(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "M-'") #'eglot-find-implementation) ; Fast access
  (define-key eglot-mode-map (kbd "C-c l i") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") #'eglot-find-typeDefinition)

  ;; Actions
  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l d") #'eldoc-doc-buffer)      ; Show documentation
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-action-organize-imports))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(defun my/flymake-toggle-diagnostics ()
  "Toggle flymake diagnostics buffer. 
If diagnostics buffer is visible, hide it. Otherwise, show it."
  (interactive)
  (let ((diag-buffer (get-buffer "*Flymake diagnostics*")))
    (if (and diag-buffer (get-buffer-window diag-buffer))
        ;; Buffer visible → hide it
        (delete-windows-on diag-buffer)
      ;; Buffer not visible → show it
      (flymake-show-buffer-diagnostics))))

(global-set-key (kbd "<f8>") #'my/flymake-toggle-diagnostics)
(global-set-key (kbd "<S-f8>") #'flymake-show-project-diagnostics)
;; (global-set-key (kbd "<f8>") #'flymake-show-project-diagnostics)

;; Spell check comments and strings only (not code)
(add-hook 'prog-mode-hook #'flyspell-prog-mode)

;; Spell check everything in text modes
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'org-mode-hook #'flyspell-mode)

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         :map minibuffer-local-map
         ("C-c C-e" . embark-export))
  :config
  ;; Show embark actions via which-key (you have which-key!)
  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator)))

(use-package embark-consult
  :ensure t
  :after (embark consult))

(use-package embark-consult
  :hook (embark-collect-mode .  consult-preview-at-point-mode))






(defun embark-which-key-indicator ()
  "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
  (lambda (&optional keymap targets prefix)
    (if (null keymap)
        (which-key--hide-popup-ignore-command)
      (which-key--show-keymap
       (if (eq (plist-get (car targets) :type) 'embark-become)
           "Become"
         (format "Act on %s '%s'%s"
                 (plist-get (car targets) :type)
                 (embark--truncate-target (plist-get (car targets) :target))
                 (if (cdr targets) "…" "")))
       (if prefix
           (pcase (lookup-key keymap prefix 'accept-default)
             ((and (pred keymapp) km) km)
             (_ (key-binding prefix 'accept-default)))
         keymap)
       nil nil t (lambda (binding)
                   (not (string-suffix-p "-argument" (cdr binding))))))))

(setq embark-indicators
  '(embark-which-key-indicator
    embark-highlight-indicator
    embark-isearch-highlight-indicator))

(defun embark-hide-which-key-indicator (fn &rest args)
  "Hide the which-key indicator immediately when using the completing-read prompter."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
         (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

(advice-add #'embark-completing-read-prompter
            :around #'embark-hide-which-key-indicator)




;; M-x wgrep-change-to-wgrep-mode then edit directly in buffer and save
(use-package wgrep
  :ensure t)

;; Better jump back/forward
;; (global-set-key (kbd "C-,") #'xref-go-back)    ;; like M-,
;; (global-set-key (kbd "C-.") #'xref-go-forward)

(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))

;; World clock
(setq world-clock-list
      '(("Europe/Stockholm" "Stockholm")
	("Iran" "Tehran")
	("Asia/Kuala_Lumpur" "KL")))

;; Better buffer switching (complements C-x C-k)
(global-set-key (kbd "C-x C-b") #'ibuffer)  ; Better than list-buffers

;; Better shell behavior
(setq shell-command-prompt-show-cwd t)  ; Emacs 27+

;; Helper function for M-O (go to previous window)
(defun previous-window-or-split ()
  "Go to previous window, wrapping around if necessary."
  (interactive)
  (other-window -1))
;; M-o: Switch windows quickly (normally bound to facemenu-mode)
(global-set-key (kbd "M-o") #'other-window)
;; (global-set-key (kbd "C-u M-o") #'previous-window-or-split)    ; M-p (mnemonic: previous)

;; Mark navigation
(setq set-mark-command-repeat-pop t)

;; Auto-revert for git info (better than magit-auto-revert)
(global-auto-revert-mode 1)
(setq auto-revert-check-vc-info t)

;; ------------------------------------------------------
;; Copilot
;; ------------------------------------------------------
;; GitHub Copilot
(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main")
  :bind (:map copilot-mode-map
              ("C-c c \\" . copilot-complete)
              ("C-c c n" . copilot-next-completion)
              ("C-c c p" . copilot-previous-completion)
              ("C-g" . copilot-clear-overlay)
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion))
  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (setq copilot-idle-delay nil))  ; Disable auto-suggestions

;;; ============================================================
;;; Enhanced Window Management
;;; ============================================================

;; Quick window actions
(global-set-key (kbd "M-0") #'delete-window)
(global-set-key (kbd "M-1") #'delete-other-windows)
(global-set-key (kbd "M-2") #'split-window-right)
(global-set-key (kbd "M-3") #'split-window-below)

;; Navigate
;; (global-set-key (kbd "M-o") #'other-window)
;; (global-set-key (kbd "C-x O") 
;;   (lambda () (interactive) (other-window -1)))

;; Smart window killer (close window or kill buffer if only one window)
(defun my/delete-window-or-kill-buffer ()
  "Delete window; if only one window, kill buffer instead."
  (interactive)
  (if (one-window-p)
      (kill-this-buffer)
    (delete-window)))

(global-set-key (kbd "M-0") #'my/delete-window-or-kill-buffer)

;; Window history (undo/redo window changes)
(winner-mode 1)
(global-set-key (kbd "C-c <left>") #'winner-undo)   ; Undo window change
(global-set-key (kbd "C-c <right>") #'winner-redo)  ; Redo window change


;; ------------------------------------------------------
;; Tree sitter
;; ------------------------------------------------------
;; Tree-sitter setup (Emacs 29+)
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

;; ------------------------------------------------------
;; Git - Minimal changes sidebar
;; ------------------------------------------------------
(load "~/.config/emacs/git-sidebar.el")
(global-set-key (kbd "C-c g c") #'my-git-changes-sidebar)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ansible beacon breadcrumb cape copilot corfu-terminal diff-hl docker
	     doom-themes dracula-theme embark-consult
	     exec-path-from-shell expand-region go-mode iedit
	     json-mode kind-icon lsp-treemacs magit marginalia minimap
	     multiple-cursors nerd-icons-dired orderless
	     persistent-scratch reformatter standard-themes super-save
	     tree-sitter-langs treemacs-all-the-icons
	     treemacs-icons-dired treemacs-nerd-icons typescript-mode
	     undo-tree vertico wgrep yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
