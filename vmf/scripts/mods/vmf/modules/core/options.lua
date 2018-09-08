local vmf = get_mod("VMF")

-- This variable is defined here and not in widget data initialization function because some error messages
-- require it to be dumped to game log.
local _unfolded_raw_widgets_data

-- Saves used setting_ids for initializable mod. Is used to detect if 2 widgets use the same setting_id
local _defined_mod_settings

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function throw_error(error_message, ...)
  error(string.format(error_message, ...), 0)
end

-- #############################
-- # Default collapsed widgets #
-- #############################

-- @BUG: you can set it for disabled checkbox and it will be displayed as collapsed @TODO: fix it for new mod options
local function initialize_collapsed_widgets(mod, collapsed_widgets)

  local new_collapsed_widgets = {}
  for i, collapsed_widget_name in ipairs(collapsed_widgets) do
    if type(collapsed_widget_name) == "string" then
      new_collapsed_widgets[collapsed_widget_name] = true
    else
      throw_error("'collapsed_widgets[%d]' is not a string", i)
    end
  end

  local options_menu_collapsed_widgets = vmf:get("options_menu_collapsed_widgets")
  options_menu_collapsed_widgets[mod:get_name()] = new_collapsed_widgets
  vmf:set("options_menu_collapsed_widgets", options_menu_collapsed_widgets)
end

-- ################
-- # Widgets data #
-- ################

----------------
-- VALIDATION --
----------------

local function validate_generic_widget_data(data)
  local setting_id = data.setting_id

  if type(setting_id) ~= "string" then
    vmf:dump(_unfolded_raw_widgets_data, "widgets", 1)
    throw_error("[widget#%d (%s)]: 'setting_id' field is required and must have 'string' type. " ..
                 "See dumped table in game log for reference.", data.index, data.type)
  end

  if not data.localize and not data.title then
    throw_error("[widget \"%s\" (%s)]: lacks 'title' field (localization is disabled)", setting_id, data.type)
  end

  if data.title and type(data.title) ~= "string" then
    throw_error("[widget \"%s\" (%s)]: 'title' field must have 'string' type", setting_id, data.type)
  end

  if data.tooltip and type(data.tooltip) ~= "string" then
    throw_error("[widget \"%s\" (%s)]: 'tooltip' field must have 'string' type", setting_id, data.type)
  end

  if _defined_mod_settings[setting_id] then
    vmf:dump(_unfolded_raw_widgets_data, "widgets", 1)
    throw_error("Widgets %d and %d have the same setting_id (\"%s\"). See dumped table in game log for reference.",
                 _defined_mod_settings[setting_id], data.index, setting_id)
  else
    _defined_mod_settings[setting_id] = data.index
  end
end


local function validate_checkbox_data(data)
  if type(data.default_value) ~= "boolean" then
    throw_error("[widget \"%s\" (checkbox)]: 'default_value' field is required and must have 'boolean' type",
                 data.setting_id)
  end
end


local allowed_dropdown_values = {
  boolean = true,
  string  = true,
  number  = true
}
local function validate_dropdown_data(data)

  if not allowed_dropdown_values[type(data.default_value)] then
    throw_error("[widget \"%s\" (dropdown)]: 'default_value' field is required and must have 'string', " ..
                 "'number' or 'boolean' type", data.setting_id)
  end

  if type(data.options) ~= "table" then
    throw_error("[widget \"%s\" (dropdown)]: 'options' field is required and must have 'table' type", data.setting_id)
  end

  local default_value = data.default_value
  local default_value_match = false
  local used_values = {}
  for i, option in ipairs(data.options) do
    local option_value = option.value

    if type(option.text) ~= "string" then
      throw_error("[widget \"%s\" (dropdown)]: 'options[%d]'-> 'text' field is required and must have 'string' type",
                   data.setting_id, i)
    end

    if not allowed_dropdown_values[type(option_value)] then
      throw_error("[widget \"%s\" (dropdown)]: 'options[%d]'-> 'value' field is required and must have 'string', " ..
                   "'number' or 'boolean' type", data.setting_id, i)
    end

    if option.show_widgets and type(option.show_widgets) ~= "table" then
      throw_error("[widget \"%s\" (dropdown)]: 'options[%d]'-> 'show_widgets' field must have 'table' type",
                   data.setting_id, i)
    end

    if used_values[option_value] then
      throw_error("[widget \"%s\" (dropdown)]: 'options[%d]' has 'value' field set to the same value " ..
                   "as one of previous options", data.setting_id, i)
    end

    used_values[option_value] = true

    if default_value == option_value then
      default_value_match = true
    end
  end

  if not default_value_match then
    throw_error("[widget \"%s\" (dropdown)]: 'default_value' field contains value not defined in 'options' field",
                 data.setting_id)
  end
