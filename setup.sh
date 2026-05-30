#!/bin/bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
REPO_URL="https://github.com/nullst8/dotfiles.git"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%s)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[*]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[x]${NC} $1"; }

cleanup() {
  [[ -d "$BACKUP_DIR" && ! "$(ls -A "$BACKUP_DIR")" ]] && rmdir "$BACKUP_DIR"
}
trap cleanup EXIT

# --- Clone or update repo ---
if [[ -d "$DOTFILES/.git" ]]; then
  info "Dotfiles repo already exists at $DOTFILES"
else
  if [[ -d "$DOTFILES" ]]; then
    warn "$DOTFILES exists but is not a git repo — skipping clone"
  else
    info "Cloning dotfiles into $DOTFILES"
    git clone "$REPO_URL" "$DOTFILES"
  fi
fi

cd "$DOTFILES"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    local current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      info "Already linked: $dst → $src"
      return
    fi
  fi

  if [[ -e "$dst" ]]; then
    warn "Backing up $dst → $BACKUP_DIR/"
    mkdir -p "$BACKUP_DIR/$(dirname "$dst")"
    mv "$dst" "$BACKUP_DIR/$dst"
  fi

  ln -sf "$src" "$dst"
  info "Linked: $dst → $src"
}

info "Creating symlinks..."

# XDG config directories
link "$DOTFILES/nvim"     "$HOME/.config/nvim"
link "$DOTFILES/hypr"     "$HOME/.config/hypr"
link "$DOTFILES/kitty"    "$HOME/.config/kitty"
link "$DOTFILES/waybar"   "$HOME/.config/waybar"
link "$DOTFILES/swaync"   "$HOME/.config/swaync"
link "$DOTFILES/dunst"    "$HOME/.config/dunst"
link "$DOTFILES/yazi"     "$HOME/.config/yazi"

# Zsh
link "$DOTFILES/zsh/.zshrc"           "$HOME/.zshrc"
link "$DOTFILES/zsh/.zsh_plugins.zsh" "$HOME/.zsh_plugins.zsh"
link "$DOTFILES/zsh/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"

# Tmux
link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

# Wallpapers
link "$DOTFILES/.wallpaper.jpg" "$HOME/.wallpaper.jpg"
link "$DOTFILES/.wallpaper.png" "$HOME/.wallpaper.png"

# --- Post-setup hints ---
BOLD='\033[1m'
echo -e "\n${GREEN}${BOLD}Done!${NC} Symlinks are in place."
echo -e "${YELLOW}Post-install reminders:${NC}"
echo -e "  • ${BOLD}Neovim:${NC}    Open nvim — lazy will auto-install plugins"
echo -e "  • ${BOLD}TMUX:${NC}      Start tmux, hit ${BOLD}Prefix + I${NC} to install TPM plugins"
echo -e "  • ${BOLD}Zsh:${NC}       Antidote bundles generate on first source"
echo -e "  • ${BOLD}Waybar:${NC}    Restart: ${BOLD}killall waybar && waybar${NC}"
echo -e "  • ${BOLD}Swaync:${NC}    Restart: ${BOLD}killall swaync && swaync${NC}"
