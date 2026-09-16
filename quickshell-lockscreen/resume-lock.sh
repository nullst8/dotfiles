#!/usr/bin/env bash
#
# Reconcile the session lock after resuming from suspend.
#
# Hyprland's ext-session-lock-v1 state can desync across suspend/resume
# (see hyprwm/Hyprland discussion #13184): the compositor may report the
# session as unlocked while the quickshell lock surface is still mapped,
# leaving a stale lock surface on an already unlocked session. Kill the old
# locker, clear Hyprland's stale lock bookkeeping, then start a fresh lock.

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Stop any leftover lock screen client. This also releases lock.sh's flock.
pkill -TERM -f "quickshell.*lock_shell\.qml" 2>/dev/null || true
for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "quickshell.*lock_shell\.qml" >/dev/null 2>&1 || break
    sleep 0.1
done
pkill -KILL -f "quickshell.*lock_shell\.qml" 2>/dev/null || true
sleep 0.2

# Reset Hyprland's session lock state if it thinks a lock is active.
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl eval 'hl.clear_crashed_lockscreen()' >/dev/null 2>&1 || true
fi

# Start a fresh lock screen, detached so hypridle is not blocked.
setsid "$DIR/lock.sh" >/dev/null 2>&1 &
