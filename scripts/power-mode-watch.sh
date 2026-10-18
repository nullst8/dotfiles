#!/usr/bin/env bash
# power-mode-watch.sh — react to AC/battery changes.
#
# On battery: disable Hyprland blur/shadows/animations, enable hardware
#             cursors, drop window transparency, and dim the backlight.
# On AC:      restore all of the above (brightness is saved/restored).
#
# The Lua config parser doesn't support `hyprctl keyword`, so battery
# cosmetics go through `hyprctl eval` + `hl.config`; AC restores via reload.

set -uo pipefail

AC="${POWER_AC_PATH:-/sys/class/power_supply/ADP1/online}"
DIM_PERCENT="${DIM_PERCENT:-75}"
INTERVAL="${INTERVAL:-30}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/power-mode-watch"
BRIGHT_STATE="$STATE_DIR/brightness"

mkdir -p "$STATE_DIR"

COSMETICS_OFF='hl.config({ decoration = { blur = { enabled = false }, shadow = { enabled = false }, active_opacity = 1.0, inactive_opacity = 1.0 }, animations = { enabled = false }, cursor = { no_hardware_cursors = false } })'

# The unit can outlive a Hyprland session, leaving a stale instance signature
# in its environment; always target the newest live instance.
refresh_sig() {
  local d
  d=$(ls -1td "${XDG_RUNTIME_DIR:-/run/user/$UID}"/hypr/*/ 2>/dev/null | head -n1)
  [[ -n "$d" ]] && HYPRLAND_INSTANCE_SIGNATURE=$(basename "$d") && export HYPRLAND_INSTANCE_SIGNATURE
}

hypr_eval() { refresh_sig; hyprctl eval "$1" >/dev/null 2>&1 || true; }

is_ac() { [[ "$(cat "$AC" 2>/dev/null)" == "1" ]]; }

apply_battery() {
  hypr_eval "$COSMETICS_OFF"
  if [[ ! -s "$BRIGHT_STATE" ]]; then
    brightnessctl get >"$BRIGHT_STATE" 2>/dev/null || true
  fi
  brightnessctl set "${DIM_PERCENT}%" >/dev/null 2>&1 || true
}

apply_ac() {
  # Reload the config so blur/shadow/opacity/animation values come from
  # hyprland.lua rather than a second copy of them here.
  refresh_sig
  hyprctl reload >/dev/null 2>&1 || true
  if [[ -s "$BRIGHT_STATE" ]]; then
    local v
    v=$(cat "$BRIGHT_STATE")
    [[ -n "$v" ]] && brightnessctl set "$v" >/dev/null 2>&1
    rm -f "$BRIGHT_STATE"
  fi
}

# Apply state now (handles starting on either AC or battery).
if is_ac; then apply_ac; else apply_battery; fi

# Watch for transitions. udev power_supply events wake us immediately; the
# read timeout is a safety net in case an event is missed or udevadm dies.
exec 3< <(udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null)
last=$(is_ac && echo ac || echo bat)
while true; do
  read -r -t "$INTERVAL" -u 3 _
  rc=$?
  # rc 1 = udevadm exited (EOF); avoid spinning.
  (( rc == 1 )) && sleep "$INTERVAL"
  # Debounce bursts of events, then drain them.
  (( rc == 0 )) && { sleep 0.5; while read -r -t 0.1 -u 3 _; do :; done; }
  cur=$(is_ac && echo ac || echo bat)
  if [[ "$cur" != "$last" ]]; then
    if [[ "$cur" == ac ]]; then apply_ac; else apply_battery; fi
    last="$cur"
  fi
done
