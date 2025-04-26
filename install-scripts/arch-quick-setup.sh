#!/bin/bash

echo "\n --- Installing base arch packages..."
sudo pacman -Sy git tmux neovim kitty stow fzf bat zoxide eza yazi starship nvm fcron
echo "\n --- Installing AUR packages..."
yay -S brave-bin task timew taskopen 
echo "\n --- Symlinking everything..."
cd ..
stow .
echo "\n --- Installing TPM for Tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "\n --- Changing default shell to ZSH..."
chsh -s /bin/zsh
