#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ask() {
  local prompt="$1"
  local resp
  read -r -p "$prompt [y/N] " resp
  [[ "$resp" =~ ^[Yy]$ ]]
}

if [[ ! -r /etc/os-release ]] || ! grep -qE '^ID="?fedora"?$' /etc/os-release; then
  echo "This setup script is intended for Fedora."
  exit 1
fi

# --- Install base Fedora packages ---
if ask "Install base Fedora packages with dnf (git, tmux, neovim, kitty, stow, fzf, bat, zoxide, eza, lazygit, git-delta, gitui, zsh, nodejs, npm, plus starship and yazi from COPR)"; then
  echo -e "\n--- Installing base Fedora packages..."
  sudo dnf install -y git tmux neovim kitty stow fzf bat zoxide eza lazygit git-delta gitui zsh nodejs npm
  if ! dnf copr --help >/dev/null 2>&1; then
    # dnf5 (Fedora 41+) ships the copr command in dnf5-plugins; dnf4 in dnf-plugins-core.
    sudo dnf install -y dnf5-plugins || sudo dnf install -y dnf-plugins-core
  fi
  sudo dnf copr enable -y atim/starship
  sudo dnf copr enable -y lihaohong/yazi
  sudo dnf install -y starship yazi
else
  echo "Skipping base Fedora packages."
fi

# --- Install JetBrains Mono Nerd Font ---
if ask "Install JetBrains Mono Nerd Font into ~/.local/share/fonts"; then
  echo -e "\n--- Installing JetBrains Mono Nerd Font..."
  font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
  if compgen -G "$font_dir/*.[ot]tf" >/dev/null; then
    echo "JetBrains Mono Nerd Font already exists at $font_dir"
  else
    mkdir -p "$font_dir"
    font_archive="$(mktemp)"
    curl -fL --retry 3 -o "$font_archive" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    tar -xJf "$font_archive" -C "$font_dir"
    rm -f "$font_archive"
  fi
  fc-cache -f
else
  echo "Skipping JetBrains Mono Nerd Font."
fi

# --- Symlink default dotfiles ---
if ask "Symlink default dotfiles with stow"; then
  echo -e "\n--- Symlinking 00-default..."
  mkdir -p "$HOME/.config"
  stow 00-default
else
  echo "Skipping default dotfiles symlinking."
fi

# --- Install Loremaster ---
if ask "Install Loremaster (lore CLI via go install)"; then
  echo -e "\n--- Installing Loremaster..."
  command -v go >/dev/null 2>&1 || sudo dnf install -y golang
  GOPATH="${GOPATH:-$HOME/.go}" go install github.com/GyroZepelix/loremaster/cmd/lore@latest
else
  echo "Skipping Loremaster."
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
  command -v zsh >/dev/null 2>&1 || sudo dnf install -y zsh
  chsh -s "$(command -v zsh)"
else
  echo "Skipping shell change."
fi

# --- Kanata setup ---
if ask "Set up Kanata (cargo install, uinput, groups, udev, systemd user service)"; then
  echo -e "\n--- Setting up Kanata..."
  echo -e "\n---/--- Installing Kanata with cargo (builds from source, may take a few minutes)..."
  command -v cargo >/dev/null 2>&1 || sudo dnf install -y cargo
  cargo install kanata
  echo -e "\n---/--- Applying 'uinput' and 'input' groups to $USER..."
  getent group uinput >/dev/null || sudo groupadd --system uinput
  sudo usermod -aG uinput,input "$USER"
  echo -e "\n---/--- Adding udev rule for uinput..."
  echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/kanata.rules
  echo -e "\n---/--- Loading uinput on boot..."
  echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf
  echo -e "\n---/--- Installing systemd user service for Kanata..."
  mkdir -p "$HOME/.config/systemd/user"
  sed 's#^ExecStart=/usr/bin/kanata#ExecStart=%h/.cargo/bin/kanata#' \
    install-scripts/systemd-services/kanata.service >"$HOME/.config/systemd/user/kanata.service"
  systemctl --user daemon-reload
  systemctl --user enable kanata.service
  echo -e "\n---/--- Please reboot your system for Kanata to work properly!"
else
  echo "Skipping Kanata setup."
fi

echo -e "\nDone. Restart your terminal, or run: exec zsh"
