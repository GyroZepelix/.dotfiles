#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ask() {
  local prompt="$1"
  local resp
  read -r -p "$prompt [y/N] " resp
  [[ "$resp" =~ ^[Yy]$ ]]
}

if [[ -z "${TERMUX_VERSION:-}" && "${PREFIX:-}" != *com.termux* ]]; then
  echo "This setup script is intended for Termux on Android."
  exit 1
fi

# --- Install base Termux packages ---
if ask "Install base Termux packages with pkg (git, tmux, neovim, stow, fzf, bat, zoxide, eza, yazi, starship, zsh, lazygit, git-delta, gitui, ripgrep, fd, nodejs)"; then
  echo -e "\n--- Installing base Termux packages..."
  pkg update
  pkg install -y git tmux neovim stow fzf bat zoxide eza yazi starship zsh lazygit git-delta gitui ripgrep fd nodejs
else
  echo "Skipping base Termux packages."
fi

# --- Symlink default and Termux-specific dotfiles ---
if ask "Symlink default and Termux-specific dotfiles with stow (00-default, 05-termux)"; then
  echo -e "\n--- Symlinking 00-default and 05-termux..."
  mkdir -p "$HOME/.config"
  stow 00-default
  mkdir -p "$HOME/.config"
  stow 05-termux
  if command -v termux-reload-settings >/dev/null 2>&1; then
    termux-reload-settings
  fi
else
  echo "Skipping default and Termux-specific dotfiles symlinking."
fi

# --- Symlink agentic LLM dotfiles ---
if ask "Symlink agentic LLM dotfiles with stow (02-agentic-llms)"; then
  echo -e "\n--- Symlinking 02-agentic-llms..."
  mkdir -p "$HOME/.config"
  stow 02-agentic-llms
else
  echo "Skipping agentic LLM dotfiles symlinking."
fi

# --- Clone Neovim config ---
if ask "Clone Neovim config (GyroZepelix/init.lua) into ~/.config/nvim"; then
  echo -e "\n--- Cloning Neovim config..."
  if [[ -e "$HOME/.config/nvim" ]]; then
    echo "Neovim config already exists at ~/.config/nvim"
  else
    mkdir -p "$HOME/.config"
    git clone https://github.com/GyroZepelix/init.lua.git "$HOME/.config/nvim"
  fi
else
  echo "Skipping Neovim config clone."
fi

# --- Install TPM for Tmux ---
if ask "Install TPM for Tmux"; then
  echo -e "\n--- Installing TPM for Tmux..."
  mkdir -p "$HOME/.config/tmux/plugins"
  if [[ -d "$HOME/.config/tmux/plugins/tpm" ]]; then
    echo "TPM already exists at ~/.config/tmux/plugins/tpm"
  else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  fi
else
  echo "Skipping TPM installation."
fi

# --- Change default shell to ZSH ---
if ask "Change default shell to ZSH"; then
  echo -e "\n--- Changing default shell to ZSH..."
  chsh -s zsh
else
  echo "Skipping shell change."
fi

echo -e "\nDone. Restart Termux, or run: exec zsh"
