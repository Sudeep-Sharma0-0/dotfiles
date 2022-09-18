#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

# Display Resolution
#xrandr --output DisplayPort-0 --primary --mode 2560x1440 --rate 144.00 --output HDMI-A-1 --mode 1920x1080 --rate 75.00 --right-of DisplayPort-0 --output HDMI-A-0 --mode 1920x1080 --rate 75.00 --above DisplayPort-0 &
#xrandr --output DisplayPort-0 --primary --mode 2560x1440 --rate 144.00 --output HDMI-A-1 --mode 1920x1080 --rate 75.00 &

# Cursor active at boot
xsetroot -cursor_name left_ptr &

# Starting utility applications at boot time
run stalonetray &
run mpd &
run flameshot &
dunst &
numlockx on &

# Conky
(sleep 5; conky -c $HOME/.config/conky/conky) &

picom --config $HOME/.xmonad/scripts/picom.conf &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Some ways to set your wallpaper besides variety or nitrogen
#feh --randomize --bg-fill /home/ns/Pictures/Wallpapers/Arch/Arch-1.png &
pgrep /usr/bin/emacs --daemon > /dev/null || /usr/bin/emacs --daemon > /dev/null 2>&1 &

run caffeine &
#run insync start &
#run ckb-next -b &
