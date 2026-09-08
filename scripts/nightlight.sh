#!/usr/bin/env bash
# nightlight — blue-light filter via hyprsunset's temperature, on a fixed
# sunset/sunrise schedule (IST approximation).
#
#     on      → fade to warm (NIGHT_K)
#     off     → fade to neutral (DAY_K)
#     auto    → set instantly based on the current time (for login)
#     toggle  → instant flip on/off
#     status  → current temperature + day/night state
#     get     → current temperature (K)

set -euo pipefail

NIGHT_K="${NIGHT_K:-4000}"
DAY_K="${DAY_K:-6500}"
NIGHT_START="${NIGHT_START:-18:30}"       # HH:MM (24h) — sunset
NIGHT_END="${NIGHT_END:-06:00}"           # HH:MM (24h) — sunrise
FADE_DURATION="${FADE_DURATION:-1200}"    # seconds (default 20 min)
FADE_STEP="${FADE_STEP:-15}"              # seconds between fade steps
FADE_PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/nightlight-fade.pid"

get_temp() { hyprctl hyprsunset temperature 2>/dev/null | tr -d '[:space:]'; }

set_temp() { hyprctl hyprsunset temperature "$1" >/dev/null 2>&1 || true; }

hm_to_min() {
    local h m
    IFS=: read -r h m <<< "$1"
    echo $((10#$h * 60 + 10#$m))
}

is_night() {
    local now start end
    now=$(hm_to_min "$(date +%H:%M)")
    start=$(hm_to_min "$NIGHT_START")
    end=$(hm_to_min "$NIGHT_END")
    if (( start < end )); then
        (( now >= start && now < end ))
    else
        (( now >= start || now < end ))
    fi
}

kill_fade() {
    if [[ -f "$FADE_PIDFILE" ]]; then
        local p
        p=$(cat "$FADE_PIDFILE" 2>/dev/null || true)
        if [[ -n "$p" ]] && kill -0 "$p" 2>/dev/null; then
            kill "$p" 2>/dev/null || true
        fi
        rm -f "$FADE_PIDFILE"
    fi
}

fade_to() {
    local target=$1
    local from steps interval i cur
    kill_fade
    echo "$$" > "$FADE_PIDFILE"
    from=$(get_temp)
    if [[ "$from" =~ ^[0-9]+$ ]] && [[ "$from" != "$target" ]]; then
        steps=$((FADE_DURATION / FADE_STEP))
        (( steps < 1 )) && steps=1
        interval=$((FADE_DURATION / steps))
        for ((i = 1; i <= steps; i++)); do
            cur=$((from + (target - from) * i / steps))
            set_temp "$cur"
            sleep "$interval"
        done
    fi
    set_temp "$target"
    rm -f "$FADE_PIDFILE"
}

case "${1:-status}" in
    on)
        fade_to "$NIGHT_K"
        echo "nightlight: on ($(get_temp) K)"
        ;;
    off)
        fade_to "$DAY_K"
        echo "nightlight: off ($(get_temp) K)"
        ;;
    auto)
        kill_fade
        if is_night; then set_temp "$NIGHT_K"; else set_temp "$DAY_K"; fi
        echo "nightlight: $(is_night && echo on || echo off) ($(get_temp) K)"
        ;;
    toggle)
        kill_fade
        if [[ "$(get_temp)" == "$NIGHT_K" ]]; then set_temp "$DAY_K"; else set_temp "$NIGHT_K"; fi
        echo "nightlight: $(get_temp) K"
        ;;
    status)
        echo "nightlight: $(is_night && echo night || echo day) · $(get_temp) K"
        ;;
    get)
        get_temp
        ;;
    *)
        echo "usage: nightlight.sh [on|off|auto|toggle|status|get]" >&2
        exit 1
        ;;
esac
