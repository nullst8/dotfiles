#!/usr/bin/env bash
# media — show ONE MPRIS player in waybar.
# Pick: a Playing player (sticky: keep the current one while it still plays),
# else the current one if paused, else the first Paused. Only emits on change.
MAX=32
STATE="${XDG_RUNTIME_DIR:-/tmp}/media.player"
current=""
last=""

pick() {
    local line player status playing="" paused="" cur_status=""
    while IFS='|' read -r player status _; do
        [[ "$player" == "$current" ]] && cur_status="$status"
        [[ "$status" == "Playing" && -z "$playing" ]] && playing="$player"
        [[ "$status" == "Paused"  && -z "$paused"  ]] && paused="$player"
    done < <(playerctl -a metadata --format '{{playerInstance}}|{{status}}|' 2>/dev/null)

    if   [[ "$cur_status" == "Playing" ]]; then :
    elif [[ -n "$playing" ]]; then current="$playing"
    elif [[ "$cur_status" == "Paused"  ]]; then :
    elif [[ -n "$paused"  ]]; then current="$paused"
    else current=""; fi
}

render() {
    local out status artist title icon label tip
    pick
    printf %s "$current" > "$STATE"
    if [[ -z "$current" ]]; then
        out='{"text":"","class":"stopped"}'
    else
        IFS='|' read -r status artist title < <(playerctl -p "$current" metadata \
            --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null)
        if [[ -z "$title" ]]; then
            out='{"text":"","class":"stopped"}'
        else
            [[ "$status" == "Playing" ]] && icon=$'' || icon=$''
            label="$title"; [[ -n "$artist" ]] && label="$artist - $title"
            tip="$label"
            (( ${#label} > MAX )) && label="${label:0:MAX-1}…"
            for v in label tip; do
                local s=${!v}; s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//&/&amp;}
                printf -v "$v" '%s' "$s"
            done
            out=$(printf '{"text":"%s  %s","tooltip":"%s","class":"%s"}' "$icon" "$label" "$tip" "${status,,}")
        fi
    fi
    if [[ "$out" != "$last" ]]; then echo "$out"; last="$out"; fi
}

while true; do
    render
    sleep 1
done
