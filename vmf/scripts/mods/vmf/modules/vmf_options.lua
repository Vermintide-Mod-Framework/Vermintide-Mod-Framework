local vmf = get_mod("VMF")

local vmf_mod_data = {}
vmf_mod_data.name = "Vermintide Mod Framework"
vmf_mod_data.options = {
  widgets = {
    {
      setting_id      = "open_vmf_options",
      type            = "keybind",
      default_value   = {"f4"},
      keybind_trigger = "pressed",
      keybind_type    = "action_call",
      action_name     = "open_vmf_options"
    },
    {
      setting_id    = "vmf_options_scrolling_speed",
      type          = "numeric",
      default_value = 100,
      range         = {1, 1000},
      unit_text     = "percent"
    },
    {
      setting_id    = "ui_scaling",
      type          = "checkbox",
      default_value = true
    },
    {
      setting_id    = "developer_mode",
      type          = "checkbox",
      default_value = false,
      sub_widgets = {
        {
          setting_id    = "show_developer_console",
          type          = "checkbox",
          default_value = false
        },
        {
          setting_id      = "toggle_developer_console",
          type            = "keybind",
          default_value   = {},
          keybind_trigger = "pressed",
          keybind_type    = "action_call",
          action_name     = "toggle_developer_console"
        },
        {
          setting_id    = "show_network_debug_info",
          type          = "checkbox",
          default_value = false
        },
        {
          setting_id    = "log_ui_renderers_info",
          type          = "checkbox",
          default_value = false
        }
      }
    },
    {
      setting_id    = "logging_mode",
      type          = "dropdown",
      default_value = "default",
      options = {
        {text = "settings_default", value = "default"},
        {text = "settings_custom",  value = "custom", show_widgets = {1, 2, 3, 4, 5}},
      },
      sub_widgets = {
        {
          setting_id    = "output_mode_echo",
          type          = "dropdown",
          default_value = 3,
          options = {
            {text = "output_disabled",     value = 0},
            {text = "output_log",          value = 1},
            {text = "output_chat",         value = 2},
            {text = "output_log_and_chat", value = 3},
          }
        },
        {
          setting_id    = "output_mode_error",
          type          = "dropdown",
          default_value = 3,
          options = {
            {text = "output_disabled",     value = 0},
            {text = "output_log",          value = 1},
            {text = "output_chat",         value = 2},
            {text = "output_log_and_chat", value = 3},
          }
        },
        {
          setting_id    = "output_mode_warning",
          type          = "dropdown",
          default_value = 3,
          options = {
            {text = "output_disabled",     value = 0},
            {text = "output_log",          value = 1},
            {text = "output_chat",         value = 2},
            {text = "output_log_and_chat", value = 3},
          }
        },
        {
          setting_id    = "output_mode_info",
          type          = "dropdown",
          default_value = 1,
          options = {
            {text = "output_disabled",     value = 0},
            {text = "output_log",          value = 1},
            {text = "output_chat",         value = 2},
            {text = "output_log_and_chat", value = 3},
          }
        },
        {
          setting_id    = "output_mode_debug",
          type          = "dropdown",
          default_value = 0,
          options = {
            {text = "output_disabled",     value = 0},
            {text = "output_log",          value = 1},
            {text = "output_chat",         value = 2},
            {text = "output_log_and_chat", value = 3},
          }
        }
      }
    },
    {
      setting_id    = "chat_history_enable",
      type          = "checkbox",
      default_value = true,
      sub_widgets = {
        {
          setting_id    = "chat_history_save",
          type          = "checkbox",
          default_value = true
        },
        {
          setting_id    = "chat_history_buffer_size",
          type          = "numeric",
          default_value = 50,
          range         = {10, 200}
        },
        {
          setting_id    = "chat_history_remove_dups",
          type          = "checkbox",
          default_value = false,
          sub_widgets = {
            {
              setting_id    = "chat_history_remove_dups_mode",
              type          = "dropdown",
              default_value = "last",
              options = {
                {text = "settings_last", value = "last"},
                {text = "settings_all",  value = "all"},
              }
            }
          }
        },
        {
          setting_id = "chat_history_commands_only",
          type = "checkbox",
          default_value = false
        }
      }
    }
  }
}

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.on_setting_changed = function (setting_id)

  if setting_id == "vmf_options_scrolling_speed" then

    vmf.load_vmf_options_view_settings()

  elseif setting_id == "developer_mode" then

    vmf.load_developer_mode_settings()
    vmf.load_network_settings()
    vmf.load_custom_textures_settings()
    vmf.load_dev_console_settings()

  elseif setting_id == "show_developer_console" then

    vmf.load_dev_console_settings()

  elseif setting_id == "show_network_debug_info" then

    vmf.load_network_settings()

  elseif setting_id == "log_ui_renderers_info" then

    vmf.load_custom_textures_settings()

  elseif setting_id == "ui_scaling" then

    vmf.load_ui_scaling_settings()

  elseif setting_id == "logging_mode"
      or setting_id == "output_mode_echo"
      or setting_id == "output_mode_error"
      or setting_id == "output_mode_warning"
      or setting_id == "output_mode_info"
      or setting_id == "output_mode_debug" then

    vmf.load_logging_settings()

  elseif setting_id == "chat_history_enable"
      or setting_id == "chat_history_save"
      or setting_id == "chat_history_buffer_size"
      or setting_id == "chat_history_remove_dups"
      or setting_id == "chat_history_remove_dups_mode"
      or setting_id == "chat_history_commands_only" then

    vmf.load_chat_history_settings(setting_id == "chat_history_enable" or
                                   setting_id == "chat_history_buffer_size" or
                                   setting_id == "chat_history_commands_only")
  end
end

vmf.load_developer_mode_settings = function () --@TODO: maybe move it to somewhere else?
  Managers.mod._settings.developer_mode = vmf:get("developer_mode")
  Application.set_user_setting("mod_settings", Managers.mod._settings)
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.initialize_mod_data(vmf, vmf_mod_data)

-- first VMF initialization
-- it will be run only 1 time, when the player launch the game with VMF for the first time
if not vmf:get("vmf_initialized") then

  vmf.load_logging_settings()
  vmf.load_developer_mode_settings()
  vmf.load_network_settings()
  vmf.load_custom_textures_settings()
  vmf.load_dev_console_settings()
  vmf.load_chat_history_settings()
  vmf.load_ui_scaling_settings()
  vmf.load_vmf_options_view_settings()

  vmf:set("vmf_initialized", true)
end