end


local allowed_keybind_triggers = {
  pressed  = true,
  released = true,
  held     = true
}
local allowed_keybind_types = {
  action_call = true,
  view_toggle = true,
  mod_toggle  = true
}
local allowed_special_keys = {
  ctrl  = true,
  alt   = true,
  shift = true
}
local function validate_keybind_data(data)
  if data.keybind_global and type(data.keybind_global) ~= "boolean" then
    throw_error("[widget \"%s\" (keybind)]: 'keybind_global' field must have 'boolean' type", data.setting_id)
  end

  if not allowed_keybind_triggers[data.keybind_trigger] then
    throw_error("[widget \"%s\" (keybind)]: 'keybind_trigger' field is required and must contain string " ..
                 "\"action_call\", \"view_toggle\" or \"mod_toggle\"", data.setting_id)
  end

  local keybind_type = data.keybind_type
  if not allowed_keybind_types[keybind_type] then
    throw_error("[widget \"%s\" (keybind)]: 'keybind_type' field is required and must contain string " ..
                 "\"pressed\", \"released\" or \"held\"", data.setting_id)
  end
  if keybind_type == "action_call" and type(data.action_name) ~= "string" then
    throw_error("[widget \"%s\" (keybind)]: 'keybind_type' is set to \"action_call\" so 'action_name' " ..
                 "field is required and must have 'string' type", data.setting_id)
  end
  if keybind_type == "view_toggle" and type(data.view_name) ~= "string" then
    throw_error("[widget \"%s\" (keybind)]: 'keybind_type' is set to \"view_toggle\" so 'view_name' " ..
                 "field is required and must have 'string' type", data.setting_id)
  end

  local default_value = data.default_value
  if type(default_value) ~= "table" then
    throw_error("[widget \"%s\" (keybind)]: 'default_value' field is required and must have 'table' type",
                 data.setting_id)
  end
  if #default_value > 4 then
    throw_error("[widget \"%s\" (keybind)]: table stored in 'default_value' field can't exceed 4 elements",
                 data.setting_id)
  end
  if default_value[1] and (not vmf.readable_key_names[default_value[1]] or allowed_special_keys[default_value[1]]) then
    throw_error("[widget \"%s\" (keybind)]: 'default_value[1]' must be a valid key name", data.setting_id)
  end
  if default_value[2] and not allowed_special_keys[default_value[2]] or
     default_value[3] and not allowed_special_keys[default_value[3]] or
     default_value[4] and not allowed_special_keys[default_value[4]]
  then
    throw_error("[widget \"%s\" (keybind)]: 'default_value [2], [3] and [4]' can be only strings: \"ctrl\", " ..
                 "\"alt\" and \"shift\" (in no particular order)", data.setting_id)
  end

  local used_keys = {}
  for _, key in ipairs(default_value) do
    if used_keys[key] then
      throw_error("[widget \"%s\" (keybind)]: you can't define the same key in 'default_value' table twice",
                   data.setting_id)
    end
    used_keys[key] = true
  end
end


