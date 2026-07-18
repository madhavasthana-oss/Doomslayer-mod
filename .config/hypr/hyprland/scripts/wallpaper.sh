#!/bin/bash
WALLPAPER="$1"

# Expand tilde just in case
WALLPAPER="${WALLPAPER/#\~/$HOME}"

if [ -z "$WALLPAPER" ]; then
  echo "Error: No wallpaper path provided" >&2
  exit 1
fi

if [ ! -f "$WALLPAPER" ]; then
  echo "Error: Wallpaper not found: $WALLPAPER" >&2
  exit 1
fi

# Wait for hyprland socket to be available
for i in {1..30}; do
    if hyprctl monitors >/dev/null 2>&1; then
        break
    fi
    sleep 0.1
done

pkill hyprpaper 2>/dev/null
sleep 0.2

# Start hyprpaper in background, but give it a moment
hyprpaper &
sleep 0.5

# Now set wallpaper
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"

echo "Wallpaper set: $WALLPAPER"