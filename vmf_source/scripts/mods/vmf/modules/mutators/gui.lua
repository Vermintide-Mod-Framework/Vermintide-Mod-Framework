local vmf  = get_mod("VMF")
local mutators = vmf.mutators


local window = nil
local button = nil
local window_opened = false

local function update_window_visibility(map_view)
	if not window then return end
	button.visible = map_view and map_view.friends and not map_view.friends:is_active()
	window.visible = window_opened and button.visible
end

local function destroy_window(map_view)
	if window then
		window:destroy()
		window = nil
		button:destroy()
		map_view.ui_scenegraph.settings_button.position[1] = map_view.ui_scenegraph.settings_button.position[1] - 50
		map_view.ui_scenegraph.friends_button.position[1] = map_view.ui_scenegraph.friends_button.position[1] - 50
		map_view.ui_scenegraph.lobby_button.position[1] = map_view.ui_scenegraph.lobby_button.position[1] - 50
	end
end

local function create_window(map_view)
	destroy_window(map_view)

	vmf.sort_mutators()
	vmf.disable_impossible_mutators()

	local window_size = {0, 0}
	local window_position = {50, 500}

	window = get_mod("gui").create_window("mutators_window", window_position, window_size)

	for i, mutator in ipairs(mutators) do
		window:create_checkbox("label"  .. mutator:get_name(), {10, 40 * i},  {30, 30}, mutator:get_config().title, mutator:is_enabled(), function()
			if not mutator:is_enabled() and mutator:can_be_enabled() then
				mutator:enable()
			elseif mutator:is_enabled() then
				mutator:disable()
			else
				create_window(map_view)
			end
		end)
	end

	window:init()

	button = get_mod("gui").create_window("mutators_button", window_position, window_size)
	button:create_button("mutators", {55, -75}, {65, 65}, "Mut", function()
		window_opened = not window_opened
	end)
	button:init()

	map_view.ui_scenegraph.settings_button.position[1] = map_view.ui_scenegraph.settings_button.position[1] + 50
	map_view.ui_scenegraph.friends_button.position[1] = map_view.ui_scenegraph.friends_button.position[1] + 50
	map_view.ui_scenegraph.lobby_button.position[1] = map_view.ui_scenegraph.lobby_button.position[1] + 50

	update_window_visibility(map_view)
end

vmf:hook("MapView.on_enter", function(func, self, ...)
	func(self, ...)
	print("on_enter")
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.on_level_index_changed", function(func, self, ...)
	func(self, ...)
	print("on_level_index_changed")
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.on_difficulty_index_changed", function(func, self, ...)
	func(self, ...)
	print("on_difficulty_index_changed")
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.set_difficulty_stepper_index", function(func, self, ...)
	func(self, ...)
	print("set_difficulty_stepper_index")
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.on_exit", function(func, self, ...)
	func(self, ...)
	print("on_exit")
	vmf:pcall(function() destroy_window(self) end)
	window_opened = false
end)

vmf:hook("MapView.suspend", function(func, self, ...)
	func(self, ...)
	print("suspend")
	vmf:pcall(function() destroy_window(self) end)
end)

vmf:hook("MapView.update", function(func, self, dt, t)
	func(self, dt, t)
	vmf:pcall(function() update_window_visibility(self) end)
end)

vmf:hook("MapView.draw", function(func, self, input_service, gamepad_active, dt)
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, widget in ipairs(self.background_widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	local number_of_player = self.number_of_player or 0

	for i = 1, number_of_player, 1 do
		local widget = self.player_list_widgets[i]

		UIRenderer.draw_widget(ui_renderer, widget)
	end

	if not window_opened then
		if self.settings_button_widget.content.toggled then
			for widget_name, widget in pairs(self.advanced_settings_widgets) do
				UIRenderer.draw_widget(ui_renderer, widget)
			end
		else
			for widget_name, widget in pairs(self.normal_settings_widgets) do
				UIRenderer.draw_widget(ui_renderer, widget)
			end
		end
	end

	UIRenderer.draw_widget(ui_renderer, self.player_list_conuter_text_widget)
	UIRenderer.draw_widget(ui_renderer, self.description_field_widget)
	UIRenderer.draw_widget(ui_renderer, self.title_text_widget)
	UIRenderer.draw_widget(ui_renderer, self.game_mode_selection_bar_widget)
	UIRenderer.draw_widget(ui_renderer, self.game_mode_selection_bar_bg_widget)
	UIRenderer.draw_widget(ui_renderer, self.private_checkbox_widget)

	if not gamepad_active then
		UIRenderer.draw_widget(ui_renderer, self.friends_button_widget)
		UIRenderer.draw_widget(ui_renderer, self.settings_button_widget)
		UIRenderer.draw_widget(ui_renderer, self.confirm_button_widget)
		UIRenderer.draw_widget(ui_renderer, self.cancel_button_widget)
		UIRenderer.draw_widget(ui_renderer, self.lobby_button_widget)

		if not self.confirm_button_widget.content.button_hotspot.disabled then
			UIRenderer.draw_widget(ui_renderer, self.button_eye_glow_widget)
		else
			UIRenderer.draw_widget(ui_renderer, self.confirm_button_disabled_tooltip_widget)
		end
	else
		UIRenderer.draw_widget(ui_renderer, self.background_overlay_console_widget)
		UIRenderer.draw_widget(ui_renderer, self.gamepad_button_selection_widget)
	end

	local draw_intro_description = self.draw_intro_description

	if draw_intro_description then
		for key, text_widget in pairs(self.description_text_widgets) do
			UIRenderer.draw_widget(ui_renderer, text_widget)
		end
	end

	UIRenderer.end_pass(ui_renderer)

	local friends_menu_active = self.friends:is_active()

	if gamepad_active and not friends_menu_active and not self.popup_id and not draw_intro_description then
		self.menu_input_description:draw(ui_renderer, dt)
	end

end)
