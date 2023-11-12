local wezterm = require("wezterm")

local function configs(dark, light)
	local appearance = wezterm.gui.get_appearance()
	if appearance:find("Dark") then
		return dark
	else
		return light
	end
end

local colorsDark = {
	foreground = "#dcd7ba",
	background = "#1f1f28",
	cursor_bg = "#c8c093",
	-- cursor_fg = "#c8c093",
	cursor_border = "#c8c093",
	selection_fg = "#c8c093",
	selection_bg = "#2d4f67",
	scrollbar_thumb = "#16161d",
	split = "#16161d",
	ansi = { "#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
	brights = { "#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
	indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

local colorsLight = {
	foreground = "#545464",
	background = "#f2ecbc",
	cursor_bg = "#c8c093",
	-- cursor_fg = "#c8c093",
	cursor_border = "#c8c093",
	selection_fg = "#c8c093",
	selection_bg = "#2d4f67",
	scrollbar_thumb = "#16161d",
	split = "#16161d",
	ansi = { "#090618", "#c34043", "#76946a", "#938056", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093" },
	brights = { "#727169", "#e82424", "#98bb6c", "#938056", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba" },
	indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}
return {
	window_background_opacity = configs(0.95, 1),
	send_composed_key_when_right_alt_is_pressed = true,
	-- send_composed_key_when_left_alt_is_pressed = true,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	hide_tab_bar_if_only_one_tab = true,
	font = wezterm.font_with_fallback({
		"ComicCodeLigatures Nerd Font",
		"FiraCode Nerd Font",
		"JetBrainsMono Nerd Font",
		"MesloLGS NF",
	}),
	font_size = 16.0,
	-- force_reverse_video_cursor = true,
	colors = configs(colorsDark, colorsLight),
	keys = {
		{
			key = "Enter",
			mods = "ALT",
			action = wezterm.action.DisableDefaultAssignment,
		},
	},
}
