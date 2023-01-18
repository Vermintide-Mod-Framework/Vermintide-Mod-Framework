local dmf = get_mod("DMF")

--[[
  Manages everything related to mutators: loading order, enabling/disabling process, giving extra rewards etc.
--]]

-- Global backup of original print() method
local print = __print

-- List of mods that are also mutators in order in which they should be enabled
local _mutators = {}

-- This lists mutators and which ones should be enabled after them
local _mutators_sequence = {
  --[[
  this_mutator = {
    "will be enabled",
    "before these ones"
  }
  ]]--
}

-- So we don't sort after each one is added
local _mutators_sorted = false

-- So we don't have to check when player isn't hosting
local _all_mutators_disabled = false

-- External modules
local reward_manager = dmf:io_dofile("dmf/scripts/mods/dmf/modules/core/mutators/mutators_reward")
local set_lobby_data = dmf:io_dofile("dmf/scripts/mods/dmf/modules/core/mutators/mutators_info")

-- Get default configuration
local _default_config = dmf:io_dofile("dmf/scripts/mods/dmf/modules/core/mutators/mutators_default_config")

-- List of enabled mutators in case DMF is reloaded in the middle of the game
local _enabled_mutators = dmf:persistent_table("enabled_mutators")

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function get_index(tbl, o)
  for i, v in ipairs(tbl) do
    if o == v then
      return i
    end
  end
  return nil
end


-- Called after mutator is enabled
local function on_enabled(mutator)
  local config = mutator:get_internal_data("mutator_config")
  reward_manager.addReward(config.reward)
  set_lobby_data()
  print("[MUTATORS] Enabled " .. mutator:get_name() .. " (" .. tostring(get_index(_mutators, mutator)) .. ")")

  _enabled_mutators[mutator:get_name()] = true
end


-- Called after mutator is disabled
local function on_disabled(mutator, initial_call)
  local config = mutator:get_internal_data("mutator_config")

  -- All mutators run on_disabled on initial call, so there's no need to remove rewards and set lobby data
  if not initial_call then
    reward_manager.removeReward(config.reward)
    set_lobby_data()
  end
  print("[MUTATORS] Disabled " .. mutator:get_name() .. " (" .. tostring(get_index(_mutators, mutator)) .. ")")

  _enabled_mutators[mutator:get_name()] = nil
end


-- Checks if the player is server in a way that doesn't incorrectly return false during loading screens
local function player_is_server()
  return Managers and Managers.state and Managers.state.game_session and Managers.state.game_session:is_server()

  --[[ -- Might not be necessary?
  return Managers and Managers.state and (
    (Managers.state.game_session and Managers.state.game_session:is_server()) or
    (Managers.state.game_mode and Managers.state.game_mode._game_mode == nil))
  --]]
end


-- Sorts mutators in order they should be enabled
local function sort_mutators()

  if _mutators_sorted then return end

  --[[
  -- LOG --
  dmf:dump(_mutators_sequence, "seq", 5)
  for i, v in ipairs(mutators) do
    print(i, v:get_name())
  end
  print("-----------")
  -- /LOG --
  --]]

  -- The idea is that all mutators before the current one are already in the right order
  -- Starting from second mutator
  local i = 2
  while i <= #_mutators do
    local mutator = _mutators[i]
    local mutator_name = mutator:get_name()
    local enable_these_after = _mutators_sequence[mutator_name] or {}

    -- Going back from the previous mutator to the start of the list
    local j = i - 1
    while j > 0 do
      local other_mutator = _mutators[j]

      -- Moving it after the current one if it is to be enabled after it
      if table.contains(enable_these_after, other_mutator:get_name()) then
        table.remove(_mutators, j)
        table.insert(_mutators, i, other_mutator)

        -- This will shift the current mutator back, so adjust the index
        i = i - 1
      end
      j = j - 1
    end

    i = i + 1
  end
  _mutators_sorted = true

  --[[
  -- LOG --
  print("[MUTATORS] Sorted")
  for k, v in ipairs(_mutators) do
    print("    ", k, v:get_name())
  end
  -- /LOG --
  --]]
