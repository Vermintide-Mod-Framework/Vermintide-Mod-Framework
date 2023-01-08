-- Global backup of original print() method
local print = __print

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function set_internal_data(mod, key, value)
  getmetatable(mod._data).__index[key] = value
end

-- #####################################################################################################################
-- ##### DMFMod (not API) ##############################################################################################
-- #####################################################################################################################

-- Defining DMFMod class.
DMFMod = class("DMFMod")

-- Creating mod data table when object of DMFMod class is created.
function DMFMod:init(mod_name)
  if mod_name == "DMF" then
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

  print(string.format("Init DMF mod '%s' [workshop_name: '%s', workshop_id: %s]", mod_name, vanilla_mod_data.name,
                                                                                   vanilla_mod_data.id))
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Universal function for retrieving any internal mod data. Returned table values shouldn't be modified, because it can
  lead to unexpected DMF behaviour.
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
function DMFMod:get_internal_data(key)
  return self._data[key]
end


--[[
  Predefined functions for retrieving specific internal mod data.
--]]
function DMFMod:get_name()
  return self._data.name
end
function DMFMod:get_readable_name()
  return self._data.readable_name
end
function DMFMod:get_description()
  return self._data.description
end
function DMFMod:is_enabled()
  return self._data.is_enabled
end
