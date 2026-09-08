#!/usr/bin/env bash
# perf-mode — control the power/performance profile via power-profiles-daemon.
#
# Profiles:
#     power-saver  — Saver       (lowest power, best battery life)
#     balanced     — Standard    (default)
#     performance  — Performance (max performance)
#
# Usage:
#     perf-mode.sh               print current profile
#     perf-mode.sh get           same as above
#     perf-mode.sh list          list profiles (active marked)
#     perf-mode.sh set <mode>    saver|standard|performance (+ aliases)
#     perf-mode.sh toggle        performance <-> power-saver
#     perf-mode.sh status        current profile
#     perf-mode.sh popup         yad widget (3 buttons)

set -euo pipefail

die() { echo "perf-mode: $*" >&2; exit 1; }

current() { powerprofilesctl get 2>/dev/null; }

# map a user-supplied mode to the exact profile token (empty if unknown)
canon() {
    case "${1,,}" in
        saver|power-saver|powersave|power_saver|battery) echo "power-saver" ;;
        standard|balanced|balance|normal|default)        echo "balanced" ;;
        performance|perf|high|max)                       echo "performance" ;;
        *) echo "" ;;
    esac
}

# map a profile token to a human-friendly name
friendly() {
    case "$1" in
        power-saver) echo "Saver" ;;
        balanced)    echo "Standard" ;;
        performance) echo "Performance" ;;
        *)           echo "$1" ;;
    esac
}

set_mode() {
    local p
    p=$(canon "${1:-}")
    [[ -n "$p" ]] || die "unknown profile '${1:-}' (use: saver, standard, performance)"
    powerprofilesctl set "$p"
    echo "profile: $p"
}

usage() {
    cat >&2 <<'EOF'
usage: perf-mode.sh [get|list|set <mode>|toggle|status|popup]

modes: saver (power-saver), standard (balanced), performance
EOF
}

popup() {
    # single-instance toggle: click the bar module again to close
    local lock="${XDG_RUNTIME_DIR:-/tmp}/perf-mode-popup.pid"
    if [[ -f "$lock" ]]; then
        local old
        old=$(cat "$lock" 2>/dev/null || true)
        if [[ -n "$old" ]] && kill -0 "$old" 2>/dev/null; then
            kill "$old" 2>/dev/null
            rm -f "$lock"
            return 0
        fi
        rm -f "$lock"
    fi

    local cur fmode text css
    cur=$(current)
    fmode=$(friendly "$cur")
    text=$(printf '<span size="x-large" weight="bold">Power Mode</span>\n<span color="#a6adc8">%s</span>' "$fmode")
    css="${PERF_MODE_CSS:-$HOME/.dotfiles/scripts/popup.css}"

    yad \
        --name=perf-mode --class=perf-mode \
        --title="Power" \
        --width=420 --borders=20 \
        --text="$text" \
        --buttons-layout=center \
        --button="Saver":10 \
        --button="Standard":11 \
        --button="Performance":12 \
        --undecorated --skip-taskbar --fixed \
        --css="$css" \
        >/dev/null 2>&1 &
    local ypid=$!
    echo "$ypid" > "$lock"

    local rc=0
    wait "$ypid" || rc=$?
    rm -f "$lock"

    case "$rc" in
        10) set_mode saver ;;
        11) set_mode standard ;;
        12) set_mode performance ;;
    esac
}

case "${1:-get}" in
    get)
        current
        ;;
    list)
        c=$(current)
        for p in performance balanced power-saver; do
            if [[ "$p" == "$c" ]]; then echo "* $(friendly "$p") ($p)"; else echo "  $(friendly "$p") ($p)"; fi
        done
        ;;
    set)
        [[ -n "${2:-}" ]] || die "set needs a mode"
        set_mode "$2"
        ;;
    toggle)
        case "$(current)" in
            performance) set_mode power-saver ;;
            power-saver) set_mode performance ;;
            *)           set_mode performance ;;
        esac
        ;;
    status)
        printf '%s\n' "$(current)"
        ;;
    popup)
        popup
        ;;
    *)
        usage
        exit 1
        ;;
esac
