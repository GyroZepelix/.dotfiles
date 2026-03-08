# My dotfiles

A modular dotfiles repository for Arch Linux systems, featuring a modern tmux + neovim Personal Development Environment (PDE) with kitty terminal emulator. Built with flexibility and productivity in mind, using GNU Stow for symlink management.

## Features

### Core Setup
- **Terminal Multiplexer:** tmux with [TPM](https://github.com/tmux-plugins/tpm) and custom prefix (Ctrl+s)
- **Terminal Emulator:** kitty with minimal padding
- **Text Editor:** neovim (managed as git submodule)
- **IDE Integration:** Comprehensive IdeaVim configuration with LSP-like mappings
- **Shell:** ZSH with modular configuration system
- **Prompt:** Starship with minimal left prompt and rich right-side information

### Modern CLI Tools
- **eza** - Modern ls replacement with icons and git integration
- **zoxide** - Smart directory jumping (cd replacement)
- **bat** - Syntax-highlighted cat alternative
- **fzf** - Fuzzy finder for files and command history
- **yay** - AUR helper for Arch Linux
- **gitui** - Terminal UI for git with vim keybindings

### Theme
Currently using **Catppuccin Mocha** theme across:
- tmux
- kitty
- *(Commented alternatives: Dracula, Rose Pine)*

### Productivity Features
- **Kanata Keyboard Remapping:**
  - Caps Lock → Esc (tap) / Ctrl (hold)
  - hjkl → Arrow keys when Caps Lock held
  - Runs as systemd service

- **Workmode Script:**
  - Blocks distracting websites (YouTube, Twitter, LinkedIn, Instagram, Facebook)
  - Interactive WORK/WASTE mode toggle

- **Git Integration:**
  - Open current repo in browser with `open-github.sh`
  - gitui for terminal-based git workflow

### Modular Architecture
Four distinct modules managed via GNU Stow, prefixed with numbers to communicate load order:
1. **00-default** - Core configurations for daily use
2. **01-dwm-addons** - Additional configs for DWM window manager
3. **02-agentic-llms** - Claude Code and OpenCode configurations
4. **99-deprecated** - Legacy Taskwarrior/Timewarrior configs (optional)

## Requirements

### Core Dependencies
The following are installed automatically by the `arch-quick-setup.sh` script:

**Essential:**
```
git
tmux
neovim
kitty
stow
zsh
ttf-jetbrains-mono-nerd (JetBrains Mono Nerd Font)
```

**Modern CLI Tools:**
```
fzf
bat
zoxide
eza
yay
starship
gitui
```

**Productivity:**
```
kanata-bin (AUR)
```

**Development:**
```
nvm (Node Version Manager)
sdkman (JVM tool management)
```

### Optional Dependencies
For **01-dwm-addons** module:
```
dwm
brightnessctl
dunst
xorg-xsetroot
dwmbar-git (AUR)
```

For **99-deprecated** module:
```
taskwarrior
timewarrior
taskopen
fcron (or any cron implementation)
```

## Installation

### Quick Setup (Recommended)

Clone the repository with submodules:

```bash
cd ~
git clone https://github.com/GyroZepelix/.dotfiles.git --recursive
cd .dotfiles
```

Run the automated installation script:

```bash
cd install-scripts
chmod +x arch-quick-setup.sh
./arch-quick-setup.sh
```

The script will:
- Install all core dependencies
- Symlink default dotfiles using GNU Stow
- Install TPM (Tmux Plugin Manager)
- Set up Kanata with systemd service
- Change default shell to ZSH
- Optionally set up Taskwarrior sync

### Manual Installation

If you prefer manual installation:

```bash
cd ~/.dotfiles
stow 00-default
```

Install TPM manually:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Open tmux and install plugins:

```bash
tmux
# Press Ctrl+s then I to install plugins
```

Open neovim to install plugins:

```bash
nvim
# Wait for Lazy to install all plugins
```

### Post-Installation

**Important:** Reboot your system for Kanata keyboard remapping to work properly.

```bash
reboot
```

## Optional Modules

### DWM Window Manager

Install additional configurations for DWM:

```bash
cd install-scripts
chmod +x patch-dwm.sh
./patch-dwm.sh
```

This adds:
- `.xinitrc` with dunst, dwmbar, and dwm startup
- dwmbar status bar configuration
- DWM-specific shell aliases

### Deprecated Features (Taskwarrior/Timewarrior)

Install legacy task and time tracking tools:

```bash
cd install-scripts
chmod +x patch-deprecated.sh
./patch-deprecated.sh
```

**Warning:** These configurations are no longer actively maintained and come with zero guarantees for functionality.

#### Syncing Setup
If you choose to use Taskwarrior and Timewarrior, you can set up syncing:

- **Taskwarrior:** Uses [taskchampion-sync-server](https://github.com/GothenburgBitFactory/taskchampion-sync-server)
- **Timewarrior:** Uses [timew-sync-server](https://github.com/timewarrior-synchronize/timew-sync-server)

The deprecated module includes:
- Automated sync scripts with file locking
- Systemd services and timers for automatic syncing
- Manual sync scripts: `taskw-update.sh` and `timew-update.sh`

## Project Structure

```
.dotfiles/
├── 00-default/           # Core configurations
│   ├── .config/
│   │   ├── tmux/         # Tmux config + TPM
│   │   ├── kitty/        # Kitty terminal config
│   │   ├── kanata/       # Keyboard remapping
│   │   ├── gitui/        # Git TUI config
│   │   └── starship.toml # Shell prompt
│   ├── .scripts/
│   │   ├── shell_config/ # Modular ZSH configs (see below)
│   │   ├── bin/          # Custom utility scripts
│   │   └── completion_zsh/ # Shell completions
│   ├── .zshrc            # Main ZSH configuration
│   └── .ideavimrc        # IdeaVim configuration
│
├── 01-dwm-addons/        # DWM-specific configs
│   ├── .xinitrc
│   └── .config/dwmbar/
│
├── 02-agentic-llms/      # Claude Code and OpenCode configs
│   ├── .claude/
│   └── .opencode/
│
├── 99-deprecated/        # Legacy task management
│   ├── .config/task/
│   ├── .config/timew/
│   └── .local/bin/       # Sync scripts
│
└── install-scripts/      # Automated setup
    ├── arch-quick-setup.sh
    ├── patch-dwm.sh
    ├── patch-deprecated.sh
    └── systemd-services/ # Service definitions
```

## Configuration Highlights

### Modular Shell Configuration

`.zshrc` is intentionally minimal — it only initialises the zsh completion system and then sources every `*.zsh` file found in `~/.scripts/shell_config/` in alphabetical order. All other configuration lives in that directory as numbered modules.

**Rules for shell_config files:**
- Filename format: `NN-description.zsh` (two-digit prefix, e.g. `05-history.zsh`)
- The number controls load order — lower numbers load first
- Each patch directory contributes its own files into `shell_config/` via stow; the prefix number should reflect which patch it belongs to (00–09 for `00-default`, 10–19 for `01-dwm-addons`, 20–29 for `02-agentic-llms`, etc.)
- Reserve `99-*.zsh` for tool initialisations that must run last (e.g. sdkman requires this)
- Do **not** put completion system setup, history config, or tool init hooks directly in `.zshrc` — use the appropriate numbered module instead

**Current modules (contributed by each patch via stow):**

| File | Patch | Purpose |
|---|---|---|
| `01_add_scripts_to_path.zsh` | `00-default` | Adds `~/.scripts/bin` to PATH |
| `02-advanced_terminal.zsh` | `00-default` | CLI aliases (eza, git, docker, nvim) and zoxide |
| `03-neovim_default_editor.zsh` | `00-default` | Sets `EDITOR`, `VISUAL`, `MANPAGER` |
| `04-zsh_bindkey.zsh` | `00-default` | Vi mode and advanced key bindings |
| `05-history.zsh` | `00-default` | History file, size, and save settings |
| `06-env.zsh` | `00-default` | Environment variables and PATH additions |
| `10-dwm.zsh` | `01-dwm-addons` | DWM-specific aliases (if installed) |
| `20-agentic-llms.zsh` | `02-agentic-llms` | Agentic LLM tool aliases (e.g. `cdsp`) |
| `99-tool-init.zsh` | `00-default` | Tool initialisations: starship, nvm, bun, sdkman |

### Tmux Features
- Custom prefix: `Ctrl+s`
- Plugins: vim-tmux-navigator, tmux-resurrect, tmux-yank, cpu/battery monitoring
- Catppuccin Mocha theme
- Seamless vim-tmux navigation

### IdeaVim Configuration
Comprehensive 334-line configuration with:
- LSP-like mappings for code navigation
- Debugging integration
- Git integration
- Custom leader key workflows

### Productivity Scripts
- **workmode.sh** - Block distracting websites for focus sessions
- **open-github.sh** - Open current git repository in browser
- **task-topprojects.sh** - View top Taskwarrior projects (deprecated module)

## Customization

### Changing Themes
Theme alternatives are commented in the configuration files:

**tmux** (`~/.config/tmux/tmux.conf`):
```bash
# Uncomment desired theme
# set -g @plugin 'rose-pine/tmux'
# set -g @plugin 'dracula/tmux'
set -g @plugin 'catppuccin/tmux'
```

**kitty** (`~/.config/kitty/kitty.conf`):
```bash
# Uncomment desired theme
# include ./themes/dracula.conf
include ./themes/catppuccin-mocha.conf
```

### Adding Custom Shell Functions
Create a new numbered file in the appropriate patch's `shell_config/` directory and re-stow:
```bash
echo 'alias myalias="command"' > ~/.dotfiles/00-default/.scripts/shell_config/07-custom.zsh
```

The file will be symlinked into `~/.scripts/shell_config/` by stow and automatically sourced on next shell startup. Follow the numbering convention — use a prefix in the range that corresponds to the owning patch.

## Keyboard Shortcuts

### Kanata Remapping
- **Caps Lock (tap):** Escape
- **Caps Lock (hold):** Control
- **Caps Lock + h/j/k/l:** Left/Down/Up/Right arrows

### Tmux (prefix: Ctrl+s)
- **prefix + I:** Install plugins
- **prefix + |:** Split window vertically
- **prefix + -:** Split window horizontally
- **Ctrl+h/j/k/l:** Navigate between tmux panes and vim windows

## Troubleshooting

### Kanata Not Working
- Ensure you're in the `uinput` group: `groups`
- Check service status: `systemctl --user status kanata`
- Reboot after installation

### Tmux Plugins Not Loading
- Install TPM: Press `prefix + I` in tmux
- Check TPM directory: `ls ~/.tmux/plugins/tpm`

### ZSH Configuration Not Loading
- Ensure you're using ZSH: `echo $SHELL`
- Change shell: `chsh -s $(which zsh)`
- Source configuration: `source ~/.zshrc`

### Neovim Plugins Issues
- Open neovim and run: `:Lazy sync`
- Check neovim health: `:checkhealth`

## Contributions

Your contributions are always welcome! If you would like to improve the dotfiles or have suggestions:

1. Fork the repository
2. Create a new branch with your improvements: `git checkout -b feature-xyz`
3. Make your changes or additions
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin feature-xyz`
6. Create a new Pull Request

Please ensure your commit messages are clear and code changes are well-documented. Code reviews and discussions about improvements are highly appreciated.

## License

Feel free to use and modify these dotfiles for your own setup.

## Acknowledgments

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Theme
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- [Kanata](https://github.com/jtroo/kanata) - Keyboard remapper
- [Starship](https://starship.rs/) - Cross-shell prompt
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager
