local vmf = get_mod("VMF")

-- Keeps track of disabled non-mutator mods to carry their state between game
-- sessions and VMF reloads.
local _disabled_mods = vmf:get("disabled_mods_list") or {}

-- List of enabled mutators to carry their state between VMF reloads.
local _enabled_mutators = vmf:persistent_table("enabled_mutators")

-- =============================================================================
-- Local functions
-- =============================================================================

-- * Sets mod's state.
-- * Enables/disables all mod hooks depending on mod state.
-- * Calls `on_enabled`/`on_disabled` events.
-- * Keeps track of disabled mods and enabled mutators.
local function set_mod_state(mod, is_enabled, initial_call)
  vmf.set_internal_data(mod, "is_enabled", is_enabled)

  if is_enabled then
    mod:enable_all_hooks()
    vmf.mod_enabled_event(mod, initial_call)
  else
    mod:disable_all_hooks()
    vmf.mod_disabled_event(mod, initial_call)
  end

  if not initial_call then
    if mod:get_internal_data("is_mutator") then
      _enabled_mutators[mod:get_name()] = is_enabled
    else
      _disabled_mods[mod:get_name()] = not is_enabled or nil
      vmf:set("disabled_mods_list", _disabled_mods)
    end
  end
end

-- A fancy `set_mod_state` wrapper for mutators.
-- * Ensures correct toggling order.
-- * Notifies mutator module about mutator's changed state.
-- Correct toggling order is ensured only after all mods are initialized.
-- Otherwise, launcher's order is used.
local function set_mutator_state(mutator, is_enabled, initial_call)
  local disabled_mutators = {}

  -- Disable all enabled dependant mutators.
  if not initial_call then
    for _, dependant_mutator in ipairs(vmf.mutators[mutator]) do
      if dependant_mutator:is_enabled() then
        set_mutator_state(dependant_mutator, false, false)
        table.insert(disabled_mutators, dependant_mutator)
      end
    end
  end

  -- Toggle current mutator state.
  set_mod_state(mutator, is_enabled, initial_call)
  vmf.on_mutator_state_changed(mutator, is_enabled, initial_call)

  -- Re-enable disabled mutators.
  if not initial_call then
    for _, disabled_mutator in ipairs(disabled_mutators) do
      set_mutator_state(disabled_mutator, true, false)
    end
  end
end

-- =============================================================================
-- VMF internal functions
-- =============================================================================

-- Sets mod's state for the first time.
-- * Called for all togglable mods and mutators when they finish their
--   initialization process.
-- * All mutators are disabled by default unless they were enabled before
--   VMF reloading.
function vmf.initialize_mod_state(mod)
  local state
  if mod:get_internal_data("is_mutator") then
    state = not not _enabled_mutators[mod:get_name()]
    set_mutator_state(mod, state, true)
  else
    state = not _disabled_mods[mod:get_name()]
    set_mod_state(mod, state, true)
  end
end

-- Sets mod's state if safety checks were successful.
function vmf.set_mod_state(mod, is_enabled)
  if not mod:get_internal_data("is_togglable") or is_enabled == mod:is_enabled() then
    return
  end

  if mod:get_internal_data("is_mutator") then
    set_mutator_state(mod, is_enabled, false)
  else
    set_mod_state(mod, is_enabled, false)
  end
end
