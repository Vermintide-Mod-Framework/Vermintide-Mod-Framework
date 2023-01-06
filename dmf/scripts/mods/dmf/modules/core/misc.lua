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
