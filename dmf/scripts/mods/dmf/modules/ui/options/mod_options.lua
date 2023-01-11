local dmf = get_mod("DMF")

local OptionsUtilities = require("scripts/utilities/ui/options")

local _type_template_map = {}

local _devices = {
  "keyboard",
  "mouse"
}
local _cancel_keys = {
  "keyboard_esc"
}
local _reserved_keys = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

-- #####################
-- ###### Header #######
-- #####################

-- Create header template
local create_header_template = function (self, params)

  local template = {
    category = params.category,
    display_name = params.readable_mod_name or params.title,
    group_name = params.mod_name,
    tooltip_text = params.tooltip,
    widget_type = "group_header",
  }
  return template
end
_type_template_map["header"] = create_header_template

-- ##########################
-- ###### Description #######
-- ##########################

-- Create description template
local create_description_template = function (self, params)

  local template = {
    category = params.category,
    group_name = params.mod_name,
    display_name = params.description,
    widget_type = "description",
    after = params.after
  }
  return template
end
_type_template_map["description"] = create_description_template

-- ###########################
-- ###### Percent Slider #####
-- ###########################

-- Create percentage slider template
local create_percent_slider_template = function (self, params)

  params.on_value_changed_function = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value, true)

    return true
  end
  params.value_get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  params.display_name = params.title
  params.apply_on_drag = true
  params.default_value = params.default_value
  params.normalized_step_size = 1 / 100

  local template = OptionsUtilities.create_percent_slider_template(params)

  template.after = params.parent_index
  template.category = params.category
  template.indentation_level = params.depth
  template.tooltip_text = params.tooltip

  return template
end
_type_template_map["percent_slider"] = create_percent_slider_template


-- ###########################
-- ###### Value Slider #######
-- ###########################

-- Create value slider template
local create_value_slider_template = function (self, params)

  params.on_value_changed_function = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value, true)

    return true
  end
  params.value_get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  params.display_name = params.title
  params.apply_on_drag = true
  params.default_value = params.default_value
  params.max_value = params.range[2]
  params.min_value = params.range[1]
  params.num_decimals = params.decimals_number
  params.step_size_value = math.pow(10, params.decimals_number * -1)
  params.type = "value_slider"

  local template = OptionsUtilities.create_value_slider_template(params)

  template.after = params.parent_index
  template.category = params.category
  template.indentation_level = params.depth
  template.tooltip_text = params.tooltip

  return template
end
_type_template_map["value_slider"] = create_value_slider_template
_type_template_map["numeric"] = create_value_slider_template


-- ######################
-- ###### Checkbox ######
-- ######################

-- Create checkbox template
local create_checkbox_template = function (self, params)
  local template = {
    after = params.parent_index,
    category = params.category,
    default_value = params.default_value,
    display_name = params.title,
    indentation_level = params.depth,
    tooltip_text = params.tooltip,
    value_type = "boolean",
  }
  template.on_activated = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value, true)

    return true
  end
  template.get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  return template
end
_type_template_map["checkbox"] = create_checkbox_template


-- ########################
-- ###### Mod Toggle ######
-- ########################

-- Create mod toggle template
local create_mod_toggle_template = function (self, params)
  local template = {
    after = params.after,
    category = params.category,
    default_value = true,
    display_name = dmf:localize("toggle_mod"),
    indentation_level = 0,
    tooltip_text = dmf:localize("toggle_mod_description"),
    value_type = "boolean",
  }

  template.on_activated = function(new_value)
    dmf.mod_state_changed(params.mod_name, new_value)

    return true
  end
  template.get_function = function()
    return get_mod(params.mod_name):is_enabled()
  end

  return template
end
_type_template_map["mod_toggle"] = create_mod_toggle_template


-- ######################
-- ###### Dropdown ######
-- ######################

-- Create dropdown template
local create_dropdown_template = function (self, params)

  for i = 1, #params.options do
    params.options[i].id = i - 1
    params.options[i].display_name = params.options[i].text
  end

  local template = {
    after = params.parent_index,
    category = params.category,
    default_value = params.default_value,
    display_name = params.title,
    indentation_level = params.depth,
    options = params.options,
    tooltip_text = params.tooltip,
    widget_type = "dropdown",
  }
  template.on_activated = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value, true)

    return true
  end
  template.get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  return template
end
_type_template_map["dropdown"] = create_dropdown_template


-- ###########################
-- ######### Keybind #########
-- ###########################

local set_new_keybind = function (self, keybind_data)
  local mod = get_mod(keybind_data.mod_name)
  dmf.add_mod_keybind(
    mod,
    keybind_data.setting_id,
    {
      global          = keybind_data.keybind_global,
      trigger         = keybind_data.keybind_trigger,
      type            = keybind_data.keybind_type,
      keys            = keybind_data.keys,
      function_name   = keybind_data.function_name,
      view_name       = keybind_data.view_name,
    }
  )
  mod:set(keybind_data.setting_id, keybind_data.keys, true)
end


