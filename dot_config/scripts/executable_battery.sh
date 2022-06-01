#!/usr/bin/env bash

OUTPUT=$(acpi | awk '{print $4}' | sed s/,//)

if [[ $OUTPUT == '100%' ]]; then
   printf "  %s" "$OUTPUT"
fi
