local dmf = get_mod("DMF")

local _commands = {}

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Registers chat command.
  * command_name        [string]  : command's name; should contain only [a-z, A-Z, 0-9, _] characters
  * command_description [string]  : (optional) command's decription; can be multiline
  * command_function    [function]: function, that will be executed, when chat command is activated; supports arguments
--]]
function DMFMod:command(command_name, command_description, command_function)
  if dmf.check_wrong_argument_type(self, "command", "command_name", command_name, "string") or
     dmf.check_wrong_argument_type(self, "command", "command_description", command_description, "string", "nil") or
     dmf.check_wrong_argument_type(self, "command", "command_function", command_function, "function")
  then
    return
  end

  if string.match(command_name, "[^%w_]") then
    self:error("(command) '%s': command name can contain only [a-z, A-Z, 0-9, _] characters", command_name)
    return
  end

  command_name = command_name:lower()

  local command_data = _commands[command_name]
  if command_data and command_data.mod ~= self then
    self:error("(command): command name '%s' is already used by another mod '%s'", command_name,
                                                                                    command_data.mod:get_name())
    return
  end

  _commands[command_name] = {
    mod = self,
    exec_function = command_function,
    description = command_description or "",
    is_enabled = true
  }
end


--[[
  Removes registered chat command.
  * command_name [string]: command's name
--]]
function DMFMod:command_remove(command_name)
  if dmf.check_wrong_argument_type(self, "command_remove", "command_name", command_name, "string") then
    return
  end

  _commands[command_name] = nil
end


--[[
  Disables registered chat command so it can be enabled later.
  * command_name [string]: command's name
--]]
function DMFMod:command_disable(command_name)
  if dmf.check_wrong_argument_type(self, "command_disable", "command_name", command_name, "string") then
    return
  end

  if _commands[command_name] then
    _commands[command_name].is_enabled = false
  end
end


--[[
  Enables disabled chat command.
  * command_name [string]: command's name
--]]
function DMFMod:command_enable(command_name)
  if dmf.check_wrong_argument_type(self, "command_enable", "command_name", command_name, "string") then
    return
  end

  if _commands[command_name] then
    _commands[command_name].is_enabled = true
  end
end


--[[
  Removes all registered chat commands for the mod.
--]]
function DMFMod:remove_all_commands()
  for command_name, command_data in pairs(_commands) do
    if command_data.mod == self then
      _commands[command_name] = nil
    end
  end
end


--[[
  Disables all registered chat commands for the mod.
--]]
function DMFMod:disable_all_commands()
  for _, command_data in pairs(_commands) do
    if command_data.mod == self then
      command_data.is_enabled = false
    end
  end
end


--[[
  Enables all disabled chat commands for the mod.
--]]
function DMFMod:enable_all_commands()
  for _, command_data in pairs(_commands) do
    if command_data.mod == self then
      command_data.is_enabled = true
    end
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Returns a table with command data entries whose name contains 'name_contains' string. If `exact_match` is set
-- to 'true', it will return a table with only one command, whose name fully matches 'name_contains' string. Returns
-- empty table if nothing is found.
function dmf.get_commands_list(name_contains, exact_match)
  name_contains = name_contains:lower()
  local commands_list = {}
  for command_name, command_data in pairs(_commands) do
    if exact_match then
      if command_name == name_contains and command_data.is_enabled then
        table.insert(commands_list, {name = command_name, description = command_data.description})
        break
      end
    else
      local command_match = ( string.sub(command_name, 1, string.len(name_contains)) == name_contains )
      if command_match and command_data.is_enabled and command_data.mod:is_enabled() then
        table.insert(commands_list, {name = command_name, description = command_data.description})
      end
    end
  end
  table.sort(commands_list, function(a, b) return a.name < b.name end)
  return commands_list
end


-- Safely executes function bound to a command with a set name
function dmf.run_command(command_name, ...)
  local command_data = _commands[command_name]
  if command_data then
    local error_prefix = "(commands) " .. tostring(command_name)
    dmf.safe_call_nr(command_data.mod, error_prefix, command_data.exec_function, ...)
  else
    dmf:error("(commands): command '%s' wasn't found.", command_name) -- Should never see this
  end
end
