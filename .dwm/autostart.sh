# picom --fade-in-step=1 --fade-out-step=1 --fade-delta=0 --no-fading-openclose &
feh --bg-fill ~/pictures/arch.jpg
nvim --headless &

brightnessctl s 100%

dunst &

killall volumeicon
volumeicon &
nm-applet &
#connman-ui-gtk &
i3-battery-popup -n &
blueman-applet &

xsetroot -cursor_name left_ptr &
slstatus &

xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Left Handed Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
xinput set-prop 10 "libinput Left Handed Enabled" 1

xset s off
xset -dpms

pactl -- set-sink-volume 0 100%

# wmname LG3D

redshift -x
redshift -O 5000

kdeconnect-indicator &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
