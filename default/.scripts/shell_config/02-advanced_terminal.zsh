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
alias dcs="docker compose ps"

# Neovim
alias n="nvim"

# Other
alias c="clear"

if [ -z "$DISABLE_ZOXIDE" ]; then
  eval "$(zoxide init zsh --cmd cd)"
fi
