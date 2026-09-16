# nullst8/dotfiles

> A personal, declarative Linux environment built around [Hyprland](https://hyprland.org/), [Neovim](https://neovim.io/), [Zsh](https://www.zsh.org/), and [Tmux](https://github.com/tmux/tmux). Managed with a single `setup.sh` and symlinked into `~/.config`.

## Overview

This repository contains my entire day-to-day Unix environment. It is designed for:

- **Window Manager:** Hyprland (Wayland), configured with the experimental Lua DSL.
- **Terminal:** Kitty, with JetBrainsMono Nerd Font and a custom dark color palette.
- **Editor:** Neovim (Lazy.nvim plugin manager, LSP, Mason, blink.cmp, conform, snacks, opencode.nvim).
- **Shell:** Zsh with the [antidote](https://getantidote.github.io/) plugin manager, zsh-vi-mode, autosuggestions, syntax highlighting, and a custom async git prompt.
- **Multiplexer:** Tmux with TPM and sensible defaults.
- **System UI:** Waybar and SwayNC notifications.
- **File Manager:** Yazi (terminal-based).

The repo is kept simple: config files live here directly and `setup.sh` symlinks them into place.

## Repository Layout

```
.dotfiles/
├── setup.sh                 # One-shot install / symlink script
├── README.md                # This file
├── .tmux.conf               # Tmux configuration
├── .wallpaper.jpg           # Default wallpaper
├── .wallpaper.png           # Alternative wallpaper
├── hypr/                    # Hyprland, Hypridle, Hyprlock configs
├── kitty/                   # Kitty terminal config
├── nvim/                    # Neovim config (init.lua + lua/nullst8/)
├── quickshell-lockscreen/   # Vendored qylock session lock (Hyprland)
├── scripts/                 # Helper scripts for Hyprland, tmux, wallpapers
├── swaync/                  # SwayNC notification center config
├── waybar/                  # Waybar status bar config
├── yazi/                    # Yazi file manager config
└── zsh/                     # Zsh config (.zshrc, .zsh_plugins.*)
```

## Requirements

### Primary Target

- **OS:** Arch Linux (or an Arch-based distro)
- **Display:** Wayland compositor
- **Shell:** Zsh

### Fonts

A [Nerd Font](https://www.nerdfonts.com/) is **strongly recommended** for Waybar, SwayNC, and any terminal glyphs. The config expects:

- `JetBrainsMono Nerd Font` (primary)
- `RobotoMono Nerd Font` (fallback)

### Optional External Tools

A few tools referenced by the configs are still external and must be installed separately:

- `awww-daemon` — wallpaper daemon (AUR: `awww`)
- `hyprsunset` — blue-light/gamma control for Hyprland (`brightnessctl` + `hyprsunset` handle brightness keys)
- qylock assets (`~/.local/share/quickshell-lockscreen/imports` + `themes_link`) — used by the vendored lock screen in `quickshell-lockscreen/` (see below)

Everything else is now vendored in the `scripts/` directory and added to `$PATH` by Zsh.

### Scripts (`scripts/`)

The `scripts/` directory contains small helpers used by Hyprland and Zsh. They are automatically added to your `$PATH` when Zsh loads.

| Script | Used by | Purpose |
| --- | --- | --- |
| `tmux-sessionizer` | `zsh/.zshrc` (`tx` alias) | Fuzzy-find a directory and attach/create a tmux session |
| `setrandwall` | `hypr/hyprland.lua` | Set a random wallpaper from `~/.walls` (or `$WALLPAPER_DIR`) |
| `wallpaper-select` | `hypr/hyprland.lua` | Interactive wallpaper picker from `~/.walls` (`SUPER + SHIFT + W`) |
| `bat-threshold.sh` | `~/.config/waybar` | Battery charge mode popup (`Fast`/`Standard`/`Long_Life`) on battery-icon click |
| `perf-mode.sh` | `~/.config/waybar` | Power profile popup (`Saver`/`Standard`/`Performance`) via `powerprofilesctl` |
| `toggle-grayscale.sh` | `hypr/hyprland.lua` | Toggle a grayscale shader (`SUPER + G`) |
| `power-menu.sh` | `hypr/hyprland.lua` | Power/session menu (`SUPER + SHIFT + P`) |

The wallpaper scripts use `awww`; the grayscale script writes a minimal GLSL shader to `~/.config/hypr/grayscale.glsl` if it does not exist.

There are also app-specific scripts inside config directories:

| Script | Used by | Purpose |
| --- | --- | --- |
| `hypr/scripts/brightness-ctl.sh` | `hypr/hyprland.lua` | Handle `XF86MonBrightnessUp/Down` with hardware brightness + `hyprsunset` gamma boost |
| `waybar/scripts/brightness.sh` | `waybar/config.jsonc` | Report brightness/gamma as JSON for the Waybar brightness module |

## Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/nullst8/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the install script:

   ```bash
   ./setup.sh
   ```

   `setup.sh` will:

   - Symlink the relevant directories/files into `~/.config` and `$HOME`.
   - Back up any existing dotfiles that collide.
   - Create `~/.vim/undodir` for Neovim persistent undo.
   - Optionally install TPM (Tmux Plugin Manager).
   - On Arch Linux, optionally install the core packages via `paru`, `yay`, or `sudo pacman`.
   - Skip package installation with `./setup.sh --no-deps`.

3. Change your default shell to Zsh (if it is not already):

   ```bash
   chsh -s $(command -v zsh)
   ```

4. Log out and back in (or start Hyprland from a TTY/display manager).

### Non-Destructive / Manual

If you prefer to cherry-pick, just symlink the files you want:

```bash
ln -s ~/.dotfiles/nvim ~/.config/nvim
ln -s ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
# ...etc
```

## What's Inside

### Hyprland (`hypr/`)

- `hyprland.lua` — Main configuration written in the experimental Lua DSL. Sets the window rules, keybindings, startup applications, monitor configuration, and animations.
- `hypridle.conf` — Idle / suspend / lock behavior.
- `hyprlock.conf` — Lock screen with date/time widget and wallpaper background.
- `wallpaper2.jpg` — Lock-screen wallpaper.

Highlights:

- `SUPER + Enter` — Open Kitty
- `SUPER + W` — Open Zen browser
- `SUPER + D` — Open Rofi launcher
- `SUPER + H/J/K/L` — Focus / resize windows
- `SUPER + Print` — Region screenshot via `grim` + `slurp`
- `XF86Audio*` / `XF86MonBrightness*` — Volume and brightness (brightness uses `brightnessctl` + `hyprsunset` gamma boost above 100%)

### Quickshell lock screen (`quickshell-lockscreen/`)

The qylock-based session lock is vendored here so local fixes survive a qylock
reinstall. It reuses qylock's assets from `~/.local/share/quickshell-lockscreen`
(QML imports and themes), which must be installed separately:

```bash
git clone https://github.com/Darkkal44/qylock
./qylock/quickshell.sh
```

- `lock.sh` — launcher (single-instance `flock` guard); used by `SUPER + Escape`, `hypridle`'s `lock_cmd`, and `before_sleep_cmd`.
- `lock_shell.qml` — the Quickshell session lock; releases the lock before exiting.
- `shim/SddmShim.qml` — SDDM-compatible user/session/PAM shim used by the themes.
- `resume-lock.sh` — runs on resume (`hypridle`'s `after_sleep_cmd`): kills any stale lock client, clears Hyprland's stale session-lock state, and re-locks. Works around [hyprwm/Hyprland#13184](https://github.com/hyprwm/Hyprland/discussions/13184), where the compositor's session-lock state desyncs across suspend/resume and can leave a stuck lock surface.

If a stuck lock surface appears anyway, recover from a TTY with:

```bash
hyprctl eval 'hl.clear_crashed_lockscreen()'
pkill -f lock_shell.qml
```

### Neovim (`nvim/`)

Managed by `lazy.nvim` with `lua/nullst8/` as the config namespace.

| Plugin / Feature | Purpose |
| --- | --- |
| `lazy.nvim` | Plugin manager |
| `mason.nvim` + `mason-lspconfig.nvim` | LSP server management |
| `nvim-lspconfig` | LSP configs |
| `saghen/blink.cmp` | Autocompletion |
| `L3MON4D3/LuaSnip` | Snippets |
| `stevearc/conform.nvim` | Auto-formatting (stylua, black, clang-format, prettier, rustfmt) |
| `folke/snacks.nvim` | Picker, lazygit, notifier, indent, etc. |
| `nvim-treesitter` | Syntax highlighting |
| `nvim-treesitter-context` | Sticky context lines |
| `dark2026.nvim` | Default colorscheme |
| `rose-pine` | Alternative colorscheme |
| `gruvbox.nvim` | Alternative colorscheme |
| `nvim-autopairs` | Auto-pairs |
| `telescope.nvim` | Currently disabled (snacks picker is used instead) |
| `opencode.nvim` | AI assistant integration |
| `firenvim` | Browser editor integration |
| `rustaceanvim` | Rust-specific tooling |

Languages with out-of-the-box LSP support:

- Lua (`lua_ls`)
- Rust (`rust_analyzer` via rustaceanvim, `bacon_ls` via cargo backend)
- C/C++ (`clangd`)
- TypeScript/JavaScript (`ts_ls`)
- Python (`pyright`)

### Zsh (`zsh/`)

- `.zshrc` — Main shell config with a hand-rolled async git prompt, completion, history, and extensive aliases.
- `.zsh_plugins.txt` — Antidote plugin bundle list.
- `.zsh_plugins.zsh` — Generated bundle file (rebuilt automatically when `.zsh_plugins.txt` is newer).

Plugins managed by antidote:

- `zsh-users/zsh-history-substring-search`
- `jeffreytse/zsh-vi-mode`
- `zsh-users/zsh-autosuggestions`
- `agkozak/zsh-z`
- `zsh-users/zsh-syntax-highlighting`

Notable aliases:

- `vim` → `nvim`
- `cat` → `bat --theme=gruvbox-dark --pager=never`
- `ls` → `eza`, `ll` → `eza -l`, `la` → `eza -la`
- `grep` → `rg`
- `p` → `paru`, `update` → `paru -Syu`
- `g` → `git`, `gs` → `git status`, `glog` → `git log --oneline --decorate --graph`
- `t` → `tmux`, `tx` → `tmux-sessionizer`

### Tmux (`.tmux.conf`)

- Prefix: `Ctrl + a`
- Mouse support enabled
- Pane switching with `Ctrl + h/j/k/l` (no prefix)
- Pane resizing with `Alt + h/j/k/l`
- Plugins: `tpm`, `tmux-sensible`, `tmux-continuum` (auto-restore)
- Copy mode with vi keys

### Kitty (`kitty/`)

- JetBrainsMono Nerd Font at 10.8pt
- Custom dark colors (`colors.conf`)
- Block cursor, no ligatures
- `Ctrl + Shift + Alt + Super + F12` — show GPU info

### Waybar (`waybar/`)

- Top bar with: Hyprland workspaces, centered clock, and a right-side block containing CPU, RAM, brightness, battery, pulseaudio, notification count, and tray.
- Brightness module reports hardware brightness normally and `hyprsunset` gamma level when boosted above 100%.
- Minimal dark theme (`style.css`).

### SwayNC (`swaync/`)

- Notification daemon and control center.
- Styled to match the dark Waybar theme.
- `SUPER + Space` — Close latest notification
- `SUPER + Shift + Space` — Toggle notification center

### Yazi (`yazi/`)

- `Ctrl + T` — Open a Kitty terminal at the current directory.
- Default editor set to `nvim`.

## Keybindings Cheatsheet

### Hyprland

| Key | Action |
| --- | --- |
| `SUPER + Enter` | Open terminal (Kitty) |
| `SUPER + Shift + Enter` | Open file manager (Yazi in Kitty) |
| `SUPER + E` | Open GUI file manager (pcmanfm) |
| `SUPER + W` | Open browser (Zen) |
| `SUPER + D` | Rofi run menu |
| `SUPER + P` | Power menu |
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen toggle |
| `SUPER + V` | Float toggle |
| `SUPER + H/J/K/L` | Focus window |
| `SUPER + Shift + H/J/K/L` | Move window |
| `SUPER + 1…9` | Switch workspace |
| `SUPER + Shift + 1…9` | Move window to workspace |
| `SUPER + S` | Toggle special workspace |
| `SUPER + Tab` | Previous workspace |
| `Print` | Full screenshot |
| `SUPER + Print` | Region screenshot |
| `SUPER + ;` | Full screenshot |
| `SUPER + Shift + ;` | Region screenshot to clipboard |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute |
| `XF86MonBrightnessUp` | Brightness up (switches to `hyprsunset` gamma boost once hardware max is reached) |
| `XF86MonBrightnessDown` | Brightness down |
| `SUPER + Escape` | Lock screen |
| `SUPER + Shift + C` | Exit Hyprland |

### Tmux

| Key | Action |
| --- | --- |
| `Ctrl + a` | Prefix |
| `Ctrl + a` then `c` | New window |
| `Ctrl + a` then `h/j/k/l` | Switch pane (or `Ctrl + h/j/k/l` without prefix) |
| `Alt + h/j/k/l` | Resize pane |
| `Ctrl + a` then `r` | Reload config |
| `Ctrl + a` then `S` | Toggle status bar |

### Neovim

| Key | Action |
| --- | --- |
| `Space` | Leader |
| `<leader>pv` | Open file explorer |
| `<leader>ff` | Snacks file picker |
| `<leader>fg` | Snacks live grep |
| `<Ctrl + p>` | Git files picker |
| `<leader>gg` | LazyGit |
| `<leader>s` | Replace word under cursor |
| `<leader>x` | Make current file executable |
| `<leader>oa` | Ask opencode |
| `<leader>ox` | Select opencode |
| `Ctrl + .` | Toggle opencode |

## Post-Install Notes

After running `setup.sh`:

1. **Neovim:** Open `nvim`. `lazy.nvim` will download and install all plugins automatically.
2. **Tmux:** Start `tmux`, press `Ctrl + a` then `I` (capital i) to install TPM plugins.
3. **Zsh:** The first prompt will generate the antidote bundle; the second prompt will be fully loaded.
4. **Mason:** Inside Neovim, run `:Mason` to install any missing LSP/formatters.
5. **LSPs:** For Rust, `rustaceanvim` will attach automatically when opening a `Cargo.toml` project.
6. **Waybar / SwayNC:** Restart them manually if they were already running:

   ```bash
   killall waybar && waybar
   killall swaync && swaync
   ```

## Maintenance

### Updating the dotfiles

```bash
cd ~/.dotfiles
git pull
./setup.sh
```

### Updating Neovim plugins

```bash
nvim
# Run inside Neovim:
:Lazy update
```

### Updating Tmux plugins

```bash
# Inside tmux:
Ctrl + a I
```

### Updating Zsh plugins

Antidote regenerates the bundle automatically when `.zsh_plugins.txt` changes. To force an update:

```bash
rm ~/.zsh_plugins.zsh
source ~/.zshrc
```

## Performance

Neovim is tuned for low startup and runtime overhead:

- `lazy.nvim` disables unused built-in plugins (`gzip`, `rplugin`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`). `matchit` and `netrwPlugin` are kept.
- Alternative colorschemes (`rose-pine`, `gruvbox`) are lazy-loaded; `dark2026` loads eagerly.
- `updatetime` is 250 ms to reduce CPU usage from `CursorHold` events.
- LSP log level is set to `WARN`.
- Rust-specific speedups:
  - `rustaceanvim` manages `rust-analyzer` with diagnostics offloaded to `bacon-ls`.
  - `rust-analyzer` semantic highlighting and inlay hints are disabled.
  - `cargo check` is used instead of `clippy`.

### Profiling startup

```bash
nvim --startuptime /tmp/startup.log
# Inspect:
sort -k2 -nr /tmp/startup.log | head -20
```

## Troubleshooting

### Shebang on `setup.sh`

The script is executable and should be run as `./setup.sh`. If your shell complains, make sure the first line is:

```bash
#!/bin/bash
```

### Hyprland Lua config does not load

The `hyprland.lua` file uses the **experimental Hyprland Lua DSL**. It requires a Hyprland build that supports Lua configuration. If your build only supports the standard `hyprland.conf` syntax, you will need to convert the file or use the appropriate Hyprland version.

### Missing scripts

Most helper scripts now live in `scripts/` and are added to `$PATH` by Zsh. The only remaining external dependencies are `awww-daemon` and the qylock assets used by `quickshell-lockscreen/` (`~/.local/share/quickshell-lockscreen/imports` and `themes_link`).

## License

This repository is personal configuration. Use it as a reference or fork it freely.
