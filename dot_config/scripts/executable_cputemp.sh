#!/usr/bin/env bash

sensors | grep "Package id 0:" | awk '{printf(" %.0f°C",substr($4,2))}'