-- Create keybind template
local create_keybind_template = function (self, params)

  local template = {
    widget_type = "keybind",
    service_type = "Ingame",
    tooltip_text = params.tooltip,
    display_name = params.title,
    group_name = params.category,
    category = params.category,
    after = params.parent_index,
    devices = _devices,
    sort_order = params.sort_order,
    cancel_keys = _cancel_keys,
    reserved_keys = _reserved_keys,
    indentation_level = params.depth,
    mod_name = params.mod_name,
    setting_id = params.setting_id,
    keys = dmf.keys_to_keybind_result(params.keys),

    on_activated = function (new_value, old_value)

      for i = 1, #_cancel_keys do
        local cancel_key = _cancel_keys[i]
        if cancel_key == new_value.main then

          -- Prevent unbinding the mod options menu
          if params.setting_id ~= "open_dmf_options" then

            -- Unbind the keybind
            params.keys = {}
            set_new_keybind(self, params)
          end

          return true
        end
      end

      for i = 1, #_reserved_keys do
        local reserved_key = _reserved_keys[i]
        if reserved_key == new_value.main then
          return false
        end
      end

      -- Get the new keybind
      local keys = dmf.keybind_result_to_keys(new_value)

      -- Bind the new key and prevent unbinding the mod options menu
      if keys and #keys > 0 or params.setting_id ~= "open_dmf_options" then
        params.keys = keys
        set_new_keybind(self, params)
      end

      return true
    end,

    get_function = function (template)
      local keys = get_mod(template.mod_name):get(template.setting_id)
      local keybind_result = dmf.keys_to_keybind_result(keys)

      return keybind_result
    end,
  }

  return template
end
_type_template_map["keybind"] = create_keybind_template


-- ###########################
-- ###### Miscellaneous ######
-- ###########################

-- Get the template creation function associated with a given widget data type
local function widget_data_to_template(self, data)
  if data and data.type and type(data.type) == "string" and _type_template_map[data.type] then
    return _type_template_map[data.type](self, data)
  else
    dmf:dump(data, "widget", 1)
    dmf.throw_error("[widget \"%s\"]: 'type' field must contain valid widget type name.", data.setting_id)
  end
end


--  Add a mod category to the options view categories
local function create_mod_category(self, categories, widget_data)
  local category = {
    can_be_reset = widget_data.can_be_reset or true,
    display_name = widget_data.readable_mod_name or widget_data.mod_name or "",
    custom       = true
  }
  categories[#categories + 1] = category
  return category
end


-- Create an option template and handle index offsets
local function create_option_template(self, widget_data, category_name, index_offset)
  local template = widget_data_to_template(self, widget_data)
  if template then
    template.custom = true
    template.category = category_name
    template.after = template.after and template.after + index_offset or nil

    return template
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

-- ####################################################################################################################
-- ##### DMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- Add mod settings to options view
dmf.create_mod_options_settings = function (self, options_templates)
  local categories = options_templates.categories
  local settings = options_templates.settings

  -- Create a category for every mod
  for _, mod_data in ipairs(dmf.options_widgets_data) do
    local category = create_mod_category(self, categories, mod_data[1])

    local index_offset = 0

    -- Create the category header
    local template = create_option_template(self, mod_data[1], category.display_name, index_offset)
    if template then
      settings[#settings + 1] = template
    end

    -- Create the mod description
    if mod_data[1].tooltip then
      local desc_widget_data = {
        mod_name = mod_data[1].mod_name,
        description = mod_data[1].tooltip,
        category = category.display_name,
        display_name = category.display_name,
        after = #settings,
        type = "description"
      }
      local desc_template = create_option_template(self, desc_widget_data, category.display_name, index_offset)

      if desc_template then
        settings[#settings + 1] = desc_template
        index_offset = index_offset + 1
      end
    end

    -- Create a top-level toggle option if the mod is togglable
    if mod_data[1].is_togglable then
      local toggle_widget_data = {
        mod_name = mod_data[1].mod_name,
        category = category.display_name,
        after = #settings,
        type = "mod_toggle"
      }

      local toggle_template = create_option_template(self, toggle_widget_data, category.display_name, index_offset)
      if toggle_template then
        settings[#settings + 1] = toggle_template
        index_offset = index_offset + 1
      end
    end

    -- Populate the category with options taken from the remaining options data
    for i = 2, #mod_data do
      local widget_data = mod_data[i]

      template = widget_data_to_template(self, widget_data)
      if template then
        template.custom = true
        template.category = category.display_name
        template.after = template.after + index_offset

        settings[#settings + 1] = template
      end
    end
  end

  return options_templates
end


dmf.initialize_dmf_options_view = function ()
  dmf:add_require_path("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view")
  dmf:add_require_path("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view_definitions")
  dmf:add_require_path("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view_settings")
  dmf:add_require_path("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view_content_blueprints")

  dmf:register_view({
    view_name = "dmf_options_view",
    view_settings = {
      init_view_function = function (ingame_ui_context)
        return true
      end,
      class = "DMFOptionsView",
      disable_game_world = false,
      display_name = "loc_options_view_display_name",
      game_world_blur = 1.1,
      load_always = true,
      load_in_hub = true,
      package = "packages/ui/views/options_view/options_view",
      path = "dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view",
      state_bound = true,
      enter_sound_events = {
        "wwise/events/ui/play_ui_enter_short"
      },
      exit_sound_events = {
        "wwise/events/ui/play_ui_back_short"
      },
      wwise_states = {
        options = "ingame_menu"
      }
    },
    view_transitions = {},
    view_options = {
      close_all = false,
      close_previous = false,
      close_transition_time = nil,
      transition_time = nil
    }
  })

  dmf:io_dofile("dmf/scripts/mods/dmf/modules/ui/options/dmf_options_view")
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################
