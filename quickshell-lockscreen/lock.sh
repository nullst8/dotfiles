#!/usr/bin/env bash
#
# Quickshell session lock (qylock) launcher.
#
# Vendored into the dotfiles repo from Darkkal44/qylock so local fixes survive
# a qylock reinstall. Heavy assets (QML imports and themes) are still read from
# the qylock install directory; only the launcher and QML are overridden here.

set -u

# Directory containing this script (the vendored copy).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# qylock install directory that provides imports/ and themes_link/.
ASSETS="${QYLOCK_ASSETS:-$HOME/.local/share/quickshell-lockscreen}"

if [[ ! -d "$ASSETS/imports" ]]; then
    echo "qylock assets not found at $ASSETS/imports" >&2
    echo "Install qylock first (git clone https://github.com/Darkkal44/qylock && ./qylock/quickshell.sh)" >&2
    exit 1
fi

# Set library paths
export QML2_IMPORT_PATH="$ASSETS/imports:$DIR/imports:${QML2_IMPORT_PATH:-}"
export QML_XHR_ALLOW_FILE_READ=1

# Get session type
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-$(loginctl show-session "$(loginctl | grep "$(whoami)" | awk '{print $1}')" -p Type --value 2>/dev/null || echo wayland)}"

# User theme preference
CONFIG_FILE="$HOME/.config/qylock/theme"
if [ -n "${1:-}" ]; then
    export QS_THEME="$1"
elif [ -f "$CONFIG_FILE" ]; then
    export QS_THEME=$(cat "$CONFIG_FILE")
else
    export QS_THEME="nier-automata"
fi

# Set theme path (prefer the qylock install, fall back to a local ./themes dir)
if [ -d "$ASSETS/themes_link/$QS_THEME" ]; then
    export QS_THEME_PATH="$ASSETS/themes_link/$QS_THEME"
elif [ -d "$ASSETS/../themes/$QS_THEME" ]; then
    export QS_THEME_PATH="$ASSETS/../themes/$QS_THEME"
elif [ -d "$HOME/.local/share/qylock/themes/$QS_THEME" ]; then
    export QS_THEME_PATH="$HOME/.local/share/qylock/themes/$QS_THEME"
else
    export QS_THEME_PATH="$ASSETS/themes_link/$QS_THEME"
fi

# Single-instance guard: only one lock screen may hold the session lock at a
# time. Concurrent triggers (hypridle lock_cmd + before_sleep_cmd + keybind)
# would otherwise spawn overlapping quickshell lockers.
LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/qylock.lock"
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    echo "Quickshell lock screen is already running; not starting another instance."
    exit 0
fi

echo "Locking with Quickshell using theme: $QS_THEME"
echo "Theme path: $QS_THEME_PATH"

# Process cleanup: drop other lockers so only this instance owns the session.
killall -9 hyprlock swaylock wlogout 2>/dev/null || true

# Execute lock (fd 9 keeps the flock held for the lifetime of quickshell).
exec quickshell -p "$DIR/lock_shell.qml"
