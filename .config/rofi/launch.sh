#!/usr/bin/env bash
# Doomslayer rofi launcher --- fix locale for xkb compose, then show mode.
# LANG=en_IN (non-UTF-8) maps to en_IN.ISO8859-1 which has no Compose file.
set -euo pipefail

MODE="${1:-drun}"

# Prefer system India UTF-8, then C.UTF-8. Leave other LC_* alone if set.
if locale -a 2>/dev/null | grep -qiE '^en_IN\.utf-?8$'; then
	export LANG=en_IN.UTF-8
	export LC_CTYPE=en_IN.UTF-8
elif locale -a 2>/dev/null | grep -qiE '^C\.utf-?8$'; then
	export LANG=C.UTF-8
	export LC_CTYPE=C.UTF-8
elif locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
	export LANG=en_US.UTF-8
	export LC_CTYPE=en_US.UTF-8
fi
unset LC_ALL 2>/dev/null || true

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
exec rofi -config "$CONFIG" -show "$MODE"
