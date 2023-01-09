local dmf = get_mod("DMF")

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function dmf.check_wrong_argument_type(mod, dmf_function_name, argument_name, argument, ...)
  local allowed_types = {...}
  local argument_type = type(argument)

  for _, allowed_type in ipairs(allowed_types) do
    if allowed_type == argument_type then
      return false
    end
  end

  mod:error("(%s): argument '%s' should have the '%s' type, not '%s'", dmf_function_name, argument_name,
                                                                        table.concat(allowed_types, "/"), argument_type)
  return true
end


-- http://lua-users.org/wiki/CopyTable
function dmf.deepcopy(original_table)
  local orig_type = type(original_table)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, original_table, nil do
      copy[dmf.deepcopy(orig_key)] = dmf.deepcopy(orig_value)
    end
    setmetatable(copy, dmf.deepcopy(getmetatable(original_table)))
  else -- number, string, boolean, etc
    copy = original_table
  end
  return copy
end