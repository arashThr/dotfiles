;;; init-completion.el --- Vertico, Consult, Corfu, Embark and friends -*- lexical-binding: t; -*-

;; ======================================================
;; COMPLETION (Vertico, Consult, Corfu)
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
(use-package nerd-icons-corfu
  :after corfu
  :demand t
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

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

(provide 'init-completion)
;;; init-completion.el ends here
