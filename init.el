;;; init.el --- Minimal Emacs: Go + Eglot + Treemacs + Vertico/Consult + Corfu

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
;; UI cleanup
;; ------------------------------------------------------
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 150)
  (setq-default line-spacing 5)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (global-set-key (kbd "s-<mouse-1>") #'xref-find-definitions)
  (load-theme 'leuven t))

(setq inhibit-startup-screen t)
(xterm-mouse-mode 1)

(use-package exec-path-from-shell
  :if (display-graphic-p)
  :config
  (exec-path-from-shell-initialize))

;; Put auto-save and backup files in system temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; ------------------------------------------------------
;; Tabs / indentation
;; ------------------------------------------------------
;; (setq-default tab-width 4
;; 			  indent-tabs-mode t) ;; Go uses tabs

;; Go mode - use tabs with width 4
(add-hook 'go-mode-hook
          (lambda ()
            (setq tab-width 4)
            (setq indent-tabs-mode t)))

;; JSON mode - use 2 spaces (no tabs)
(add-hook 'json-mode-hook
          (lambda ()
            (setq tab-width 2)
            (setq indent-tabs-mode nil)
            (setq js-indent-level 2)))

;; ------------------------------------------------------
;; Motion aids with Avy
;; ------------------------------------------------------
(use-package avy
  :ensure t
  :demand t
  :bind (("C-;" . avy-goto-char-timer)  ;; type chars, shows jump hints
        ("C-'" . avy-goto-line)))       ;; jump to line

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
		corfu-auto-prefix 1))

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
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
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
;; Go + Eglot LSP
;; ------------------------------------------------------
(use-package go-mode
  :mode "\\.go\\'")

(use-package eglot
  :hook ((go-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t       ;; cleanup unused LSP servers
		eglot-sync-connect nil)    ;; faster startup
  (setq-default eglot-workspace-configuration
                '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  (add-hook 'go-mode-hook
			(lambda ()
			  (add-hook 'before-save-hook #'eglot-format-buffer nil t))))

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
  (define-key eglot-mode-map (kbd "M-i") #'eglot-find-implementation))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

;; ------------------------------------------------------
;; Xref: use completing-read instead of xref buffer
;; ------------------------------------------------------
(setq xref-show-definitions-function #'xref-show-definitions-completing-read)
(setq xref-show-xrefs-function #'xref-show-definitions-completing-read)

;; Better jump back/forward
(global-set-key (kbd "C-,") 'xref-go-back)    ;; like M-,
(global-set-key (kbd "C-.") 'xref-go-forward)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
