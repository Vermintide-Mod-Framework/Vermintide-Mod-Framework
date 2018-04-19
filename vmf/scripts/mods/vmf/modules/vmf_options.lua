local vmf = get_mod("VMF")

local vmf_mod_data = {}
vmf_mod_data.name = "Vermintide Mod Framework"
vmf_mod_data.options_widgets = {
  {
    ["setting_name"] = "open_vmf_options",
    ["widget_type"] = "keybind",
    ["text"] = vmf:localize("open_vmf_options"),
    ["tooltip"] = vmf:localize("open_vmf_options") .. "\n" ..
                  vmf:localize("open_vmf_options_tooltip"),
    ["default_value"] = {"f4"},
    ["action"] = "open_vmf_options"
  },
  {
    ["setting_name"] = "vmf_options_scrolling_speed",
    ["widget_type"] = "numeric",
    ["text"] = vmf:localize("vmf_options_scrolling_speed"),
    ["unit_text"] = "%",
    ["range"] = {1, 1000},
    ["default_value"] = 100
  },
  {
    ["setting_name"] = "ui_scaling",
    ["widget_type"] = "checkbox",
    ["text"] = vmf:localize("ui_scaling"),
    ["tooltip"] = vmf:localize("ui_scaling") .. "\n" ..
                  vmf:localize("ui_scaling_tooltip"),
    ["default_value"] = true
  },
  {
    ["setting_name"] = "developer_mode",
    ["widget_type"] = "checkbox",
    ["text"] = vmf:localize("developer_mode"),
    ["tooltip"] = vmf:localize("developer_mode") .. "\n" ..
                  vmf:localize("developer_mode_tooltip"),
    ["default_value"] = false,
    ["sub_widgets"] = {
      {
        ["setting_name"] = "show_developer_console",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("show_developer_console"),
        ["tooltip"] = vmf:localize("show_developer_console") .. "\n" ..
                      vmf:localize("show_developer_console_tooltip"),
        ["default_value"] = false
      },
      {
        ["setting_name"] = "toggle_developer_console",
        ["widget_type"] = "keybind",
        ["text"] = vmf:localize("toggle_developer_console"),
        ["default_value"] = {},
        ["action"] = "toggle_developer_console"
      },
      {
        ["setting_name"] = "show_network_debug_info",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("show_network_debug_info"),
        ["tooltip"] = vmf:localize("show_network_debug_info") .. "\n" ..
                      vmf:localize("show_network_debug_info_tooltip"),
        ["default_value"] = false
      },
      {
        ["setting_name"] = "log_ui_renderers_info",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("log_ui_renderers_info"),
        ["tooltip"] = vmf:localize("log_ui_renderers_info") .. "\n" ..
                      vmf:localize("log_ui_renderers_info_tooltip"),
        ["default_value"] = false
      }
    }
  },
  {
    ["setting_name"] = "logging_mode",
    ["widget_type"] = "dropdown",
    ["text"] = vmf:localize("logging_mode"),
    ["options"] = {
      {--[[1]] text = vmf:localize("settings_default"), value = "default"},
      {--[[2]] text = vmf:localize("settings_custom"),  value = "custom"},
    },
    ["default_value"] = "default",
    ["sub_widgets"] = {
      {
        ["show_widget_condition"] = {2},

        ["setting_name"] = "output_mode_echo",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_echo"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 3
      },
      {
        ["show_widget_condition"] = {2},

        ["setting_name"] = "output_mode_error",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_error"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 3
      },
      {
        ["show_widget_condition"] = {2},

        ["setting_name"] = "output_mode_warning",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_warning"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 3
      },
      {
        ["show_widget_condition"] = {2},

        ["setting_name"] = "output_mode_info",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_info"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 1
      },
      {
        ["show_widget_condition"] = {2},

        ["setting_name"] = "output_mode_debug",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_debug"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 0
      }
    }
  },
  {
    ["setting_name"] = "chat_history_enable",
    ["widget_type"] = "checkbox",
    ["text"] = vmf:localize("chat_history_enable"),
    ["tooltip"] = vmf:localize("chat_history_enable") .. "\n" ..
                  vmf:localize("chat_history_enable_tooltip"),
    ["default_value"] = true,
    ["sub_widgets"] = {
      {
        ["setting_name"] = "chat_history_save",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("chat_history_save"),
        ["tooltip"] = vmf:localize("chat_history_save") .. "\n" ..
                      vmf:localize("chat_history_save_tooltip"),
        ["default_value"] = true
      },
      {
        ["setting_name"] = "chat_history_buffer_size",
        ["widget_type"] = "numeric",
        ["text"] = vmf:localize("chat_history_buffer_size"),
        ["tooltip"] = vmf:localize("chat_history_buffer_size") .. "\n" ..
                      vmf:localize("chat_history_buffer_size_tooltip"),
        ["range"] = {10, 200},
        ["default_value"] = 50
      },
      {
        ["setting_name"] = "chat_history_remove_dups",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("chat_history_remove_dups"),
        ["default_value"] = false,
        ["sub_widgets"] = {
          {
            ["setting_name"] = "chat_history_remove_dups_mode",
            ["widget_type"] = "dropdown",
            ["text"] = vmf:localize("chat_history_remove_dups_mode"),
            ["tooltip"] = vmf:localize("chat_history_remove_dups_mode") .. "\n" ..
                          vmf:localize("chat_history_remove_dups_mode_tooltip"),
            ["options"] = {
              {text = vmf:localize("settings_last"), value = "last"},
              {text = vmf:localize("settings_all"),  value = "all"},
            },
            ["default_value"] = "last"
          }
        }
      },
      {
        ["setting_name"] = "chat_history_commands_only",
        ["widget_type"] = "checkbox",
        ["text"] = vmf:localize("chat_history_commands_only"),
        ["tooltip"] = vmf:localize("chat_history_commands_only") .. "\n" ..
                      vmf:localize("chat_history_commands_only_tooltip"),
        ["default_value"] = false
      }
    }
  }
}

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.on_setting_changed = function (setting_name)

  if setting_name == "vmf_options_scrolling_speed" then

    vmf.load_vmf_options_view_settings()

  elseif setting_name == "developer_mode" then

    vmf.load_developer_mode_settings()
    vmf.load_network_settings()
    vmf.load_custom_textures_settings()
    vmf.load_dev_console_settings()

  elseif setting_name == "show_developer_console" then

    vmf.load_dev_console_settings()

  elseif setting_name == "show_network_debug_info" then

    vmf.load_network_settings()

  elseif setting_name == "log_ui_renderers_info" then

    vmf.load_custom_textures_settings()

  elseif setting_name == "ui_scaling" then

    vmf.load_ui_scaling_settings()

  elseif setting_name == "logging_mode"
      or setting_name == "output_mode_echo"
      or setting_name == "output_mode_error"
      or setting_name == "output_mode_warning"
      or setting_name == "output_mode_info"
      or setting_name == "output_mode_debug" then

    vmf.load_logging_settings()

  elseif setting_name == "chat_history_enable"
      or setting_name == "chat_history_save"
      or setting_name == "chat_history_buffer_size"
      or setting_name == "chat_history_remove_dups"
      or setting_name == "chat_history_remove_dups_mode"
      or setting_name == "chat_history_commands_only" then

    vmf.load_chat_history_settings(setting_name == "chat_history_enable" or setting_name == "chat_history_buffer_size" or setting_name == "chat_history_commands_only")
  end
end

vmf.load_developer_mode_settings = function () --@TODO: maybe move it to somewhere else?
  Managers.mod._settings.developer_mode = vmf:get("developer_mode")
  Application.set_user_setting("mod_settings", Managers.mod._settings)
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf:initialize_data(vmf_mod_data)

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

  vmf:set("vmf_initialized", true)
end
