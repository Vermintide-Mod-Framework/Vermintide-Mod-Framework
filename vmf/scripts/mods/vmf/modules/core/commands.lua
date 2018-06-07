local vmf = get_mod("VMF")
--[[
  * letters' case doesn't matter
  * ctrl+c & ctrl+v
  * very flexible chat history without any glitches that occured in the past
  * commands are not shown if the mod is disabled

  not sure about UI scaling
]]
local _commands = {}

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.command = function (self, command_name, command_description, command_function)

  if vmf.check_wrong_argument_type(self, "command", "command_name", command_name, "string") or
     vmf.check_wrong_argument_type(self, "command", "command_description", command_description, "string", "nil") or
     vmf.check_wrong_argument_type(self, "command", "command_function", command_function, "function") then

    return
  end

  if string.find(command_name, " ") then

    self:error("(command): command name can't contain spaces: [%s]", command_name)
    return
  end

  command_name = command_name:lower()

  if _commands[command_name] and _commands[command_name].mod ~= self then
    self:error("(command): command name '%s' is already used by another mod '%s'",
               command_name, _commands[command_name].mod:get_name())
    return
  end

  _commands[command_name] = {
    mod = self,
    exec_function = command_function,
    description = command_description,
    is_enabled = true
  }
end


VMFMod.command_remove = function (self, command_name)

  if vmf.check_wrong_argument_type(self, "command_remove", "command_name", command_name, "string") then
    return
  end

  _commands[command_name] = nil
end


VMFMod.command_disable = function (self, command_name)

  if vmf.check_wrong_argument_type(self, "command_disable", "command_name", command_name, "string") then
    return
  end

  if _commands[command_name] then
    _commands[command_name].is_enabled = false
  end
end


VMFMod.command_enable = function (self, command_name)

  if vmf.check_wrong_argument_type(self, "command_enable", "command_name", command_name, "string") then
    return
  end

  if _commands[command_name] then
    _commands[command_name].is_enabled = true
  end
end


VMFMod.remove_all_commands = function (self)

  for command_name, command_entry in pairs(_commands) do
    if command_entry.mod == self then
      _commands[command_name] = nil
    end
  end
end


VMFMod.disable_all_commands = function (self)
  for _, command_entry in pairs(_commands) do
    if command_entry.mod == self then
      command_entry.is_enabled = false
    end
  end
end


VMFMod.enable_all_commands = function (self)
  for _, command_entry in pairs(_commands) do
    if command_entry.mod == self then
      command_entry.is_enabled = true
    end
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.get_commands_list = function(name_contains, exact_match)

  name_contains = name_contains:lower()

  local commands_list = {}

  for command_name, command_entry in pairs(_commands) do

    if exact_match then
      if command_name == name_contains and command_entry.is_enabled then
        table.insert(commands_list, {name = command_name, description = command_entry.description})
        break
      end
    else
      local command_match = ( string.sub(command_name, 1, string.len(name_contains)) == name_contains )
      if command_match and command_entry.is_enabled and command_entry.mod:is_enabled() then
        table.insert(commands_list, {name = command_name, description = command_entry.description})
      end
    end
  end

  table.sort(commands_list, function(a, b) return a.name < b.name end)

  return commands_list
end


vmf.run_command = function(command_name, ...)

  local command_entry = _commands[command_name]
  if command_entry then
    local error_prefix = "(commands) " .. tostring(command_name)
    vmf.xpcall_no_return_values(command_entry.mod, error_prefix, command_entry.exec_function, ...)
  else
    vmf:error("(commands): command '%s' wasn't found.", command_name) -- should never see this
  end
end