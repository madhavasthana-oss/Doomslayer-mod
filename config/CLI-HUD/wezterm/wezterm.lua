-- WezTerm config (Doomslayer / Bad Blood)
-- Hyprland: native Wayland is broken on wezterm 20240203 → force XWayland.

local wezterm = require("wezterm")
local config = wezterm.config_builder()

--------------------------------------------------------------------------
-- Platform / launch
--------------------------------------------------------------------------
config.enable_wayland = false
config.enable_kitty_graphics = true
-- config.default_prog = { "/usr/bin/env zsh" }

--------------------------------------------------------------------------
-- Font + ligatures / OpenType features
-- CaskaydiaCove = Cascadia Code Nerd Font (same as Kitty / Ghostty)
-- calt/liga/clig  = programming ligatures (=>, !=, ===, ->, ...)
-- ss01..ss20      = stylistic sets (font-dependent; safe to request)
-- zero            = slashed zero when the font has it
--------------------------------------------------------------------------
config.font = wezterm.font_with_fallback({
	{
		family = "CaskaydiaCove Nerd Font Mono",
		weight = "Regular",
		harfbuzz_features = {
			"calt=1",
			"clig=1",
			"liga=1",
			"zero=1",
			"ss01=1",
			"ss02=1",
			"ss03=1",
			"ss04=1",
			"ss05=1",
			"ss06=1",
			"ss07=1",
			"ss08=1",
			"ss09=1",
			"ss10=1",
			"ss19=1",
			"ss20=1",
		},
	},
	"CaskaydiaCove Nerd Font",
	"JetBrains Mono",
	"Symbols Nerd Font Mono",
})
config.font_size = 8
config.line_height = 1.0
config.cell_width = 1.0
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
config.warn_about_missing_glyphs = false

-- Bold / italic variants keep the same ligature features
config.font_rules = {
	{
		intensity = "Bold",
		font = wezterm.font({
			family = "CaskaydiaCove Nerd Font Mono",
			weight = "Bold",
			harfbuzz_features = {
				"calt=1",
				"clig=1",
				"liga=1",
				"zero=1",
			},
		}),
	},
	{
		italic = true,
		font = wezterm.font({
			family = "CaskaydiaCove Nerd Font Mono",
			style = "Italic",
			harfbuzz_features = {
				"calt=1",
				"clig=1",
				"liga=1",
				"zero=1",
			},
		}),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = "CaskaydiaCove Nerd Font Mono",
			weight = "Bold",
			style = "Italic",
			harfbuzz_features = {
				"calt=1",
				"clig=1",
				"liga=1",
				"zero=1",
			},
		}),
	},
}

--------------------------------------------------------------------------
-- Window / chrome
--------------------------------------------------------------------------
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_decorations = "TITLE | RESIZE"
config.window_padding = {
	left = 25,
	right = 25,
	top = 25,
	bottom = 25,
}
config.window_frame = {
	font = wezterm.font({
		family = "CaskaydiaCove Nerd Font Mono",
		weight = "Regular",
	}),
	font_size = 9,
}

--------------------------------------------------------------------------
-- Terminal opacity
-- No background image anymore, so this is just a plain, flat opaque
-- terminal. Set to 1.0 = fully opaque. Lower it if you want a plain
-- (imageless) glass/transparency effect via WezTerm itself; just be
-- aware your Hyprland decoration:active_opacity / inactive_opacity
-- settings (confirmed present on this machine at 0.95 / 0.90) apply
-- on top of whatever you set here, since that's compositor-level and
-- outside WezTerm's control.
--------------------------------------------------------------------------
config.window_background_opacity = 0.7
config.text_background_opacity = 0.7

--------------------------------------------------------------------------
-- Colors (Bad Blood — from theme.conf / Kitty palette)
--------------------------------------------------------------------------
config.colors = {
	foreground = "#FF2222",
	background = "#040000",
	cursor_bg = "#FF0000",
	cursor_fg = "#FFFFFF",
	cursor_border = "#FF0000",
	selection_fg = "#FFFFFF",
	selection_bg = "#4d0900",
	ansi = {
		"#000000",
		"#90002a",
		"#FF6347",
		"#C51046",
		"#FF69B4",
		"#DC143C",
		"#FFA07A",
		"#FFC080",
	},
	brights = {
		"#800080",
		"#FF0033",
		"#FFA500",
		"#FF6347",
		"#C71585",
		"#FF1493",
		"#FF0000",
		"#FFA500",
	},
	tab_bar = {
		active_tab = {
			bg_color = "#80bfff",
			fg_color = "#00141d",
		},
		inactive_tab = {
			bg_color = "#1a1a1a",
			fg_color = "#FFFFFF",
		},
		new_tab = {
			bg_color = "#1a1a1a",
			fg_color = "#4fc3f7",
		},
	},
}

--------------------------------------------------------------------------
-- Cursor / term / performance
--------------------------------------------------------------------------
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.term = "xterm-256color"
config.bold_brightens_ansi_colors = false
config.max_fps = 120
config.animation_fps = 60
config.front_end = "OpenGL"
config.webgpu_power_preference = "HighPerformance"

-- Unicode / emoji / undercurl
config.unicode_version = 14
config.custom_block_glyphs = true
config.underline_thickness = "200%"
config.underline_position = "-2pt"

--------------------------------------------------------------------------
-- Keys (ALT for tabs & splits)
--------------------------------------------------------------------------
config.keys = {
	-- Tabs
	{ key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "ALT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	{ key = "n", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },

	-- Panes
	{ key = "v", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },

	-- Pane navigation
	{ key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },

	-- Clipboard (explicit)
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

	-- Font size
	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },

	-- Fullscreen
	{ key = "Enter", mods = "ALT", action = wezterm.action.ToggleFullScreen },
}

--------------------------------------------------------------------------
-- Scrollback / misc
--------------------------------------------------------------------------
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.check_for_updates = false

return config
