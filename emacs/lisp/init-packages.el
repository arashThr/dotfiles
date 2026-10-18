;;; init-packages.el --- Package archives, use-package bootstrap, custom-file -*- lexical-binding: t; -*-

;; ======================================================
;; PACKAGE MANAGEMENT & BOOTSTRAP
;; ======================================================

(require 'package)
;; Only MELPA (not melpa-stable): mixing both causes version conflicts
;; and was the source of the random load errors.
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      package-quickstart t                 ;; precompiled autoloads = faster startup
      package-install-upgrade-built-in t)  ;; allow real `compat' over Emacs' stub
(package-initialize)

;; Bootstrap 'use-package'
(with-eval-after-load 'gnutls
  (add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(require 'bind-key)
(setq use-package-always-ensure t
      use-package-always-defer t)  ;; load packages lazily (big startup win)

(use-package compat :demand t)

;; Set Custom output file to keep this file intact when install packages manually
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil t))

(provide 'init-packages)
;;; init-packages.el ends here
