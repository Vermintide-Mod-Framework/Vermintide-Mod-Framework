local vmf = get_mod("VMF")

local _MUTATORS = vmf.mutators

local _SELECTED_DIFFICULTY_KEY -- Currently selected difficulty in the map view.

local _DEFINITIONS = dofile("scripts/mods/vmf/modules/ui/mutators/mutators_gui_definitions")
local _UI_SCENEGRAPH
local _MUTATOR_LIST_WIDGETS = {}
local _PARTY_BUTTON_WIDGET
local _NO_MUTATORS_TEXT_WIDGET
local _OTHER_WIDGETS = {}

local _ORIGINAL_VALUES = {} -- @TODO: get rid of it?

local _IS_MUTATOR_LIST_VISIBLE -- 'true' if Mutator view is active, 'false' if Party view is active.
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


-- Toggles mutator list (switches between Party and Mutators views).
local function show_mutator_list(map_view, is_visible)

  _IS_MUTATOR_LIST_VISIBLE = is_visible

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

-- Used in the next function to calculate tooltip offset, since Fatshark's solution doesn't support
-- tooltips with cursor being in the left-bottom corner.
local function calculate_tooltip_offset (widget_content, widget_style, ui_renderer)

  local input_service = ui_renderer.input_service
  if input_service then

    local cursor_position = UIInverseScaleVectorToResolution(input_service:get("cursor"))
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

      widget_style.cursor_offset[1] = widget_style.cursor_default_offset[1]
      widget_style.cursor_offset[2] = widget_style.cursor_default_offset[2] - (tooltip_height * UIResolutionScale())
    end
  end
end

-- Callback function for mutator widgets. It's not defined in definitions file because it works with mutators array.
local function offset_function_callback(ui_scenegraph_, style, content, ui_renderer)

  local mutator = content.mutator


  -- Find out if mutator can be enabled.
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


  -- Enable/disable mutator.
  if content.highlight_hotspot.on_release then
    if mutator:is_enabled() then
      vmf.set_mutator_state(mutator, false, false) --@TODO: change method?
    elseif can_be_enabled then
      vmf.set_mutator_state(mutator, true, false)
    end
  end


  -- Build tooltip (only for currently selected mutator widget).
  if content.highlight_hotspot.is_hover then

    -- DESCRIPTION

    local tooltip_text = content.description

    -- MUTATORS COMPATIBILITY

    local incompatible_mods = {}
    if next(except) then
      tooltip_text = tooltip_text .. (is_mostly_compatible and vmf:localize("tooltip_incompatible_mutators") or
                                       vmf:localize("tooltip_compatible_mutators"))

      for other_mutator, _ in pairs(except) do
        table.insert(incompatible_mods, " * " .. other_mutator:get_readable_name())
      end

      tooltip_text = tooltip_text .. table.concat(incompatible_mods, "\n")
    else
      if is_mostly_compatible then
        tooltip_text = tooltip_text .. vmf:localize("tooltip_compatible_with_all_mutators")
      else
        tooltip_text = tooltip_text .. vmf:localize("tooltip_incompatible_with_all_mutators")
      end
    end

    -- DIFFICULTIES COMPATIBILITY

    local difficulties = {}
    local compatible_difficulties_number = mutator_compatibility_config.compatible_difficulties_number
    if compatible_difficulties_number < 8 then
      tooltip_text = tooltip_text .. (compatible_difficulties_number > 4 and
                                       vmf:localize("tooltip_incompatible_diffs") or
                                        vmf:localize("tooltip_compatible_diffs"))

      for difficulty_key, is_compatible in pairs(mutator_compatibility_config.compatible_difficulties) do
        if compatible_difficulties_number > 4 and not is_compatible
        or not (compatible_difficulties_number > 4) and is_compatible then
          table.insert(difficulties, " * " .. vmf:localize(difficulty_key))
        end
      end

      tooltip_text = tooltip_text .. table.concat(difficulties, "\n")
    else
      tooltip_text = tooltip_text .. vmf:localize("tooltip_compatible_with_all_diffs")
    end

    -- CONFLICTS

    if not can_be_enabled then
      tooltip_text = tooltip_text .. vmf:localize("tooltip_conflicts")

      local conflicting_mods = {}
      for _, other_mutator in ipairs(_MUTATORS) do
        if other_mutator:is_enabled() and other_mutator ~= mutator then
          if not (is_mostly_compatible and not except[other_mutator] or
                   not is_mostly_compatible and except[other_mutator]) then

            table.insert(conflicting_mods, " * " .. other_mutator:get_readable_name() ..
                          vmf:localize("tooltip_append_mutator"))
          end
        end
      end

      if #conflicting_mods > 0 then
        tooltip_text = tooltip_text .. table.concat(conflicting_mods, "\n") .. "\n"
      end

      if not mutator_compatibility_config.compatible_difficulties[_SELECTED_DIFFICULTY_KEY] then
        tooltip_text = tooltip_text .. " * " .. vmf:localize(_SELECTED_DIFFICULTY_KEY) ..
                        vmf:localize("tooltip_append_difficulty")
      end
    end

    -- Applying tooltip

    content.tooltip_text = tooltip_text
    calculate_tooltip_offset(content, style.tooltip_text, ui_renderer)
  end


  -- Visual changing (text color and checkboxes).
  local is_enabled = content.mutator:is_enabled()

  style.text.text_color = content.can_be_enabled and (is_enabled and content.text_color_enabled or
                           content.text_color_disabled) or content.text_color_inactive

  content.checkbox_texture = is_enabled and content.checkbox_checked_texture or
                              content.checkbox_unchecked_texture
