#!/bin/bash

cd ..

# --- Install base Arch packages ---
read -p "Install base Arch packages (git, tmux, neovim, etc)? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Installing base arch packages..."
    sudo pacman -Sy git tmux neovim kitty stow fzf bat zoxide eza yazi starship nvm rustup zsh ttf-jetbrains-mono-nerd
else
    echo "Skipping base Arch packages."
fi

# --- Install AUR packages ---
read -p "Install AUR packages (task, timew, kanata-bin, etc)? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Installing AUR packages..."
    yay -S task timew kanata-bin
else
    echo "Skipping AUR packages."
fi

# --- Symlink dotfiles ---
read -p "Symlink dotfiles with stow? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Symlinking everything..."
    stow .
else
    echo "Skipping symlinking."
fi

# --- Install TPM for Tmux ---
read -p "Install TPM for Tmux? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Installing TPM for Tmux..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "Skipping TPM installation."
fi

# --- Change default shell to ZSH ---
read -p "Change default shell to ZSH? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Changing default shell to ZSH..."
    chsh -s /usr/bin/zsh
else
    echo "Skipping shell change."
fi

# --- Kanata setup ---
read -p "Set up Kanata (uinput, groups, udev, systemd)? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Setting up Kanata..."
    echo -e "\n---/--- Applying 'uinput' and 'input' roles to $USER..."
    sudo groupadd uinput
    sudo usermod -aG uinput,input "$USER"
    echo -e "\n---/--- Adding udev rule for uinput..."
    echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/kanata.rules
    echo -e "\n---/--- Loading uinput on boot..."
    echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf
    echo -e "\n---/--- Installing Systemd for Kanata..."
    sudo cp install-scripts/systemd-services/kanata-hidden.service /etc/systemd/user
    systemctl --user daemon-reload
    systemctl --user enable kanata-hidden.service
    echo -e "\n---/--- Please reboot your system for Kanata to work properly!"
else
    echo "Skipping Kanata setup."
fi

read -p "Set up Taskwarrior sync? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
    echo -e "\n--- Setting up Taskwarrior sync"
    sudo cp install-scripts/systemd-services/task-sync.service /etc/systemd/user
    sudo cp install-scripts/systemd-services/task-sync.timer /etc/systemd/user
    systemctl --user daemon-reload
    systemctl --user enable task-sync.service
    systemctl --user enable task-sync.timer
    systemctl --user start task-sync.service
    systemctl --user start task-sync.timer
    echo -e "\n--- Please setup your credentials for taskw sync in .taskrc!"
    echo -e "\n--- ( For more information run 'man task-sync' )"
else
    echo "Skipping Timewarrior sync setup."
fi


