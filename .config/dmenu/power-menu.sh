#!/bin/sh

export LANG="en_US.utf8"

# case "$(echo -e "Shutdown\nRestart\nLogout\nSuspend\nLock" | dmenu \
case "$(echo "Shutdown\nRestart\nSuspend\nLock" | dmenu \
    -nb "${COLOR_BACKGROUND:-#151515}" \
    -nf "${COLOR_DEFAULT:-#aaaaaa}" \
    -sf "${COLOR_HIGHLIGHT:-#589cc5}" \
    -sb "#1a1a1a" \
    -i -p \
    "Power:" -l 5)" in
        Shutdown) exec loginctl poweroff;;
        Restart) exec loginctl reboot;;
        # Logout) exec bspc quit;;
        Suspend) exec loginctl suspend;;
        Lock) exec slock;;
        # Lock) exec systemctl --user start lock.target;;
esac
