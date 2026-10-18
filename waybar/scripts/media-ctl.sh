#!/usr/bin/env bash
# media-ctl <play-pause|next|previous> — act on the player shown in the bar.
p=$(cat "${XDG_RUNTIME_DIR:-/tmp}/media.player" 2>/dev/null)
exec playerctl ${p:+-p "$p"} "$1"
