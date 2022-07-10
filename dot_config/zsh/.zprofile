if [[ "$(tty)" = "/dev/tty1" ]]; then
	pgrep bspwm || startx "$HOME/.config/X11/xinitrc"
fi

if [[ "$(tty)" = "/dev/tty2" ]]; then
	pgrep xfce4-session || startx "$HOME/.config/X11/xinitrc_xmonad"
fi

if [[ "$(tty)" = "/dev/tty3" ]]; then
	pgrep xfce4-session || startx "$HOME/.config/X11/xinitrc_dwm"
fi

if [[ "$(tty)" = "/dev/tty4" ]]; then
	pgrep cinnamon-session || startx "$HOME/.config/X11/xinitrc_cinnamon"
fi
