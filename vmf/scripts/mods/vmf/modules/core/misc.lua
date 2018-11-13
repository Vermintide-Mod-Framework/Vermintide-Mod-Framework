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

function vmf.check_old_vmf()
  local old_vmf_table = rawget(_G, "Mods")

  if old_vmf_table and old_vmf_table.exec then
    error("Unfortunately, workshop mods and old-fashioned mods (VMF-pack or QoL) are incompatible. " ..
           "Either remove old mods or disable workshop mods.")
  end
end