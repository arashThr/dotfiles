;;; init-python.el --- Python: formatting, envrc, run/test helpers -*- lexical-binding: t; -*-

;; ======================================================
;; PYTHON
;; ======================================================

;; Format on save with ruff (isort + format)
(use-package apheleia
  :hook (python-ts-mode . apheleia-mode)
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

;; Per-project env via .envrc (uses the project's .venv for LSP/REPL/compile)
(use-package envrc
  :hook (after-init . envrc-global-mode))

(defun my/python-run-file ()
  "Run current file with `uv run' (interactive, so input() works)."
  (interactive)
  (save-buffer)
  (compile (concat "uv run " (shell-quote-argument buffer-file-name)) t))

(defun my/python-test ()
  "Run pytest from the project root."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (compile "uv run pytest -q" t)))

(defun my/python-scratch ()
  "Open a new throwaway script in ~/Documents/workspace/scratch/."
  (interactive)
  (let ((dir (expand-file-name "~/Documents/workspace/scratch/")))
    (make-directory dir t)
    (find-file (expand-file-name (format-time-string "%Y%m%d-%H%M%S.py") dir))
    (when (= (buffer-size) 0)
      (insert "# /// script\n# requires-python = \">=3.12\"\n# dependencies = []\n# ///\n\n"))))
(global-set-key (kbd "C-c n p") #'my/python-scratch)

(with-eval-after-load 'python
  (define-key python-ts-mode-map (kbd "C-c C-k") #'my/python-run-file)
  (define-key python-ts-mode-map (kbd "C-c C-t") #'my/python-test)
  (setq python-shell-interpreter "python3"
        python-indent-guess-indent-offset-verbose nil))

(provide 'init-python)
;;; init-python.el ends here
