;;; init-editing.el --- Navigation, windows, buffers and editing tools -*- lexical-binding: t; -*-

;; ======================================================
;; NAVIGATION, WINDOWS & EDITING
;; ======================================================

;; Key concepts:
;; - Point: cursor position
;; - Mark: selection start (C-SPC to set)
;; - Region: text between mark and point
;; - Kill ring: clipboard history

;; Basic movement
;; C-f/b/n/p: forward/back/next/previous char/line
;; M-f/b: forward/back word
;; C-a/e: beginning/end of line
;; M-a/e: beginning/end of sentence
;; M-m: Back to indentation (first char of the line)
;; M-</>: beginning/end of buffer
;; M-/: Auto-complete text

;; Selection & killing
;; C-SPC: set mark (start selection)
;; C-w: kill (cut) region
;; M-w: copy region
;; C-y: yank (paste)
;; M-y: cycle through kill ring
;; C-x h: select all

(setq set-mark-command-repeat-pop t) ; Keep popping marks with C-u C-SPC

;; --- WINDOW MANAGEMENT ---
;; Window concepts:
;; - Frame: OS window (entire Emacs window)
;; - Window: pane within frame (split)
;; - Buffer: file content (can be shown in multiple windows)

;; Quick window actions
(global-set-key (kbd "M-o") #'other-window)          ; Navigate windows

;; Smart close: close window or kill buffer if last window
(defun my/delete-window-or-kill-buffer ()
  "Delete window; if only one window, kill buffer instead."
  (interactive)
  (if (one-window-p)
      (kill-current-buffer)
    (delete-window)))
(global-set-key (kbd "M-0") #'my/delete-window-or-kill-buffer)

;; Undo/redo window changes
(winner-mode 1)
(global-set-key (kbd "C-c <left>") #'winner-undo)
(global-set-key (kbd "C-c <right>") #'winner-redo)

;; --- BUFFER MANAGEMENT ---
;; Ctrl-Tab: switch to last buffer (like Alt-Tab)
(defun my/switch-to-previous-buffer ()
  "Switch to previously used buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))
(global-set-key (kbd "C-<tab>") #'my/switch-to-previous-buffer)
(global-set-key (kbd "C-S-<tab>") #'previous-buffer)
(global-set-key (kbd "<C-iso-lefttab>") #'previous-buffer)

;; --- EDITING TOOLS ---
;; Undo/Redo with visualization
;; C-/: undo | C-?: redo | C-x u: visualize undo tree
(use-package undo-tree
  :demand t
  :config
  (setq undo-tree-auto-save-history nil)
  (global-undo-tree-mode))

;; Fast jumping with avy
(use-package avy
  :bind (("M-j" . avy-goto-char-in-line)
         ("M-J" . avy-goto-char-timer)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g c" . avy-goto-char)))

;; Expand selection incrementally
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; Multiple cursors (VS Code style)
(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-c C-S-c" . mc/edit-lines)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;; Edit all occurrences of symbol
(use-package iedit
  :bind ("C-c ;" . iedit-mode))

;; Show function breadcrumb in header
(use-package breadcrumb
  :demand t
  :config (breadcrumb-mode 1))

(provide 'init-editing)
;;; init-editing.el ends here
