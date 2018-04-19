--[[ Add mutators panel to the map view --]]
--@TODO: button highlighted incorrectly
local vmf = get_mod("VMF")

local _MUTATORS = vmf.mutators

--vmf:custom_textures("mutator_button", "mutator_button_hover")
--vmf:inject_materials("ingame_ui", "materials/vmf/mutator_button", "materials/vmf/mutator_button_hover")

local _DEFINITIONS = vmf:dofile("scripts/mods/vmf/modules/ui/mutators/mutator_gui_definitions")

local _PER_PAGE = _DEFINITIONS.PER_PAGE

local mutators_view = {

	initialized = false,
	active = false,
	was_active = false,
	map_view = nil,
	current_page = 1,
	mutators_sorted = {},
	mutator_checkboxes = {},

	init = function(self, map_view)
		if self.initialized then return end

		self.map_view = map_view
		if not self.map_view then return end

		self:update_mutator_list()

		-- Recreate the map_view scenegraph defs
		self.map_view.scenegraph_definition = UISceneGraph.init_scenegraph(_DEFINITIONS.scenegraph_definition)

		-- Setup custom widgets
		self.widgets = {
			banner_mutators = UIWidget.init(_DEFINITIONS.new_widgets.banner_mutators_widget),
			mutators_button = UIWidget.init(_DEFINITIONS.new_widgets.mutators_button_widget),
			no_mutators_text = UIWidget.init(_DEFINITIONS.new_widgets.no_mutators_text_widget)
		}

		for i = 1, _PER_PAGE do
			table.insert(self.mutator_checkboxes, UIWidget.init(_DEFINITIONS.new_widgets["mutator_checkbox_" .. i]))
		end

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
		print("[MUTATORS] GUI initialized")
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
		print("[MUTATORS] GUI deinitialized")
	end,

	-- Sorts mutators by title
	update_mutator_list = function(self)
		self.mutators_sorted = {}
		for _, mutator in ipairs(_MUTATORS) do
			table.insert(self.mutators_sorted, {mutator:get_name(), mutator:get_readable_name()})
		end
		table.sort(self.mutators_sorted, function(a, b) return string.lower(a[2]) < string.lower(b[2]) end)
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

			self:update_checkboxes()
		end
	end,

	-- Sets appropriate text and style to checkboxes, hides/shows them as needed
	update_checkboxes = function(self)

		local widgets = self.map_view.normal_settings_widget_types

		for i = 1, _PER_PAGE do

			local current_index = _PER_PAGE * (self.current_page - 1) + i

			local checkbox = self.mutator_checkboxes[i]
			local hotspot = checkbox.content.button_hotspot

			-- Hide if fewer mutators shown than there are checkboxes
			if #self.mutators_sorted < current_index then

				checkbox.content.setting_text = ""
				checkbox.content.tooltip_text = ""

				-- Remove from render lists
				widgets.adventure["mutator_checkbox_" .. i] = nil
				widgets.survival["mutator_checkbox_" .. i] = nil
			else
				local mutator_info = self.mutators_sorted[current_index]
				local mutator = get_mod(mutator_info[1])

				-- Set text and tooltip
				checkbox.content.setting_text = mutator_info[2]
				checkbox.content.tooltip_text = self:generate_tooltip_for(mutator)

				-- Add to render lists
				widgets.adventure["mutator_checkbox_" .. i] = checkbox
				widgets.survival["mutator_checkbox_" .. i] = checkbox

				-- Set colors based on whether mutator can be enabled
				local active = vmf.mutator_can_be_enabled(mutator)
				local color = active and "cheeseburger" or "slate_gray"
				local color_hover = active and "white" or "slate_gray"
				checkbox.style.setting_text.text_color = Colors.get_color_table_with_alpha(color, 255)
				checkbox.style.setting_text_hover.text_color = Colors.get_color_table_with_alpha(color_hover, 255)
				checkbox.style.checkbox_style.color = Colors.get_color_table_with_alpha(color_hover, 255)

				-- Sound on hover
				if hotspot.on_hover_enter then
					self.map_view:play_sound("Play_hud_hover")
				end

				-- Click event
				if hotspot.on_release then
					self.map_view:play_sound("Play_hud_select")
					if mutator:is_enabled() then
						vmf.mod_state_changed(mutator:get_name(), false)
					else
						vmf.mod_state_changed(mutator:get_name(), true)
					end
				end

				checkbox.content.selected = mutator:is_enabled()
			end
		end

		if #_MUTATORS == 0 then

			widgets.adventure["no_mutators_text"] = self.widgets.no_mutators_text
			widgets.survival["no_mutators_text"] = self.widgets.no_mutators_text
		else
			widgets.adventure["no_mutators_text"] = nil
			widgets.survival["no_mutators_text"] = nil
		end
	end,

	-- Activate on button click or map open
	activate = function(self)
		if not self.initialized or not self.map_view.active or self.active then return end

		-- Widgets
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
		local level_stepper_widget = self.map_view.steppers.level.widget
		local num_pages = math.ceil(#_MUTATORS/_PER_PAGE)
		level_stepper_widget.style.setting_text.offset[2] = -10000
		level_stepper_widget.style.hover_texture.offset[2] = -10000
		level_stepper_widget.content.left_button_hotspot.disable_button = num_pages <= 1
		level_stepper_widget.content.right_button_hotspot.disable_button = num_pages <= 1

		self.active = true

		print("[MUTATORS] GUI activated")
	end,

	-- Deactivate on button click or map close
	deactivate = function(self)
		if not self.initialized or not self.active then return end

		self.active = false

		-- Widgets
		local widgets = self.map_view.normal_settings_widget_types

		widgets.adventure.level_preview = self.saved_widgets.level_preview
		widgets.adventure.level_preview_text = self.saved_widgets.level_preview
		widgets.adventure.banner_mutators = nil

		widgets.survival.level_preview = self.saved_widgets.level_preview
		widgets.survival.level_preview_text = self.saved_widgets.level_preview
		widgets.survival.banner_mutators = nil

		widgets.adventure["no_mutators_text"] = nil
		widgets.survival["no_mutators_text"] = nil

		-- "Mission" banner position
		self.map_view.ui_scenegraph.banner_level_text.position[2] = 0

		-- Update steppers
		self.map_view.steppers.level.widget.style.setting_text.offset[2] = -120
		self.map_view.steppers.level.widget.style.hover_texture.offset[2] = -19.5
		self.map_view:update_level_stepper()

		-- Mutator checkboxes
		for i = 1, _PER_PAGE do
			widgets.adventure["mutator_checkbox_" .. i] = nil
			widgets.survival["mutator_checkbox_" .. i] = nil
		end

		print("[MUTATORS] GUI deactivated")
	end,

	-- Changes which muttators are displayed
	on_mutators_page_change = function(self, index_change)
		if not self.initialized then return end

		if self.active then
			local current_index = self.current_page
			local new_index = current_index + index_change
			local num_pages = math.ceil(#_MUTATORS/_PER_PAGE)

			if new_index < 1 then
				new_index = num_pages
			elseif num_pages < new_index then
				new_index = 1
			end

			self.current_page = new_index
		else
			self.map_view:on_level_index_changed(index_change)
		end
	end,

	-- Creates and return text for checkbox tooltip
	generate_tooltip_for = function(self, mutator)
		local config = vmf.get_mutator_config(mutator)
		local text = ""

		-- Show supported difficulty when can't be enabled due to difficulty level
		local supports_difficulty = vmf.mutator_supports_current_difficulty(mutator)
		if not supports_difficulty then
			text = text .. "\n" .. vmf:localize("tooltip_supported_difficulty") .. ":"
			for i, difficulty in ipairs(config.difficulty_levels) do
				text = text .. (i == 1 and " " or ", ") .. vmf:localize(difficulty)
			end
		end

		-- Show enabled incompatible
		local incompatible_mutators = vmf.get_incompatible_mutators(mutator, true)
		local currently_compatible = #incompatible_mutators == 0

		-- Or all incompatible if difficulty is compatible
		if supports_difficulty and #incompatible_mutators == 0 then
			incompatible_mutators = vmf.get_incompatible_mutators(mutator)
		end

		if #incompatible_mutators > 0 then

			if currently_compatible and config.incompatible_with_all or #incompatible_mutators == #_MUTATORS - 1 then
				-- Show special message when incompatible with all
				text = text .. "\n" .. vmf:localize("tooltip_incompatible_with_all")
			else
				text = text .. "\n" .. vmf:localize("tooltip_incompatible_with") .. ":"
				for i, other_mutator in ipairs(incompatible_mutators) do
					text = text .. (i == 1 and " " or ", ") .. other_mutator:get_readable_name()
				end
			end

		elseif config.compatible_with_all then
			-- Special message when compatible with all
			text = text .. "\n" .. vmf:localize("tooltip_compatible_with_all")
		end

		-- Special message if switched to unsupported difficulty level
		if mutator:is_enabled() and not supports_difficulty then
			text = text .. "\n" .. vmf:localize("tooltip_will_be_disabled")
		end

		-- Description
		if string.len(text) > 0 then
			text = "\n-------------" .. text
		end
		text = config.description .. text

		return text
	end,

	setup_hooks = function(self)

		-- Update the view after map_view has updated
		vmf:hook("MapView.update", function(func, map_view, dt, t)
			func(map_view, dt, t)
			self:update(dt, t)
		end)

		-- Activate the view on enter if it was active on exit
		vmf:hook("MapView.on_enter", function(func, map_view)
			func(map_view)
			if self.was_active then
				self.widgets.mutators_button.content.toggled = true
				self:activate()
			end
		end)

		-- Deactivate the view on exit
		vmf:hook("MapView.on_exit", function(func, map_view)
			func(map_view)
			self:deactivate()
		end)

		-- We don't want to let the game disable steppers when mutators view is active
		vmf:hook("MapView.update_level_stepper", function(func, map_view)
			if not self.active then
				func(map_view)
			end
		end)

		--[[
		vmf:hook("MapView.on_level_index_changed", function(func, map_view, ...)
			func(map_view, ...)
			print("on_level_index_changed")
			vmf.disable_impossible_mutators(true)
		end)

		vmf:hook("MapView.on_difficulty_index_changed", function(func, map_view, ...)
			func(map_view, ...)
			print("on_difficulty_index_changed")
			vmf.disable_impossible_mutators(true)
		end)

		vmf:hook("MapView.set_difficulty_stepper_index", function(func, map_view, ...)
			func(map_view, ...)
			print("set_difficulty_stepper_index")
			vmf.disable_impossible_mutators(true)
		end)
		--]]
	end,

	reset_hooks = function(self)
		vmf:hook_remove("MapView.update")
		vmf:hook_remove("MapView.on_enter")
		vmf:hook_remove("MapView.on_exit")
		vmf:hook_remove("MapView.update_level_stepper")
		-- vmf:hook_remove("MapView.on_level_index_changed")
		-- vmf:hook_remove("MapView.on_difficulty_index_changed")
		-- vmf:hook_remove("MapView.set_difficulty_stepper_index")
	end,

	get_map_view = function(self)
		local ingame_ui = Managers.matchmaking and  Managers.matchmaking.ingame_ui
		return ingame_ui and ingame_ui.views and ingame_ui.views.map_view
	end
}

-- Initialize mutators view after map view
vmf:hook("MapView.init", function(func, self, ...)
	func(self, ...)
	mutators_view:init(self)
end)

-- Destroy mutators view after map view
vmf:hook("MapView.destroy", function(func, ...)
	mutators_view:deinitialize()
	func(...)
end)

return mutators_view