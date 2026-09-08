#!/usr/bin/env bash
# bat-threshold — control battery charge mode on Lenovo IdeaPads.
#
# Wraps the ideapad_laptop driver's charge_types sysfs knob, which exposes
# three preset modes (not arbitrary % thresholds):
#     Fast      — Rapid Charge   (charge to 100% as fast as possible)
#     Standard  — Normal          (charge to 100%)
#     Long_Life — Conservation    (cap ~60%, best for always-plugged-in use)
#
# Usage:
#     bat-threshold.sh                 print current mode
#     bat-threshold.sh get             same as above
#     bat-threshold.sh list            list available modes (active marked)
#     bat-threshold.sh set <mode>      set mode (fast|standard|longlife, + aliases)
#     bat-threshold.sh toggle          Standard <-> Long_Life
#     bat-threshold.sh status          mode + capacity% + charging state
#     bat-threshold.sh popup           yad widget (3 buttons)
#     bat-threshold.sh setup           one-time udev+group setup (passwordless writes)

set -euo pipefail

BAT="${BAT:-BAT0}"
SYS="/sys/class/power_supply/$BAT"
CT="$SYS/charge_types"
CAP="$SYS/capacity"
STATUS="$SYS/status"

die() { echo "bat-threshold: $*" >&2; exit 1; }

# "Fast [Standard] Long_Life" -> "Standard"
current_mode() { grep -oE '\[[^]]+\]' "$CT" | tr -d '[]'; }

# token list without the brackets: "Fast Standard Long_Life"
available_modes() { sed 's/\[\([^]]*\)\]/\1/' "$CT"; }

capacity() { cat "$CAP" 2>/dev/null || echo "?"; }
charge_status() { cat "$STATUS" 2>/dev/null || echo "?"; }

# map a user-supplied mode to the exact sysfs token (empty if unknown)
canon() {
    case "${1,,}" in
        fast|rapid|rapidcharge|rapid_charge|quick) echo Fast ;;
        standard|normal|default)                    echo Standard ;;
        long|longlife|long_life|conservation|conserve|eco) echo Long_Life ;;
        *) echo "" ;;
    esac
}

# map a sysfs token to a human-friendly name
friendly() {
    case "$1" in
        Fast)      echo "Rapid Charge" ;;
        Standard)  echo "Standard" ;;
        Long_Life) echo "Long Life" ;;
        *)         echo "$1" ;;
    esac
}

write_mode() {
    local token="$1"
    local avail
    avail=$(available_modes)
    [[ " $avail " == *" $token "* ]] || die "unsupported mode '$token' (available: $avail)"

    if [[ -w "$CT" ]]; then
        echo "$token" > "$CT"
    elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        echo "$token" | sudo tee "$CT" >/dev/null
    else
        die "cannot write $CT (run 'bat-threshold.sh setup' once, then re-login)"
    fi
}

set_mode() {
    local token
    token=$(canon "${1:-}")
    [[ -n "$token" ]] || die "unknown mode '${1:-}' (use: fast, standard, longlife)"
    write_mode "$token"
    echo "charge mode: $token"
}

usage() {
    cat >&2 <<'EOF'
usage: bat-threshold.sh [get|list|set <mode>|toggle|status|popup|setup]

modes: fast (Rapid Charge), standard (Normal), longlife (Conservation ~60%)
EOF
}

popup() {
    [[ -r "$CT" ]] || die "no charge_types for $BAT — not a supported Ideapad?"

    # single-instance toggle: click battery icon again to close
    local lock="${XDG_RUNTIME_DIR:-/tmp}/bat-threshold-popup.pid"
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

    local mode cap st fmode text
    mode=$(current_mode)
    cap=$(capacity)
    st=$(charge_status)
    fmode=$(friendly "$mode")

    text=$(printf '<span size="x-large" weight="bold">Charge Mode</span>\n<span color="#a6adc8">%s · %s%% · %s</span>' "$fmode" "$cap" "$st")

    local css="${BAT_THRESHOLD_CSS:-$HOME/.dotfiles/scripts/popup.css}"

    yad \
        --name=bat-threshold --class=bat-threshold \
        --title="Battery" \
        --width=420 --borders=20 \
        --text="$text" \
        --buttons-layout=center \
        --button="Rapid Charge":10 \
        --button="Standard":11 \
        --button="Long Life":12 \
        --undecorated --skip-taskbar --fixed \
        --css="$css" \
        >/dev/null 2>&1 &
    local ypid=$!
    echo "$ypid" > "$lock"

    local rc=0
    wait "$ypid" || rc=$?
    rm -f "$lock"

    case "$rc" in
        10) set_mode fast ;;
        11) set_mode standard ;;
        12) set_mode longlife ;;
    esac
}

setup() {
    local group="battery_ctl"
    local rule="/etc/udev/rules.d/99-battery-mode.rules"
    local user="${SUDO_USER:-$USER}"

    getent group "$group" >/dev/null 2>&1 || sudo groupadd -r "$group"
    id -nG "$user" 2>/dev/null | tr ' ' '\n' | grep -qx "$group" || sudo usermod -aG "$group" "$user"

    sudo tee "$rule" >/dev/null <<EOF
ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="$BAT", RUN+="/usr/bin/chgrp $group /sys/class/power_supply/$BAT/charge_types", RUN+="/usr/bin/chmod 0664 /sys/class/power_supply/$BAT/charge_types"
EOF

    sudo udevadm control --reload-rules
    sudo udevadm trigger --subsystem-match=power_supply

    sudo chgrp "$group" "$CT" 2>/dev/null && sudo chmod 0664 "$CT" 2>/dev/null

    echo "Done. Re-login (or reboot) so the '$group' group takes effect."
    echo "Then 'bat-threshold.sh set longlife' works without sudo."
}

case "${1:-get}" in
    get)   [[ -r "$CT" ]] && current_mode ;;
    list)
        [[ -r "$CT" ]] || die "no charge_types for $BAT"
        m=$(current_mode)
        for t in $(available_modes); do
            if [[ "$t" == "$m" ]]; then echo "* $t"; else echo "  $t"; fi
        done
        ;;
    set)   [[ -n "${2:-}" ]] || die "set needs a mode"; set_mode "$2" ;;
    toggle)
        case "$(current_mode)" in
            Long_Life) set_mode standard ;;
            *)         set_mode longlife ;;
        esac
        ;;
    status) printf '%s  %s%%  %s\n' "$(current_mode)" "$(capacity)" "$(charge_status)" ;;
    popup)  popup ;;
    setup)  setup ;;
    *)      usage; exit 1 ;;
esac
