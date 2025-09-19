return {
	black = 0xff181819,
	white = 0xffe2e2e3,
	red = 0xfff38ba8,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	lavender = 0xffb4befe,
	rosewater = 0xfff5e0dc,
	text = 0xffcdd6f4,
	overlay0 = 0xff9399b2,
	transparent = 0x00000000,

	bar = {
		bg = 0x00000000,
		border = 0xff2c2e34,
	},
	popup = {
		bg = 0xc02c2e34,
		border = 0xff7f8490,
	},
	bg1 = 0xff1e1e2e,
	bg2 = 0xff9399b2,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
