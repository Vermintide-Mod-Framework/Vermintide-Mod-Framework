--[[
	Author:
--]]

local gui = new_mod("gui")
local basic_gui = get_mod("basic_gui")

-- ################################################################################################################
-- ##### UTF8 #####################################################################################################
-- ################################################################################################################
local UTF8 = {
	-- UTF-8 Reference:
	-- 0xxxxxxx - 1 byte UTF-8 codepoint (ASCII character)
	-- 110yyyxx - First byte of a 2 byte UTF-8 codepoint
	-- 1110yyyy - First byte of a 3 byte UTF-8 codepoint
	-- 11110zzz - First byte of a 4 byte UTF-8 codepoint
	-- 10xxxxxx - Inner byte of a multi-byte UTF-8 codepoint

	chsize = function(self, char)
		if not char then
			return 0
		elseif char > 240 then
			return 4
		elseif char > 225 then
			return 3
		elseif char > 192 then
			return 2
		else
			return 1
		end
	end,

	-- This function can return a substring of a UTF-8 string, properly handling
	-- UTF-8 codepoints.  Rather than taking a start index and optionally an end
	-- index, it takes the string, the starting character, and the number of
	-- characters to select from the string.

	utf8sub = function(self, str, startChar, numChars)
		local startIndex = 1
		while startChar > 1 do
			local char = string.byte(str, startIndex)
			startIndex = startIndex + self:chsize(char)
			startChar = startChar - 1
		end

		local currentIndex = startIndex

		while numChars > 0 and currentIndex <= #str do
			local char = string.byte(str, currentIndex)
			currentIndex = currentIndex + self:chsize(char)
			numChars = numChars -1
		end
		return str:sub(startIndex, currentIndex - 1)
	end,
}


-- ################################################################################################################
-- ##### Input keymap #############################################################################################
-- ################################################################################################################
MOD_GUI_KEY_MAP = {
	win32 = {
		["backspace"] = {"keyboard", "backspace", "held"},
		["enter"] = {"keyboard", "enter", "pressed"},
		["esc"] = {"keyboard", "esc", "pressed"},
	},
}
MOD_GUI_KEY_MAP.xb1 = MOD_GUI_KEY_MAP.win32
local ui_special_keys = {"space", "<", ">"}

-- ################################################################################################################
-- ##### Color helper #############################################################################################
-- ################################################################################################################
local ColorHelper = {
	--[[
		Transform color values to table
	]]--
	box = function(a, r, g, b)
		return {a, r, g, b}
	end,
	--[[
		Transform color table to color
	]]--
	unbox = function(box)
		return Color(box[1], box[2], box[3], box[4])
	end,
}

-- ################################################################################################################
-- ##### Main Object ##############################################################################################
-- ################################################################################################################
gui.theme = "default"

gui.width = 1920
gui.height = 1080

gui.adjust_to_fit_position_and_scale = function(position)
	position = gui.adjust_to_fit_scale(position)

	local screen_w, screen_h = UIResolution()
	local scale = UIResolutionScale()
	local ui_w = 1920*scale
	local ui_h = 1080*scale

	position = {
		position[1] + (screen_w - ui_w)/2,
		position[2] + (screen_h - ui_h)/2
	}

	--gui:echo(position[1], position[2])

	return position
end

gui.adjust_to_fit_scale = function(position)
	if not position then return {0, 0} end

	local scale = UIResolutionScale()

	position = {
		position[1] * scale,
		position[2] * scale
	}

	--gui:echo(position[1], position[2])

	return position
end

-- ################################################################################################################
-- ##### Create containers ########################################################################################
-- ################################################################################################################
--[[
	Create window
]]--
gui.create_window = function(name, position, size)

	-- Create window
	position = gui.adjust_to_fit_position_and_scale(position)
	size = gui.adjust_to_fit_scale(size)

	local window = table.clone(gui.widgets.window)
	window:set("name", name or "name")
	window:set("position", position)
	window:set("size", size or {0, 0})
	window:set("original_size", size or {0, 0})

	-- Add window to list
	gui.windows:add_window(window)

	return window
end

-- ################################################################################################################
-- ##### Cycle ####################################################################################################
-- ################################################################################################################
--[[
	Update
]]--
gui._update = function(dt)
	-- Update timers
	gui.timers:update(dt)

	gui.input:check()

	-- Click
	local position = gui.mouse:cursor()
	if stingray.Mouse.pressed(stingray.Mouse.button_id("left")) then
		gui.mouse:click(position, gui.windows.list)
	elseif stingray.Mouse.released(stingray.Mouse.button_id("left")) then
		gui.mouse:release(position, gui.windows.list)
	end

	-- Hover
	gui.mouse:hover(position, gui.windows.list)

	-- Update windows
	gui.windows:update()
end

gui:hook("MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)
	gui._update(dt)
end)

-- ################################################################################################################
-- ##### Common functions #########################################################################################
-- ################################################################################################################
--[[
	Transform position and size to bounds
]]--
gui.to_bounds = function(position, size)
	return {position[1], position[1] + size[1], position[2], position[2] + size[2]}
end
--[[
	Check if position is in bounds
]]--
gui.point_in_bounds = function(position, bounds)
	if position[1] >= bounds[1] and position[1] <= bounds[2] and position[2] >= bounds[3] and position[2] <= bounds[4] then
		return true, {position[1] - bounds[1], position[2] - bounds[3]}
	end
	return false, {0, 0}
end