end

local function initialize_scrollbar()

  local scrollbar_widget_content = _OTHER_WIDGETS.scrollbar.content

  if _TOTAL_PAGES_NUMBER > 1 then
    scrollbar_widget_content.visible = true
    scrollbar_widget_content.scroll_bar_info.bar_height_percentage = 1 / _TOTAL_PAGES_NUMBER
  else
    scrollbar_widget_content.visible = false
  end
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

  -- "No mutators installed" text
  _NO_MUTATORS_TEXT_WIDGET = UIWidget.init(_DEFINITIONS.no_mutators_text_widget)

  -- Other widgets
  for widget_name, widget in pairs(_DEFINITIONS.widgets_definition) do
    _OTHER_WIDGETS[widget_name] = UIWidget.init(widget)
  end

  -- Modify original map_view look
  change_map_view_look(map_view, true)
  show_mutator_list(map_view, true)

  -- Find out if scrollbar is needed, calculate scrollbar size
  initialize_scrollbar()

  _IS_MUTATORS_GUI_INITIALIZED = true
end


local function draw(map_view, dt)
  local input_service = map_view.input_manager:get_service("map_menu")
  local ui_renderer = map_view.ui_renderer
  local render_settings = map_view.render_settings

  UIRenderer.begin_pass(ui_renderer, _UI_SCENEGRAPH, input_service, dt, nil, render_settings)

  -- Party button
  UIRenderer.draw_widget(ui_renderer, _PARTY_BUTTON_WIDGET)

  if _IS_MUTATOR_LIST_VISIBLE then
    if #_MUTATORS > 0 then
      -- Mutator list (render only 8 (or less) currently visible mutator widgets)
      for i = ((_CURRENT_PAGE_NUMBER - 1) * 8 + 1), (_CURRENT_PAGE_NUMBER * 8) do
        if not _MUTATOR_LIST_WIDGETS[i] then
          break
        end
        UIRenderer.draw_widget(ui_renderer, _MUTATOR_LIST_WIDGETS[i])
      end
    else
      UIRenderer.draw_widget(ui_renderer, _NO_MUTATORS_TEXT_WIDGET)
    end

    -- Other widgets
    for _, widget in pairs(_OTHER_WIDGETS) do
      UIRenderer.draw_widget(ui_renderer, widget)
    end
  end

  UIRenderer.end_pass(ui_renderer)
end

-- Sets new scrollbar position (called when user changes the current page number with mouse scroll input)
local function update_scrollbar_position()
  local scrollbar_widget_content = _OTHER_WIDGETS.scrollbar.content
  local percentage = (1 / (_TOTAL_PAGES_NUMBER - 1)) * (_CURRENT_PAGE_NUMBER - 1)
  scrollbar_widget_content.scroll_bar_info.value = percentage
  scrollbar_widget_content.scroll_bar_info.old_value = percentage
end

-- Reads scrollbar input and if it was changed, set current page according to the new scrollbar position
local function update_scrollbar_input()
  local scrollbar_info = _OTHER_WIDGETS.scrollbar.content.scroll_bar_info
  local value = scrollbar_info.value
  local old_value = scrollbar_info.old_value
  if value ~= old_value then
    _CURRENT_PAGE_NUMBER = math.clamp(math.ceil(value / (1 / _TOTAL_PAGES_NUMBER)), 1, _TOTAL_PAGES_NUMBER)
    scrollbar_info.old_value = value
  end
end

-- Reads mousewheel scrolls from corresponding widget and changes current page number, if possible.
local function update_mousewheel_scroll_area_input()
  local widget_content = _OTHER_WIDGETS.mousewheel_scroll_area.content
  local mouse_scroll_value = widget_content.scroll_value
  if mouse_scroll_value ~= 0 then
    _CURRENT_PAGE_NUMBER = math.clamp(_CURRENT_PAGE_NUMBER + mouse_scroll_value, 1, _TOTAL_PAGES_NUMBER)
    widget_content.scroll_value = 0
    update_scrollbar_position()
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

  update_mousewheel_scroll_area_input()
  update_scrollbar_input()
  draw(map_view, dt)
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

-- Changes map_view VMF way
function vmf.modify_map_view()
  local map_view = get_map_view()
  if map_view then
    initialize_mutators_ui(map_view)
  end
end

-- Restores map_view to its defaults
function vmf.reset_map_view()
  local map_view = get_map_view()
  if map_view then
    change_map_view_look(map_view, false)
    show_mutator_list(map_view, false)
  end
end