# The following lines were added by compinstall
zstyle :compinstall filename '/home/dgjalic/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install

# Personal Configuration

SC="$HOME/.scripts/shell_config"

source $SC/advanced_terminal
source $SC/add_scripts_to_path
source $SC/zsh_bindkey
source $SC/neovim_default_editor

# Bob (neovim version manager) export path
export PATH=$PATH:/home/dgjalic/.local/share/bob/nvim-bin

# Export nix commands
export PATH=$PATH:$HOME/.nix-profile/bin

# Setup Starship
eval "$(starship init zsh)"

source /usr/share/nvm/init-nvm.sh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
