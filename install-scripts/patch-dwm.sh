# --- Install base Arch packages ---
read -p "Install base packages for dwm? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  echo -e "\n--- Installing base arch packages..."
  sudo pacman -Sy brigtnessctl dunst xorg-xsetroot
else
  echo "Skipping base Arch packages."
fi

--- Install AUR packages ---
read -p "Install AUR packages (kanata-bin, etc)? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  echo -e "\n--- Installing AUR packages..."
  yay -S dwmbar-git
else
  echo "Skipping AUR packages."
fi

# --- Symlink dotfiles ---
read -p "Symlink dwm dotfiles with stow? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  echo -e "\n--- Symlinking everything..."
  stow dwm-addons
else
  echo "Skipping symlinking."
fi