end


-- Check if a mutator can be enabled
local function mutator_can_be_enabled(mutator)

  -- If conflicting mutators are enabled
  local mutator_compatibility_config = mutator:get_internal_data("mutator_config").compatibility
  local is_mostly_compatible = mutator_compatibility_config.is_mostly_compatible
  local except = mutator_compatibility_config.except
  for _, other_mutator in ipairs(_mutators) do
    if other_mutator:is_enabled() and other_mutator ~= mutator and
        (is_mostly_compatible and except[other_mutator] or not is_mostly_compatible and not except[other_mutator]) then
      return false
    end
  end

  -- If player is no longer the server
  if not player_is_server() then
    return false
  end

  -- If conflicting difficulty is set (if no difficulty is set, all mutators are allowed)
  local actual_difficulty = Managers.state and Managers.state.difficulty:get_difficulty() or 0
  local compatible_difficulties = mutator_compatibility_config.compatible_difficulties
  return not actual_difficulty or compatible_difficulties[actual_difficulty]
end


-- Disables mutators that cannot be enabled right now
local function disable_impossible_mutators(is_broadcast, reason_text_id)
  local disabled_mutators = {}
  for i = #_mutators, 1, -1 do
    local mutator = _mutators[i]
    if mutator:is_enabled() and not mutator_can_be_enabled(mutator) then
      dmf.mod_state_changed(mutator:get_name(), false)
      table.insert(disabled_mutators, mutator)
    end
  end
  if #disabled_mutators > 0 then
    local disabled_mutators_text_id = is_broadcast and "broadcast_disabled_mutators" or "local_disabled_mutators"
    local message = dmf:localize(disabled_mutators_text_id) .. " " .. dmf:localize(reason_text_id) .. ":"
    message = message .. " " .. dmf.add_mutator_titles_to_string(disabled_mutators, ", ", false)
    if is_broadcast then
      dmf:chat_broadcast(message)
    else
      dmf:echo(message)
    end
  end
end


-- INITIALIZING


-- Adds mutator names from enable_these_after to the list of mutators that should be enabled after the mutator_name
local function update_mutators_sequence(mutator)

  local raw_config = mutator:get_internal_data("mutator_config").raw_config
  local enable_before_these = raw_config.enable_before_these
  local enable_after_these = raw_config.enable_after_these
  local mutator_name = mutator:get_name()

  if enable_before_these then
    _mutators_sequence[mutator_name] = _mutators_sequence[mutator_name] or {}

    for _, other_mutator_name in ipairs(enable_before_these) do
      if _mutators_sequence[other_mutator_name] and
          table.contains(_mutators_sequence[other_mutator_name], mutator_name) then
        dmf:error("(mutators): Mutators '%s' and '%s' are both set to load after each other.", mutator_name,
                                                                                                other_mutator_name)
      elseif not table.contains(_mutators_sequence[mutator_name], other_mutator_name) then
        table.insert(_mutators_sequence[mutator_name], other_mutator_name)
      end
    end

  end
  if enable_after_these then
    for _, other_mutator_name in ipairs(enable_after_these) do
      _mutators_sequence[other_mutator_name] = _mutators_sequence[other_mutator_name] or {}

      if _mutators_sequence[mutator_name] and table.contains(_mutators_sequence[mutator_name], other_mutator_name) then
        dmf:error("(mutators): Mutators '%s' and '%s' are both set to load after each other.", mutator_name,
                                                                                                other_mutator_name)
      elseif not table.contains(_mutators_sequence[other_mutator_name], mutator_name) then
        table.insert(_mutators_sequence[other_mutator_name], mutator_name)
      end
    end
  end
end


