#!/bin/sh
free_output=$(free -m | grep Mem)

MEMUSED=$(echo $free_output | awk '{printf ("%.0f", $3)}')
MEMTOT=$(echo $free_output | awk '{printf ("%.0f", $2)}')

printf " %s MB" "$MEMUSED"
