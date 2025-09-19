-- items/workspaces.lua
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local query_workspaces =
	"aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
local query_focused = "aerospace list-workspaces --focused"

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

local workspaces = {}

local function withWindows(f)
	local open_windows = {}
	local get_windows = "aerospace list-windows --monitor all --format '%{workspace}%{app-name}' --json"
	local query_visible_workspaces =
		"aerospace list-workspaces --visible --monitor all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
	sbar.exec(get_windows, function(workspace_and_windows)
		for _, entry in ipairs(workspace_and_windows) do
			local workspace_index = entry.workspace
			local app = entry["app-name"]
			if open_windows[workspace_index] == nil then
				open_windows[workspace_index] = {}
			end
			table.insert(open_windows[workspace_index], app)
		end
		sbar.exec(query_focused, function(focused_workspaces)
			sbar.exec(query_visible_workspaces, function(visible_workspaces)
				local args = {
					open_windows = open_windows,
					focused_workspaces = focused_workspaces,
					visible_workspaces = visible_workspaces,
				}
				f(args)
			end)
		end)
	end)
end

local function updateWindow(workspace_index, args)
	local open_windows = args.open_windows[workspace_index]
	local focused_workspaces = args.focused_workspaces
	local visible_workspaces = args.visible_workspaces

	if open_windows == nil then
		open_windows = {}
	end

	local icon_line = ""
	local no_app = true
	for _, open_window in ipairs(open_windows) do
		no_app = false
		local app = open_window
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. " " .. icon
	end

	sbar.animate("tanh", 10, function()
		for _, visible_workspace in ipairs(visible_workspaces) do
			if no_app and workspace_index == visible_workspace["workspace"] then
				local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
				icon_line = " —"
				workspaces[workspace_index]:set({
					icon = { drawing = true },
					label = {
						string = icon_line,
						drawing = true,
						-- padding_right = 20,
						font = "sketchybar-app-font:Regular:16.0",
						y_offset = -1,
					},
					background = { drawing = true },
					padding_right = 1,
					padding_left = 1,
					display = monitor_id,
				})
				return
			end
		end
		if no_app and workspace_index ~= focused_workspaces then
			workspaces[workspace_index]:set({
				icon = { drawing = false },
				label = { drawing = false },
				background = { drawing = false },
				padding_right = 0,
				padding_left = 0,
			})
			return
		end
		if no_app and workspace_index == focused_workspaces then
			icon_line = " —"
			workspaces[workspace_index]:set({
				icon = { drawing = true },
				label = {
					string = icon_line,
					drawing = true,
					-- padding_right = 20,
					font = "sketchybar-app-font:Regular:16.0",
					y_offset = -1,
				},
				background = { drawing = true },
				padding_right = 1,
				padding_left = 1,
			})
		end

		workspaces[workspace_index]:set({
			icon = { drawing = true },
			label = { drawing = true, string = icon_line },
			background = { drawing = true },
			padding_right = 1,
			padding_left = 1,
		})
	end)
end

local function updateWindows()
	withWindows(function(args)
		for workspace_index, _ in pairs(workspaces) do
			updateWindow(workspace_index, args)
		end
	end)
end

local function updateWorkspaceMonitor()
	local workspace_monitor = {}
	sbar.exec(query_workspaces, function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local space_index = entry.workspace
			local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
			workspace_monitor[space_index] = monitor_id
		end
		for workspace_index, _ in pairs(workspaces) do
			local workspace = workspaces[workspace_index]
			workspace:set({
				display = workspace_monitor[workspace_index],
			})
			workspace.spacer:set({
				display = workspace_monitor[workspace_index],
			})
		end
	end)
end

local function onWorkspaceChanged(workspace, selected)
	sbar.animate("tanh", 10, function()
		workspace:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = { border_color = selected and colors.black or colors.bg1 },
		})
		workspace.space_bracket:set({
			background = { border_color = selected and colors.grey or colors.bg2 },
		})
	end)
	updateWindows()
end

