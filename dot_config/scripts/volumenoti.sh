function get_volume {
  amixer get Master | grep '%' | head -n 1 | cut -d '[' -f 2 | cut -d '%' -f 1
}

function send_notification {
  iconSound="audio-volume-high"
  iconMuted="audio-volume-muted"
  if is_mute ; then
    dunstify -i $iconMuted -r 2593 -u normal "mute"
  else
    volume=$(get_volume)
    bar=$(seq --separator="─" 0 "$((volume / 5))" | sed 's/[0-9]//g')
    dunstify -i $iconSound -r 2593 -u normal "    $bar"
  fi
}

case $1 in
  inc)
    amixer set Master on
    playerctl volume 0.05+
    send_notification
    ;;
  dec)
    amixer set Master on
    playerctl volume 0.05-
    send_notification
    ;;
esac
