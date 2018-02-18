local vmf = get_mod("VMF")

local _DISABLED_MODS_LIST = vmf:get("disabled_mods_list") or {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function change_mod_state(mod, enable, initial_call)

  if enable then

    _DISABLED_MODS_LIST[mod:get_name()] = nil

    vmf.mod_enabled_event(mod, initial_call)
  else

    _DISABLED_MODS_LIST[mod:get_name()] = true

    vmf.mod_disabled_event(mod, initial_call)
  end

  if initial_call then
    return
  end

  vmf:set("disabled_mods_list", _DISABLED_MODS_LIST)
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.is_enabled = function (self)

  return not _DISABLED_MODS_LIST[self:get_name()]
end

VMFMod.disable = function (self)

  if not _DISABLED_MODS_LIST[self:get_name()] then

    change_mod_state(self, false, false)
  end
end

VMFMod.enable = function (self)

  if _DISABLED_MODS_LIST[self:get_name()] then

    change_mod_state(self, true, false)
  end
end

VMFMod.init_state = function (self)

  if _DISABLED_MODS_LIST[self:get_name()] then
    change_mod_state(self, false, true)
  else
    change_mod_state(self, true, true)
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.disabled_mods_list = _DISABLED_MODS_LIST

vmf.mod_state_changed = function (mod_name, is_enabled)

  local mod = get_mod(mod_name)

  if is_enabled then
    mod:enable()
  else
    mod:disable()
  end
end