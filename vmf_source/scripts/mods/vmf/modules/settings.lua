--[[
  This is the settings manager.
  * It operates settings within the mod namespace (you can define settings with the same name for different mods)
  * Settings location: "%AppData%\Roaming\Fatshark\Warhammer End Times Vermintide\user_settings.config"
  * All settings are being saved to the settings-file only when map changes
--]]

local vmf = get_mod("VMF")

local MODS_SETTINGS = {}
local THERE_ARE_UNSAVED_CHANGES = false

-- ####################################################################################################################
-- ##### Private functions ############################################################################################
-- ####################################################################################################################

local function load_settings(mod_name)
  local mod_settings = Application.user_setting(mod_name)

  mod_settings = mod_settings or {}

  MODS_SETTINGS[mod_name] = mod_settings
end

local function save_all_settings()

  if THERE_ARE_UNSAVED_CHANGES then
    Application.save_user_settings()

    THERE_ARE_UNSAVED_CHANGES = false
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

 local mod_name = self._name

  if not MODS_SETTINGS[mod_name] then
    load_settings(mod_name)
  end

  local mod_settings = MODS_SETTINGS[mod_name]
  mod_settings[setting_name] = setting_value

  Application.set_user_setting(mod_name, mod_settings)

  THERE_ARE_UNSAVED_CHANGES = true

  if call_setting_changed_event and self.setting_changed then
    self.setting_changed(setting_name)
  end
end

--[[
  * setting_name  [string]: setting name, can contain any characters lua-string can @TODO: check this
--]]
VMFMod.get = function (self, setting_name)
  local mod_name = self._name

  if not MODS_SETTINGS[mod_name] then
    load_settings(mod_name)
  end

  local mod_settings = MODS_SETTINGS[mod_name]

  return mod_settings[setting_name]
end

-- ####################################################################################################################
-- ##### Event functions ##############################################################################################
-- ####################################################################################################################

vmf.save_unsaved_settings_to_file = function()
  save_all_settings()
end