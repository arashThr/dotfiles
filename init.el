;;; init.el --- Minimal Emacs: Go + Eglot + Treemacs + Vertico/Consult + Corfu

;; ======================================================
;; External Dependencies
;; ======================================================
;; This config requires the following external tools:
;;   - gopls:  go install golang.org/x/tools/gopls@latest
;;   - npm install -g vscode-json-languageserver
;;   - brew install ripgrep (or apt install ripgrep)
;;   - npm i -g typescript-language-server
;; Make sure these are installed and in your PATH!
;; ======================================================

;; ======================================================
;; Shortkeys
;; ======================================================
;; M-x eval-buffer (while in init.el)

;; ## Navigation & Editing:

;; C-SPC - set mark (start selection)
;; C-f/b/n/p - forward/back/next/previous char/line
;; C-w - kill (cut), M-w - copy, C-y - yank (paste)
;; C-x SPC - rectangle select (vertical), C-x r t - insert text in rectangle
;; C-x h - Select all

;; ## Buffers & Files:

;; C-x b - switch buffer
;; C-x C-f - find file
;; C-x C-s - save
;; C-x C-c - quit Emacs

;; ## Project.el:

;; C-x p f - find file in project
;; C-x p g - grep in project

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
;; Shift-Ctrl-Backspace - Delete entire line the point is on

;; ## Markers

;; C-x r SPC a - save position to register a
;; C-x r SPC b - save position to register b

;; Jump to marker:
;; C-x r j a - jump to register a

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
;; Package system
;; ------------------------------------------------------
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; ------------------------------------------------------
;; Org mode
;; ------------------------------------------------------
(setq org-agenda-files '("~/todo.org"))
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
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
  (setq-default line-spacing 4)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions)
  (load-theme 'leuven t))

(setq inhibit-startup-screen t)
(xterm-mouse-mode 1)

(use-package exec-path-from-shell
  :if (display-graphic-p)
  :config
  (exec-path-from-shell-initialize))

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
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
;; (setq display-line-numbers-type 'relative)

(setq display-line-numbers-width 3)           ; Reserve space for 3 digits
(setq display-line-numbers-grow-only t)       ; Don't shrink line number width
(setq display-line-numbers-width-start t)     ; Minimum width based on buffer
;; (global-hl-line-mode 1)

;; ------------------------------------------------------
;; Motion aids with Avy
;; ------------------------------------------------------
(use-package avy
  :ensure t
  :demand t
  :bind (("C-;" . avy-goto-char-in-line)   ;; Fast, scoped to line
         ("C-'" . avy-goto-char-timer)     ;; Whole buffer search
         ("M-g l" . avy-goto-line)         ;; Line navigation
         ("M-g w" . avy-goto-word-1)       ;; Word navigation
         ("M-g c" . avy-goto-char)))       ;; Bonus: single-char jump

(use-package expand-region
  :bind ("C-=" . er/expand-region))  ;; keep pressing to expand selection

;; Cycle through buffers
(global-set-key (kbd "<C-tab>") 'next-buffer)
(global-set-key (kbd "<C-S-tab>") 'previous-buffer)

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
  :ensure t
  :bind (
         ;; Drop-in replacements
         ("C-x b" . consult-buffer)     ; orig. switch-to-buffer
         ("M-y"   . consult-yank-pop)   ; orig. yank-pop
         ;; Searching
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)       ; Alternative: rebind C-s to use
         ("M-s s" . consult-line)       ; consult-line instead of isearch, bind
         ("M-s L" . consult-line-multi) ; isearch to M-s s
         ("M-s o" . consult-outline)
	 ("C-c f" . consult-find)
	 ("C-c i" . consult-imenu)
	 ("C-x C-r" . consult-recent-file)
	 ("C-x r j" . consult-register)
	 ("C-x r SPC" . consult-register-store)

         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)   ; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
         ("M-s l" . consult-line)            ; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)      ; needed by consult-line to detect isearch
         )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

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

  (add-hook 'before-save-hook
                      (lambda ()
                        (call-interactively 'eglot-code-action-organize-imports))
                      nil t)
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

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
  :bind (("C-x g" . magit-status)))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
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
  (define-key eglot-mode-map (kbd "C-c l d") #'eldoc-doc-buffer))      ; Show documentation

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

;; ------------------------------------------------------
;; Xref: use completing-read instead of xref buffer
;; ------------------------------------------------------
(setq xref-show-definitions-function #'consult-xref)
(setq xref-show-xrefs-function #'consult-xref)

;; Better jump back/forward
(global-set-key (kbd "C-,") 'xref-go-back)    ;; like M-,
(global-set-key (kbd "C-.") 'xref-go-forward)

;; ------------------------------------------------------
;; Copilot
;; ------------------------------------------------------
;; GitHub Copilot
(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main")
  :bind (:map copilot-mode-map
              ("M-\\" . copilot-complete)
              ("M-n" . copilot-next-completion)
              ("M-p" . copilot-previous-completion)
              ("C-g" . copilot-clear-overlay)
              ("<tab>" . copilot-accept-completion)
              ("TAB" . copilot-accept-completion))
  :config
  (setq copilot-idle-delay nil))  ; Disable auto-suggestions

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ansible beacon cape consult copilot corfu-terminal diff-hl
	     exec-path-from-shell expand-region go-mode json-mode
	     kind-icon lsp-treemacs magit marginalia minimap
	     nerd-icons-dired orderless persistent-scratch reformatter
	     super-save treemacs-all-the-icons treemacs-icons-dired
	     treemacs-nerd-icons undo-tree vertico yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
