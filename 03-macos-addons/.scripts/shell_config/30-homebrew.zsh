# macOS Homebrew environment and zsh completions.
# `brew shellenv zsh` sets HOMEBREW_* vars, PATH/MANPATH/INFOPATH, and prepends
# Homebrew's zsh site-functions directory to fpath for completions.
if [[ "$(uname -s)" == "Darwin" && -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"

  # .zshrc runs compinit before shell_config modules, so refresh completion setup
  # after Homebrew prepends its zsh site-functions directory to fpath.
  if [[ -o interactive ]]; then
    autoload -Uz compinit
    compinit -i
  fi
fi
