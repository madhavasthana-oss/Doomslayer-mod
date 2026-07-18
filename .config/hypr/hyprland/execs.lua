-- put former exec-once commands inside the func and former exec commands outside
hl.on("hyprland.start", function ()
    -- local variables
    local home = os.getenv("HOME")
    local wallpaper = string.format("%s/Pictures/Wallpapers/Doomslayer-1.jpg", home)
    local wallpaper_script_path = string.format("%s/.config/hypr/hyprland/scripts/wallpaper.sh", home)
    local quickshell_path = string.format("%s/Doomslayer-mod/.config/quickshell/shell.qml", home)
    
    -- Bar, wallpaper
    hl.exec_cmd("$HOME/.config/hypr/hyprland/scripts/start_geoclue_agent.sh")
    hl.exec_cmd("$HOME/.config/hypr/custom/scripts/__restore_video_wallpaper.sh")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("dbus-update-activation-environment --all")
    hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP") -- Some fix idk

    -- Audio
    hl.exec_cmd("easyeffects --hide-window --service-mode")

    -- Clipboard: history
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

    -- kill noctalia
    hl.exec_cmd("pkill -f noctalia")

    -- load wallpaper
    hl.exec_cmd(string.format("bash %s %q", wallpaper_script_path, wallpaper))

    -- load quickshell
    hl.exec_cmd(string.format("quickshell -p %q", quickshell_path))
end)
