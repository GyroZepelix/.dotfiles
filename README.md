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
fcron (or any cron implementation)
rustup
kanata
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

## Other features
### Taskwarrior and Timewarrior syncing
Using Taskwarrior and Timewarrior with multiple devices can be abit tricky seeing as they are not one unified app that can easly be synced.
Because of that I needed to employ two different pieces of software to keep both logging techniques synced on all of my devices.
For Taskwarrior I am using [taskchampion-sync-server](https://github.com/GothenburgBitFactory/taskchampion-sync-server) by GothenburgBitFactory while for Timewarrior I use [timew-sync-server](https://github.com/timewarrior-synchronize/timew-sync-server).
They are two pieces of software working quite so sadly its not something that can be integrated together quite easly, but seeing how much both of them help me with productivity, it's an evil deemed neccesary. ( Until I stumble on something that could fit my workstyle better that is :D )

For the backend you can find the way I have it hosted on my [server dockerfiles repositry (WIP)](), while for local auto syncing I have made two simple scripts under `.config/task/scripts/...` that can be added to your chosen implementation of cron to run however often you want.
```bash
$ fcrontab -e

# I have mine set to run every 15 minutes, which might be too often!
*/15 * * * * $HOME/.config/task/scripts/cron-update.sh
*/15 * * * * $HOME/.config/task/scripts/timew-cron-update.sh
```

### Keyboard remaping using Kanata
Using Kanata I am able to remap the Capslock key to increase the efficiency I am able to move and use shortcuts. For example I remapped Capslock to work as Esc on a quick tap, but work as ctrl when held down.
Other examples can be found inside `.config/kanata/kanata.kdb`.

For installation please either follow the [Kanata official Github page](https://github.com/jtroo/kanata) or use one of the provided installation scripts inside `install-scripts`!


## Contributions
Your contributions are always welcome! If you would like to improve the dotfiles or have suggestions, please feel free to:

1. Fork the repository.
2. Create a new branch with your improvements (git checkout -b feature-xyz).
3. Make your changes or additions.
4. Commit your changes (git commit -am 'Add some feature').
5. Push to the branch (git push origin feature-xyz).
6. Create a new Pull Request.

Please ensure your commit messages are clear and the code changes are well-documented. Code reviews and discussions about improvements are highly appreciated.
