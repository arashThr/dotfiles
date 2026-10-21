;;; init-ai.el --- AI agents in chat buffers (agent-shell) -*- lexical-binding: t; -*-

;; ======================================================
;; AI AGENTS
;; ======================================================

;; agent-shell talks to agent CLIs over ACP (Agent Client Protocol).
;; Each agent logs in through its own CLI; run it once in a terminal:
;;   claude   (Claude subscription; claude-agent-acp reuses that login)
;;   copilot  (GitHub account with Copilot)
;;   grok     (xAI account; installs to ~/.grok/bin)
;;
;; In the shell: C-c C-v pick model, C-c C-m pick mode, C-c C-c interrupt.

;; The Grok installer doesn't always put ~/.grok/bin on PATH.
(add-to-list 'exec-path (expand-file-name "~/.grok/bin"))

(use-package agent-shell
  :ensure-system-package
  ((claude-agent-acp . "npm install -g @agentclientprotocol/claude-agent-acp")
   (copilot . "npm install -g @github/copilot")
   (grok . "curl -fsSL https://x.ai/cli/install.sh | bash"))
  :bind (("C-c a a" . agent-shell)                    ;; open/switch to the project's chat
         ("C-c a n" . agent-shell-new-shell)          ;; start another chat
         ("C-c a t" . agent-shell-toggle)             ;; show/hide the chat window
         ("C-c a s" . agent-shell-send-dwim)          ;; send region (or error at point)
         ("C-c a f" . agent-shell-send-file)          ;; add a file as context
         ("C-c a c" . agent-shell-prompt-compose)     ;; write a long prompt in its own buffer
         ("C-c a w" . agent-shell-new-worktree-shell)) ;; isolated chat in a new git worktree
  :config
  ;; Only offer the three agents we use; Claude is preselected in the picker.
  (setq agent-shell-agent-configs
        (list (agent-shell-anthropic-make-claude-code-config)
              (agent-shell-github-make-copilot-config)
              (agent-shell-xai-make-grok-config))
        agent-shell-preferred-agent-config '(preselect . claude-code)))

(provide 'init-ai)
;;; init-ai.el ends here
