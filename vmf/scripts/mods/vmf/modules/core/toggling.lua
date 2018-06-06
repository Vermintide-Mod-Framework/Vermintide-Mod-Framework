local vmf = get_mod("VMF")

local _DISABLED_MODS = vmf:get("disabled_mods_list") or {}

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.set_mod_state = function (mod, is_enabled, initial_call)

  mod._data.is_enabled = is_enabled

  if is_enabled then
    mod:enable_all_hooks()
    vmf.mod_enabled_event(mod, initial_call)
  else
    mod:disable_all_hooks()
    vmf.mod_disabled_event(mod, initial_call)
  end

  if not (initial_call or mod:is_mutator()) then
    if is_enabled then
      _DISABLED_MODS[mod:get_name()] = nil
    else
      _DISABLED_MODS[mod:get_name()] = true
    end
    vmf:set("disabled_mods_list", _DISABLED_MODS)
  end
end

-- Called when mod is loaded for the first time using mod:initialize()
vmf.initialize_mod_state = function (mod)

  local state
  if mod:is_mutator() then
    -- if VMF was reloaded and mutator was activated
    if vmf.is_mutator_enabled(mod:get_name()) then
      state = true
    else
      state = false
    end
    vmf.set_mutator_state(mod, state, true)
  else
    state = not _DISABLED_MODS[mod:get_name()]
    vmf.set_mod_state(mod, state, true)
  end
end

vmf.mod_state_changed = function (mod_name, is_enabled)

  local mod = get_mod(mod_name)

  if not mod:is_togglable() or is_enabled == mod:is_enabled() then
    return
  end

  if mod:is_mutator() then
    vmf.set_mutator_state(mod, is_enabled, false)
  else
    vmf.set_mod_state(mod, is_enabled, false)
  end
end