-- Uses raw_config to determine if mutators are compatible both ways
local function is_compatible(mutator, other_mutator)
  local raw_config = mutator:get_internal_data("mutator_config").raw_config
  local other_raw_config = other_mutator:get_internal_data("mutator_config").raw_config

  local mutator_name = mutator:get_name()
  local other_mutator_name = other_mutator:get_name()

  local incompatible_specifically = (
    #raw_config.incompatible_with > 0 and (
      table.contains(raw_config.incompatible_with, other_mutator_name)
    ) or
    #other_raw_config.incompatible_with > 0 and (
      table.contains(other_raw_config.incompatible_with, mutator_name)
    )
  )

  local compatible_specifically = (
    #raw_config.compatible_with > 0 and (
      table.contains(raw_config.compatible_with, other_mutator_name)
    ) or
    #other_raw_config.compatible_with > 0 and (
      table.contains(other_raw_config.compatible_with, mutator_name)
    )
  )

  local compatible
  if incompatible_specifically then
    compatible = false
  elseif compatible_specifically then
    compatible = true
  elseif raw_config.compatible_with_all or other_raw_config.compatible_with_all then
    compatible = true
  elseif raw_config.incompatible_with_all or other_raw_config.incompatible_with_all then
    compatible = false
  else
    compatible = true
  end

  return compatible
end


-- Creates 'compatibility' entry for the mutator, checks compatibility of given mutator with all other mutators.
-- 'compatibility.is_mostly_compatible' is 'true' when mutator is not specifically set to be incompatible with
-- all other mutators. All the incompatible mutators will be added to 'compatibility.except'. And vice versa,
-- if 'is_mostly_compatible' is 'false', all the compatible mutators will be added to 'except'.
-- Also, converts given difficulties compatibility to optimized form.
local function update_compatibility(mutator)

  -- Create default 'compatibility' entry
  local config = mutator:get_internal_data("mutator_config")
  config.compatibility = {}
  local compatibility = config.compatibility

  -- Compatibility with other mods
  compatibility.is_mostly_compatible = not config.raw_config.incompatible_with_all
  compatibility.except = {}

  local is_mostly_compatible = compatibility.is_mostly_compatible
  local except = compatibility.except

  for _, other_mutator in ipairs(_mutators) do

    local other_config = other_mutator:get_internal_data("mutator_config")
    local other_mostly_compatible = other_config.compatibility.is_mostly_compatible
    local other_except = other_config.compatibility.except

    if is_compatible(mutator, other_mutator) then
      if not is_mostly_compatible then except[other_mutator] = true end
      if not other_mostly_compatible then other_except[mutator] = true end
    else
      if is_mostly_compatible then except[other_mutator] = true end
      if other_mostly_compatible then other_except[mutator] = true end
    end
  end

  -- Compatibility with current difficulty (This part works only for VT1. Will see what to do with VT2 later.)
  compatibility.compatible_difficulties = {
    lowest = false,
    low = false,
    medium = false,
    high = false,
    highest = false,
  }
  local compatible_difficulties = compatibility.compatible_difficulties
  local compatible_difficulties_number = 0
  for _, difficulty_key in ipairs(config.raw_config.difficulty_levels) do
    if type(compatible_difficulties[difficulty_key]) ~= "nil" then
      compatible_difficulties[difficulty_key] = true
      compatible_difficulties_number = compatible_difficulties_number + 1
    end
  end
  compatibility.compatible_difficulties_number = compatible_difficulties_number
end


-- Converts user-made config to form used by mutators module
local function initialize_mutator_config(mutator, _raw_config)

  -- Shapes raw config, so it will have only elements that are intended to be in there.
  -- Also, adds missing elements with their default values.
  local raw_config = table.clone(_default_config)
  if type(_raw_config) == "table" then
    for k, v in pairs(raw_config) do
      if type(_raw_config[k]) == type(v) then
        raw_config[k] = _raw_config[k]
      end
    end
  end
  if raw_config.short_title == "" then raw_config.short_title = nil end

  dmf.set_internal_data(mutator, "mutator_config", {})

  local config = mutator:get_internal_data("mutator_config")

  config.reward          = raw_config.reward
  config.short_title     = raw_config.short_title
  config.title_placement = raw_config.title_placement

  -- 'raw_config' will be used in 2 following functions to fill compatibility and mutator sequence tables.
  -- It will be deleted after all mods are loaded and those 2 tables are formed.
  config.raw_config      = raw_config

  -- config.compatibility
  update_compatibility(mutator)

  -- _mutators_sequence
  update_mutators_sequence(mutator)
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

