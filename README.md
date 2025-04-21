# My dotfiles

This directory contains the dotfiles for my system
I currently use a combination of `tmux` and `neovim` as a PDE, combined with
`kitty` as my terminal emulator because I dont like the extra clutter Konsole
on KDE has.

## Requirements
There are two options of installing the requirements, with or without an installation script.

Ensure you have the following installed on your system
```
git
tmux
neovim
kitty
Nerdfont - JetbrainsMono Nerd Font
stow
fzf
bat
zoxide
eza
taskwarrior
timewarrior
taskopen
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```bash
$ git clone https://github.com/GyroZepelix/.dotfiles.git --recursive
$ cd dotfiles
```

Install the dependencies using the arch install script

```bash
$ cd install-scripts
$ chmod +x arch-quick-setup.sh
$ ./arch-quick-setup.sh
$ cd ..
```

then use GNU stow to create symlinks ( Only when not using the script )

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
