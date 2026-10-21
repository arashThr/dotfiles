;;; init-ui.el --- Theme, fonts, frame and scrolling -*- lexical-binding: t; -*-

;; ======================================================
;; UI & THEMING
;; ======================================================

;; doom-themes stays installed to try its themes: M-x consult-theme RET doom-<TAB>
(use-package doom-themes :demand t)

;; Modus is built in and has the clearest diff faces of any theme.
;; <f5> toggles light/dark.
(setq modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi-tinted)
      modus-themes-bold-constructs t
      modus-themes-common-palette-overrides
      '((fringe unspecified)                    ;; fringe blends into the buffer
        (border-mode-line-active unspecified)   ;; flat mode line
        (border-mode-line-inactive unspecified)
        (bg-line-number-active bg-hl-line)))
(load-theme 'modus-operandi-tinted t)
(global-set-key (kbd "<f5>") #'modus-themes-toggle)

;; Follow the macOS light/dark setting (emacs-plus builds only).
(when (boundp 'ns-system-appearance-change-functions)
  (add-hook 'ns-system-appearance-change-functions
            (lambda (appearance)
              (mapc #'disable-theme custom-enabled-themes)
              (load-theme (if (eq appearance 'dark) 'modus-vivendi-tinted 'modus-operandi-tinted) t))))

;; Fonts: first installed one wins.
;; macOS: brew install --cask font-jetbrains-mono font-symbols-only-nerd-font
(defun my/first-font (&rest families)
  (seq-find (lambda (f) (find-font (font-spec :family f))) families))

(when (display-graphic-p)
  (when-let* ((mono (my/first-font "JetBrains Mono" "SF Mono" "Menlo" "DejaVu Sans Mono")))
    (set-face-attribute 'default nil :family mono :height 140)
    (set-face-attribute 'fixed-pitch nil :family mono :height 1.0))
  (setq-default line-spacing 0.2)

  ;; Nerd icons must come from the *Mono* symbols font. Otherwise Emacs falls
  ;; back to whatever font has the glyph, which is often double width, and
  ;; the right half of the icon gets clipped (Treemacs, Dired, Corfu).
  (setq nerd-icons-font-family "Symbols Nerd Font Mono")
  (if (find-font (font-spec :family nerd-icons-font-family))
      (dolist (range '((#xe000 . #xf8ff) (#xf0000 . #xfffff)))
        (set-fontset-font t range nerd-icons-font-family nil 'prepend))
    (message "Icons: font missing, run M-x nerd-icons-install-fonts and restart")))

;; Frame: a bit of padding, thin window dividers, pixel-exact sizing.
(setq frame-resize-pixelwise t
      window-divider-default-right-width 1
      window-divider-default-bottom-width 1
      window-divider-default-places t)
(window-divider-mode 1)
(add-to-list 'default-frame-alist '(internal-border-width . 8))
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; Line numbers and current-line highlight where they help.
(setq-default display-line-numbers-width 3)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)

;; Mouse support in terminal
(xterm-mouse-mode 1)

;; Get PATH from shell (macOS fix). Non-interactive shell = faster.
(use-package exec-path-from-shell
  :if (display-graphic-p)
  :demand t
  :config
  (setq exec-path-from-shell-arguments '("-l" "-i"))
  (exec-path-from-shell-initialize))

;; Smooth scrolling (trackpad momentum, no jumpy recentering)
(setq pixel-scroll-precision-use-momentum t
      scroll-conservatively 101
      scroll-margin 2
      mouse-wheel-progressive-speed nil)
(pixel-scroll-precision-mode 1)

;; PgUp/PgDn: animated half-page scroll
(defun scroll-half-page-down ()
  (interactive)
  (pixel-scroll-precision-interpolate (/ (window-text-height nil t) 2) nil 1))

(defun scroll-half-page-up ()
  (interactive)
  (pixel-scroll-precision-interpolate (- (/ (window-text-height nil t) 2)) nil 1))

(define-key pixel-scroll-precision-mode-map (kbd "<prior>") 'scroll-half-page-down)
(define-key pixel-scroll-precision-mode-map (kbd "<next>") 'scroll-half-page-up)

(provide 'init-ui)
;;; init-ui.el ends here