-- ################################################################################################################
-- ##### Window system ############################################################################################
-- ################################################################################################################
gui.windows = {
	list = {},
	--[[
		Add window to list
	]]--
	add_window = function(self, window)
		self:inc_z_orders(#self.list)
		window.z_order = 1
		self.list[#self.list+1] = window
	end,
	--[[
		Shift z orders of windows
	]]--
	inc_z_orders = function(self, changed_z)
		for z=changed_z, 1, -1 do
			for _, window in pairs(self.list) do
				if window.z_order == z then
					window.z_order = window.z_order + 1
				end
			end
		end
	end,
	--[[
		Shift z orders of windows
	]]--
	dec_z_orders = function(self, changed_z)
		--for z=changed_z, 1, -1 do
		for z=changed_z+1, #self.list do
			for _, window in pairs(self.list) do
				if window.z_order == z then
					window.z_order = window.z_order - 1
				end
			end
		end
	end,
	--[[
		Shift z orders of windows
	]]--
	unfocus = function(self)
		for _, window in pairs(self.list) do
			if window.z_order == 1 then
				window:unfocus()
			end
		end
	end,
	--[[
		Update windows
	]]--
	update = function(self)
		if #self.list > 0 then
			for z=#self.list, 1, -1 do
				for _, window in pairs(self.list) do
					if window.visible then
						if window.z_order == z then
							window:update()
							window:render()
						end
					end
				end
			end
		end
	end,
}

-- ################################################################################################################
-- ##### Mouse system #############################################################################################
-- ################################################################################################################
gui.mouse = {
	--[[
		Process click
	]]--
	click = function(self, position, windows)
		for z=1, #windows do
			for _, window in pairs(windows) do
				if window.z_order == z then
					if gui.point_in_bounds(position, window:extended_bounds()) then
						window:click(position)
					else
						window:unfocus()
					end
				end
			end
		end
	end,
	--[[
		Process release
	]]--
	release = function(self, position, windows)
		for z=1, #windows do
			for _, window in pairs(windows) do
				if window.z_order == z then
					if gui.point_in_bounds(position, window:extended_bounds()) then
						window:release(position)
					else
						window:unfocus()
					end
				end
			end
		end
	end,
	--[[
		Process hover
	]]--
	hover = function(self, position, windows)
		self:un_hover_all(windows)
		for z=1, #windows do
			for _, window in pairs(windows) do
				if window.z_order == z then
					local hovered, cursor = gui.point_in_bounds(position, window:extended_bounds())
					if hovered then
						window:hover(cursor)
						return
					end
				end
			end
		end
	end,
	--[[
		Unhover all
	]]--
	un_hover_all = function(self, windows)
		for _, window in pairs(windows) do
			if window.hovered then
				window:hover_exit()
			end
		end
	end,
	--[[
		Get mouse position
	]]--
	cursor = function(self)
		local cursor_axis_id = stingray.Mouse.axis_id("cursor")	-- retrieve the axis ID
		local value = stingray.Mouse.axis(cursor_axis_id)		-- use the ID to access to value
		return {value[1], value[2]}
	end,
}

-- ################################################################################################################
-- ##### Timer system #############################################################################################
-- ################################################################################################################
gui.timers = {
	-- Timer list
	items = {},
	-- Timer template
	template = {
		name = nil,
		rate = 100,
		enabled = false,
		time_passed = 0,
		params = nil,

		-- ##### Methods ##############################################################################
		--[[
			Enable timer
		]]--
		enable = function(self)
			self.enabled = true
		end,
		--[[
			Disable timer
		]]--
		disable = function(self)
			self.enabled = false
		end,

		-- ##### Cycle ################################################################################
		--[[
			Process tick
		]]--
		tick = function(self)
			--if self.on_tick and type(self.on_tick) == "function" then
			self:on_tick(self.params)
			--end
		end,
		--[[
			Update
		]]--
		update = function(self, dt)
			if self.enabled then
				self.time_passed = self.time_passed + dt
				if self.time_passed >= self.rate / 1000 then
					self:tick()
					self.time_passed = 0
				end
			else
				self.time_passed = 0
			end
		end,

		-- ##### Events ################################################################################
		--[[
			On click event
		]]--
		on_tick = function(self, ...)
		end,
	},
	--[[
		Create timer
	]]--
	create_timer = function(self, name, rate, enabled, on_tick, ...) --, wait)
		if not table.has_item(self.items, name) then
			local new_timer = table.clone(self.template)
			new_timer.name = name or "timer_" .. tostring(#self.items+1)
			new_timer.rate = rate or new_timer.rate
			new_timer.enabled = enabled or new_timer.enabled
			new_timer.on_tick = on_tick or new_timer.on_tick
			new_timer.params = ...
			--new_timer.wait = wait or new_timer.wait
			self.items[name] = new_timer
			return new_timer
		end
		return nil
	end,
	--[[
		Update timers
	]]--
	update = function(self, dt)
		for name, timer in pairs(self.items) do
			timer:update(dt)
		end
	end,
}

-- ################################################################################################################
-- ##### Input system #############################################################################################
-- ################################################################################################################
gui.input = {
	blocked_services = nil,
	--[[
		Check and create input system
	]]--
	check = function(self)
		if not Managers.input:get_input_service("mod_gui") then
			Managers.input:create_input_service("mod_gui", "MOD_GUI_KEY_MAP")
			Managers.input:map_device_to_service("mod_gui", "keyboard")
			Managers.input:map_device_to_service("mod_gui", "mouse")
			Managers.input:map_device_to_service("mod_gui", "gamepad")
		end
	end,
	--[[
		Get list of unblocked input services and block them
	]]--
	block = function(self)
		if not self.blocked_services then
			self.blocked_services = {}
			Managers.input:get_unblocked_services("keyboard", 1, self.blocked_services)
			for _, s in pairs(self.blocked_services) do
				Managers.input:device_block_service("keyboard", 1, s)
				Managers.input:device_block_service("mouse", 1, s)
				Managers.input:device_block_service("gamepad", 1, s)
			end
		end
	end,
	--[[
		Unblock previously blocked services
	]]--
	unblock = function(self)
		if self.blocked_services then
			for _, s in pairs(self.blocked_services) do
				Managers.input:device_unblock_service("keyboard", 1, s)
				Managers.input:device_unblock_service("mouse", 1, s)
				Managers.input:device_unblock_service("gamepad", 1, s)
			end
			self.blocked_services = nil
		end
	end,
}

-- ################################################################################################################
-- ##### Font system ##############################################################################################
-- ################################################################################################################
gui.fonts = {
	fonts = {},
	--[[
		Font template
	]]--
	template = {
		font = "hell_shark",
		material = "materials/fonts/gw_body_32",
		size = 22,
		font_size = function(self)
			if not self.dynamic_size then
				return self.size
			else
				local screen_w, screen_h = UIResolution()
				local size = screen_w / 100
				return size
			end
		end,
		dynamic_size = false,
	},
	--[[
		Create font
	]]--
	create = function(self, name, font, size, material, dynamic_size)
		if not table.has_item(self.fonts, name) then
			local new_font = table.clone(self.template)
			new_font.font = font or new_font.font
			new_font.material = material or new_font.material
			new_font.size = size or new_font.size
			new_font.dynamic_size = dynamic_size or new_font.dynamic_size
			self.fonts[name] = new_font
		end
	end,
	--[[
		Get font by name
	]]--
	get = function(self, name)
		for k, font in pairs(self.fonts) do
			if k == name then
				return font
			end
		end
		return gui.fonts.default or nil
	end,
}

-- ################################################################################################################
-- ##### Anchor system ############################################################################################
-- ################################################################################################################
gui.anchor = {
	styles = {
		"bottom_left",
		"center_left",
		"top_left",
		"middle_top",
		"top_right",
		"center_right",
		"bottom_right",
		"middle_bottom",
		"fill",
	},
	bottom_left = {
		position = function(window, widget)
			local x = window.position[1] + widget.offset[1]
			local y = window.position[2] + widget.offset[2]
			return {x, y}, widget.size
		end,
	},
	center_left = {
		position = function(window, widget)
			local x = window.position[1] + widget.offset[1]
			local y = window.position[2] + window.size[2]/2 - widget.size[2]/2
			return {x, y}, widget.size
		end,
	},
	top_left = {
		position = function(window, widget)
			local x = window.position[1] + widget.offset[1]
			local y = window.position[2] + window.size[2] - widget.offset[2] - widget.size[2]
			return {x, y}, widget.size
		end,
	},
	middle_top = {
		position = function(window, widget)
			local x = window.position[1] + window.size[1]/2 - widget.size[1]/2
			local y = window.position[2] + window.size[2] - widget.offset[2] - widget.size[2]
			return {x, y}, widget.size
		end,
	},
	top_right = {
		position = function(window, widget)
			local x = window.position[1] + window.size[1] - widget.offset[1] - widget.size[1]
			local y = window.position[2] + window.size[2] - widget.offset[2] - widget.size[2]
			return {x, y}, widget.size
		end,
	},
	center_right = {
		position = function(window, widget)
			local x = window.position[1] + window.size[1] - widget.offset[1] - widget.size[1]
			local y = window.position[2] + window.size[2]/2 - widget.size[2]/2
			return {x, y}, widget.size
		end,
	},
	bottom_right = {
		position = function(window, widget)
			local x = window.position[1] + window.size[1] - widget.offset[1] - widget.size[1]
			local y = window.position[2] + widget.offset[2]
			return {x, y}, widget.size
		end,
	},
	middle_bottom = {
		position = function(window, widget)
			local x = window.position[1] + window.size[1]/2 - widget.size[1]/2
			local y = window.position[2] + widget.offset[2]
			return {x, y}, widget.size
		end,
	},
	fill = {
		position = function(window, widget)
			return {window.position[1], window.position[2]}, {window.size[1], window.size[2]}
		end,
	},
}

-- ################################################################################################################
-- ##### Textalignment system #####################################################################################
-- ################################################################################################################
gui.text_alignment = {
	bottom_left = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[3] - bounds[4]
			local left = bounds[1]
			local bottom = bounds[3]
			local fix = 2*scale
			return {left + fix, bottom + fix}
		end,
	},
	bottom_center = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[3] - bounds[4]
			local left = bounds[1]
			local bottom = bounds[3]
			local fix = 2*scale
			return {left + frame_width/2 - text_width/2, bottom + fix}
		end,
	},
	bottom_right = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[3] - bounds[4]
			local right = bounds[2]
			local bottom = bounds[3]
			local fix = 2*scale
			return {right - text_width, bottom + fix}
		end,
	},
	middle_left = {
		position = function(text, font, bounds, padding)
			local scale = UIResolutionScale()
			local text_height = font:font_size()
			local frame_height = bounds[4] - bounds[3]
			local left = bounds[1]
			local bottom = bounds[3]
			--local border = 5*scale
			local fix = 2*scale
			return {left + fix, bottom + fix + (frame_height/2) - (text_height/2)}
		end,
	},
	middle_center = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[4] - bounds[3]
			local left = bounds[1]
			local bottom = bounds[3]
			local fix = 2*scale
			return {left + fix + frame_width/2 - text_width/2, bottom + fix + (frame_height/2) - (text_height/2)}
		end,
	},
	middle_right = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[4] - bounds[3]
			local right = bounds[2]
			local bottom = bounds[3]
			local fix = 2*scale
			return {right - text_width - fix, bottom + fix + (frame_height/2) - (text_height/2)}
		end,
	},
	top_left = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[4] - bounds[3]
			local left = bounds[1]
			local top = bounds[4]
			local fix = 2*scale
			return {left + fix, top - fix - text_height/2}
		end,
	},
	top_center = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[4] - bounds[3]
			local left = bounds[1]
			local top = bounds[4]
			local fix = 2*scale
			return {left + frame_width/2 - text_width/2, top - fix - text_height/2}
		end,
	},
	top_right = {
		position = function(text, font, bounds)
			local scale = UIResolutionScale()
			local text_width = basic_gui.text_width(text, font.material, font:font_size())
			local text_height = font:font_size() --basic_gui.text_height(text, font.material, font:font_size())
			local frame_width = bounds[2] - bounds[1]
			local frame_height = bounds[4] - bounds[3]
			local right = bounds[2]
			local bottom = bounds[3]
			local fix = 2*scale
			return {right - fix - text_width, bottom - fix + frame_height - (text_height/2)}
		end,
	},
}