local function validate_numeric_data(data)
  if data.unit_text and type(data.unit_text) ~= "string" then
    throw_error("[widget \"%s\" (numeric)]: 'unit_text' field must have 'string' type", data.setting_id)
  end

  if type(data.decimals_number) ~= "number" then
    throw_error("[widget \"%s\" (numeric)]: 'decimals_number' field must have 'number' type", data.setting_id)
  end
  if data.decimals_number < 0 then -- @TODO: eventually do max cap as well
    throw_error("[widget \"%s\" (numeric)]: 'decimals_number' value can't be lower than zero", data.setting_id)
  end

  local range = data.range
  if type(range) ~= "table" then
    throw_error("[widget \"%s\" (numeric)]: 'range' field is required and must have 'table' type", data.setting_id)
  end
  if #range ~= 2 then
    throw_error("[widget \"%s\" (numeric)]: 'range' field must contain an array-like table with 2 elements",
                 data.setting_id)
  end
  local range_min = range[1]
  local range_max = range[2]
  if type(range_min) ~= "number" or type(range_max) ~= "number" then
    throw_error("[widget \"%s\" (numeric)]: table stored in 'range' field must contain only numbers",
                 data.setting_id)
  end
  if range_min > range_max then
    throw_error("[widget \"%s\" (numeric)]: 'range[2]' must be bigger than 'range[1]'", data.setting_id)
  end

  local default_value = data.default_value
  if type(default_value) ~= "number" then
    throw_error("[widget \"%s\" (numeric)]: 'default_value' field is required and must have 'number' type",
                 data.setting_id)
  end
  if default_value < range_min or default_value > range_max then
    throw_error("[widget \"%s\" (numeric)]: 'default_value' field must contain number fitting set 'range'",
                 data.setting_id)
  end
end

------------------
-- LOCALIZATION --
------------------

local function localize_generic_widget_data(mod, data)
  if data.localize then
    data.title = mod:localize(data.title or data.setting_id)
    if data.tooltip then
      data.tooltip = mod:localize(data.tooltip)
    else
      data.tooltip = vmf.quick_localize(mod, data.setting_id .. "_description")
    end
  end
end


local function localize_dropdown_data(mod, data)
  local options = data.options
  local localize = data.localize
  if options.localize ~= nil then
    localize = options.localize
  end
  if localize then
    for _, option in ipairs(options) do
      option.text = mod:localize(option.text)
    end
  end
end


local function localize_numeric_data(mod, data)
  if data.localize and data.unit_text then
    data.unit_text = mod:localize(data.unit_text)
  end
end

--------------------
-- INITIALIZATION --
--------------------

local function initialize_header_data(mod, data)
  local new_data = {}
  new_data.type              = data.type
  new_data.index             = data.index
  new_data.mod_name          = mod:get_name()
  new_data.readable_mod_name = mod:get_readable_name()
  new_data.tooltip           = mod:get_description()
  new_data.is_togglable      = mod:get_internal_data("is_togglable") and not mod:get_internal_data("is_mutator")
  new_data.is_collapsed      = vmf:get("options_menu_collapsed_mods")[mod:get_name()]

  for _, favorited_mod_name in ipairs(vmf:get("options_menu_favorite_mods")) do
    if favorited_mod_name == new_data.mod_name then
      new_data.is_favorited  = true
    end
  end

  return new_data
end


-- The data that applies to any widget, except for header
local function initialize_generic_widget_data(mod, data, localize)
  local new_data = {}

  -- Automatically generated values
  new_data.index         = data.index
  new_data.parent_index  = data.parent_index
  new_data.depth         = data.depth
  new_data.mod_name      = mod:get_name()

  -- Defined in widget
  new_data.type          = data.type
  new_data.setting_id    = data.setting_id
  new_data.title         = data.title         -- optional, if (localize == true)
  new_data.tooltip       = data.tooltip       -- optional
  new_data.default_value = data.default_value

  -- Overwrite global optons localization setting if widget defined it
  if data.localize == nil then
    new_data.localize = localize
  else
    new_data.localize = data.localize
  end

  validate_generic_widget_data(new_data)
  localize_generic_widget_data(mod, new_data)

  new_data.tooltip = new_data.tooltip and (new_data.title .. "\n" .. new_data.tooltip)

  return new_data
