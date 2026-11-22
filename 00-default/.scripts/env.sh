# Shared environment loader: plain exports and PATH additions for every shell.
#
# Sourced by ~/.zshenv (every zsh, including `ssh host 'cmd'`), by
# ~/.scripts/shell_config/06-env.zsh (interactive zsh), and by Pi's
# `shellCommandPrefix` (`bash -c` tool commands). It sources every
# ~/.scripts/env.d/*.sh drop-in in name order; each stow package contributes
# its own drop-in, numbered like shell_config (00-default.sh, 20-..., 31-...).
#
# Keep this file and the drop-ins POSIX sh, cheap, idempotent, and silent:
# only variable and PATH exports, no aliases, prompts, completion, or output.

# path_prepend DIR: move DIR to the front of PATH (adds it when missing).
path_prepend() {
  [ -n "$1" ] || return 0
  __dotfiles_p=":$PATH:"
  while :; do
    case $__dotfiles_p in
      *":$1:"*) __dotfiles_p="${__dotfiles_p%%":$1:"*}:${__dotfiles_p#*":$1:"}" ;;
      *) break ;;
    esac
  done
  __dotfiles_p=${__dotfiles_p#:}
  __dotfiles_p=${__dotfiles_p%:}
  PATH="$1${__dotfiles_p:+:$__dotfiles_p}"
  unset __dotfiles_p
}

# path_append DIR: add DIR to the end of PATH unless it is already present.
path_append() {
  [ -n "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

# Pattern matching on the long PATH is about twice as slow in a UTF-8 locale,
# and Pi pays this cost on every command, so load the drop-ins under LC_ALL=C
# and restore the caller's LC_ALL afterwards (drop-ins must not set LC_ALL).
__dotfiles_lc_all=${LC_ALL-__dotfiles_unset__}
LC_ALL=C
for __dotfiles_env in "$HOME"/.scripts/env.d/*.sh; do
  if [ -r "$__dotfiles_env" ]; then
    . "$__dotfiles_env"
  fi
done
if [ "$__dotfiles_lc_all" = __dotfiles_unset__ ]; then
  unset LC_ALL
else
  LC_ALL=$__dotfiles_lc_all
fi
unset __dotfiles_env __dotfiles_lc_all
unset -f path_prepend path_append
export PATH
