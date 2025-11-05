# --- Symlink dotfiles ---
read -p "Are you sure you want to continue with patching deprecated configs? There are ZERO guarantees it will work [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  echo -e "\n--- Continuing with patching depreacted options..."
else
  exit 0
fi

# --- Symlink dotfiles ---
read -p "Symlink deprecated dotfiles with stow? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  echo -e "\n--- Symlinking everything..."
  stow deprecated
else
  echo "Skipping symlinking."
fi

# --- Setup taskwarrior sync ---
read -p "Set up Taskwarrior sync? [y/N] " resp
if [[ "$resp" =~ ^[Yy]$ ]]; then
  yay -S task timew
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
