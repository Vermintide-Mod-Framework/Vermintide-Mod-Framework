--[[
  Settings manager.
  * Operates settings within the mod namespace (you can define settings with the same name for different mods)
  * Settings location: "%AppData%\Roaming\Fatshark\Warhammer End Times Vermintide\user_settings.config"
  * All settings are saved to the settings-file when game state changes, when options menu is closed, and on reload
--]]
local vmf = get_mod("VMF")

local _mods_settings = Application.user_setting("mods_settings") or {}

local _there_are_unsaved_changes = false

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function save_all_settings()
  if _there_are_unsaved_changes then
    Application.set_user_setting("mods_settings", _mods_settings)
    Application.save_user_settings()
    _there_are_unsaved_changes = false
  end
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Sets mod's setting to a given value. If setting is used in some option widget, make sure given
  value matches one of the predefined values in this widget.
  * setting_name  [string]  : setting name (can contain any characters lua-string can)
  * setting_value [anything]: setting value (can be any SJSON serializable format)
  * notify_mod    [bool]    : if 'true', calls 'mod.on_setting_changed' event
--]]
function VMFMod:set(setting_name, setting_value, notify_mod)
  local mod_name = self:get_name()

  if not _mods_settings[mod_name] then
    _mods_settings[mod_name] = {}
  end

  local mod_settings = _mods_settings[mod_name]
  mod_settings[setting_name] = type(setting_value) == "table" and table.clone(setting_value) or setting_value

  _there_are_unsaved_changes = true

  if notify_mod then
    vmf.mod_setting_changed_event(self, setting_name)
  end
end


--[[
  Returns a mod's setting. Don't call this method for table settings very frequently, because tables are cloned on every
  call.
  * setting_name [string]: setting name (can contain any characters lua-string can)
--]]
function VMFMod:get(setting_name)
  local mod_name = self:get_name()
  local mod_settings = _mods_settings[mod_name]
  local setting_value = mod_settings and mod_settings[setting_name]

  return type(setting_value) == "table" and table.clone(setting_value) or setting_value
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function vmf.save_unsaved_settings_to_file()
  save_all_settings()
end