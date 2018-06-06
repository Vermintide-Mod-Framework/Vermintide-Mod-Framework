local vmf = get_mod("VMF")

local _MODS = vmf.mods
local _MODS_UNLOADING_ORDER = vmf.mods_unloading_order

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function run_event(mod, event_name, event, ...)
  vmf.xpcall_no_return_values(mod, "(event) " .. event_name, event, ...)
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- call 'on_unload' for every mod which defined it
vmf.mods_unload_event = function(exit_game)

  local event_name = "on_unload"

  for _, mod_name in ipairs(_MODS_UNLOADING_ORDER) do

    local mod = _MODS[mod_name]
    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event, exit_game)
    end
  end
end

-- call 'update' for every mod which defined it
vmf.mods_update_event = function(dt)

  local event_name = "update"

  for _, mod in pairs(_MODS) do
    if mod:is_enabled() then
      local event = mod[event_name]
      if event then
        run_event(mod, event_name, event, dt)
      end
    end
  end
end

-- call 'on_game_state_changed' for every mod which defined it
vmf.mods_game_state_changed_event = function(status, state_name)

  local event_name = "on_game_state_changed"

  for _, mod in pairs(_MODS) do

    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event, status, state_name)
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
    mod:warning("Attempt to call undefined event 'mod.%s'.", event_name)
  end
end

vmf.mod_disabled_event = function(mod, initial_call)

  local event_name = "on_disabled"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, initial_call)
  else
    mod:warning("Attempt to call undefined event 'mod.%s'.", event_name)
  end
end

vmf.mod_user_joined_the_game = function(mod, player)

  local event_name = "on_user_joined"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, player)
  end
end

vmf.mod_user_left_the_game = function(mod, player)

  local event_name = "on_user_left"

  local event = mod[event_name]
  if event then
    run_event(mod, event_name, event, player)
  end
end

vmf.all_mods_loaded_event = function()

  local event_name = "on_all_mods_loaded"

  for _, mod_name in ipairs(_MODS_UNLOADING_ORDER) do

    local mod = _MODS[mod_name]
    local event = mod[event_name]
    if event then
      run_event(mod, event_name, event)
    end
  end
end