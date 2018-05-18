
local vmf = get_mod("VMF")


local _MUTATORS = vmf.mutators

local _SELECTED_DIFFICULTY_KEY

local _DEFINITIONS = dofile("scripts/mods/vmf/modules/ui/mutators/mutators_gui_definitions")
local _UI_SCENEGRAPH
local _MUTATOR_LIST_WIDGETS = {}
local _PARTY_BUTTON_WIDGET
local _OTHER_WIDGETS = {}


local _ORIGINAL_VALUES = {} -- @TODO: get rid of it?

local _MUTATOR_LIST_IS_VISIBLE
local _CURRENT_PAGE_NUMBER
local _TOTAL_PAGES_NUMBER


local _IS_MUTATORS_GUI_INITIALIZED = false

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function get_map_view()
  local map_view_exists, map_view = pcall(function () return Managers.matchmaking.ingame_ui.views.map_view end)
  if map_view_exists then
    return map_view
  end
end


local function show_mutator_list(map_view, is_visible)

  _MUTATOR_LIST_IS_VISIBLE = is_visible

  if is_visible then

    -- Banner
    local banner_widget = map_view.background_widgets[3]
    banner_widget.style.text.localize = false
    banner_widget.style.tooltip_text.localize = false
    banner_widget.content.text = vmf:localize("mutators_title")
    banner_widget.content.tooltip_text = vmf:localize("mutators_banner_tooltip")

    -- Players list
    for _, widget in ipairs(map_view.player_list_widgets) do
      widget.content.visible = false
    end

    -- Players counter
    map_view.player_list_conuter_text_widget.content.visible = false
  else

    -- Banner
    local banner_widget = map_view.background_widgets[3]
    banner_widget.style.text.localize = true
    banner_widget.style.tooltip_text.localize = true
    banner_widget.content.text = "map_party_title"
    banner_widget.content.tooltip_text = "map_party_setting_tooltip"

    -- Players list
    for _, widget in ipairs(map_view.player_list_widgets) do
      widget.content.visible = true
    end

    -- Players counter
    map_view.player_list_conuter_text_widget.content.visible = true
  end
end

local function change_map_view_look(map_view, is_vmf_look)

  if is_vmf_look then
    _ORIGINAL_VALUES.settings_button_position_x = map_view.ui_scenegraph.settings_button.position[1]
    _ORIGINAL_VALUES.friends_button_position_x  = map_view.ui_scenegraph.friends_button.position[1]
    _ORIGINAL_VALUES.lobby_button_position_x    = map_view.ui_scenegraph.lobby_button.position[1]

    map_view.ui_scenegraph.settings_button.position[1] = -50
		map_view.ui_scenegraph.friends_button.position[1] = 50
    map_view.ui_scenegraph.lobby_button.position[1] = 150
  else
    map_view.ui_scenegraph.settings_button.position[1] = _ORIGINAL_VALUES.settings_button_position_x
		map_view.ui_scenegraph.friends_button.position[1] = _ORIGINAL_VALUES.friends_button_position_x
    map_view.ui_scenegraph.lobby_button.position[1] = _ORIGINAL_VALUES.lobby_button_position_x
  end
end

--@TODO: clean up, and probably do direct change instead of return
local function calculate_tooltip_offset (widget_content, widget_style, ui_renderer)

  --local cursor_offset_bottom = widget_style.cursor_offset_bottom

  if ui_renderer.input_service then

    local cursor_position = UIInverseScaleVectorToResolution(ui_renderer.input_service.get(ui_renderer.input_service, "cursor"))
    if cursor_position then

      local text = widget_content.tooltip_text
      local max_width = widget_style.max_width

      local font, font_size = UIFontByResolution(widget_style)
      local font_name = font[3]
      local font_material = font[1]

      local _, font_min, font_max = UIGetFontHeight(ui_renderer.gui, font_name, font_size)

      local texts = UIRenderer.word_wrap(ui_renderer, text, font_material, font_size, max_width)
      local num_texts = #texts
      local full_font_height = (font_max + math.abs(font_min)) * RESOLUTION_LOOKUP.inv_scale

      local tooltip_height = full_font_height * num_texts

      --if((cursor_offset_bottom[2] / UIResolutionScale() + tooltip_height) > cursor_position[2]) then

        local cursor_offset_top = {}
        cursor_offset_top[1] = widget_style.cursor_offset_top[1]
        cursor_offset_top[2] = widget_style.cursor_offset_top[2] - (tooltip_height * UIResolutionScale())

        return cursor_offset_top
      --else
      --  return cursor_offset_bottom
      --end
    end
  end

  --return cursor_offset_bottom
