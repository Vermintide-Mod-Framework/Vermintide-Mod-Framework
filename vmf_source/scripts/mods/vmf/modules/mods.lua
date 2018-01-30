-- @TODO: on_game_state_changed, show messages in the chat even if they were sent when the chat wasn't initialized
local vmf = nil

local MODS = {}
local MODS_UNLOADING_ORDER = {}

-- ####################################################################################################################
-- ##### Public functions #############################################################################################
-- ####################################################################################################################

function new_mod(mod_name)
  if MODS[mod_name] then
    vmf:echo("ERROR: you can't create mod \"" .. mod_name .. "\" because it already exists")
    return nil
  end

  table.insert(MODS_UNLOADING_ORDER, 1, mod_name)

  local mod = VMFMod:new(mod_name)
  MODS[mod_name] = mod

  return mod
end

function get_mod(mod_name)
  return MODS[mod_name]
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod = class(VMFMod)


VMFMod.init = function (self, mod_name)
  self._name = mod_name
end


VMFMod.echo = function (self, message, show_mod_name)

  message = tostring(message)

  print("[ECHO][" .. self._name .. "] " .. message)

  if show_mod_name then
    message = "[" .. self._name .. "] " .. message
  end

  if Managers.chat and Managers.chat:has_channel(1) then
    Managers.chat:add_local_system_message(1, message, true)
  else
    table.insert(vmf.unsent_chat_messages, message)
  end
end


VMFMod.pcall = function (self, ...)
  local status, value = pcall(...)

  if not status then
    self:echo("ERROR(pcall): " .. tostring(value), true)
  end

  return status, value
end


VMFMod.dofile = function (self, script_path)

  local status, value = pcall(dofile, script_path)

  if not status then
    self:echo("ERROR(loadfile): " .. value.error, true)

    print("\nTRACEBACK:\n\n" .. value.traceback .. "\nLOCALS:\n\n" .. value.locals)
  end

  return value
end
-- ####################################################################################################################
-- ##### VMF Initialization ###########################################################################################
-- ####################################################################################################################

vmf = new_mod("VMF")

vmf.unsent_chat_messages = {}

-- ####################################################################################################################
-- ##### Event functions ##############################################################################################
-- ####################################################################################################################

-- call 'unload' for every mod which definded it
vmf.mods_unload = function()
  for _, mod_name in pairs(MODS_UNLOADING_ORDER) do --@TODO: maybe ipairs?
    if MODS[mod_name].unload then
      MODS[mod_name].unload()
    end
  end
end

-- call 'update' for every mod which definded it
vmf.mods_update = function(dt)
  for _, mod in pairs(MODS) do --@TODO: maybe ipairs?
    if mod.update then
      mod.update(dt)
    end
  end
end

-- call 'game_state_changed' for every mod which definded it
vmf.mods_game_state_changed = function(status, state)
  for _, mod in pairs(MODS) do --@TODO: maybe ipairs?
    if mod.game_state_changed then
      mod.game_state_changed(status, state)
    end
  end
end