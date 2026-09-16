#!/usr/bin/env bash
set -euo pipefail

NL=~/.dotfiles/scripts/nightlight.sh

state=$("$NL" state 2>/dev/null)
temp=$("$NL" get 2>/dev/null)

case "$state" in
    on) icon="\uf186"; cls="night" ;;
    *)  icon="\uf185"; cls="day" ;;
esac

printf '{"text":"%s","tooltip":"Night light: %s (%s K)","class":"%s"}\n' "$icon" "$state" "$temp" "$cls"
