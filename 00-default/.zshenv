# Read by every zsh, including non-interactive `ssh host 'cmd'` and `zsh -c`.
# Keep it silent and cheap: aliases, prompt, completion, and tool init belong
# in ~/.zshrc and ~/.scripts/shell_config/*.zsh.

# Machine-specific setup that is not tracked in the dotfiles repo.
if [[ -r "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi

# Shared POSIX exports and PATH additions (~/.scripts/env.d/*.sh).
if [[ -r "$HOME/.scripts/env.sh" ]]; then
  emulate sh -c '. "$HOME/.scripts/env.sh"'
fi
