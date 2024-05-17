# My dotfiles

This directory contains the dotfiles for my system
I currently use a combination of `tmux` and `neovim` as a PDE, combined with
`kitty` as my terminal emulator because I dont like the extra clutter Konsole
on KDE has.

## Requirements

Ensure you have the following installed on your system

```
git
stow
tmux
fzf
bat
zoxide
eza
Nerdfont - JetbrainsMono Nerd Font
[tpm](https://github.com/tmux-plugins/tpm) - git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
[packer](https://github.com/wbthomason/packer.nvim) - git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
kitty
taskwarrior
timewarrior
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```bash
$ git clone git@github.com/GyroZepelix/.dotfiles.git --recursive
$ cd dotfiles
```

then use GNU stow to create symlinks

```bash
$ stow .
```

next open up tmux and press `prefix + I` to install the plugins
```bash
$ tmux
```

finally open up neovim and run `:PackerInstall` to install the plugins

```bash
$ nvim
```

## Contributions
Your contributions are always welcome! If you would like to improve the dotfiles or have suggestions, please feel free to:

1. Fork the repository.
2. Create a new branch with your improvements (git checkout -b feature-xyz).
3. Make your changes or additions.
4. Commit your changes (git commit -am 'Add some feature').
5. Push to the branch (git push origin feature-xyz).
6. Create a new Pull Request.

Please ensure your commit messages are clear and the code changes are well-documented. Code reviews and discussions about improvements are highly appreciated.
