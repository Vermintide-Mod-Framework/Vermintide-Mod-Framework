local vmf = get_mod("VMF")

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function vmf.check_wrong_argument_type(mod, vmf_function_name, argument_name, argument, ...)
  local allowed_types = {...}
  local argument_type = type(argument)

  for _, allowed_type in ipairs(allowed_types) do
    if allowed_type == argument_type then
      return false
    end
  end

  mod:error("(%s): argument '%s' should have the '%s' type, not '%s'", vmf_function_name, argument_name,
                                                                        table.concat(allowed_types, "/"), argument_type)
  return true
end


function vmf.throw_error(error_message, ...)
  error(string.format(error_message, ...), 0)
end


function vmf.catch_errors(mod, error_prefix, additional_error_prefix_info, exec_function, ...)
  local success, error_message = pcall(exec_function, ...)
  if not success then
    error_prefix = string.format(error_prefix, additional_error_prefix_info)
    mod:error(string.format("%s: %s", error_prefix, error_message))
    return true
  end
end