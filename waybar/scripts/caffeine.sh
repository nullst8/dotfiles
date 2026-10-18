#!/usr/bin/env bash
# caffeine — block idle/sleep via a systemd inhibitor held by a background process.
#   toggle  → flip on/off and refresh waybar
#   (none)  → print waybar JSON status
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.pid"

is_on() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

case "${1:-status}" in
    toggle)
        if is_on; then
            kill "$(cat "$PIDFILE")" 2>/dev/null || true
            rm -f "$PIDFILE"
        else
            nohup systemd-inhibit --what=idle:sleep --who=caffeine \
                --why="Caffeine enabled from waybar" sleep infinity >/dev/null 2>&1 &
            echo $! > "$PIDFILE"
        fi
        pkill -SIGRTMIN+10 waybar || true
        ;;
    *)
        if is_on; then
            printf '{"text":"\\udb80\\udd76","tooltip":"Caffeine: on (sleep blocked)","class":"on"}\n'
        else
            printf '{"text":"\\udb80\\udd76","tooltip":"Caffeine: off","class":"off"}\n'
        fi
        ;;
esac
