# 00-default exports, loaded by ~/.scripts/env.sh (POSIX sh, silent).

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

export GOPATH="$HOME/.go"
export OBSIDIAN="$HOME/Documents/obsidian"
export BUN_INSTALL="$HOME/.bun"

path_append "$HOME/.scripts/bin"
path_prepend "$BUN_INSTALL/bin"
path_append "$HOME/.local/bin"
path_append "$HOME/.lmstudio/bin"
path_append "$GOPATH/bin"
