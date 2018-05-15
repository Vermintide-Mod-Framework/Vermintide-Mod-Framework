
local vmf = get_mod("VMF")

local _DEFINITIONS = dofile("scripts/mods/vmf/modules/ui/mutators/mutators_gui_definitions")

local _MUTATORS = vmf.mutators

local _UI_SCENEGRAPH
local _MUTATOR_LIST_WIDGETS = {}
local _PARTY_BUTTON_WIDGET
local _OTHER_WIDGETS = {}


local _ORIGINAL_VALUES = {}

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


local function initialize_mutators_ui(map_view)

  -- Scenegraph
  _UI_SCENEGRAPH = UISceneGraph.init_scenegraph(_DEFINITIONS.scenegraph_definition)

  -- Creating mutator list widgets and calculating total pages number
  for i, mutator in ipairs(_MUTATORS) do
    local offset = ((i - 1) % 8) + 1
    _MUTATOR_LIST_WIDGETS[i] = UIWidget.init(_DEFINITIONS.create_mutator_widget(mutator))
    _MUTATOR_LIST_WIDGETS[i].offset = {0, -32 * offset, 0}
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
