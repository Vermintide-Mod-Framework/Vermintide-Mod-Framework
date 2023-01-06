local vmf = get_mod("VMF")

local OptionsUtilities = require("scripts/utilities/ui/options")
local InputUtils = require("scripts/managers/input/input_utils")

local _type_template_map = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

-- Create value slider template
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


-- Create percentage slider template
local create_percent_slider_template = function (self, params)

  params.on_value_changed_function = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value)

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


-- Create value slider template
local create_value_slider_template = function (self, params)

  params.on_value_changed_function = function(new_value)
    get_mod(params.mod_name):set(params.setting_id, new_value)

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
    get_mod(params.mod_name):set(params.setting_id, new_value)

    return true
  end
  template.get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  return template
end
_type_template_map["checkbox"] = create_checkbox_template


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
    get_mod(params.mod_name):set(params.setting_id, new_value)

    return true
  end
  template.get_function = function()
    return get_mod(params.mod_name):get(params.setting_id)
  end

  return template
end
_type_template_map["dropdown"] = create_dropdown_template


local set_new_keybind = function (self, keybind_widget_content)
  vmf.add_mod_keybind(
    get_mod(keybind_widget_content.mod_name),
    keybind_widget_content.setting_id,
    {
      global          = keybind_widget_content.keybind_global,
      trigger         = keybind_widget_content.keybind_trigger,
      type            = keybind_widget_content.keybind_type,
      keys            = keybind_widget_content.keys,
      function_name   = keybind_widget_content.function_name,
      view_name       = keybind_widget_content.view_name,
    }
  )
end


-- Create keybind template
local create_keybind_template = function (self, params)
  local reserved_keys = {}
  local cancel_keys = {
    "keyboard_esc"
  }
  local devices = {
    "keyboard",
    "mouse",
    "xbox_controller",
    "ps4_controller"
  }

  local template = {
    widget_type = "keybind",
    service_type = "Ingame",
    tooltip_text = params.tooltip,
    display_name = params.title,
    group_name = params.category,
    category = params.category,
    after = params.parent_index,
    devices = devices,
    sort_order = params.sort_order,
    cancel_keys = cancel_keys,
    reserved_keys = reserved_keys,
    indentation_level = params.depth,
    mod_name = params.mod_name,
    setting_id = params.setting_id,

    on_activated = function (new_value, old_value)

      for i = 1, #cancel_keys do
        local cancel_key = cancel_keys[i]
        if cancel_key == new_value.main then

          -- Prevent unbinding the mod options menu
          if params.setting_id ~= "open_vmf_options" then

            params.keybind_text = ""
            params.keys         = {}

            set_new_keybind(self, params)
          end
          return true
        end
      end

      for i = 1, #reserved_keys do
        local reserved_key = reserved_keys[i]
        if reserved_key == new_value.main then
          return false
        end
      end

      local device_type = InputUtils.key_device_type(new_value.main)
      local key_name = InputUtils.local_key_name(new_value.main, device_type)

      params.keybind_text = key_name
      params.keys         = {key_name}

      set_new_keybind(self, params)
      return true
    end,

    get_function = function (template)

      local setting = get_mod(template.mod_name):get(template.setting_id)
      local local_name = setting and setting[1]
      if not local_name then
        return false
      end

      local global_name = InputUtils.local_to_global_name(local_name, "keyboard")
      return {
        main = global_name,
        disablers = {},
        enablers = {},
      }
    end,
  }

  return template
end
_type_template_map["keybind"] = create_keybind_template


local function widget_data_to_template(self, data)
  if data and data.type and type(data.type) == "string" and _type_template_map[data.type] then
    return _type_template_map[data.type](self, data)
  else
    vmf:dump(data, "widget", 1)
    vmf.throw_error("[widget \"%s\"]: 'type' field must contain valid widget type name.", data.setting_id)
  end
end


--  Add mod categories to options view
local create_mod_category = function (self, categories, widget_data)
  local category = {
    can_be_reset = widget_data.can_be_reset or true,
    display_name = widget_data.readable_mod_name or widget_data.mod_name or "",
    icon         = widget_data.icon_material or "content/ui/materials/icons/system/settings/category_gameplay",
    custom       = true
  }
  categories[#categories + 1] = category
  return category
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################


-- Add mod settings to options view
vmf.create_mod_options_settings = function (self, options_templates)
  local categories = options_templates.categories
  local settings = options_templates.settings

  for _, mod_data in ipairs(vmf.options_widgets_data) do
    local category = create_mod_category(self, categories, mod_data[1])

    for _, widget_data in ipairs(mod_data) do
      local template = widget_data_to_template(self, widget_data)
      if template then
        template.custom = true
        template.category = category.display_name
        
        settings[#settings + 1] = template
      end
    end
  end

  return options_templates

  --[[local settings = OptionsView._options_templates.settings

  for name, this_mod in pairs(Mods) do
    -- Custom settings
    if type(this_mod) == "table" and this_mod.options then

      local text = this_mod.text or name
      Mods.Localization.add("loc_settings_menu_group_mods_"..name, text)

      local options_no_after = 0
      for _, option in pairs(this_mod.options) do
        if not option.after then
          options_no_after = options_no_after + 1
        end
      end

      if options_no_after > 0 then
        settings[#settings+1] = {
          widget_type = "group_header",
          group_name = "mods_settings",
          display_name = "loc_settings_menu_group_mods_"..name,
          category = "loc_settings_menu_category_mods",
          custom = true,
        }
      end

      for _, setting in pairs(this_mod.options) do
        setting.custom = true
        setting.category = setting.category or "loc_settings_menu_category_mods"
        setting.indentation_level = setting.after and 1 or 0
        if setting.after then
          local index = self:after_index(OptionsView, setting.after)
          table.insert(settings, index, setting)
        else
          settings[#settings+1] = setting
        end
      end
      
    end
  end]]
end


vmf.initialize_vmf_options_view = function ()
  vmf:add_require_path("dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view")
  vmf:add_require_path("dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view_definitions")
  vmf:add_require_path("dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view_settings")
  vmf:add_require_path("dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view_content_blueprints")

  vmf:register_view({
    view_name = "vmf_options_view",
    view_settings = {
      init_view_function = function (ingame_ui_context)
        return true
      end,
      class = "VMFOptionsView",
      disable_game_world = false,
      display_name = "loc_options_view_display_name",
      game_world_blur = 1.1,
      load_always = true,
      load_in_hub = true,
      package = "packages/ui/views/options_view/options_view",
      path = "dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view",
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

  vmf:dofile("dmf/scripts/mods/vmf/modules/ui/options/vmf_options_view")
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################
