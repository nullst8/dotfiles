#!/bin/sh

export LANG="en_US.utf8"

# case "$(echo -e "Shutdown\nRestart\nLogout\nSuspend\nLock" | dmenu \
case "$(echo -e "Shutdown\nRestart\nSuspend\nLock" | dmenu \
    -nb "${COLOR_BACKGROUND:-#151515}" \
    -nf "${COLOR_DEFAULT:-#aaaaaa}" \
    -sf "${COLOR_HIGHLIGHT:-#589cc5}" \
    -sb "#1a1a1a" \
    -i -p \
    "Power:" -l 5)" in
        Shutdown) exec systemctl poweroff;;
        Restart) exec systemctl reboot;;
        # Logout) exec bspc quit;;
        Suspend) exec systemctl suspend;;
        Lock) exec betterlockscreen -l;;
        # Lock) exec systemctl --user start lock.target;;
esac
