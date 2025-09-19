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
				local workspace = workspaces[workspace_index]
				icon_line = " —"
				workspace:set({
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
				workspace.spacer:set({
					display = monitor_id,
					drawing = true,
				})
				return
			end
		end
		local workspace = workspaces[workspace_index]
		if no_app and workspace_index ~= focused_workspaces then
			workspace:set({
				icon = { drawing = false },
				label = { drawing = false },
				background = { drawing = false },
				padding_right = 0,
				padding_left = 0,
			})
			workspace.spacer:set({
				drawing = false,
			})
			return
		end
		if no_app and workspace_index == focused_workspaces then
			icon_line = " —"
			workspace:set({
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
			workspace.spacer:set({
				drawing = true,
			})
		end

		workspace:set({
			icon = { drawing = true },
			label = { drawing = true, string = icon_line },
			background = { drawing = true },
			padding_right = 1,
			padding_left = 1,
		})
		workspace.spacer:set({
			drawing = true,
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
			background = { border_color = selected and colors.lavender or colors.bg2 },
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
				color = colors.lavender,
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

	local front_app = sbar.add("item", "front_app", {
		display = "active",
		icon = { drawing = false },
		label = {
			color = colors.text,
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

-- space_window_observer:subscribe("space_windows_change", function(env)
-- 	local icon_line = ""
-- 	local no_app = true
-- 	for app, _ in pairs(env.INFO.apps) do
-- 		no_app = false
-- 		local lookup = app_icons[app]
-- 		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
-- 		icon_line = icon_line .. icon
-- 	end
--
-- 	if no_app then
-- 		icon_line = " —"
-- 	end
-- 	-- sbar.animate("tanh", 10, function()
-- 	-- 	workspaces[env.INFO.space]:set({ label = icon_line })
-- 	-- end)
-- end)
