local vmf = nil

local _MODS = {}
local _MODS_UNLOADING_ORDER = {}

-- ####################################################################################################################
-- ##### Public functions #############################################################################################
-- ####################################################################################################################

function new_mod(mod_name)

  if type(mod_name) ~= "string" then
    vmf:error("(new_mod): the mod name should be the string, not '%s'", type(mod_name)) -- @EARLY_CALL:
    return nil
  end

  if _MODS[mod_name] then
    vmf:error("(new_mod): you can't use name \"%s\" for your mod, because the mod with the same name already exists", mod_name) -- @EARLY_CALL:
    return nil
  end

  table.insert(_MODS_UNLOADING_ORDER, 1, mod_name)

  local mod = VMFMod:new(mod_name)
  _MODS[mod_name] = mod

  return mod
end

function get_mod(mod_name)
  return _MODS[mod_name]
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod = class(VMFMod)

VMFMod.init = function (self, mod_name)
  self._data = {}
  -- @TODO: forbid changing _data table
  self._data.name = mod_name
  self._data.readable_name = mod_name
  self._data.is_enabled = true
  self._data.is_togglable = false
  self._data.is_mutator = false
end

-- DATA

VMFMod.get_name = function (self)
  return self._data.name
end

VMFMod.get_readable_name = function (self)
  return self._data.readable_name
end

VMFMod.get_description = function (self)
  return self._data.description
end

VMFMod.is_enabled = function (self)
  return self._data.is_enabled
end

VMFMod.is_togglable = function (self)
    return self._data.is_togglable
end

VMFMod.is_mutator = function (self)
  return self._data.is_mutator
end

VMFMod.get_config = function (self)
  return self._data.config
end

-- ####################################################################################################################
-- ##### VMF Initialization ###########################################################################################
-- ####################################################################################################################

vmf = new_mod("VMF")

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.mods = _MODS
vmf.mods_unloading_order = _MODS_UNLOADING_ORDER