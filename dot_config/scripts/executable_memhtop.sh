#!/bin/sh
free_output=$(free -m | grep Mem)

MEMUSED=$(echo $free_output | awk '{print $3}')
MEMTOT=$(echo $free_output | awk '{print $2}')

printf " %sMB / %sMB" "$MEMUSED" "$MEMTOT"
