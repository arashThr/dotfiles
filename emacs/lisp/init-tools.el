;;; init-tools.el --- Copilot, Markdown, Ibuffer, shell and misc utilities -*- lexical-binding: t; -*-

;; ======================================================
;; MISC TOOLS
;; ======================================================

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

(provide 'init-tools)
;;; init-tools.el ends here
