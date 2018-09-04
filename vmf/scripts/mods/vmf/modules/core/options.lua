local vmf = get_mod("VMF")

-- @TODO: rename stupid original field names
-- @TODO: rename to options_widget_data and probably add mod instead of mod name. Meaning adding mod data after
--        widget initialization?
vmf.options_widgets_definition = {}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

----------------
-- VALIDATION --
----------------

local function validate_generic_widget_data(mod, data)
  --[[
    string:
      data.setting_id
      data.title (optional if localize)
      data.tooltip (optional)
  ]]
end


local function validate_checkbox_data(mod, data)

end


local function validate_dropdown_data(mod, data)

  -- default value - something?
  -- options - table
  -- options.text - string
  -- options.value - something + some of them is default value
  -- options.show_widgets - table

end


local function validate_keybind_data(mod, data)

end


local function validate_numeric_data(mod, data)

end

------------------
-- LOCALIZATION --
------------------

local function localize_generic_widget_data(mod, data)
  if data.localize then
    data.text = mod:localize(data.text or data.setting_name)
    if data.tooltip then
      data.tooltip = mod:localize(data.tooltip)
    else
      data.tooltip = vmf.quick_localize(mod, data.setting_name .. "_description")
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

--------------------
-- INITIALIZATION --
--------------------

local function initialize_header_data(mod, data)
  local new_data = {}
  new_data.widget_index        = data.widget_index
  new_data.mod_name            = mod:get_name()
  new_data.readable_mod_name   = mod:get_readable_name()
  new_data.tooltip             = mod:get_description()
  new_data.is_mod_toggable     = mod:get_internal_data("is_togglable") and not mod:get_internal_data("is_mutator")
  new_data.is_widget_collapsed = vmf:get("options_menu_collapsed_mods")[mod:get_name()]
  new_data.is_favorited        = vmf:get("options_menu_favorite_mods")[mod:get_name()]

  new_data.widget_type         = data.type
  return new_data
end


-- The data that applies to any widget, except for header
local function initialize_generic_widget_data(mod, data, localize)
  local new_data = {}

  -- Automatically generated values
  new_data.widget_index         = data.widget_index
  new_data.parent_widget_number = data.parent_widget_index
  new_data.widget_level         = data.depth
  new_data.mod_name             = mod:get_name()

  -- Defined in widget
  new_data.widget_type          = data.type
  new_data.setting_name         = data.setting_id
  new_data.text                 = data.title         -- optional, if (localize == true)
  new_data.tooltip              = data.tooltip       -- optional
  new_data.default_value        = data.default_value

  -- Overwrite global optons localization setting if widget defined it
  if data.localize == nil then
    new_data.localize = localize
  else
    new_data.localize = data.localize
  end

  validate_generic_widget_data(mod, new_data)
  localize_generic_widget_data(mod, new_data)

  return new_data
end


local function initialize_group_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_widget_collapsed = collapsed_widgets[data.setting_id]

  return new_data
end


local function initialize_checkbox_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_widget_collapsed = collapsed_widgets[data.setting_id]

  validate_checkbox_data(mod, new_data)

  return new_data
end


local function initialize_dropdown_data(mod, data, localize, collapsed_widgets)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.is_widget_collapsed = collapsed_widgets[data.setting_id]
  new_data.options             = data.options

  validate_dropdown_data(mod, new_data)
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
            new_show_widgets[data.sub_widgets[sub_widget_index].widget_index] = true
          else
            error(string.format("'widget \"%s\" (dropdown) -> options -> [%d] -> show_widgets -> [%d] \"%s\"' points" ..
                                 " to non-existing sub_widget", data.setting_id, i, j, sub_widget_index))
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
  new_data.action          = data.action_name
  new_data.view_name       = data.view_name

  validate_keybind_data(mod, new_data)

  return new_data
end


local function initialize_numeric_data(mod, data, localize)
  local new_data = initialize_generic_widget_data(mod, data, localize)

  new_data.unit_text       = data.unit_text
  new_data.range           = data.range
  new_data.decimals_number = data.decimals_number

  validate_numeric_data(mod, new_data)

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
  else
    -- @TODO: throw an error or something
  end
end

-----------
-- OTHER --
-----------

-- unfold nested table?
local function unfold_table(unfolded_table, unfoldable_table, parent_widget_index, depth)
  for i = 1, #unfoldable_table do
    local nested_table = unfoldable_table[i]
    if type(nested_table) == "table" then
      table.insert(unfolded_table, nested_table)
      nested_table.depth = depth
      nested_table.widget_index = #unfolded_table
      nested_table.parent_widget_index = parent_widget_index
      local nested_table_sub_widgets = nested_table.sub_widgets
      if nested_table_sub_widgets then
        if type(nested_table_sub_widgets) == "table" then
          unfold_table(unfolded_table, nested_table_sub_widgets, #unfolded_table, depth + 1)
        else
          vmf:dump(unfolded_table, "widgets", 1)
          error(string.format("'sub_widgets' field of widget [%d] is not a table, it's %s. " ..
                               "See dumped table in game log for reference.", #unfolded_table,
                                                                               type(nested_table_sub_widgets)), 0)
        end
      end
    else
      vmf:dump(unfolded_table, "widgets", 1)
      error(string.format("sub_widget#%d of widget [%d] is not a table, it's %s. " ..
                           "See dumped table in game log for reference.", i, parent_widget_index,
                                                                           type(nested_table)), 0)
    end
  end
  return unfolded_table
end


local function initialize_mod_options_widgets_data(mod, widgets_data, localize)
  local initialized_data = {}

  -- Define widget data for header, because it's not up to modders to define it.
  local header_widget_data = {type = "header", widget_index = 1, sub_widgets = widgets_data}
  -- Put data of all widgets in one-dimensional array in order they will be displayed in mod options.
  local unfolded_raw_widgets_data = unfold_table({header_widget_data}, widgets_data, 1, 1)
  -- Load info about widgets previously collapsed by user
  local collapsed_widgets = vmf:get("options_menu_collapsed_widgets")[mod:get_name()] or {}

  for _, widget_data in ipairs(unfolded_raw_widgets_data) do
    table.insert(initialized_data, initialize_widget_data(mod, widget_data, localize, collapsed_widgets))
  end

  -- Set setting to default value that were not set before (skipping header)
  -- Also, initialize keybinds
  for i = 2, #initialized_data do
    local data = initialized_data[i]
    if mod:get(data.setting_name) == nil then
      mod:set(data.setting_name, data.default_value)
    end
    if data.widget_type == "keybind" then
      mod:keybind(data.setting_name, data.action, mod:get(data.setting_name))
    end
  end

  table.insert(vmf.options_widgets_definition, initialized_data)

  -- @DEBUG:
  mod:dump(unfolded_raw_widgets_data, "unfolded_raw_widgets_data", 1)
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

vmf.initialize_mod_options = function (mod, options)
  -- Global localization (for all options elements) ('true' by defualt)
  local localize_options_global = options.localize ~= false
  -- Options widgets localization (inherits from global one, unless defined in 'widgets' table)
  local localize_options_widgets = localize_options_global
  if options.widgets.localize ~= nil then
    localize_options_widgets = options.widgets.localize
  end

  -- @TODO: remove "vmf"
  local success, value = vmf:pcall(initialize_mod_options_widgets_data, mod, options.widgets, localize_options_widgets)
  if not success then
    mod:error("Could not initialize options widgets, options initialization aborted: %s", value)
    return
  end

  -- @DEBUG:
  mod:echo("INITIALIZE OPTIONS")
  return true
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