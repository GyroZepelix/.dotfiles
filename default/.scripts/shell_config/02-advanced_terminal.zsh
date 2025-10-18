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
