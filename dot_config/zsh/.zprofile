if [[ "$(tty)" = "/dev/tty1" ]]; then
	pgrep bspwm || startx "$HOME/.config/X11/xinitrc"
fi

if [[ "$(tty)" = "/dev/tty2" ]]; then
	pgrep xmonad || startx "$HOME/.config/X11/xinitrc2"
fi

if [[ "$(tty)" = "/dev/tty3" ]]; then
	pgrep xfce4-session || startx "$HOME/.config/X11/xinitrc_i3"
fi

if [[ "$(tty)" = "/dev/tty4" ]]; then
	pgrep cinnamon-session || startx "$HOME/.config/X11/xinitrc_cinnamon"
fi
