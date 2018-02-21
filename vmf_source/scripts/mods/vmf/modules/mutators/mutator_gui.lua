local manager  = get_mod("vmf_mutator_manager")
local mutators = manager.mutators

local definitions = manager:dofile("scripts/mods/vmf/modules/mutators/mutator_gui_definitions")

local PER_PAGE = 5

local mutators_view = {

	initialized = false,
	active = false,
	was_active = false,
	map_view = nil,
	current_page = 1,

	init = function(self, map_view)
		if self.initialized then return end

		self.map_view = map_view
		if not self.map_view then return end

		-- Recreate the map_view scenegraph defs
		self.map_view.scenegraph_definition = UISceneGraph.init_scenegraph(definitions.scenegraph_definition)

		-- Setup custom widgets
		self.widgets = {
			banner_mutators = UIWidget.init(definitions.new_widgets.banner_mutators_widget),
			mutators_button = UIWidget.init(definitions.new_widgets.mutators_button_widget),
		}

		-- Save widgets we're gonna mess with
		local widgets = self.map_view.normal_settings_widget_types
		self.saved_widgets = {
			level_preview = widgets.adventure.level_preview,
			level_preview_text = widgets.adventure.level_preview_text
		}

		-- Add our button to render lists
		widgets.adventure.mutators_button = self.widgets.mutators_button
		widgets.survival.mutators_button = self.widgets.mutators_button
		self.map_view.advanced_settings_widgets.mutators_button = self.widgets.mutators_button

		-- Move other buttons over
		self.map_view.ui_scenegraph.settings_button.position[1] = -50
		self.map_view.ui_scenegraph.lobby_button.position[1] = 150
		self.map_view.ui_scenegraph.friends_button.position[1] = 50

		-- Alter level select stepper's callback
		self.map_view.steppers.level.callback = function(index_change)
			self:on_mutators_page_change(index_change)
		end

		self:setup_hooks()

		self.initialized = true
		print("INIT")
	end,

	deinitialize = function(self)
		if not self.initialized then return end

		self:deactivate()
		self.was_active = false

		-- Reset the stepper callback
		self.map_view.steppers.level.callback = callback(self.map_view, "on_level_index_changed")

		-- Remove our button
		self.map_view.normal_settings_widget_types.adventure.mutators_button = nil
		self.map_view.normal_settings_widget_types.survival.mutators_button = nil
		self.map_view.advanced_settings_widgets.mutators_button = nil

		-- Move other buttons back
		self.map_view.ui_scenegraph.settings_button.position[1] = -100
		self.map_view.ui_scenegraph.lobby_button.position[1] = 100
		self.map_view.ui_scenegraph.friends_button.position[1] = 0

		self.saved_widgets = {}

		self:reset_hooks()

		self.map_view = nil

		self.initialized = false
		print("DEINIT")
	end,

	update = function(self)
		if not self.initialized then
			self:init()
		end

		if not self.initialized or not self.map_view.active then return end

		local transitioning = self.map_view:transitioning()
		local friends = self.map_view.friends
		local friends_menu_active = friends:is_active()

		local mutators_button = self.widgets.mutators_button
		local mutators_button_hotspot = mutators_button.content.button_hotspot
		local settings_button = self.map_view.settings_button_widget

		-- Handle menu toggles
		if not transitioning and not friends_menu_active then
			if mutators_button_hotspot.on_release then
				self.map_view:play_sound("Play_hud_select")
				mutators_button.content.toggled = not mutators_button.content.toggled
				if mutators_button.content.toggled then
					settings_button.content.toggled = false
				end
			elseif settings_button.content.toggled then
				mutators_button.content.toggled = false
			end
		end

		-- Open/close mutators view
		if mutators_button.content.toggled then
			self:activate()
			self.was_active = true
		else
			self:deactivate()
			self.was_active = false
		end

		if self.active then
			-- Disable the Mission banner tooltip
			local widgets = self.map_view.normal_settings_widget_types
			widgets.adventure.banner_level.content.tooltip_hotspot.disabled = true
			widgets.survival.banner_level.content.tooltip_hotspot.disabled = true
		end
	end,

	activate = function(self)
		if not self.initialized or not self.map_view.active or self.active then return end

		-- Hiding widgets
		local widgets = self.map_view.normal_settings_widget_types

		widgets.adventure.level_preview = nil
		widgets.adventure.level_preview_text = nil
		widgets.adventure.banner_mutators = self.widgets.banner_mutators

		widgets.survival.level_preview = nil
		widgets.survival.level_preview_text = nil
		widgets.survival.banner_mutators = self.widgets.banner_mutators

		-- "Mission" banner position
		self.map_view.ui_scenegraph.banner_level_text.position[2] = -10000

		-- Update steppers
		self.map_view.steppers.level.widget.style.setting_text.offset[2] = -10000
		local level_stepper_widget = self.map_view.steppers.level.widget
		local num_pages = math.ceil(#mutators/PER_PAGE)
		level_stepper_widget.content.left_button_hotspot.disable_button = num_pages <= 1
		level_stepper_widget.content.right_button_hotspot.disable_button = num_pages <= 1

		self.active = true

		print("ACTIVE")
	end,

	deactivate = function(self)
		if not self.initialized or not self.active then return end

		-- Showing widgets
		local widgets = self.map_view.normal_settings_widget_types

		widgets.adventure.level_preview = self.saved_widgets.level_preview
		widgets.adventure.level_preview_text = self.saved_widgets.level_preview
		widgets.adventure.banner_mutators = nil

		widgets.survival.level_preview = self.saved_widgets.level_preview
		widgets.survival.level_preview_text = self.saved_widgets.level_preview
		widgets.survival.banner_mutators = nil

		-- "Mission" banner position
		self.map_view.ui_scenegraph.banner_level_text.position[2] = 0

		-- Update steppers
		self.map_view.steppers.level.widget.style.setting_text.offset[2] = -120
		self.map_view:update_level_stepper()

		self.active = false

		print("DEACTIVE")
	end,

	on_mutators_page_change = function(self, index_change)
		if not self.initialized then return end

		if self.active then
			local current_index = self.current_page
			local new_index = current_index + index_change
			local num_pages = math.ceil(#mutators/PER_PAGE)

			if new_index < 1 then
				new_index = num_pages
			elseif num_pages < new_index then
				new_index = 1
			end

			self.current_page = new_index
			print("TEST", tostring(new_index))
		else
			self.map_view:on_level_index_changed(index_change)
		end
	end,

	setup_hooks = function(self)

		-- Update the view after map_view has updated
		manager:hook("MapView.update", function(func, map_view, dt, t)
			func(map_view, dt, t)
			manager:pcall(function() self:update(dt, t)	end)
		end)

		-- Activate the view on enter if it was active on exit
		manager:hook("MapView.on_enter", function(func, map_view)
			func(map_view)
			if self.was_active then
				self.widgets.mutators_button.content.toggled = true
				manager:pcall(function() self:activate() end)
			end
		end)

		-- Deactivate the view on exit
		manager:hook("MapView.on_exit", function(func, map_view)
			func(map_view)
			manager:pcall(function() self:deactivate() end)
		end)

		-- We don't want to let the game disable steppers when mutators view is active
		manager:hook("MapView.update_level_stepper", function(func, map_view)
			if not self.active then
				func(map_view)
			end
		end)
	end,

	reset_hooks = function(self)
		manager:hook_remove("MapView.update")
		manager:hook_remove("MapView.on_enter")
		manager:hook_remove("MapView.on_exit")
		manager:hook_remove("MapView.update_level_stepper")
	end,
}

-- Initialize mutators view after map view
manager:hook("MapView.init", function(func, self, ...)
	func(self, ...)
	manager:pcall(function() mutators_view:init(self) end)
end)

-- Destroy mutators view after map view
manager:hook("MapView.destroy", function(func, ...)
	mutators_view:deinitialize()
	func(...)
end)


-- Initialize mutators view when map_view has been initialized already
local function get_map_view()
	local ingame_ui = Managers.matchmaking and  Managers.matchmaking.ingame_ui
	return ingame_ui and ingame_ui.views and ingame_ui.views.map_view
end

manager:pcall(function() mutators_view:init(get_map_view()) end)

return mutators_view