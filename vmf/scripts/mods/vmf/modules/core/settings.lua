--[[
  This is the settings manager.
  * It operates settings within the mod namespace (you can define settings with the same name for different mods)
  * Settings location: "%AppData%\Roaming\Fatshark\Warhammer End Times Vermintide\user_settings.config"
  * All settings are being saved to the settings-file when game state changes, when options menu is closed and on reload
--]]
local vmf = get_mod("VMF")

local _MODS_SETTINGS = Application.user_setting("mods_settings") or {}

local _THERE_ARE_UNSAVED_CHANGES = false

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function save_all_settings()

  if _THERE_ARE_UNSAVED_CHANGES then
    Application.set_user_setting("mods_settings", _MODS_SETTINGS)
    Application.save_user_settings()

    _THERE_ARE_UNSAVED_CHANGES = false
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

--[[
  * setting_name               [string]  : setting name, can contain any characters lua-string can @TODO: check this
  * setting_value              [anything]: setting value, will be serialized to SJSON format, so you can save whole tables
  * call_setting_changed_event [bool]    : if 'true', when some setting will be changed, 'setting_changed' event will be called (if mod defined one)
--]]
VMFMod.set = function (self, setting_name, setting_value, call_setting_changed_event)

  local mod_name = self:get_name()

  if not _MODS_SETTINGS[mod_name] then
    _MODS_SETTINGS[mod_name] = {}
  end

  local mod_settings = _MODS_SETTINGS[mod_name]

  mod_settings[setting_name] = type(setting_value) == "table" and table.clone(setting_value) or setting_value

  _THERE_ARE_UNSAVED_CHANGES = true

  if call_setting_changed_event then
    vmf.mod_setting_changed_event(self, setting_name)
  end
end

--[[
  * setting_name  [string]: setting name, can contain any characters lua-string can @TODO: check this
--]]
VMFMod.get = function (self, setting_name)

  local mod_name = self:get_name()

  local mod_settings = _MODS_SETTINGS[mod_name]

  local setting_value

  if mod_settings then
    setting_value = mod_settings[setting_name]
  else
    return nil
  end

  return type(setting_value) == "table" and table.clone(setting_value) or setting_value
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.save_unsaved_settings_to_file = function()
  save_all_settings()
end