end


local function initialize_group_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_collapsed = collapsed_widgets[data.setting_id]

  return new_data
end


local function initialize_checkbox_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_collapsed = collapsed_widgets[data.setting_id]

  validate_checkbox_data(new_data)

  return new_data
end


local function initialize_dropdown_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_collapsed = collapsed_widgets[data.setting_id]
  new_data.options      = data.options

  validate_dropdown_data(new_data)
  localize_dropdown_data(mod, new_data)

  -- Converting show_widgets from human-readable form to vmf-options-readable
  -- i.e. {[1] = 2, [2] = 3, [3] = 5} -> {[113] = true, [114] = true, [116] = true}
  -- Where the 2nd set of numbers are the real widget numbers of subwidgets
  if data.sub_widgets ~= nil then
    for i, option in ipairs(data.options) do
      if option.show_widgets then
        local new_show_widgets = {}
        for j, sub_widget_index in ipairs(option.show_widgets) do
          if data.sub_widgets[sub_widget_index] then
            new_show_widgets[data.sub_widgets[sub_widget_index].index] = true
          else
            throw_error("[widget \"%s\" (dropdown)]: 'options -> [%d] -> show_widgets -> [%d] \"%s\"' points" ..
                         " to non-existing sub_widget", data.setting_id, i, j, sub_widget_index)
          end
        end
        option.show_widgets = new_show_widgets
      end
    end
  end

  return new_data
end


local function initialize_keybind_data(mod, data, localize)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.keybind_global  = data.keybind_global
  new_data.keybind_trigger = data.keybind_trigger
  new_data.keybind_type    = data.keybind_type
  new_data.action_name     = data.action_name
  new_data.view_name       = data.view_name

  validate_keybind_data(new_data)

  return new_data
end


local function initialize_numeric_data(mod, data, localize)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.unit_text       = data.unit_text
  new_data.range           = data.range
  new_data.decimals_number = data.decimals_number or 0

  validate_numeric_data(new_data)
  localize_numeric_data(mod, new_data)

  return new_data
end


local function initialize_widget_data(mod, data, localize, collapsed_widgets)
  if data.type == "header" then
    return initialize_header_data(mod, data)
  elseif data.type == "group" then
    return initialize_group_data(mod, data, localize, collapsed_widgets)
  elseif data.type == "checkbox" then
    return initialize_checkbox_data(mod, data, localize, collapsed_widgets)
  elseif data.type == "dropdown" then
    return initialize_dropdown_data(mod, data, localize, collapsed_widgets)
  elseif data.type == "keybind" then
    return initialize_keybind_data(mod, data, localize)
  elseif data.type == "numeric" then
    return initialize_numeric_data(mod, data, localize)
  end
  -- if data.type is incorrect, returns nil
end

-----------
-- OTHER --
-----------

