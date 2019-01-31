-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function set_internal_data(mod, key, value)
  getmetatable(mod._data).__index[key] = value
end

-- #####################################################################################################################
-- ##### VMFMod (not API) ##############################################################################################
-- #####################################################################################################################

-- Defining VMFMod class.
VMFMod = class(VMFMod)

-- Creating mod data table when object of VMFMod class is created.
function VMFMod:init(mod_name)
  if mod_name == "VMF" then
    self.set_internal_data = set_internal_data
  end

  self._data = setmetatable({}, {
    __index = {},
    __newindex = function(t_, k)
      self:warning("Attempt to change internal mod data value (\"%s\"). Changing internal mod data is forbidden.", k)
    end
  })
  set_internal_data(self, "name",          mod_name)
  set_internal_data(self, "readable_name", mod_name)
  set_internal_data(self, "is_enabled",    true)
  set_internal_data(self, "is_togglable",  false)
  set_internal_data(self, "is_mutator",    false)

  local vanilla_mod_data = Managers.mod._mods[Managers.mod._mod_load_index]
  set_internal_data(self, "workshop_id",   vanilla_mod_data.id)
  set_internal_data(self, "workshop_name", vanilla_mod_data.name)
  set_internal_data(self, "mod_handle",    vanilla_mod_data.handle)

  print(string.format("Init VMF mod '%s' [workshop_name: '%s', workshop_id: %s]", mod_name, vanilla_mod_data.name,
                                                                                   vanilla_mod_data.id))
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Universal function for retrieving any internal mod data. Returned table values shouldn't be modified, because it can
  lead to unexpected VMF behaviour.
  * key [string]: data entry name
--]]
function VMFMod:get_internal_data(key)
  return self._data[key]
end


--[[
  Predefined functions for retrieving specific internal mod data.
--]]
function VMFMod:get_name()
  return self._data.name
end
function VMFMod:get_readable_name()
  return self._data.readable_name
end
function VMFMod:get_description()
  return self._data.description
end
function VMFMod:is_enabled()
  return self._data.is_enabled
end
