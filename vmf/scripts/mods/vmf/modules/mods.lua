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
  self._name = mod_name
end

VMFMod.get_name = function (self)
  return self._name
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