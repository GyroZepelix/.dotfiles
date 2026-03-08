eval "$(starship init zsh)"
source /usr/share/nvm/init-nvm.sh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
