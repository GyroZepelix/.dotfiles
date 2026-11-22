# Plain exports and PATH additions live in ~/.scripts/env.d/*.sh, loaded by
# ~/.scripts/env.sh (also sourced from ~/.zshenv). Load it again here so login
# shells restore the dotfiles PATH order after path_helper and ~/.zprofile.
typeset -U PATH
if [[ -r "$HOME/.scripts/env.sh" ]]; then
  emulate sh -c '. "$HOME/.scripts/env.sh"'
fi
[[ -n "$GOPATH" ]] && mkdir -p "$GOPATH/bin"
