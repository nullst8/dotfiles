picom --fade-in-step=1 --fade-out-step=1 --fade-delta=0 &
feh --bg-fill /usr/share/backgrounds/solus/Excl_Autumn_Leaf.jpg

dunst &

nm-applet &
blueman-applet &

xsetroot -cursor_name left_ptr &
slstatus &

# xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Left Handed Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "HID 1bcf:08a0 Mouse" "libinput Left Handed Enabled" 1

pactl -- set-sink-volume 0 100%

# wmname LG3D

xautolock -time 10 -locker slock &

redshift -x
redshift -O 5000

kdeconnect-indicator &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
