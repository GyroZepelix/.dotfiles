# My dotfiles

This directory contains the dotfiles for my system
I currently use a combination of `tmux` and `neovim` as a PDE, combined with
`kitty` as my terminal emulator because I dont like the extra clutter Konsole
on KDE has.

## Requirements
There are two options of installing the requirements, with or without [Nix](https://nixos.org/)
If you don't use [Nix](https://nixos.org/) then install the dependencies manualy and skip the Nix section in `Installation`

Ensure you have the following installed on your system
```
git
tmux
neovim
kitty
Nerdfont - JetbrainsMono Nerd Font
```
... these ones will get installed by nix if you use it

```
stow
fzf
bat
zoxide
eza
taskwarrior
timewarrior
```

> **_NOTE:_** The reason why some packages are included in the nix install script and some not is simply because I expect the above ones to already be installed before installing the dotfiles on your systems local package manager.

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```bash
$ git clone git@github.com/GyroZepelix/.dotfiles.git --recursive
$ cd dotfiles
```

install the dependencies using Nix by executing `nix-install-packages.sh`

```bash
$ chmod +x nix-install-packages.sh
$ ./nix-install-packages.sh
```

then use GNU stow to create symlinks

```bash
$ stow .
```

next install [TPM](https://github.com/tmux-plugins/tpm) and open up tmux and press `prefix + I` to install the plugins
```bash
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
$ tmux
```

finally open up neovim and wait for lazy to install all the plugins

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