local function unfold_table(unfolded_table, unfoldable_table, parent_index, depth)
  for i = 1, #unfoldable_table do
    local nested_table = unfoldable_table[i]
    if type(nested_table) == "table" then
      table.insert(unfolded_table, nested_table)
      nested_table.depth = depth
      nested_table.index = #unfolded_table
      nested_table.parent_index = parent_index
      local nested_table_sub_widgets = nested_table.sub_widgets
      if nested_table_sub_widgets then
        if type(nested_table_sub_widgets) == "table" then
          unfold_table(unfolded_table, nested_table_sub_widgets, #unfolded_table, depth + 1)
        else
          vmf:dump(unfolded_table, "widgets", 1)
          throw_error("'sub_widgets' field of widget [%d] is not a table, it's %s. " ..
                       "See dumped table in game log for reference.", #unfolded_table, type(nested_table_sub_widgets))
        end
      end
    else
      vmf:dump(unfolded_table, "widgets", 1)
      throw_error("sub_widget#%d of widget [%d] is not a table, it's %s. " ..
                   "See dumped table in game log for reference.", i, parent_index, type(nested_table))
    end
  end
  return unfolded_table
end


local function initialize_mod_options_widgets_data(mod, widgets_data, localize)
  widgets_data = widgets_data or {}
  -- Override global localize option if it's set for widgets data
  if widgets_data.localize ~= nil then
    localize = widgets_data.localize
  end

  local initialized_data = {}

  -- Define widget data for header widget, because it's not up to modders to define it.
  local header_widget_data = {type = "header", sub_widgets = widgets_data}
  -- Put data of all widgets in one-dimensional array in order they will be displayed in mod options.
  _unfolded_raw_widgets_data = unfold_table({header_widget_data}, widgets_data, 1, 1)
  -- Load info about widgets previously collapsed by user
  local collapsed_widgets = vmf:get("options_menu_collapsed_widgets")[mod:get_name()] or {}

  -- Before starting widgets data initialization, clear this table. It's used to detect if 2 widgets
  -- defined the same setting_id.
  _defined_mod_settings = {}
  -- Initialize widgets' data.
  for _, widget_data in ipairs(_unfolded_raw_widgets_data) do
    local initialized_widget_data = initialize_widget_data(mod, widget_data, localize, collapsed_widgets)
    if initialized_widget_data then
      table.insert(initialized_data, initialized_widget_data)
    else
      vmf:dump(_unfolded_raw_widgets_data, "widgets", 1)
      throw_error("[widget#%d]: 'type' field must contain valid widget type name. " ..
                   "See dumped table in game log for reference.", widget_data.index, widget_data.type)
    end
  end

  return initialized_data
end

-- ################################################
-- # Default settings and keybinds initialization #
-- ################################################

local function initialize_default_settings_and_keybinds(mod, initialized_widgets_data)
  for i = 2, #initialized_widgets_data do
    local data = initialized_widgets_data[i]
    if mod:get(data.setting_id) == nil then
      mod:set(data.setting_id, data.default_value)
    end
    if data.type == "keybind" then
      mod:keybind(data.setting_id, data.action_name, mod:get(data.setting_id))
    end
  end
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Is used in Mod Options to create options widgets
vmf.options_widgets_data = {}

-- Initializes mod's options data. If this function is called with 'options.widgets' not specified, it just creates
-- widget data with single header with checkbox.
function vmf.initialize_mod_options(mod, options)
  options = options or {}

  -- If this is the first time user launches this mod, set collapsed widgets list to default one.
  if options.collapsed_widgets and not vmf.mod_has_settings(mod) then
    initialize_collapsed_widgets(mod, options.collapsed_widgets)
  end

  -- Initialize mod's options widgets data.
  local initialized_widgets_data = initialize_mod_options_widgets_data(mod, options.widgets, options.localize ~= false)

  -- Initialize mod's settings that were not initialized before by setting them to their default values.
  -- Also, initialize mod's keybinds.
  initialize_default_settings_and_keybinds(mod, initialized_widgets_data)

  -- Insert initialized widgets data to the table which will be used by Mod Options to built options widgets list
  -- for this mod.
  table.insert(vmf.options_widgets_data, initialized_widgets_data)
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

if type(vmf:get("options_menu_favorite_mods")) ~= "table" then
  vmf:set("options_menu_favorite_mods", {})
end

if type(vmf:get("options_menu_collapsed_mods")) ~= "table" then
  vmf:set("options_menu_collapsed_mods", {})
end

if type(vmf:get("options_menu_collapsed_widgets")) ~= "table" then
  vmf:set("options_menu_collapsed_widgets", {})
end