sbar.exec(query_workspaces, function(workspaces_and_monitors)
	for _, entry in ipairs(workspaces_and_monitors) do
		local i = entry.workspace

		local workspace = sbar.add("item", "space." .. i, {
			icon = {
				font = { family = settings.font.numbers },
				string = i,
				padding_left = 15,
				padding_right = 8,
				color = colors.white,
				highlight_color = colors.red,
			},
			label = {
				padding_right = 20,
				color = colors.grey,
				highlight_color = colors.white,
				font = "sketchybar-app-font:Regular:16.0",
				y_offset = -1,
			},
			padding_right = 1,
			padding_left = 1,
			background = {
				color = colors.bg1,
				border_width = 1,
				border_color = colors.bg1,
			},
			click_script = "aerospace workspace " .. i,
		})

		workspaces[i] = workspace

		-- Single item bracket for space items to achieve double border on highlight
		local space_bracket = sbar.add("bracket", { workspace.name }, {
			background = {
				color = colors.transparent,
				height = 30,
				border_color = colors.bg2,
			},
		})
		workspaces[i].space_bracket = space_bracket

		-- Padding space
		local spacer = sbar.add("item", "item.padding." .. i, {
			script = "",
			width = 4,
		})
		workspaces[i].spacer = spacer

		workspace:subscribe("aerospace_workspace_change", function(env)
			onWorkspaceChanged(workspace, env.FOCUSED_WORKSPACE == i)
		end)
	end

	local spaces_indicator = sbar.add("item", {
		padding_left = -3,
		padding_right = 0,
		icon = {
			padding_left = 8,
			padding_right = 9,
			color = colors.grey,
			string = icons.switch.on,
		},
		label = {
			width = 0,
			padding_left = 0,
			padding_right = 8,
			string = "Spaces",
			color = colors.bg1,
		},
		background = {
			color = colors.with_alpha(colors.grey, 0.0),
			border_color = colors.with_alpha(colors.bg1, 0.0),
		},
	})

	spaces_indicator:subscribe("swap_menus_and_spaces", function()
		local currently_on = spaces_indicator:query().icon.value == icons.switch.on
		spaces_indicator:set({
			icon = currently_on and icons.switch.off or icons.switch.on,
		})
	end)

	spaces_indicator:subscribe("mouse.entered", function()
		sbar.animate("tanh", 30, function()
			spaces_indicator:set({
				background = {
					color = { alpha = 1.0 },
					border_color = { alpha = 1.0 },
				},
				icon = { color = colors.bg1 },
				label = { width = "dynamic" },
			})
		end)
	end)

	spaces_indicator:subscribe("mouse.exited", function()
		sbar.animate("tanh", 30, function()
			spaces_indicator:set({
				background = {
					color = { alpha = 0.0 },
					border_color = { alpha = 0.0 },
				},
				icon = { color = colors.grey },
				label = { width = 0 },
			})
		end)
	end)

	spaces_indicator:subscribe("mouse.clicked", function()
		sbar.trigger("swap_menus_and_spaces")
	end)

	local front_app = sbar.add("item", "front_app", {
		display = "active",
		icon = { drawing = false },
		label = {
			font = {
				style = settings.font.style_map["Black"],
				size = 12.0,
			},
		},
		updates = true,
	})

	front_app:subscribe("front_app_switched", function(env)
		front_app:set({ label = { string = env.INFO } })
	end)

	front_app:subscribe("mouse.clicked", function()
		sbar.trigger("swap_menus_and_spaces")
	end)

	space_window_observer:subscribe("aerospace_focus_change", function()
		updateWindows()
	end)

	space_window_observer:subscribe("display_change", function()
		updateWorkspaceMonitor()
		updateWindows()
	end)

	-- initial setup
	updateWorkspaceMonitor()

	sbar.exec(query_focused, function(focused_workspace)
		local i = focused_workspace:match("^%s*(.-)%s*$")
		local workspace = workspaces[i]
		onWorkspaceChanged(workspace, true)
	end)
end)

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	for app, _ in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. icon
	end

	if no_app then
		icon_line = " —"
	end
	-- sbar.animate("tanh", 10, function()
	-- 	workspaces[env.INFO.space]:set({ label = icon_line })
	-- end)
end)
