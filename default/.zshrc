fpath=($HOME/.scripts/completion_zsh $fpath)
# The following lines were added by compinstall
zstyle :compinstall filename '/home/dgjalic/.zshrc'

autoload -Uz compinit
compinit
bindkey -v
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install

# Personal Configuration

SC="$HOME/.scripts/shell_config"

for config_file in "$SC/"*.zsh; do
  if [ -f "$config_file" ]; then
    source "$config_file"
  fi
done
unset config_file

# Use neovim as manpage resolver
export MANPAGER='nvim +Man!'

export GOPATH="$HOME/.go"
mkdir -p $HOME/.go/bin

# set UNIQUE paths
typeset -U PATH
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$PATH:$GOPATH/bin"

# Export default path of obsidian
# export OBSIDIAN_VAULT_PATH=...
export OBSIDIAN="$HOME/Documents/obsidian"

# Setup Starship
eval "$(starship init zsh)"

source /usr/share/nvm/init-nvm.sh

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

export PATH="$PATH:$HOME/.go/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# bun completions
[ -s "/home/dgjalic/.bun/_bun" ] && source "/home/dgjalic/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
