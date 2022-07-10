#!/usr/bin/env bash

awk '{printf(" %dh:%dm", $1/3600, ($1%3600)/60)}' /proc/uptime