-- ################################################################################################################
-- ##### widgets #################################################################################################
-- ################################################################################################################
gui.widgets = {

	window = {
		name = "",
		position = {0, 0},
		size = {0, 0},
		original_size = {0, 0},
		initialized = false,
		hovered = false,
		cursor = {0, 0},
		dragging = false,
		drag_offset = {0, 0},
		resizing = false,
		resize_offset = {0, 0},
		resize_origin = {0, 0},
		z_order = 0,
		widgets = {},
		visible = true,
		transparent = false,

		-- ################################################################################################################
		-- ##### Init #####################################################################################################
		-- ################################################################################################################
		--[[
			Set value
		--]]
		set = function(self, attribute, value)
			self[attribute] = value
		end,
		--[[
			Refresh theme
		--]]
		refresh_theme = function(self)
			self.theme = {}
			-- Default
			local theme_element = gui.themes[gui.theme].default
			if theme_element then self:copy_theme_element(theme_element) end
			-- Specific
			local theme_element = gui.themes[gui.theme]["window"]
			if theme_element then self:copy_theme_element(theme_element) end
		end,
		--[[
			Copy theme element
		--]]
		copy_theme_element = function(self, theme_element)
			-- Go through elements
			for key, element in pairs(theme_element) do
				-- Set element
				self.theme[key] = element
			end
		end,

		-- ################################################################################################################
		-- ##### Create widgets ##########################################################################################
		-- ################################################################################################################
		--[[
			Create title bar
		--]]
		create_title = function(self, name, text, height)
			-- Base widget
			local widget = self:create_widget(name, nil, nil, "title")
			-- Set attributes
			widget:set("text", text or "")
			widget:set("height", height or gui.themes[gui.theme].title.height)
			-- Add widget
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create button
		--]]
		create_button = function(self, name, position, size, text, on_click, anchor)
			-- Base widget
			local widget = self:create_widget(name, position, size, "button", anchor)
			-- Set attributes
			widget:set("text", text or "")
			if on_click then
				widget:set("on_click", on_click)
			end
			-- Add widget
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create resizer
		--]]
		--[[create_resizer = function(self, name, size)
			-- Base widget
			local widget = self:create_widget(name, nil, size, "resizer")
			-- Set attributes
			widget:set("size", size or gui.themes[gui.theme].resizer.size)
			-- Add widget
			self:add_widget(widget)
			return widget
		end,--]]
		--[[
			Create close button
		--]]
		create_close_button = function(self, name)
			local widget = self:create_widget(name, {5, 0}, {25, 25}, "close_button", gui.anchor.styles.top_right)
			widget:set("text", "X")
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create textbox
		--]]
		create_textbox = function(self, name, position, size, text, placeholder, on_text_changed)
			local widget = self:create_widget(name, position, size, "textbox")
			widget:set("text", text or "")
			widget:set("placeholder", placeholder or "")
			if on_text_changed then
				widget:set("on_text_changed", on_text_changed)
			end
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create checkbox
		--]]
		create_checkbox = function(self, name, position, size, text, value, on_value_changed)
			local widget = self:create_widget(name, position, size, "checkbox")
			widget:set("text", text or "")
			widget:set("value", value or false)
			if on_value_changed then
				widget:set("on_value_changed", on_value_changed)
			end
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create label
		--]]
		create_label = function(self, name, position, size, text)
			local widget = self:create_widget(name, position, size, "label")
			widget:set("text", text or "")
			self:add_widget(widget)
			return widget
		end,
		--[[
			Create widget
		--]]
		create_dropdown = function(self, name, position, size, options, selected_index, on_index_changed, show_items_num)
			local widget = self:create_widget(name, position, size, "dropdown")
			--local widget.widgets = {}
			widget:set("text", "")
			widget:set("options", {})
			widget:set("index", selected_index)
			--table.sort(options)
			gui:pcall(function()
			for text, index in pairs(options) do
				local sub_widget = self:create_dropdown_item(name, index, widget, text)
				-- gui:echo("--")
				-- gui:echo(tostring(index))
				widget.options[#widget.options+1] = sub_widget
			end
			end)
			widget:set("show_items_num", show_items_num or 2)
			if on_index_changed then
				widget:set("on_index_changed", on_index_changed)
			end
			self:add_widget(widget)
			return widget
		end,
		create_dropdown_item = function(self, name, index, parent, text)
			local widget = self:create_widget(name.."_option_"..text, {0, 0}, {0, 0}, "dropdown_item")
			widget:set("text", text or "")
			widget:set("index", index)
			widget:set("parent", parent)
			widget:set("anchor", nil)
			widget:set("z_order", 1)
			return widget
		end,
		--[[
			Create widget
		--]]
		create_widget = function(self, name, position, size, _type, anchor)


			position = gui.adjust_to_fit_scale(position)
			size = gui.adjust_to_fit_scale(size)

			-- Create widget
			local widget = table.clone(gui.widgets.widget)
			widget.name = name or "name"
			widget.position = position or {0, 0}
			widget.offset = widget.position
			widget.size = size or {0, 0}
			widget._type = _type or "button"
			widget.window = self
			-- Anchor
			widget.anchor = anchor or "bottom_left"
			-- Setup functions and theme
			widget:setup()

			return widget
		end,
		--[[
			Add widget to list
		--]]
		add_widget = function(self, widget)
			self:inc_z_orders(#self.widgets)
			widget.z_order = 1
			self.widgets[#self.widgets+1] = widget
		end,

		-- ################################################################################################################
		-- ##### Methods ##################################################################################################
		-- ################################################################################################################
		--[[
			Initialize window
		--]]
		init = function(self)
			-- Event
			self:on_init()

			-- Theme
			self:refresh_theme()

			-- Init widgets
			if #self.widgets > 0 then
				for _, widget in pairs(self.widgets) do
					widget:init()
				end
			end

			self:update()

			self.initialized = true
		end,
		--[[
			Bring window to front
		--]]
		bring_to_front = function(self)
			if not self:has_focus() then
				gui.windows:unfocus()
				gui.windows:inc_z_orders(self.z_order)
				self.z_order = 1
			end
		end,
		--[[
			Destroy window
		--]]
		destroy = function(self)
			self:before_destroy()
			gui.windows:dec_z_orders(self.z_order)
			table.remove(gui.windows.list, self:window_index())
		end,
		--[[
			Increase z orders
		--]]
		inc_z_orders = function(self, changed_z)
			for z=changed_z, 1, -1 do
				for _, widget in pairs(self.widgets) do
					if widget.z_order == z then
						widget.z_order = widget.z_order + 1
					end
				end
			end
		end,
		--[[
			Decrease z orders
		--]]
		dec_z_orders = function(self, changed_z)
			--for z=changed_z, #self.widgets do
			for z=changed_z+1, #self.widgets do
				for _, widget in pairs(self.widgets) do
					if widget.z_order == z then
						widget.z_order = widget.z_order - 1
					end
				end
			end
		end,
		--[[
			Focus window
		--]]
		focus = function(self)
			self:bring_to_front()
			self:on_focus()
		end,
		--[[
			Unfocus window
		--]]
		unfocus = function(self)
			for _, widget in pairs(self.widgets) do
				widget:unfocus()
			end
			self:on_unfocus()
		end,
		--[[
			Hover window
		--]]
		hover = function(self, cursor)
			if not self.hovered then self:hover_enter() end
			self.cursor = cursor
			self:on_hover(cursor)
		end,
		--[[
			Start hover window
		--]]
		hover_enter = function(self)
			--gui.mouse:un_hover_all(gui.windows.list)
			self.hovered = true
			self:on_hover_enter()
		end,
		--[[
			End hover window
		--]]
		hover_exit = function(self)
			self.hovered = false
			self:on_hover_exit()
		end,
		--[[
			Click window
		--]]
		click = function(self, position)
			--self:focus()
			local clicked = false
			for z=1, #self.widgets do
				for _, widget in pairs(self.widgets) do
					if widget.z_order == z then
						if not gui.point_in_bounds(position, widget:extended_bounds()) then
							widget:unfocus()
						end
						if not clicked and gui.point_in_bounds(position, widget:extended_bounds()) then
							widget:click()
							clicked = true
						end
					end
				end
			end
			self:on_click(position)
		end,
		--[[
			Release click window
		--]]
		release = function(self, position)
			self:focus()
			local released = false
			for z=1, #self.widgets do
				for _, widget in pairs(self.widgets) do
					if widget.z_order == z then
						if not gui.point_in_bounds(position, widget:extended_bounds()) then
							widget:unfocus()
						end
						if not released and gui.point_in_bounds(position, widget:extended_bounds()) then
							widget:release()
							released = true
						end
					end
				end
			end
			self:on_release(position)
		end,

		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			Window is initialized
		--]]
		on_init = function(self)
		end,
		--[[
			Window gets focus
		--]]
		on_focus = function(self)
		end,
		--[[
			Window loses focus
		--]]
		on_unfocus = function(self)
		end,
		--[[
			Window is hovered
		--]]
		on_hover = function(self, cursor)
		end,
		--[[
			Window starts being hovered
		--]]
		on_hover_enter = function(self)
		end,
		--[[
			Window ends being hovered
		--]]
		on_hover_exit = function(self)
		end,
		--[[
			Window is clicked
		--]]
		on_click = function(self, position)
		end,
		--[[
			Window click released
		--]]
		on_release = function(self, position)
		end,
		--[[
			Before window is updated
		--]]
		before_update = function(self)
		end,
		--[[
			Window was updated
		--]]
		after_update = function(self)
		end,
		--[[
			Window is dragged
		--]]
		on_dragged = function(self)
		end,
		--[[
			Window is resized
		--]]
		on_resize = function(self)
		end,
		--[[
			Before window is destroyed
		--]]
		before_destroy = function(self)
		end,

		-- ################################################################################################################
		-- ##### Attributes ###############################################################################################
		-- ################################################################################################################
		--[[
			Check if window has focus
		--]]
		has_focus = function(self)
			return self.z_order == 1
		end,
		--[[
			Get window index
		--]]
		window_index = function(self)
			for i=1, #gui.windows.list do
				if gui.windows.list[i] == self then return i end
			end
			return 0
		end,
		--[[
			Window bounds
		--]]
		bounds = function(self)
			return gui.to_bounds(self.position, self.size)
		end,
		extended_bounds = function(self)
			local bounds = self:bounds()
			for _, widget in pairs(self.widgets) do
				local cbounds = widget:extended_bounds()
				if cbounds[1] < bounds[1] then bounds[1] = cbounds[1] end
				if cbounds[2] > bounds[2] then bounds[2] = cbounds[2] end
				if cbounds[3] < bounds[3] then bounds[3] = cbounds[3] end
				if cbounds[4] > bounds[4] then bounds[4] = cbounds[4] end
			end
			return bounds
		end,
		widget_bounds = function(self, exclude_resizer)
			local bounds = {}

			for _, widget in pairs(self.widgets) do
				if exclude_resizer and widget._type == "resizer" then
					return {0, 0, 0, 0}
				else
					local cbounds = widget:extended_bounds()
					if not bounds[1] or cbounds[1] < bounds[1] then bounds[1] = cbounds[1] end
					if not bounds[2] or cbounds[2] > bounds[2] then bounds[2] = cbounds[2] end
					if not bounds[3] or cbounds[3] < bounds[3] then bounds[3] = cbounds[3] end
					if not bounds[4] or cbounds[4] > bounds[4] then bounds[4] = cbounds[4] end
				end
			end
			return bounds
		end,
		--[[
			Z position
		--]]
		position_z = function(self)
			return 800 + (#gui.windows.list - self.z_order)
		end,
		--[[
			Get widget by name
		--]]
		get_widget = function(self, name)
			for _, widget in pairs(self.widgets) do
				if widget.name == name then
					return widget
				end
			end
			return nil
		end,

		-- ################################################################################################################
		-- ##### Cycle ####################################################################################################
		-- ################################################################################################################
		--[[
			Update window
		--]]
		update = function(self)
			if self.initialized then
				self:before_update()
				if self:has_focus() then
					-- Get cursor position
					local cursor = gui.mouse.cursor()
					-- Drag
					self:drag(cursor)
					-- Resize
					self:resize(cursor)
					-- Update widgets
					self:update_widgets()
				end
				self:after_update()
			end
		end,
		--[[
			Resize window
		--]]
		drag = function(self, cursor)
			if self.dragging then
				self.position = {cursor[1] - self.drag_offset[1], cursor[2] - self.drag_offset[2]}
				self:on_dragged()
			end
		end,
		--[[
			Resize window
		--]]
		resize = function(self, cursor)
			if self.resizing then
				local new_size = {
					cursor[1] - self.resize_origin[1] + self.resize_offset[1],
					self.resize_origin[2] - cursor[2] + self.resize_offset[2],
				}
				if new_size[1] < self.original_size[1] then new_size[1] = self.original_size[1] end
				if new_size[2] < self.original_size[2] then new_size[2] = self.original_size[2] end
				self.size = new_size
				local widget_bounds = self:widget_bounds(true)
				if self.size[1] < widget_bounds[2] - widget_bounds[1] then
					self.size[1] = widget_bounds[2] - widget_bounds[1]
				end
				if self.size[2] < widget_bounds[4] - widget_bounds[3] then
					self.size[2] = widget_bounds[4] - widget_bounds[3]
				end
				self.position = {self.position[1], self.resize_origin[2] - new_size[2]}
				self:on_resize()
			end
		end,
		--[[
			Update widgets
		--]]
		update_widgets = function(self)
			if #self.widgets > 0 then
				local catched = false
				for z=1, #self.widgets do
					for _, widget in pairs(self.widgets) do
						if widget.z_order == z and not catched then
							catched = widget:update()
						end
					end
				end
			end
		end,

		-- ################################################################################################################
		-- ##### Render ###################################################################################################
		-- ################################################################################################################
		render = function(self)
			if not self.visible then return end
			self:render_shadow()
			self:render_background()
			self:render_widgets()
		end,
		--[[
			Render window
		--]]
		render_background = function(self)
			if not self.visible or self.transparent then return end
			local color = ColorHelper.unbox(self.theme.color)
			if self.hovered then
				color = ColorHelper.unbox(self.theme.color_hover)
			end
			basic_gui.rect(self.position[1], self.position[2], self:position_z(), self.size[1], self.size[2], color)
		end,
		--[[
			Render shadow
		--]]
		render_shadow = function(self)
			if not self.visible then return end
			-- Theme
			local layers = self.theme.shadow.layers
			local border = self.theme.shadow.border
			local cv = self.theme.shadow.color
			-- Render
			for i=1, layers do
				local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
				local layer = layers-i
				basic_gui.rect(self.position[1]+layer-border, self.position[2]-layer-border, self:position_z(),
					self.size[1]-layer*2+border*2, self.size[2]+layer*2+border*2, color)
			end
			for i=1, layers do
				local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
				local layer = layers-i
				basic_gui.rect(self.position[1]-layer-border, self.position[2]+layer-border, self:position_z(),
					self.size[1]+layer*2+border*2, self.size[2]-layer*2+border*2, color)
			end
		end,
		--[[
			Render widgets
		--]]
		render_widgets = function(self)
			if not self.visible then return end
			if #self.widgets > 0 then
				for z=#self.widgets, 1, -1 do
					for _, widget in pairs(self.widgets) do
						if widget.z_order == z and widget.visible then
							widget:render()
						end
					end
				end
			end
		end,

	},

	widget = {
		name = "",
		position = {0, 0},
		size = {0, 0},
		_type = "",
		anchor = "",
		hovered = false,
		cursor = {0, 0},
		--colors = {},
		z_order = 0,
		visible = true,
		theme = {},

		-- ################################################################################################################
		-- ##### widget Methods ##########################################################################################
		-- ################################################################################################################
		--[[
			Initialize
		--]]
		init = function(self)
			-- Trigger update
			self:update()
			-- Trigger event
			self:on_init()
		end,
		--[[
			Click
		--]]
		click = function(self)
			-- Disabled
			if self.disabled then return end
			-- Click
			self.clicked = true
		end,
		--[[
			Release
		--]]
		release = function(self)
			-- Disabled
			if self.disabled then return end
			-- Clicked
			if not self.clicked then return end
			-- Release
			self.clicked = false
			-- Trigger event
			self:on_click()
		end,
		--[[
			Focus
		--]]
		focus = function(self)
			-- Disabled
			if self.disabled then return end
			-- Focus
			self.has_focus = true
		end,
		--[[
			Unfocus
		--]]
		unfocus = function(self)
			-- Unfocus
			self.hovered = false
			self.clicked = false
			self.has_focus = false
		end,
		-- ################################################################################################################
		-- ##### Init #####################################################################################################
		-- ################################################################################################################
		--[[
			Set value
		--]]
		set = function(self, attribute, value)
			self[attribute] = value
		end,
		--[[
			Refresh theme
		--]]
		refresh_theme = function(self)
			self.theme = {}
			-- Default
			local theme_element = gui.themes[gui.theme].default
			if theme_element then self:copy_theme_element(theme_element) end
			-- Specific
			local theme_element = gui.themes[gui.theme][self._type]
			if theme_element then self:copy_theme_element(theme_element) end
		end,
		--[[
			Copy theme element
		--]]
		copy_theme_element = function(self, theme_element)
			-- Go through elements
			for key, element in pairs(theme_element) do
				-- Set element
				self.theme[key] = element
			end
		end,
		--[[
			Setup widget
		--]]
		setup = function(self)
			-- Copy widget specific functions
			local widget_element = gui.widgets[self._type]
			if widget_element then self:copy_widget_element(widget_element) end
			-- Refresh theme
			self:refresh_theme()
		end,
		--[[
			Copy widget element
		--]]
		copy_widget_element = function(self, widget_element)
			-- Go through elements
			for key, element in pairs(widget_element) do
				if type(element) == "function" then
					-- If function save callback to original function
					if self[key] then self[key.."_base"] = self[key] end
					self[key] = element
				else
					-- Set element
					self[key] = element
				end
			end
		end,
		-- ################################################################################################################
		-- ##### Cycle ####################################################################################################
		-- ################################################################################################################
		--[[
			Update
		--]]
		update = function(self)
			-- Trigger event
			self:before_update()
			-- Disabled
			if self.disabled or not self.visible then return end
			-- Mouse position
			local cursor = gui.mouse.cursor()
			-- Set widget position via anchor
			if self.anchor then
				self.position, self.size = gui.anchor[self.anchor].position(self.window, self)
			end
			-- Check hovered
			self.hovered, self.cursor = gui.point_in_bounds(cursor, self:extended_bounds())
			if self.hovered then
				if self.tooltip then basic_gui.tooltip(self.tooltip) end
				self:on_hover()
			end
			-- Clicked
			if self.clicked then
				self.clicked = self.hovered
			end
			-- Trigger event
			self:after_update()
			-- Return
			return self.clicked
		end,
		-- ################################################################################################################
		-- ##### Render ###################################################################################################
		-- ################################################################################################################
		--[[
			Main Render
		--]]
		render = function(self)
			-- Visible
			if not self.visible then return end
			-- Render shadow
			self:render_shadow()
			-- Render background
			self:render_background()
			-- Render text
			self:render_text()
		end,
		--[[
			Render shadow
		--]]
		render_shadow = function(self)
			-- Visible
			if not self.visible then return end
			-- Shadow set
			if self.theme.shadow then
				-- Get theme value
				local layers = self.theme.shadow.layers
				local border = self.theme.shadow.border
				local cv = self.theme.shadow.color
				-- Render
				for i=1, layers do
					local layer = layers-i
					local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
					basic_gui.rect(self.position[1]+layer-border, self.position[2]-layer-border, self:position_z(),
						self.size[1]-layer*2+border*2, self.size[2]+layer*2+border*2, color)
				end
				for i=1, layers do
					local layer = layers-i
					local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
					basic_gui.rect(self.position[1]-layer-border, self.position[2]+layer-border, self:position_z(),
						self.size[1]+layer*2+border*2, self.size[2]-layer*2+border*2, color)
				end
			end
		end,
		--[[
			Render background
		--]]
		render_background = function(self)
			-- Visible
			if not self.visible then return end
			-- Get current theme color
			local color = ColorHelper.unbox(self.theme.color)
			if self.clicked then
				color = ColorHelper.unbox(self.theme.color_clicked)
			elseif self.hovered then
				color = ColorHelper.unbox(self.theme.color_hover)
			end
			-- Get bounds
			local bounds = self:extended_bounds()
			-- Render background rectangle
			basic_gui.rect(bounds[1], bounds[4], self:position_z(), bounds[2]-bounds[1], bounds[3]-bounds[4], color)
		end,
		--[[
			Render text
		--]]
		render_text = function(self)
			-- Visible
			if not self.visible then return end
			-- Get current theme color
			local color = ColorHelper.unbox(self.theme.color_text)
			if self.clicked then
				color = ColorHelper.unbox(self.theme.color_text_clicked)
			elseif self.hovered then
				color = ColorHelper.unbox(self.theme.color_text_hover)
			end
			-- Get text info
			local text = self.text or ""
			--local font = self.theme.font
			local font = gui.fonts:get(self.theme.font)
			-- Get text alignment
			local position = {self.position[1] + self.size[2]*0.2, self.position[2] + self.size[2]*0.2}
			--local align = self.theme.text_alignment
			local align = gui.text_alignment[self.theme.text_alignment]
			if align then
				position = align.position(text, font, self:bounds())
			end
			-- Render text
			basic_gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
		end,
		-- ################################################################################################################
		-- ##### Attributes ###############################################################################################
		-- ################################################################################################################
		--[[
			Bounds
		--]]
		bounds = function(self)
			return gui.to_bounds(self.position, self.size)
		end,
		extended_bounds = function(self)
			return self:bounds()
		end,
		--[[
			Position Z
		--]]
		position_z = function(self)
			return self.window:position_z() + (#self.window.widgets - self.z_order)
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			On init
		--]]
		on_init = function(self)
		end,
		--[[
			On click
		--]]
		on_click = function(self)
		end,
		--[[
			On hover
		--]]
		on_hover = function(self)
		end,
		--[[
			Before update
		--]]
		before_update = function(self)
		end,
		--[[
			After update
		--]]
		after_update = function(self)
		end,
	},

	title = {
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Init override
		--]]
		init = function(self)
			-- Original function
			self:init_base()
			-- Change
			self.height = self.height or gui.themes[gui.theme].title.height
		end,
		--[[
			Click override
		--]]
		click = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:click_base()
			-- Drag
			self:drag()
		end,
		-- ################################################################################################################
		-- ##### Cycle overrides ##########################################################################################
		-- ################################################################################################################
		--[[
			Update override
		--]]
		update = function(self)
			-- Set bounds
			self.size = {self.window.size[1], self.height or gui.themes[gui.theme].title.height}
			self.position = {self.window.position[1], self.window.position[2] + self.window.size[2] - self.size[2]}
			-- Disabled
			if self.disabled then return end
			-- Hover
			local cursor = gui.mouse.cursor()
			self.hovered, self.cursor = gui.point_in_bounds(cursor, self:bounds())
			-- Drag
			if self.window.dragging then self:drag() end
			-- Return
			return self.clicked or self.window.dragging
		end,
		-- ################################################################################################################
		-- ##### Drag #####################################################################################################
		-- ################################################################################################################
		--[[
			Drag start
		--]]
		drag_start = function(self)
			-- Set offset
			self.window.drag_offset = self.window.cursor
			-- Dragging
			self.window.dragging = true
			-- Block input
			gui.input:block()
			-- Trigger event
			self:before_drag()
		end,
		--[[
			Drag
		--]]
		drag = function(self)
			-- Catch start event
			if not self.window.dragging then self:drag_start() end
			-- Check mouse button
			self.window.dragging = not stingray.Mouse.released(stingray.Mouse.button_id("left"))
			-- Drag
			self:on_drag()
			-- Catch end event
			if not self.window.dragging then self:drag_end() end
		end,
		--[[
			Drag end
		--]]
		drag_end = function(self)
			-- Unblock input
			gui.input:unblock()
			-- Trigger event
			self:after_drag()
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			On drag start
		--]]
		before_drag = function(self)
		end,
		--[[
			On drag
		--]]
		on_drag = function(self)
		end,
		--[[
			On drag end
		--]]
		after_drag = function(self)
		end,
	},

	button = {},

	resizer = {
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Init override
		--]]
		init = function(self)
			-- Original function
			self:init_base()
			-- Change
			self.size = self.theme.size
		end,
		--[[
			Click override
		--]]
		click = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:click_base()
			-- Resize
			self:resize()
		end,
		-- ################################################################################################################
		-- ##### Resize ###################################################################################################
		-- ################################################################################################################
		--[[
			Start resize
		--]]
		resize_start = function(self)
			-- Save offset
			self.window.resize_offset = {self.window.size[1] - self.window.cursor[1], self.window.cursor[2]}
			self.window.resize_origin = {self.window.position[1], self.window.position[2] + self.window.size[2]}
			-- Set resizing
			self.window.resizing = true
			gui.input:block()
			-- Trigger event
			self:before_resize()
		end,
		--[[
			Resize
		--]]
		resize = function(self)
			-- Catch start event
			if not self.window.resizing then self:resize_start() end
			-- Check mouse button
			self.window.resizing = not stingray.Mouse.released(stingray.Mouse.button_id("left"))
			-- Trigger event
			self:on_resize()
			-- Catch end event
			if not self.window.resizing then self:resize_end() end
		end,
		--[[
			Resize end
		--]]
		resize_end = function(self)
			-- Block input
			gui.input:unblock()
			-- Trigger event
			self:after_resize()
		end,
		-- ################################################################################################################
		-- ##### Cycle overrides ##########################################################################################
		-- ################################################################################################################
		--[[
			Update override
		--]]
		update = function(self)
			-- Update position
			self.position = {self.window.position[1] + self.window.size[1] - self.size[1] - 5, self.window.position[2] + 5}
			-- Disabled
			if self.disabled then return end
			-- Hover
			local cursor = gui.mouse.cursor()
			--local bounds = gui.to_bounds({self.position[1], self.position[2]}, self.size)
			self.hovered, self.cursor = gui.point_in_bounds(cursor, self:bounds())
			-- Resize
			if self.window.resizing then self:resize() end
			-- Return
			return self.clicked or self.window.resizing
		end,
		-- ################################################################################################################
		-- ##### Render overrides #########################################################################################
		-- ################################################################################################################
		--[[
			render_background override
		--]]
		render_background_bak = function(self)
			-- if self.window.resizing then
				-- local color = ColorHelper.unbox(self.theme.color_clicked)
				-- local bounds = self:bounds()
				-- basic_gui.rect(bounds[1], bounds[4], self:position_z(), bounds[2]-bounds[1], bounds[3]-bounds[4], color)
			-- else
				-- self:render_background_base()
			-- end
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			Before resize
		--]]
		before_resize = function(self)
		end,
		--[[
			On resize
		--]]
		on_resize = function(self)
		end,
		--[[
			After resize
		--]]
		after_resize = function(self)
		end,
	},

	close_button = {
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Init override
		--]]
		init = function(self)
			-- Original function
			self:init_base()
			-- Change
			self.size = self.theme.size
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			OnClick override
		--]]
		on_click = function(self)
			-- Destroy window
			self.window:destroy()
		end,
	},

	textbox = {
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Init override
		--]]
		init = function(self)
			-- Original function
			self:init_base()
			-- Input cursor timer
			self.input_cursor = {
				timer = gui.timers:create_timer(self.name .. "_input_cursor_timer", 500, true, self.on_input_cursor_timer, self),
				state = true,
				position = 0,
			}
			-- Input timer
			self.input = {
				--[[timer = gui.timers:create_timer(self.name .. "_input_timer", 100, true, self.on_input_timer, self),--]]
				ready = true,
			}
		end,
		--[[
			Release override
		--]]
		release = function(self)
			-- Disabled
			if self.disabled then return end
			-- Clicked
			if self.clicked then self:focus() end
			-- Original function
			self:release_base()
		end,
		--[[
			Text changed
		--]]
		text_changed = function(self)
			-- Disable input
			--self.input.ready = false
			-- Enable input timer
			--self.input.timer.enabled = true
			-- Trigger event
			self:on_text_changed()
		end,
		--[[
			Focus override
		--]]
		focus = function(self)
			-- Disabled
			if self.disabled then return end
			-- Block input
			if not self.has_focus then
				gui.input:block()
			end
			-- Original function
			self:focus_base()
		end,
		--[[
			Unfocus override
		--]]
		unfocus = function(self)
			-- Disabled
			if self.disabled then return end
			-- Unblock input
			if self.has_focus then
				gui.input:unblock()
			end
			-- Original function
			self:unfocus_base()
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			Cursor timer
		--]]
		on_input_cursor_timer = function(self, textbox)
			-- Toggle cursor state
			textbox.input_cursor.state = not textbox.input_cursor.state
		end,
		--[[
			Input timer
		--]]
		--[[on_input_timer = function(self, textbox)
			-- Disable timer
			self.enabled = false
			-- Accept input
			textbox.input.ready = true
		end,--]]
		-- ################################################################################################################
		-- ##### Cycle overrides ##########################################################################################
		-- ################################################################################################################
		--[[
			Update override
		--]]
		update = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:update_base()
			-- Input
			if self.has_focus then
				-- Get input service
				Managers.input:device_unblock_service("keyboard", 1, "mod_gui")
				local input_service = Managers.input:get_service("mod_gui")
				-- Check input and timer
				if input_service and self.input.ready then
					-- Get keystrokes
					local keystrokes = stingray.Keyboard.keystrokes()
					-- Check keystrokes
					for _, key in pairs(keystrokes) do
						print(key)
						if type(key) == "string" then
							-- If string check if special key
							if not table.has_item(ui_special_keys, key) then
								-- Oridinary printable character
								self.text = self.text .. key
								-- Trigger changed
								self:text_changed()
							elseif key == "space" then
								-- Add space
								self.text = self.text .. " "
								-- Trigger changed
								self:text_changed()
							end
						else
							-- If not string it's widget key
							if input_service:get("backspace") then
								-- Handle backspace - remove last character
								if string.len(self.text) >= 1 then
									local _, count = string.gsub(self.text, "[^\128-\193]", "")
									self.text = UTF8:utf8sub(self.text, 1, count-1)
									-- Trigger changed
									self:text_changed()
								end
							elseif input_service:get("esc") or input_service:get("enter") then
								-- Unfocus
								self:unfocus()
							end
						end
					end
				end
			end
			-- Return
			return self.clicked or self.has_focus
		end,
		-- ################################################################################################################
		-- ##### Render overrides #########################################################################################
		-- ################################################################################################################
		--[[
			Render main override
		--]]
		render = function(self)
			-- Visible
			if not self.visible then return end
			-- Original function
			self:render_base()
			-- Cursor
			self:render_cursor()
		end,
		--[[
			Render text override
		--]]
		render_text = function(self)
			-- Visible
			if not self.visible then return end
			-- Get current theme color
			local color = ColorHelper.unbox(self.theme.color_placeholder)
			if self.clicked then
				color = ColorHelper.unbox(self.theme.color_text_clicked)
			elseif self.hovered and #self.text > 0 then
				color = ColorHelper.unbox(self.theme.color_text_hover)
			elseif #self.text > 0 then
				color = ColorHelper.unbox(self.theme.color_text)
			end
			-- Get text
			local text = self.text or ""
			if not self.has_focus then
				text = #self.text > 0 and self.text or self.placeholder or ""
			end
			-- Get font
			--local font = self.theme.font
			local font = gui.fonts:get(self.theme.font)
			-- Get text alignment
			local position = {self.position[1] + self.size[2]*0.2, self.position[2] + self.size[2]*0.2}
			--local align = self.theme.text_alignment
			local align = gui.text_alignment[self.theme.text_alignment]
			if align then
				position = align.position(text, font, self:bounds())
			end
			-- Render text
			basic_gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
		end,
		--[[
			Render cursor
		--]]
		render_cursor = function(self)
			-- Visible
			if not self.visible then return end
			-- Render
			if self.has_focus and self.input_cursor.state then
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color_input_cursor)
				-- Get data
				local width = 0
				--local font = self.theme.font
				local font = gui.fonts:get(self.theme.font)
				if self.text and #self.text > 0 then
					width = basic_gui.text_width(self.text, font.material, font:font_size())
				end
				-- Render cursor
				basic_gui.rect(self.position[1]+2+width, self.position[2]+2, self:position_z(), 2, self.size[2]-4, color)
			end
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			On text changed
		--]]
		on_text_changed = function(self)
		end,
	},

	checkbox = {
		-- ################################################################################################################
		-- ##### Methods ##################################################################################################
		-- ################################################################################################################
		--[[
			Toggle state
		--]]
		toggle = function(self)
			-- Change
			self.value = not self.value
			-- Trigger event
			self:on_value_changed()
		end,
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Release override
		--]]
		release = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:release_base()
			-- Toggle
			self:toggle()
		end,
		-- ################################################################################################################
		-- ##### Render overrides #########################################################################################
		-- ################################################################################################################
		--[[
			Render override
		--]]
		render = function(self)
			-- Visible
			if not self.visible then return end
			-- Original function
			self:render_base()
			-- Render box
			self:render_box()
		end,
		--[[
			Render text override
		--]]
		render_text = function(self)
			-- Visible
			if not self.visible then return end
			-- Get current theme color
			local color = ColorHelper.unbox(self.theme.color_text)
			if self.clicked then
				color = ColorHelper.unbox(self.theme.color_text_clicked)
			elseif self.hovered then
				color = ColorHelper.unbox(self.theme.color_text_hover)
			end
			-- Get font
			--local font = self.theme.font
			local font = gui.fonts:get(self.theme.font)
			-- Get text alignment
			local position = {self.position[1] + self.size[2] + 5, self.position[2] + self.size[2]*0.2}
			-- local align = self.theme.text_alignment
			-- if align then
				-- position = align.position(self.text, font, self:bounds())
			-- end
			-- Render text
			basic_gui.text(self.text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
		end,
		--[[
			Render box
		--]]
		render_box = function(self)
			-- Visible
			if not self.visible then return end
			-- Check value
			if self.value then
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color_text)
				if self.clicked then
					color = ColorHelper.unbox(self.theme.color_text_clicked)
				elseif self.hovered then
					color = ColorHelper.unbox(self.theme.color_text_hover)
				end
				local text = "X"
				-- Get font
				--local font = self.theme.font
				local font = gui.fonts:get(self.theme.font)
				-- Get text alignment
				local position = {self.position[1] + 5, self.position[2] + self.size[2]*0.2}
				--local align = self.theme.text_alignment
				local align = gui.text_alignment[self.theme.text_alignment]
				if align then
					position = align.position(text, font, self:bounds())
				end
				-- Render text
				basic_gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
			end
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			Text changed
		--]]
		on_value_changed = function(self)
		end,
	},

	label = {},

	dropdown = {
		-- ################################################################################################################
		-- ##### Methods ##################################################################################################
		-- ################################################################################################################
		--[[
			Select index
		--]]
		select_index = function(self, index)
			-- Check options  ( options are dropdown_item widgets )
			if self.options and #self.options >= index then
				-- Set index
				self.index = index
				-- Set text
				self:update_text()
				-- Trigger event
				self:on_index_changed()
			end
		end,
		update_text = function(self)
			for _, option in pairs(self.options) do
				if option.index == self.index then
					self.text = option.text
					return
				end
			end
		end,
		--[[
			Wrap function calls to options
		--]]
		wrap_options = function(self, function_name)
			local results = {}
			-- Go through options
			for key, option in pairs(self.options) do
				-- Check for function and execute it
				if option[function_name] and type(option[function_name]) == "function" then
					local result = option[function_name](option)
					results[#results+1] = result
				end
			end
			-- Return
			return results
		end,
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Init override
		--]]
		init = function(self)
			-- Original function
			self:init_base()
			-- Wrap init
			self:wrap_options("init")
			-- If options select first
			if #self.options > 0 and not self.index then self.index = 1 end
			self:select_index(self.index)
		end,
		--[[
			Click override
		--]]
		click = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:click_base()
			-- Go through options
			for key, option in pairs(self.options) do
				-- If option hovered
				if gui.point_in_bounds(gui.mouse.cursor(), option:extended_bounds()) then
					-- Click option
					option:click()
				end
			end
		end,
		--[[
			Release override
		--]]
		release = function(self)
			-- Disabled
			if self.disabled then return end
			-- Drop
			if self.clicked then self.dropped = not self.dropped end
			-- Original function
			self:release_base()
			-- Go through options
			for key, option in pairs(self.options) do
				-- If option hovered
				if gui.point_in_bounds(gui.mouse.cursor(), option:extended_bounds()) then
					-- Release
					option:release()
				end
			end
		end,
		--[[
			Unfocus override
		--]]
		unfocus = function(self)
			-- Original function
			self:unfocus_base()
			-- Drop off
			self.dropped = false
			-- Wrap
			self:wrap_options("unfocus")
		end,
		-- ################################################################################################################
		-- ##### Cycle overrides ##########################################################################################
		-- ################################################################################################################
		--[[
			Update override
		--]]
		update = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:update_base()
			-- If dropped
			if self.dropped then
				-- Get some shit
				local scale = UIResolutionScale()
				local border = 2*scale
				local x = self.position[1] --+ border
				local y = self.position[2] - border -- self.size[2] - border
				-- Go through options
				--table.sort(self.options)
				--for i = 1, #self.options do
				--for i = #self.options, 1, -1 do
					-- gui:echo("--")
					for _, option in pairs(self.options) do
						--if option.param == i then
							-- Update position
							-- gui:echo(tostring(option.param))
							option:set("position", {x, y - (self.size[2] * option.index)})
							option:set("size", self.size)
							option:set("visible", true)
							--y = y - self.size[2] --- border
							--break
						--end
					end
				--end
				-- Wrap
				self:wrap_options("update")
			end
			-- Return
			return self.clicked or self.dropped
		end,
		-- ################################################################################################################
		-- ##### Render overrides #########################################################################################
		-- ################################################################################################################
		--[[
			Render main override
		--]]
		render = function(self)
			-- Visible
			if not self.visible then return end
			-- Original function
			self:render_base()
			-- If dropped
			if self.dropped then
				-- Wrap
				self:wrap_options("render")
			end
		end,
		-- ################################################################################################################
		-- ##### Attribute overrides ######################################################################################
		-- ################################################################################################################
		--[[
			Bounds override
		--]]
		extended_bounds = function(self)
			local bounds = self:bounds()
			-- If dropped
			if self.dropped then
				-- Change bounds to reflect dropped size
				bounds[3] = bounds[3] - (self.size[2]*#self.options)
				--bounds[4] = bounds[4] --+ self.size[2] + (self.size[2]*#self.options)
			end
			-- Return
			return bounds
		end,
		-- ################################################################################################################
		-- ##### Events ###################################################################################################
		-- ################################################################################################################
		--[[
			Index changed
		--]]
		on_index_changed = function(self)
		end,
	},

	dropdown_item = {
		-- ################################################################################################################
		-- ##### widget overrides ########################################################################################
		-- ################################################################################################################
		--[[
			Release override
		--]]
		release = function(self)
			-- Disabled
			if self.disabled then return end
			-- Original function
			self:release_base()
			-- Change
			if self.parent and self.index then
				self.parent:select_index(self.index)
			end
		end,
		-- ################################################################################################################
		-- ##### Attribute overrides ######################################################################################
		-- ################################################################################################################
		--[[
			Position Z override
		--]]
		position_z = function(self)
			-- Return parent position z + 1
			return self.parent:position_z()+1
		end,
	},

}

