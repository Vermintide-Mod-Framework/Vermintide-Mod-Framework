local vmf = get_mod("VMF")

local _MODS = vmf.mods
local _MODS_UNLOADING_ORDER = vmf.mods_unloading_order

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function run_event(mod, event_name, event, ...)

  local success, error_message = pcall(event, ...)
  if not success then
    mod:error("(mod.%s): %s", event_name, error_message)
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- call 'unload' for every mod which defined it
vmf.mods_unload_event = function()

  local event_name = "on_unload"

  for _, mod_name in ipairs(_MODS_UNLOADING_ORDER) do

    local mod = _MODS[mod_name]
    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event)
    end
  end
end

-- call 'update' for every mod which defined it
vmf.mods_update_event = function(dt)

  local event_name = "update"

  for _, mod in pairs(_MODS) do

    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event, dt)
    end
  end
end

-- call 'game_state_changed' for every mod which defined it
vmf.mods_game_state_changed_event = function(status, state)

  local event_name = "on_game_state_changed"

  for _, mod in pairs(_MODS) do

    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event, status, state)
    end
  end
end

vmf.mod_setting_changed_event = function(mod, setting_name)

  local event_name = "on_setting_changed"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, setting_name)
  end
end

vmf.mod_enabled_event = function(mod, initial_call)

  local event_name = "on_enabled"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, initial_call)
  else
    mod:warning("Attemt to call undefined event 'mod.%s'.", event_name)
  end
end

vmf.mod_disabled_event = function(mod, initial_call)

  local event_name = "on_disabled"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, initial_call)
  else
    mod:warning("Attemt to call undefined event 'mod.%s'.", event_name)
  end
end