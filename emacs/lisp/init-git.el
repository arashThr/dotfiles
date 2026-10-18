;;; init-git.el --- project.el, Magit, diff-hl and Ediff -*- lexical-binding: t; -*-

;; ======================================================
;; PROJECTS & GIT
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

(provide 'init-git)
;;; init-git.el ends here
