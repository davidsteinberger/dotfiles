local dark_colors = {
	black = 0xff45475a,
	white = 0xffcdd6f4,
	red = 0xfff38ba8,
	green = 0xffa6e3a1,
	blue = 0xff89b4fa,
	yellow = 0xfff9e2af,
	orange = 0xfffab387,
	magenta = 0xfff5c2e7,
	grey = 0xff6c7086,
	lavender = 0xffb4befe,
	rosewater = 0xfff5e0dc,
	text = 0xffcdd6f4,
	overlay0 = 0xff6c7086,
	transparent = 0x00000000,

	bar = {
		bg = 0x00000000,
		border = 0xff313244,
	},
	popup = {
		bg = 0xc0313244,
		border = 0xff6c7086,
	},
	bg1 = 0xff1e1e2e,
	bg2 = 0xff6c7086,
}

local light_colors = {
	black = 0xff5c5f77,
	white = 0xff4c4f69,
	red = 0xffd20f39,
	green = 0xff40a02b,
	blue = 0xff1e66f5,
	yellow = 0xffdf8e1d,
	orange = 0xfffe640b,
	magenta = 0xffea76cb,
	grey = 0xff9ca0b0,
	lavender = 0xff7287fd,
	rosewater = 0xffdc8a78,
	text = 0xff4c4f69,
	overlay0 = 0xff9ca0b0,
	transparent = 0x00000000,

	bar = {
		bg = 0x00000000,
		border = 0xffdce0e8,
	},
	popup = {
		bg = 0xc0dce0e8,
		border = 0xff9ca0b0,
	},
	bg1 = 0xffeff1f5,
	bg2 = 0xff9ca0b0,
}

local current_theme = "dark"
local colors = dark_colors

local function detect_theme()
	sbar.exec("defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo dark || echo light", function(mode)
		local new_theme = mode:gsub("%s+", "")
		if new_theme ~= current_theme then
			current_theme = new_theme
			if current_theme == "dark" then
				colors = dark_colors
			else
				colors = light_colors
			end
			sbar.trigger("theme_changed")
		end
	end)
end

detect_theme()

local function with_alpha(color, alpha)
	if alpha > 1.0 or alpha < 0.0 then
		return color
	end
	return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return setmetatable({
	dark = dark_colors,
	light = light_colors,
	with_alpha = with_alpha,
	get_current_theme = function()
		return current_theme
	end,
	detect_theme = detect_theme,
}, {
	__index = function(_, key)
		return colors[key]
	end,
})
