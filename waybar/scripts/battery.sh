#!/usr/bin/env bash
set -euo pipefail

BAT="${BAT:-BAT0}"
SYS="/sys/class/power_supply/$BAT"

cap=$(cat "$SYS/capacity" 2>/dev/null || echo "?")
status=$(cat "$SYS/status" 2>/dev/null || echo "Unknown")
mode=$(grep -oE '\[[^]]+\]' "$SYS/charge_types" 2>/dev/null | tr -d '[]')

if [[ "$status" == "Charging" ]]; then
    icon=""
elif [[ "$cap" =~ ^[0-9]+$ ]]; then
    if   (( cap >= 90 )); then icon=""
    elif (( cap >= 70 )); then icon=""
    elif (( cap >= 50 )); then icon=""
    elif (( cap >= 30 )); then icon=""
    else                      icon=""
    fi
else
    icon=""
fi

printf '{"text":"%s%% %s","tooltip":"Battery %s%% · %s · %s"}\n' \
    "$cap" "$icon" "$cap" "$mode" "$status"