dmf.mutators = _mutators


-- Appends, prepends and replaces the string with mutator titles
function dmf.add_mutator_titles_to_string(mutators, separator, is_short)

  if #mutators == 0 then
    return ""
  end

  local before = nil
  local after = nil
  local replace = nil

  for _, mutator in ipairs(mutators) do
    local config = mutator:get_internal_data("mutator_config")
    local added_name = (is_short and config.short_title or mutator:get_readable_name())
    if config.title_placement == "before" then
      if before then
        before = added_name .. separator .. before
      else
        before = added_name
      end
    elseif config.title_placement == "replace" then --@TODO: get rid of replace? Or maybe title_placement as a whole?
      if replace then
        replace = replace .. separator .. added_name
      else
        replace = added_name
      end
    else
      if after then
        after = after .. separator .. added_name
      else
        after = added_name
      end
    end
  end
  local new_str = replace or ""
  if before then
    new_str = before .. (string.len(new_str) > 0 and separator or "") .. new_str
  end
  if after then
    new_str = new_str .. (string.len(new_str) > 0 and separator or "") .. after
  end
  return new_str
end


-- Turns a mod into a mutator
function dmf.register_mod_as_mutator(mod, raw_config)

  initialize_mutator_config(mod, raw_config)

  table.insert(_mutators, mod)

  _mutators_sorted = false
end


-- Enables/disables mutator while preserving the sequence in which they were enabled
function dmf.set_mutator_state(mutator, state, initial_call)

  -- Sort mutators if this is the first call
  if not _mutators_sorted then
    sort_mutators()
  end

  local disabled_mutators = {}
  local enable_these_after = _mutators_sequence[mutator:get_name()]

  local i = get_index(_mutators, mutator)
  -- Disable mutators that were and are required to be enabled after the current one
  -- This will be recursive so that if mutator2 requires mutator3 to be enabled after it,
  -- mutator3 will be disabled before mutator2
  -- Yeah this is super confusing
  if enable_these_after and #_mutators > i then
    for j = #_mutators, i + 1, -1 do
      if _mutators[j]:is_enabled() and table.contains(enable_these_after, _mutators[j]:get_name()) then
        --print("Disabled ", _mutators[j]:get_name())
        dmf.set_mutator_state(_mutators[j], false, false)
        table.insert(disabled_mutators, 1, _mutators[j])
      end
    end
  end

  -- Enable/disable current mutator
  -- We're calling methods on the class object because we've overwritten them on the current one
  dmf.set_mod_state(mutator, state, initial_call)
  if state then
    _all_mutators_disabled = false
    on_enabled(mutator)
  else
    on_disabled(mutator, initial_call)
  end

  -- Re-enable disabled mutators
  -- This will be recursive
  if #disabled_mutators > 0 then
    for j = #disabled_mutators, 1, -1 do
      --print("Enabled ", disabled_mutators[j]:get_name())
      dmf.set_mutator_state(disabled_mutators[j], true, false)
    end
  end
end


-- Checks if player is still hosting (on update)
function dmf.check_mutators_state()
  if not _all_mutators_disabled and not player_is_server() then
    disable_impossible_mutators(false, "disabled_reason_not_server")
    _all_mutators_disabled = true
  end
end


-- Is called only after DMF reloading to check if some mutators were enabled before reloading
function dmf.is_mutator_enabled(mutator_name)
  return _enabled_mutators[mutator_name]
end


-- Removes all raw_configs which won't be used anymore
function dmf.mutators_delete_raw_config()
  for _, mutator in ipairs(_mutators) do
    mutator:get_internal_data("mutator_config").raw_config = nil
  end
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- @TODO: Hook to disable impossible mutators when the difficulty changes

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- Testing
--dmf:io_dofile("dmf/scripts/mods/dmf/modules/core/mutators/test/mutators_test")
