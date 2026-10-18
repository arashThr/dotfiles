;;; init-filetree.el --- Treemacs, icons and Dired -*- lexical-binding: t; -*-

;; ======================================================
;; PROJECT TREE (Treemacs) & DIRED
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

(provide 'init-filetree)
;;; init-filetree.el ends here
