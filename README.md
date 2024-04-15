# My dotfiles

This directory contains the dotfiles for my system
I currently use a combination of `tmux` and `neovim` as a PDE, combined with
`kitty` as my terminal emulator because I dont like the extra clutter Konsole
on KDE has.

## Requirements

Ensure you have the following installed on your system

### Git

```
pacman -S git
```

### Stow

```
pacman -S stow
```

### Xclip

```
pacman -S xclip
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone git@github.com/GyroZepelix/.dotfiles.git --recursive
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
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
