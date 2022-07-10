#!/usr/bin/env bash

BAR_PADDING=$(bspc config -m focused top_padding)

echo $BAR_PADDING

if [ $BAR_PADDING -ge 30 ]; then
    polybar-msg cmd toggle && bspc config -m focused top_padding 0 && bspc config window_gap 0
else
    polybar-msg cmd toggle && bspc config -m focused top_padding 30 && bspc config window_gap 5
fi
