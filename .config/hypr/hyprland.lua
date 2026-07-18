-- This file sources other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`

-- Internal stuff --
require("hyprland.lib")
require("hyprland.services")

-- Environment variables --
require("hyprland.env")

-- Default configurations --
require("hyprland.execs")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
require("hyprland.keybinds")

-- nwg-displays support --
if is_file_exists(HOME .. "/.config/hypr/workspaces.lua") then
	require("workspaces")
end
if is_file_exists(HOME .. "/.config/hypr/monitors.lua") then
	require("monitors")
end

-- Shell overrides --
require("hyprland.shellOverrides.main")
