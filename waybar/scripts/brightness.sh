#!/usr/bin/env bash
set -euo pipefail

cur=$(brightnessctl g | grep -oE '[0-9]+' | head -1)
max=$(brightnessctl m | grep -oE '[0-9]+' | head -1)
hw_pct=$(( cur * 100 / max ))

g=$(hyprctl hyprsunset gamma 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)
[ -z "$g" ] && g=100

if [ "$g" -gt 100 ]; then
    pct=$g
    cls="boost"
else
    pct=$hw_pct
    cls=""
fi

if [ "$pct" -gt 100 ]; then
    icon="󰃠"
elif [ "$pct" -ge 75 ]; then
    icon="󰃠"
elif [ "$pct" -ge 50 ]; then
    icon="󰃝"
elif [ "$pct" -ge 25 ]; then
    icon="󰃞"
else
    icon="󰃜"
fi

printf '{"text":"%s %d%%","class":"%s","tooltip":"Brightness %d%%"}\n' "$icon" "$pct" "$cls" "$pct"
