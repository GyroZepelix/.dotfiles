command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
[ -s /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ "$(uname -s)" == "Darwin" ]]; then
  export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
else
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
