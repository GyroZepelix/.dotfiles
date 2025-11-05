#!/bin/bash

# Smarter alternatives
alias ls="eza --icons always"
alias tree="eza --icons --tree --git-ignore"
alias treegit="eza --icons --tree"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"

# Docker compose aliases
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs"

# Taskwarrior and timewarrior aliases
alias t="task"
alias tw="timew"
alias tws="timew summary"
alias twp="timew stop"
alias twc="timew continue"
alias twcl="timew continue @1"
alias twms="timew summary :month :ids"
alias twm="timew month"
alias twml="timew month :lastmonth"

# Neovim
alias n="nvim"

# Other
alias c="clear"

eval "$(zoxide init zsh --cmd cd)"
