# ── Completion ────────────────────────────────────────────────
fpath=($HOME/.scripts/completion_zsh $fpath)
zstyle :compinstall filename '/home/dgjalic/.zshrc'
autoload -Uz compinit
compinit
bindkey -v

# ── History ───────────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ── Personal shell config ────────────────────────────────────
SC="$HOME/.scripts/shell_config"
for config_file in "$SC/"*.zsh; do
  if [ -f "$config_file" ]; then
    source "$config_file"
  fi
done
unset config_file

# ── Environment variables ────────────────────────────────────
export MANPAGER='nvim +Man!'
export GOPATH="$HOME/.go"
mkdir -p "$GOPATH/bin"
export OBSIDIAN="$HOME/Documents/obsidian"
export BUN_INSTALL="$HOME/.bun"

# ── PATH (typeset -U deduplicates) ───────────────────────────
typeset -U PATH
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$GOPATH/bin"

# ── Tool initialisation ─────────────────────────────────────
eval "$(starship init zsh)"
source /usr/share/nvm/init-nvm.sh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
