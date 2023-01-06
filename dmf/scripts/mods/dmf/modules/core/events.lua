local dmf = get_mod("DMF")

local _mods = dmf.mods
local _mods_unloading_order = dmf.mods_unloading_order

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function run_event(mod, event_name, ...)
  local event = mod[event_name]
  if event then
    dmf.safe_call_nr(mod, "(event) " .. event_name, event, ...)
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

--[[
  EVENT: on_unload (exit_game)

  Is called every time the game unloads mods, which happends in 2 cases: mods reloading and exiting the game.
  * exit_game [boolean]: 'true' if it's unloading before game exit
--]]
function dmf.mods_unload_event(exit_game)

  local event_name = "on_unload"

  for _, mod_name in ipairs(_mods_unloading_order) do
    local mod = _mods[mod_name]
    run_event(mod, event_name, exit_game)
  end
end


--[[
  EVENT: update (dt)

  Is called every game tick.
  * dt [float]: time passed since the last 'update' call (measured in seconds, but obvisouly, it never has integer part)
--]]
function dmf.mods_update_event(dt)

  local event_name = "update"

  for _, mod in pairs(_mods) do
    run_event(mod, event_name, dt)
  end
end


--[[
  EVENT: on_game_state_changed (status, state_name)

  Is called every time game enters or exits game state.
  * status     [string]: "enter" or "exit"
  * state_name [string]: readable state name, which you can get by searching game log files
                         for "DMF:ON_GAME_STATE_CHANGED()" string after launching  and closing the game with active DMF
--]]
function dmf.mods_game_state_changed_event(status, state_name)

  local event_name = "on_game_state_changed"

  for _, mod in pairs(_mods) do
    run_event(mod, event_name, status, state_name)
  end
end


--[[
  EVENT: on_setting_changed (setting_id)

  Is called on `mod:set` call with the 3rd parameter set to 'true'. All the mod's settings changes done under
  the DMF's hood call this event.
  * setting_id [string]: name of the setting that was changed
--]]
function dmf.mod_setting_changed_event(mod, setting_id)

  local event_name = "on_setting_changed"

  run_event(mod, event_name, setting_id)
end


--[[
  EVENT: on_enabled (initial_call)

  Is called when mod state is set to 'enabled'. Is called only for mods who set 'is_togglable'
  in their 'mod_data' to 'true'.
  * initial_call [boolean]: 'true' if this is the first call right after mod's initialization
--]]
function dmf.mod_enabled_event(mod, initial_call)

  local event_name = "on_enabled"

  run_event(mod, event_name, initial_call)
end


--[[
  EVENT: on_disabled (initial_call)

  Is called when mod state is set to 'disabled'. Is called only for mods who set 'is_togglable'
  in their 'mod_data' to 'true'.
  * initial_call [boolean]: 'true' if this is the first call right after mod's initialization
--]]
function dmf.mod_disabled_event(mod, initial_call)

  local event_name = "on_disabled"

  run_event(mod, event_name, initial_call)
end


--[[
  EVENT: on_user_joined (player)

  Is called when a player with the same mod, which uses network, joins the game. Meaning, that this event will be called
  only for mods which registered at least 1 network call.
  * player [player]: player object of the player who joined the game
--]]
function dmf.mod_user_joined_the_game(mod, player)

  local event_name = "on_user_joined"

  run_event(mod, event_name, player)
end


--[[
  EVENT: on_user_left (player)

  Is called when a player with the same mod, which uses network, leaves the game. Meaning, that this event will be
  called only for mods which registered at least 1 network call.
  * player [player]: player object of the player who is about to leave the game
--]]
function dmf.mod_user_left_the_game(mod, player)

  local event_name = "on_user_left"

  run_event(mod, event_name, player)
end


--[[
  EVENT: on_all_mods_loaded ()

  Is called when Darktide mod manager finishes mods loading.
--]]
function dmf.all_mods_loaded_event()

  local event_name = "on_all_mods_loaded"

  for _, mod_name in ipairs(_mods_unloading_order) do
    local mod = _mods[mod_name]
    run_event(mod, event_name)
  end
end
