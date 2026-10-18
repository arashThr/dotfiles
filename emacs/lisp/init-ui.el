;;; init-ui.el --- Theme, fonts, frame and scrolling -*- lexical-binding: t; -*-

;; ======================================================
;; UI & THEMING
;; ======================================================

;; tango is built in, so no theme package is needed.
;; (For Spacegray etc: (use-package doom-themes :demand t) and load-theme it.)
(use-package doom-themes
  :config
  (load-theme 'tango t))

;; Clean UI
(when (display-graphic-p)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 140)
  (set-frame-font "-*-Menlo-regular-normal-normal-*-14-*-*-*-m-0-iso10646-1" nil t)
  (setq-default line-spacing 8)
  (add-to-list 'default-frame-alist '(fullscreen . maximized)))

;; Mouse support in terminal
(xterm-mouse-mode 1)

;; Get PATH from shell (macOS fix). Non-interactive shell = faster.
(use-package exec-path-from-shell
  :if (display-graphic-p)
  :demand t
  :config
  (setq exec-path-from-shell-arguments '("-l")
        exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOBIN"))
  (exec-path-from-shell-initialize))

;; Smooth scrolling
(pixel-scroll-precision-mode 1)

(defun scroll-half-page-down ()
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

  (define-key pixel-scroll-precision-mode-map (kbd "<prior>") 'scroll-half-page-down)
  (define-key pixel-scroll-precision-mode-map (kbd "<next>") 'scroll-half-page-up)

(provide 'init-ui)
;;; init-ui.el ends here