-- ################################################################################################################
-- ##### Themes ###################################################################################################
-- ################################################################################################################
gui.themes = {
	-- Define a "default" theme element with common values for every widget
	-- Define specific elements with a widget name to overwrite default settings
	-- Default theme
	default = {
		-- default theme element
		default = {
			color = ColorHelper.box(200, 50, 50, 50),
			color_hover = ColorHelper.box(200, 60, 60, 60),
			color_clicked = ColorHelper.box(200, 90, 90, 90),
			color_text = ColorHelper.box(100, 255, 255, 255),
			color_text_hover = ColorHelper.box(200, 255, 168, 0),
			color_text_clicked = ColorHelper.box(255, 255, 180, 0),
			text_alignment = "middle_center",
			shadow = {
				layers = 5,
				border = 0,
				color = {20, 10, 10, 10},
			},
			font = "hell_shark",
		},
		-- Overwrites and additions
		window = {
			color = ColorHelper.box(200, 30, 30, 30), --
			color_hover = ColorHelper.box(255, 35, 35, 35), --
			shadow = {
				layers = 0,
				border = 0,
				color = {0, 255, 255, 255},
			},
		},
		title = {
			height = 20,
			color = ColorHelper.box(255, 40, 40, 40),
			color_hover = ColorHelper.box(255, 50, 50, 50),
			color_clicked = ColorHelper.box(255, 60, 60, 60),
			color_text = ColorHelper.box(200, 255, 255, 255),
			color_text_hover = ColorHelper.box(200, 255, 168, 0),
			color_text_clicked = ColorHelper.box(255, 255, 180, 0),
			shadow = {
				layers = 5,
				border = 0,
				color = {20, 10, 10, 10},
			},
		},
		button = {},
		resizer = {
			size = {20, 20},
		},
		close_button = {
			size = {25, 25},
		},
		textbox = {
			color_placeholder = ColorHelper.box(50, 255, 255, 255),
			color_input_cursor = ColorHelper.box(100, 255, 255, 255),
			text_alignment = "middle_left",
		},
		checkbox = {},
		dropdown = {
			draw_items_num = 5,
		},
		dropdown_item = {
			color_hover = ColorHelper.box(255, 60, 60, 60),
			color_clicked = ColorHelper.box(255, 90, 90, 90),
		},
		label = {
			color = ColorHelper.box(0, 0, 0, 0),
			color_hover = ColorHelper.box(0, 0, 0, 0),
			color_clicked = ColorHelper.box(0, 0, 0, 0),
			color_text = ColorHelper.box(200, 255, 255, 255),
			color_text_hover = ColorHelper.box(200, 255, 255, 255),
			color_text_clicked = ColorHelper.box(200, 255, 255, 255),
			shadow = {
				layers = 0,
				border = 0,
				color = {20, 10, 10, 10},
			},
		}
	},
}

-- ################################################################################################################
-- ##### Default stuff ############################################################################################
-- ################################################################################################################
gui.fonts:create("default", "hell_shark", 22)
gui.fonts:create("hell_shark", "hell_shark", 22, nil, true)

