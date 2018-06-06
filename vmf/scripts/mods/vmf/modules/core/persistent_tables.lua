local vmf = get_mod("VMF")

Managers.vmf.persistent_tables = Managers.vmf.persistent_tables or {}

local _persistent_tables = Managers.vmf.persistent_tables

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.persistent_table = function (self, table_name)

  if vmf.check_wrong_argument_type(self, "persistent_table", "table_name", table_name, "string") then
    return
  end

  local mod_name = self:get_name()
  _persistent_tables[mod_name] = _persistent_tables[mod_name] or {}

  local mod_tables = _persistent_tables[mod_name]
  mod_tables[table_name] = mod_tables[table_name] or {}

  return mod_tables[table_name]
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.persistent_data = vmf:persistent_table("persistent_data")