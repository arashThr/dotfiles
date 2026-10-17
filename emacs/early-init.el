;;; early-init.el --- Runs before package.el and the GUI -*- lexical-binding: t; -*-

;; Defer garbage collection during startup, restore sane value after.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Don't let package.el activate everything before init.el runs.
(setq package-enable-at-startup nil)

;; Skip the expensive regexp walk over file-name-handler-alist during load.
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Kill UI chrome before the frame is drawn (avoids a visible resize/repaint).
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)
(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t
      inhibit-x-resources t
      initial-scratch-message nil)

;; Quieter native-comp.
(setq native-comp-async-report-warnings-errors 'silent
      native-comp-jit-compilation t)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my/file-name-handler-alist)
            (message "Emacs ready in %.2fs with %d GCs."
                     (float-time (time-subtract after-init-time before-init-time))
                     gcs-done)))

;;; early-init.el ends here
