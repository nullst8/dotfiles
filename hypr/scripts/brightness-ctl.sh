#!/usr/bin/env bash
set -euo pipefail

hw_pct() {
    local cur max
    cur=$(brightnessctl g | grep -oE '[0-9]+' | head -1)
    max=$(brightnessctl m | grep -oE '[0-9]+' | head -1)
    echo $(( cur * 100 / max ))
}

gamma_pct() {
    local g
    g=$(hyprctl hyprsunset gamma 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)
    if [[ -z "$g" ]]; then
        g=100
    fi
    echo "$g"
}

osd() { # osd <fraction 0-1> <label>
    swayosd-client --custom-icon display-brightness-symbolic \
        --custom-progress "$1" --custom-progress-text "$2" >/dev/null 2>&1 || true
}

case "$1" in
    up)
        if [ "$(hw_pct)" -lt 100 ]; then
            brightnessctl set 3%+ >/dev/null
            osd "$(awk -v p="$(hw_pct)" 'BEGIN{print p/100}')" "$(hw_pct)%"
        else
            g=$(gamma_pct)
            ng=$(( g + 10 ))
            [ "$ng" -gt 150 ] && ng=150
            hyprctl hyprsunset gamma "$ng"
            osd "$(awk -v g="$ng" 'BEGIN{print g/150}')" "${ng}%"
        fi
        ;;
    down)
        g=$(gamma_pct)
        if [ "$g" -gt 100 ]; then
            ng=$(( g - 10 ))
            [ "$ng" -lt 100 ] && ng=100
            hyprctl hyprsunset gamma "$ng"
            osd "$(awk -v g="$ng" 'BEGIN{print g/150}')" "${ng}%"
        else
            brightnessctl set 3%- >/dev/null
            osd "$(awk -v p="$(hw_pct)" 'BEGIN{print p/100}')" "$(hw_pct)%"
        fi
        ;;
    *)
        exit 1
        ;;
esac
