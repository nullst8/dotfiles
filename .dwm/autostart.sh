picom --fade-in-step=1 --fade-out-step=1 --fade-delta=0 --no-fading-openclose &
feh --bg-fill /home/csh4dow/.dotfiles/nature.jpg

brightnessctl s 100%

dunst &

killall volumeicon
volumeicon &
nm-applet &
i3-battery-popup -n &

xsetroot -cursor_name left_ptr &
slstatus &

xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Left Handed Enabled" 1
xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
# xinput set-prop "HID 1bcf:08a0 Mouse" "libinput Left Handed Enabled" 1

xset s off
xset -dpms

redshift -x
redshift -O 5000

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# xrandr --dpi 96
