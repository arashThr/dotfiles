;;; init-org.el --- Org mode, capture, agenda and verb -*- lexical-binding: t; -*-

;; ======================================================
;; ORG
;; ======================================================

;; Org Mode
(setq org-agenda-files '("~/todo.org")
      org-startup-indented t
      org-hide-leading-stars t
      org-log-done 'time          ;; Timestamp on TODO completion
      org-log-into-drawer t)      ;; keep CLOSED/state-change notes tidy in the LOGBOOK drawer

;; Interruptions template
(setq org-capture-templates
      '(("b" "Backlog item" entry
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
(with-eval-after-load 'org
  (org-clock-persistence-insinuate))

(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; todo-mode is built in; F12 autoloads it (no `require' at startup)
(global-set-key (kbd "<f12>") #'todo-show)

;; Utilities
;; verb: bind its map only once both org and verb are loaded (fixes init error)
(use-package verb
  :after org
  :demand t
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(provide 'init-org)
;;; init-org.el ends here