end

local function offset_function_callback(ui_scenegraph_, style, content, ui_renderer)

  local mutator = content.mutator


  local can_be_enabled = true

  local mutator_compatibility_config = mutator:get_config().compatibility
  local is_mostly_compatible = mutator_compatibility_config.is_mostly_compatible
  local except = mutator_compatibility_config.except

  for _, other_mutator in ipairs(_MUTATORS) do
    if other_mutator:is_enabled() and other_mutator ~= mutator then
      can_be_enabled = can_be_enabled and (is_mostly_compatible and not except[other_mutator] or
                                           not is_mostly_compatible and except[other_mutator])
    end
  end

  can_be_enabled = can_be_enabled and mutator_compatibility_config.compatible_difficulties[_SELECTED_DIFFICULTY_KEY]

  content.can_be_enabled = can_be_enabled


  -- Enable/disable mutator
  if content.highlight_hotspot.on_release then
    if mutator:is_enabled() then
      vmf.set_mutator_state(mutator, false, false)
    elseif can_be_enabled then
      vmf.set_mutator_state(mutator, true, false)
    end
  end


  -- Tooltip
  -- Yup, a boilerplate code, kinda. I made it to divide tooltip code part, and to update it only for selected mod.
  if content.highlight_hotspot.is_hover then

    local tooltip_text = content.description


    local incompatible_mods = {}
    local conflicting_mods = {}

    if next(except) then
      tooltip_text = tooltip_text .. "\n\n" ..
                     (is_mostly_compatible and "-- INCOMPATIBLE WITH [MUTATORS] --\n" or
                      "-- COMPATIBLE ONLY WITH [MUTATORS] --\n") --@TODO: localize

      for other_mutator, _ in pairs(except) do
        table.insert(incompatible_mods, " * " .. other_mutator:get_readable_name())
      end

      tooltip_text = tooltip_text .. table.concat(incompatible_mods, "\n")
    end



    local difficulties = {}
    local compatible_difficulties_number = mutator_compatibility_config.compatible_difficulties_number
    if compatible_difficulties_number < 8 then
      tooltip_text = tooltip_text .. "\n\n" ..
                     (compatible_difficulties_number > 4 and "-- INCOMPATIBLE WITH [DIFFICULTIES] --\n" or
                      "-- COMPATIBLE ONLY WITH [DIFFICULTIES] --\n") --@TODO: localize

      for difficulty_key, is_compatible in pairs(mutator_compatibility_config.compatible_difficulties) do
        if compatible_difficulties_number > 4 and not is_compatible
        or not (compatible_difficulties_number > 4) and is_compatible then
          table.insert(difficulties, " * " .. vmf:localize(difficulty_key))
        end
      end

      tooltip_text = tooltip_text .. table.concat(difficulties, "\n")
    end



    for _, other_mutator in ipairs(_MUTATORS) do
      if other_mutator:is_enabled() and other_mutator ~= mutator then
        if not (is_mostly_compatible and not except[other_mutator] or
                 not is_mostly_compatible and except[other_mutator]) then
          table.insert(conflicting_mods, " * " .. other_mutator:get_readable_name() .. " (mutator)")
        end
      end
    end

    if not can_be_enabled then
      --tooltip_text = tooltip_text .. "\n\n" .. "--[X]-- CONFLICTS --[X]--\n"
      tooltip_text = tooltip_text .. "\n\n" .. "-- CONFLICTS --\n"
      if #conflicting_mods > 0 then
        tooltip_text = tooltip_text .. table.concat(conflicting_mods, "\n") .. "\n"
      end

      if not mutator_compatibility_config.compatible_difficulties[_SELECTED_DIFFICULTY_KEY] then
        tooltip_text = tooltip_text .. " * " .. vmf:localize(_SELECTED_DIFFICULTY_KEY) .. " (difficulty)" .. "\n"
      end
      --tooltip_text = tooltip_text .. "--[X]--\n"
    end


    content.tooltip_text = tooltip_text

    style.tooltip_text.cursor_offset = calculate_tooltip_offset(content, style.tooltip_text, ui_renderer)
  end

  -- VISUAL

  local is_enabled = content.mutator:is_enabled()

  style.text.text_color = content.can_be_enabled and (is_enabled and content.text_color_enabled or
                           content.text_color_disabled) or content.text_color_inactive

  content.checkbox_texture = is_enabled and content.checkbox_checked_texture or
                              content.checkbox_unchecked_texture
end


