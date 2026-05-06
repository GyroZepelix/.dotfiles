# ── Completion ────────────────────────────────────────────────
fpath=($HOME/.scripts/completion_zsh $fpath)
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# ── Personal shell config ────────────────────────────────────
SC="$HOME/.scripts/shell_config"
for config_file in "$SC/"*.zsh; do
  if [ -f "$config_file" ]; then
    source "$config_file"
  fi
done
unset config_file
