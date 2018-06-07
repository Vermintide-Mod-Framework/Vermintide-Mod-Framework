local vmf = get_mod("VMF")

Managers.vmf = Managers.vmf or {} -- @TODO: move it to on_reload when it will be implemented in vt1
Managers.vmf.persistent_tables = Managers.vmf.persistent_tables or {}

local _persistent_tables = Managers.vmf.persistent_tables

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  This function will create a table (or will use the one passed as 'default_table' argument) and then return this table
  on the first call. After that, it will just pass already created table without recreating it. It will continue
  returning already created table even after mods reloading.
  * table_name    [string]: table identifier; has the mod namespace, meaning that 2 different mods will get 2 different
                            tables when using the same table_name
  * default_table [table] : (optional) table that will replace empty table created by default (on the 1st call)
--]]
function VMFMod:persistent_table(table_name, default_table)

  if vmf.check_wrong_argument_type(self, "persistent_table", "table_name", table_name, "string") or
     vmf.check_wrong_argument_type(self, "persistent_table", "default_table", default_table, "table", "nil")
  then
    return
  end

  local mod_name = self:get_name()
  _persistent_tables[mod_name] = _persistent_tables[mod_name] or default_table or {}

  local mod_tables = _persistent_tables[mod_name]
  mod_tables[table_name] = mod_tables[table_name] or {}

  return mod_tables[table_name]
end