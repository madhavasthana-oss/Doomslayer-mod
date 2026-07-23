#!/usr/bin/env bash
# Apply Doomslayer-mod rofi config --> live ~/.config/rofi
set -euo pipefail

MOD_ROOT="${HOME}/Doomslayer-mod"
SRC="${MOD_ROOT}/.config/rofi"
DST="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"

if [[ ! -d "$SRC" ]]; then
	echo "error: source missing: $SRC" >&2
	exit 1
fi

echo "--> syncing (mod --> live)"
echo "    $SRC/"
echo "    ==> $DST/"
mkdir -p "$DST"
rsync -a --delete "$SRC/" "$DST/"
chmod +x "$DST/launch.sh" 2>/dev/null || true

echo "==> synced successfully"
echo "    try: ~/.config/rofi/launch.sh drun"
echo "    or:  Super+A (appManager)"
echo "==> done"
