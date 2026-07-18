#!/usr/bin/env bash
ROOT_DOOMSLAYER=$HOME/Doomslayer-mod/config/hypr
echo "--> setting hyprland config, make sure the directory has been configured in ${ROOT_DOOMSLAYER}"
cp -r "$ROOT_DOOMSLAYER" "$HOME/.config"
echo "==> configured succesfully, reloading hyprland"
hyprctl reload