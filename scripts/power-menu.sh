#!/bin/bash
# power-menu.sh — rofi-based power/session menu for Hyprland.

set -euo pipefail

declare -A actions=(
  ["Lock"]="loginctl lock-session"
  ["Suspend"]="systemctl suspend"
  ["Hibernate"]="systemctl hibernate"
  ["Reboot"]="systemctl reboot"
  ["Shutdown"]="systemctl poweroff"
  ["Logout"]="hyprctl dispatch exit"
)

if command -v rofi &>/dev/null; then
  choice=$(printf '%s\n' "${!actions[@]}" | sort | rofi -dmenu -p 'power' -i)
elif command -v wofi &>/dev/null; then
  choice=$(printf '%s\n' "${!actions[@]}" | sort | wofi -dmenu -p 'power' -i)
else
  echo "Install rofi or wofi for the power menu" >&2
  exit 1
fi

if [[ -z "$choice" ]]; then
  exit 0
fi

${actions[$choice]:-}
