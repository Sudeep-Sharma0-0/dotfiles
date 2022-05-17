CPU=$(top -bn1 | grep Cpu | awk '{print $2}')%
printf " CPU %s" "$CPU"
