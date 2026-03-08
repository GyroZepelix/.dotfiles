export GOPATH="$HOME/.go"
mkdir -p "$GOPATH/bin"
export OBSIDIAN="$HOME/Documents/obsidian"
export BUN_INSTALL="$HOME/.bun"

typeset -U PATH
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$GOPATH/bin"
