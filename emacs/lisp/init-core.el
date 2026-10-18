;;; init-core.el --- Core settings, sane defaults, file handling -*- lexical-binding: t; -*-

;; ======================================================
;; CORE SETTINGS & SANE DEFAULTS
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
 redisplay-skip-fontification-on-input t ;; snappier typing in big buffers
 load-prefer-newer t               ;; prefer newer elisp files
 confirm-kill-processes nil        ;; when I say to quit, I mean quit
 read-process-output-max (* 1024 1024) ;; 1MB reads: much faster LSP
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
  :demand t
  :diminish
  :config
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 3
        super-save-remote-files nil
        super-save-exclude '(".gpg"))
  (add-to-list 'super-save-triggers 'consult-buffer)
  (add-to-list 'super-save-triggers 'magit-status)
  (super-save-mode +1))

(use-package persistent-scratch
  :hook (after-init . persistent-scratch-setup-default))

(provide 'init-core)
;;; init-core.el ends here
