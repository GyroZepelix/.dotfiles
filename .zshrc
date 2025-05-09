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

source $SC/advanced_terminal
source $SC/add_scripts_to_path
source $SC/zsh_bindkey
source $SC/neovim_default_editor

# Use neovim as manpage resolver
export MANPAGER='nvim +Man!'

# Bob (neovim version manager) export path
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin

# Export nix commands
export PATH=$PATH:$HOME/.nix-profile/bin

export PATH=$PATH:$HOME/.local/bin

# Export default path of obsidian
# export OBSIDIAN_VAULT_PATH=...
export OBSIDIAN="$HOME/Documents/obsidian"

# Setup Starship
eval "$(starship init zsh)"

source /usr/share/nvm/init-nvm.sh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

export PATH="$PATH:$HOME/.go/bin"
