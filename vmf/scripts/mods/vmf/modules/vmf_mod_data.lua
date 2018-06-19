-- Defining VMFMod class.
VMFMod = class(VMFMod)

-- Creating mod data table when object of VMFMod class is created.
function VMFMod:init(mod_name)
  self._data = {}
  setmetatable(self._data, {
    __newindex = function(t_, k)
      self:warning("Attempt to change internal mod data value (\"%s\"). Changing internal mod data is forbidden.", k)
    end
  })
  rawset(self._data, "name",          mod_name)
  rawset(self._data, "readable_name", mod_name)
  rawset(self._data, "is_enabled",    true)
  rawset(self._data, "is_togglable",  false)
  rawset(self._data, "is_mutator",    false)
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Universal function for retrieving any internal mod data. Returned table values shouldn't be modified, because it can
  lead to unexpected VMF behaviour.
  * key [string]: data entry name

  Possible entry names:
    - name           (system mod name)
    - readable_name  (readable mod name)
    - description    (mod description)
    - is_togglable   (if the mod can be disabled/enabled)
    - is_enabled     (if the mod is curently enabled)
    - is_mutator     (if the mod is mutator)
    - mutator_config (mutator config)
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
function VMFMod:is_togglable()
    return self._data.is_togglable
end
function VMFMod:is_mutator()
  return self._data.is_mutator
end