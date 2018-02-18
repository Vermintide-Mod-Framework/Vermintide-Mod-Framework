local vmf = get_mod("VMF")

local _DISABLED_MODS_LIST = vmf:get("disabled_mods_list") or {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function change_mod_state(mod, enable, skip_saving)

  if enable then

    _DISABLED_MODS_LIST[mod:get_name()] = nil

    vmf.mod_enabled_event(mod)
  else

    _DISABLED_MODS_LIST[mod:get_name()] = true

    vmf.mod_disabled_event(mod)
  end

  if skip_saving then
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

    change_mod_state(self, false)
  end
end

VMFMod.enable = function (self)

  if _DISABLED_MODS_LIST[self:get_name()] then

    change_mod_state(self, true)
  end
end

VMFMod.initialized = function (self)

  if _DISABLED_MODS_LIST[self:get_name()] then

    change_mod_state(self, false, true)
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