;;; init-lang.el --- Major modes, Tree-sitter, Eglot, diagnostics and spell check -*- lexical-binding: t; -*-

;; ======================================================
;; LSP, LANGUAGES, & TREESITTER
;; ======================================================

;; For new languages, you need to manually install the Tree-sitter grammar
;; M-x treesit-install-language-grammar RET typescript RET
;; (or M-x my/treesit-install-all to install every missing one)
(use-package go-mode :mode "\\.go\\'")
(use-package json-mode :mode "\\.json\\'")
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.gohtml\\'" . html-mode))

;; Tree-sitter Setup (Emacs 29+)
(when (treesit-available-p)
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (cmake "https://github.com/uyha/tree-sitter-cmake")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (make "https://github.com/alemuller/tree-sitter-make")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml"))))

(defun my/treesit-install-all ()
  "Install every missing grammar in `treesit-language-source-alist'."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

;; Formatting Hook (organize-imports wrapped: some servers lack it)
(defun my-eglot-format-and-organize ()
  "Format buffer on save."
  (when (eglot-managed-p)
    (eglot-format-buffer)
    (ignore-errors (eglot-code-action-organize-imports (point-min) (point-max)))))

(use-package eglot
  :ensure nil
  ;; Language servers (basedpyright needs uv, see init-python)
  :ensure-system-package
  ((gopls . "go install golang.org/x/tools/gopls@latest")
   (typescript-language-server . "npm install -g typescript-language-server typescript")
   (vscode-json-languageserver . "npm install -g vscode-json-languageserver")
   (basedpyright-langserver . "uv tool install basedpyright"))
  :hook ((go-mode . eglot-ensure)
         (json-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (js-ts-mode . eglot-ensure)
         (yaml-ts-mode . eglot-ensure)
         (html-mode . eglot-ensure)
         (css-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (c-or-c++-mode . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (tsx-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t
        eglot-report-progress t
        eglot-extend-to-xref t
        eglot-autoreconnect t
        eglot-connect-timeout 60
        eglot-sync-connect nil
        eglot-events-buffer-config '(:size 0 :format full)) ;; no event log = faster
  ;; Go: enable test tags
  (setq-default eglot-workspace-configuration
                '(:gopls (:buildFlags ["-tags=integration_test,unit_test"])))
  ;; Python: basedpyright
  (add-to-list 'eglot-server-programs
               '((python-ts-mode python-mode) . ("basedpyright-langserver" "--stdio"))))

(add-hook 'go-mode-hook
          (lambda () (add-hook 'before-save-hook #'my-eglot-format-and-organize nil t)))

;; Eglot keybindings
;; M-.: go to definition | M-,: go back
(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "M-'") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l i") #'eglot-find-implementation)
  (define-key eglot-mode-map (kbd "C-c l t") #'eglot-find-typeDefinition)
  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format-buffer)
  (define-key eglot-mode-map (kbd "C-c l d") #'eldoc-doc-buffer)
  (define-key eglot-mode-map (kbd "C-c l o") #'eglot-code-action-organize-imports))

;; Go: tabs, width 4
(add-hook 'go-mode-hook (lambda () (setq tab-width 4 indent-tabs-mode t)))
;; JSON: spaces, width 2
(add-hook 'json-mode-hook (lambda () (setq tab-width 2 indent-tabs-mode nil js-indent-level 2)))

;; Diagnostics & Spell Check
(defun my/flymake-toggle-diagnostics ()
  (interactive)
  (let ((diag-buffer (get-buffer (format "*Flymake diagnostics for `%s'*" (buffer-name)))))
    (if (and diag-buffer (get-buffer-window diag-buffer))
        (delete-windows-on diag-buffer)
      (flymake-show-buffer-diagnostics))))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") #'flymake-goto-prev-error))

(global-set-key (kbd "<f8>") #'my/flymake-toggle-diagnostics)
(global-set-key (kbd "<S-f8>") #'flymake-show-project-diagnostics)

;; Spell check: jinx (fast, async) if enchant is installed, else flyspell.
(if (executable-find "enchant-2")
    (use-package jinx
      :hook ((text-mode prog-mode conf-mode) . jinx-mode)
      :bind (("M-$" . jinx-correct)
             ("C-M-$" . jinx-languages)))
  (add-hook 'prog-mode-hook #'flyspell-prog-mode)  ; Comments/strings only
  (add-hook 'text-mode-hook #'flyspell-mode))

(provide 'init-lang)
;;; init-lang.el ends here
