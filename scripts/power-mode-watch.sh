#!/usr/bin/env bash
# power-mode-watch.sh — react to AC/battery changes.
#
# On battery: disable Hyprland blur/shadows/animations, enable hardware
#             cursors, drop window transparency, and dim the backlight.
# On AC:      restore all of the above (brightness is saved/restored).
#
# The Lua config parser doesn't support `hyprctl keyword`, so cosmetic
# changes go through `hyprctl eval` + `hl.config`.

set -uo pipefail

AC="${POWER_AC_PATH:-/sys/class/power_supply/ADP1/online}"
DIM_PERCENT="${DIM_PERCENT:-75}"
INTERVAL="${INTERVAL:-2}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/power-mode-watch"
BRIGHT_STATE="$STATE_DIR/brightness"

mkdir -p "$STATE_DIR"

COSMETICS_ON='hl.config({ decoration = { blur = { enabled = true }, shadow = { enabled = true }, active_opacity = 0.85, inactive_opacity = 0.9 }, animations = { enabled = true }, cursor = { no_hardware_cursors = true } })'
COSMETICS_OFF='hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false }, active_opacity = 1.0, inactive_opacity = 1.0 }, animations = { enabled = false }, cursor = { no_hardware_cursors = false } })'

hypr_eval() { hyprctl eval "$1" >/dev/null 2>&1 || true; }

is_ac() { [[ "$(cat "$AC" 2>/dev/null)" == "1" ]]; }

apply_battery() {
  hypr_eval "$COSMETICS_OFF"
  if [[ ! -s "$BRIGHT_STATE" ]]; then
    brightnessctl get >"$BRIGHT_STATE" 2>/dev/null || true
  fi
  brightnessctl set "${DIM_PERCENT}%" >/dev/null 2>&1 || true
}

apply_ac() {
  hypr_eval "$COSMETICS_ON"
  if [[ -s "$BRIGHT_STATE" ]]; then
    local v
    v=$(cat "$BRIGHT_STATE")
    [[ -n "$v" ]] && brightnessctl set "$v" >/dev/null 2>&1
    rm -f "$BRIGHT_STATE"
  fi
}

# Apply state now (handles starting on either AC or battery).
if is_ac; then apply_ac; else apply_battery; fi

# Watch for transitions.
last=$(is_ac && echo ac || echo bat)
while sleep "$INTERVAL"; do
  cur=$(is_ac && echo ac || echo bat)
  if [[ "$cur" != "$last" ]]; then
    if [[ "$cur" == ac ]]; then apply_ac; else apply_battery; fi
    last="$cur"
  fi
done
