#!/usr/bin/env bash
# Start gnome-keyring and unlock the login keyring, without any prompt.
#
# WHY THIS EXISTS
#   greetd runs the session as the user but never runs pam_gnome_keyring.so,
#   so nothing unlocks the login keyring. /etc/pam.d/greetd has no keyring
#   line, and the shipped /etc/xdg/autostart/gnome-keyring-*.desktop files are
#   OnlyShowIn=GNOME so they are skipped under Hyprland. Without this script
#   the keyring stays locked and every Secret Service caller either hangs or
#   fails with "prompting failed: The operation was cancelled".
#
# WHY IT MUST BE THE ONLY STARTUP PATH
#   `gnome-keyring-daemon --unlock` both starts the daemon *and* unlocks the
#   keyring, so it only works when no daemon is running yet. If one is already
#   running (systemd socket activation, or the XDG autostart units, which the
#   systemd-xdg-autostart-generator starts despite OnlyShowIn=GNOME) then this
#   command forks a *second* daemon that cannot own org.freedesktop.secrets,
#   and the keyring silently stays locked. That double-daemon collision is
#   pinned down by masking the units -- see MASKING below.
#
# MASKING
#   gnome-keyring-daemon.socket and gnome-keyring-daemon.service are masked in
#   the user manager so nothing can pre-start a daemon. Same for the two XDG
#   autostart units, which are suppressed with Hidden=true overrides in
#   ~/.config/autostart/gnome-keyring-{pkcs11,secrets}.desktop. Re-check with:
#     systemctl --user is-enabled gnome-keyring-daemon.socket
#
# The password lives in a 0600 file *outside* the dotfiles repo so it can never
# be committed. It is a convenience secret, not a login password.
#   printf 'your-password' > ~/.config/gnome-keyring/unlock.pass
#   chmod 600 ~/.config/gnome-keyring/unlock.pass

set -uo pipefail

PASS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/gnome-keyring/unlock.pass"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Already handled (by a previous run, or a manual unlock). Note: -x matches
# against the kernel's 15-char comm, which is "gnome-keyring-d", so the long
# name never matches and -f against the full cmdline is used instead.
if pgrep -f "gnome-keyring-daemon" >/dev/null 2>&1; then
    exit 0
fi

if [[ ! -r $PASS_FILE ]]; then
    echo "keyring-unlock: cannot read $PASS_FILE" >&2
    exit 1
fi

# gnome-keyring 1:50 does not create this itself when it is started by
# --unlock, and without it the daemon cannot advertise its control socket.
mkdir -p "$RUNTIME_DIR/keyring"
chmod 700 "$RUNTIME_DIR/keyring"

# The newline matters: empty stdin is ignored by gnome-keyring, so a keyring
# with an empty password still needs a real line to be created/unlocked.
printf '%s\n' "$(cat "$PASS_FILE")" | gnome-keyring-daemon --unlock
rc=$?

if ((rc != 0)); then
    echo "keyring-unlock: gnome-keyring-daemon --unlock failed (rc=$rc)" >&2
    exit "$rc"
fi

# Give the daemon a moment to register the login collection, then confirm it
# actually came up rather than reporting success on a silent failure.
for _ in {1..20}; do
    if gdbus introspect --session --dest org.freedesktop.secrets \
        --object-path /org/freedesktop/secrets >/dev/null 2>&1; then
        exit 0
    fi
    sleep 0.25
done

echo "keyring-unlock: Secret Service did not appear on the session bus" >&2
exit 1
