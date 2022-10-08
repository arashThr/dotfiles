# Arash's custom theme

NEWLINE=$'\n'
PROMPT='%F{green}[%T]%f %F{240}(%n)%f %B%F{cyan}%~%f%b $(git_prompt_info)${NEWLINE}%F{red}>%f '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN=""

