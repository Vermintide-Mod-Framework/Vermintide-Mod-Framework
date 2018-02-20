local vmf  = get_mod("VMF")
local mutators = vmf.mutators


local banner_level_widget = UIWidgets.create_texture_with_text_and_tooltip("title_bar", "Mutators", "map_level_setting_tooltip", "banner_level", "banner_level_text", {
	vertical_alignment = "center",
	scenegraph_id = "banner_level_text",
	localize = false,
	font_size = 28,
	horizontal_alignment = "center",
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
})
local banner_level = UIWidget.init(banner_level_widget)

local window = nil
local button = nil
local window_opened = false

local function get_map_view()
	local ingame_ui = Managers.matchmaking and  Managers.matchmaking.ingame_ui
	return ingame_ui and ingame_ui.views and ingame_ui.views.map_view
end

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

	local window_size = {0, 0}
	local window_position = {50, 500}

	window = get_mod("gui").create_window("mutators_window", window_position, window_size)

	for i, mutator in ipairs(mutators) do
		local title = mutator:get_config().title or mutator:get_name()
		window:create_checkbox("checkbox_"  .. mutator:get_name(), {30, 360 - 40 * (i - 1)},  {30, 30}, title, mutator:is_enabled(), function(self)
			if self.value then
				if not mutator:is_enabled() and mutator:can_be_enabled() then
					mutator:enable()
				elseif not mutator:is_enabled() then
					create_window(map_view)
				end
			elseif mutator:is_enabled() then
				mutator:disable()
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

local function reload_window()
	local map_view = get_map_view()
	if map_view and map_view.active then
		create_window(map_view)
	end
end

vmf:hook("MapView.on_enter", function(func, self, ...)
	func(self, ...)
	print("on_enter")

	vmf.sort_mutators()
	vmf.disable_impossible_mutators()
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.on_level_index_changed", function(func, self, ...)
	func(self, ...)
	print("on_level_index_changed")

	vmf.disable_impossible_mutators()
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.on_difficulty_index_changed", function(func, self, ...)
	func(self, ...)
	print("on_difficulty_index_changed")

	vmf.disable_impossible_mutators()
	vmf:pcall(function() create_window(self) end)
end)

vmf:hook("MapView.set_difficulty_stepper_index", function(func, self, ...)
	func(self, ...)
	print("set_difficulty_stepper_index")

	vmf.disable_impossible_mutators()
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

	if window_opened or not self.settings_button_widget.content.toggled then
		for widget_name, widget in pairs(self.normal_settings_widgets) do
			local skipped_widgets_keys = {
				"stepper_level",
				"level_preview",
				"level_preview_text",
				"banner_level"
			}
			if not window_opened or not table.has_item(skipped_widgets_keys, widget_name) then
				UIRenderer.draw_widget(ui_renderer, widget)
			end
		end
		if window_opened then
			vmf:pcall(function() UIRenderer.draw_widget(ui_renderer, banner_level) end)
		end
	else
		for widget_name, widget in pairs(self.advanced_settings_widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
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

return reload_window, get_map_view
