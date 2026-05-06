#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ask() {
  local prompt="$1"
  local resp
  read -r -p "$prompt [y/N] " resp
  [[ "$resp" =~ ^[Yy]$ ]]
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script is intended for macOS (Darwin)."
  exit 1
fi

# Apple Silicon Homebrew is normally here. Load it when installed but not yet in PATH.
if ! command -v brew >/dev/null 2>&1 && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif ! command -v brew >/dev/null 2>&1 && [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  if ask "Homebrew is not installed. Install Homebrew"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo "Homebrew is required for package installation. Skipping package sections."
  fi
fi

# --- Install base macOS packages ---
if command -v brew >/dev/null 2>&1 && ask "Install base macOS packages with Homebrew (git, tmux, neovim, kitty, stow, fzf, bat, zoxide, eza, starship, zsh)"; then
  echo -e "\n--- Installing base macOS packages..."
  brew update
  brew install git tmux neovim stow fzf bat zoxide eza starship zsh
  brew install --cask kitty font-jetbrains-mono-nerd-font
else
  echo "Skipping base macOS packages."
fi

# --- Optional Node version manager ---
if command -v brew >/dev/null 2>&1 && ask "Install nvm (Node Version Manager)"; then
  echo -e "\n--- Installing nvm..."
  brew install nvm
  mkdir -p "$HOME/.nvm"
else
  echo "Skipping nvm."
fi

# --- Symlink default dotfiles ---
if ask "Symlink default dotfiles with stow"; then
  echo -e "\n--- Symlinking 00-default..."
  stow 00-default
else
  echo "Skipping default dotfiles symlinking."
fi

# --- Symlink macOS-specific dotfiles ---
if ask "Symlink macOS-specific dotfiles with stow"; then
  echo -e "\n--- Symlinking 03-macos-addons..."
  stow 03-macos-addons
else
  echo "Skipping macOS-specific dotfiles symlinking."
fi

# --- Karabiner-Elements ---
if command -v brew >/dev/null 2>&1 && ask "Install Karabiner-Elements for macOS keyboard remapping"; then
  echo -e "\n--- Installing Karabiner-Elements..."
  brew install --cask karabiner-elements
  cat <<'MSG'

Karabiner config is provided by 03-macos-addons/.config/karabiner/karabiner.json.
After stowing 03-macos-addons, open Karabiner-Elements once and grant the requested macOS permissions.
MSG
else
  echo "Skipping Karabiner-Elements."
fi

# --- Install TPM for Tmux ---
if ask "Install TPM for Tmux"; then
  echo -e "\n--- Installing TPM for Tmux..."
  if [[ -d "$HOME/.config/tmux/plugins/tpm" ]]; then
    echo "TPM already exists at ~/.config/tmux/plugins/tpm"
  else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  fi
else
  echo "Skipping TPM installation."
fi

# --- Change default shell to ZSH ---
if command -v brew >/dev/null 2>&1 && ask "Change default shell to Homebrew ZSH"; then
  echo -e "\n--- Changing default shell to ZSH..."
  brew_zsh="$(brew --prefix)/bin/zsh"
  if [[ ! -x "$brew_zsh" ]]; then
    echo "Homebrew zsh not found at $brew_zsh. Install zsh first."
    exit 1
  fi
  if ! grep -qxF "$brew_zsh" /etc/shells; then
    echo "$brew_zsh" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$brew_zsh"
else
  echo "Skipping shell change."
fi

echo -e "\nDone. Restart your terminal, or run: exec zsh"