local function initialize_mutators_ui(map_view)

  -- Scenegraph
  _UI_SCENEGRAPH = UISceneGraph.init_scenegraph(_DEFINITIONS.scenegraph_definition)

  -- Creating mutator list widgets and calculating total pages number
  for i, mutator in ipairs(_MUTATORS) do
    local offset = ((i - 1) % 8) + 1
    _MUTATOR_LIST_WIDGETS[i] = UIWidget.init(_DEFINITIONS.create_mutator_widget(mutator, offset_function_callback))
    _MUTATOR_LIST_WIDGETS[i].offset = {0, -32 * offset, 0}
    _MUTATOR_LIST_WIDGETS[i].content.mutator = mutator
  end
  _CURRENT_PAGE_NUMBER = 1
  _TOTAL_PAGES_NUMBER = math.floor(#_MUTATORS / 8) + ((#_MUTATORS % 8 > 0) and 1 or 0)

  -- Party button
  _PARTY_BUTTON_WIDGET = UIWidget.init(_DEFINITIONS.party_button_widget_defenition)

  -- Other widgets
  for widget_name, widget in pairs(_DEFINITIONS.widgets_definition) do
    _OTHER_WIDGETS[widget_name] = UIWidget.init(widget)
  end

  -- Modify original map_view look
  change_map_view_look(map_view, true)
  show_mutator_list(map_view, true)

  _IS_MUTATORS_GUI_INITIALIZED = true
end


local function draw(map_view, dt)
  local input_service = map_view.input_manager:get_service("map_menu")
  local ui_renderer = map_view.ui_renderer
  local render_settings = map_view.render_settings

  UIRenderer.begin_pass(ui_renderer, _UI_SCENEGRAPH, input_service, dt, nil, render_settings)

  -- Party button
  UIRenderer.draw_widget(ui_renderer, _PARTY_BUTTON_WIDGET)

  if _MUTATOR_LIST_IS_VISIBLE then

    -- Mutator list (render only 8 (or less) currently visible mutator widgets)
    for i = ((_CURRENT_PAGE_NUMBER - 1) * 8 + 1), (_CURRENT_PAGE_NUMBER * 8) do
      if not _MUTATOR_LIST_WIDGETS[i] then
        break
      end
      UIRenderer.draw_widget(ui_renderer, _MUTATOR_LIST_WIDGETS[i])
    end

    -- Other widgets
    for _, widget in pairs(_OTHER_WIDGETS) do
      UIRenderer.draw_widget(ui_renderer, widget)
    end
  end

  UIRenderer.end_pass(ui_renderer)
end


local function update_mousewheel_scroll_area_input()
  local widget_content = _OTHER_WIDGETS.mousewheel_scroll_area.content
  local mouse_scroll_value = widget_content.scroll_value
  if mouse_scroll_value ~= 0 then
    _CURRENT_PAGE_NUMBER = math.clamp(_CURRENT_PAGE_NUMBER + mouse_scroll_value, 1, _TOTAL_PAGES_NUMBER)
    widget_content.scroll_value = 0
  end
end


local function update_mutators_ui(map_view, dt)

  -- Show/hide mutator list if party button was pressed
  local transitioning = map_view:transitioning()
  local friends_menu_active = map_view.friends:is_active()
  if not transitioning and not friends_menu_active then
    local mutators_button_content = _PARTY_BUTTON_WIDGET.content
    if mutators_button_content.button_hotspot.on_release then
      map_view:play_sound("Play_hud_select")
      show_mutator_list(map_view, mutators_button_content.toggled)
      mutators_button_content.toggled = not mutators_button_content.toggled
    end
  end

  draw(map_view, dt)
  update_mousewheel_scroll_area_input()
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("MapView.init", function (func, self, ingame_ui_context)
  func(self, ingame_ui_context)

  initialize_mutators_ui(self)
end)

vmf:hook("MapView.update", function (func, self, dt, t)
  func(self, dt, t)

  if self.menu_active and _IS_MUTATORS_GUI_INITIALIZED then

    local difficulty_data = self.selected_level_index and self:get_difficulty_data(self.selected_level_index)
		local difficulty_layout = difficulty_data and difficulty_data[self.selected_difficulty_stepper_index]
		_SELECTED_DIFFICULTY_KEY = difficulty_layout and difficulty_layout.key

    update_mutators_ui(self, dt)
	end
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

function vmf.reset_map_view()
  local map_view = get_map_view()
  if map_view then
    change_map_view_look(map_view, false)
    show_mutator_list(map_view, false)
  end
end

function vmf.modify_map_view()
  local map_view = get_map_view()
  if map_view then
    initialize_mutators_ui(map_view)
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################
