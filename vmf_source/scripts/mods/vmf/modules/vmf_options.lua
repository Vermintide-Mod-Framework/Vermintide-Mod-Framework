local vmf = get_mod("VMF")

local options_widgets = {
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
--      {
--        ["setting_name"] = "toggle_developer_console",
--        ["widget_type"] = "keybind",
--        ["text"] = "Toggle Developer Console",
--        ["default_value"] = {},
--        ["action"] = "toggle_developer_console"
--      }
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

        ["setting_name"] = "output_mode_spew",
        ["widget_type"] = "dropdown",
        ["text"] = vmf:localize("output_mode_spew"),
        ["options"] = {
          {text = vmf:localize("output_disabled"),     value = 0},
          {text = vmf:localize("output_log"),          value = 1},
          {text = vmf:localize("output_chat"),         value = 2},
          {text = vmf:localize("output_log_and_chat"), value = 3},
        },
        ["default_value"] = 0
      }
    }
  }
}
vmf:create_options(options_widgets, false, "Vermintide Mod Framework")

vmf.setting_changed = function (setting_name)

  if setting_name == "vmf_options_scrolling_speed" then

    local ingame_ui_exists, ingame_ui = pcall(function () return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui end)
    if ingame_ui_exists then
      local vmf_options_view = ingame_ui.views["vmf_options_view"]
      if vmf_options_view then
        vmf_options_view.scroll_step = vmf_options_view.default_scroll_step / 100 * vmf:get(setting_name)
      end
    end

  elseif setting_name == "developer_mode" then

    Managers.mod._settings.developer_mode = vmf:get(setting_name)
    Application.set_user_setting("mod_settings", Managers.mod._settings)

    local show_developer_console = vmf:get(setting_name) and vmf:get("show_developer_console")
    vmf.toggle_developer_console(show_developer_console)

  elseif setting_name == "show_developer_console" then

    vmf.toggle_developer_console(vmf:get(setting_name))

  elseif setting_name == "logging_mode" then

    vmf.load_logging_settings()

  elseif setting_name == "output_mode_echo" then

    vmf.load_logging_settings()

  elseif setting_name == "output_mode_error" then

    vmf.load_logging_settings()

  elseif setting_name == "output_mode_warning" then

    vmf.load_logging_settings()

  elseif setting_name == "output_mode_info" then

    vmf.load_logging_settings()

  elseif setting_name == "output_mode_spew" then

    vmf.load_logging_settings()
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

local mod_developer_mode = Managers.mod._settings.developer_mode
local vmf_developer_mode = vmf:get("developer_mode")

if mod_developer_mode ~= vmf_developer_mode then
  Managers.mod._settings.developer_mode = vmf_developer_mode
  Application.set_user_setting("mod_settings", Managers.mod._settings)
end