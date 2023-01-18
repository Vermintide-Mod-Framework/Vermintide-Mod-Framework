local dmf = get_mod("DMF")

--[[
  Settings manager.
  * Operates settings within the mod namespace (you can define settings with the same name for different mods)
  * Settings location: "%AppData%\Roaming\Fatshark\Warhammer End Times Darktide\user_settings.config"
  * All settings are saved to the settings-file when game state changes, when options menu is closed, and on reload
  * Serializable settings types: number, string, boolean, table (array-like and map-like, but not mixed)
--]]

local _mods_settings = Application.user_setting("mods_settings") or {}

local _there_are_unsaved_changes = false

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function save_all_settings()
  if _there_are_unsaved_changes then

    local success, error = pcall(Application.set_user_setting, "mods_settings", _mods_settings)
    if not success then
      if string.find(error, "number expected, got string") then
        error = "one of mods tried to save a mixed table"
      end
      dmf:error("Darktide Mod Framework failed to save mods settings: %s", tostring(error))
      return
    end

    Application.save_user_settings()
    _there_are_unsaved_changes = false
  end
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Sets mod's setting to a given value. If setting is used in some option widget, make sure given
  value matches one of the predefined values in this widget.
  * setting_id    [string]  : setting's identifier
  * setting_value [anything]: setting value (can be any SJSON serializable format)
  * notify_mod    [bool]    : if 'true', calls 'mod.on_setting_changed' event
--]]
function DMFMod:set(setting_id, setting_value, notify_mod)
  local mod_name = self:get_name()

  if not _mods_settings[mod_name] then
    _mods_settings[mod_name] = {}
  end

  local mod_settings = _mods_settings[mod_name]
  mod_settings[setting_id] = type(setting_value) == "table" and table.clone(setting_value) or setting_value

  _there_are_unsaved_changes = true

  if notify_mod then
    dmf.mod_setting_changed_event(self, setting_id)
  end
end


--[[
  Returns a mod's setting. Don't call this method for table settings very frequently, because tables are cloned on every
  call.
  * setting_id [string]: setting's identifier
--]]
function DMFMod:get(setting_id)
  local mod_name = self:get_name()
  local mod_settings = _mods_settings[mod_name]
  local setting_value = mod_settings and mod_settings[setting_id]

  return type(setting_value) == "table" and table.clone(setting_value) or setting_value
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function dmf.save_unsaved_settings_to_file()
  save_all_settings()
end

function dmf.mod_has_settings(mod)
  if _mods_settings[mod:get_name()] then
    return true
  end
end
