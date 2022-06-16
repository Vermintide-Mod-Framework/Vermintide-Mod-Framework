local vmf = get_mod("VMF")

local _disabled_mods = vmf:get("disabled_mods_list") or {}

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.set_mod_state = function (mod, is_enabled, initial_call)

  vmf.set_internal_data(mod, "is_enabled", is_enabled)

  if is_enabled then
    mod:enable_all_hooks()
    vmf.mod_enabled_event(mod, initial_call)
    vmf.inject_hud_components(mod)
  else
    mod:disable_all_hooks()
    vmf.mod_disabled_event(mod, initial_call)
    vmf.remove_injected_hud_components(mod)
  end

  if not (initial_call or mod:get_internal_data("is_mutator")) then
    if is_enabled then
      _disabled_mods[mod:get_name()] = nil
    else
      _disabled_mods[mod:get_name()] = true
    end
    vmf:set("disabled_mods_list", _disabled_mods)
  end
end

-- Called when mod is loaded for the first time using mod:initialize()
vmf.initialize_mod_state = function (mod)

  local state
  if mod:get_internal_data("is_mutator") then
    -- if VMF was reloaded and mutator was activated
    if vmf.is_mutator_enabled(mod:get_name()) then
      state = true
    else
      state = false
    end
    vmf.set_mutator_state(mod, state, true)
  else
    state = not _disabled_mods[mod:get_name()]
    vmf.set_mod_state(mod, state, true)
  end
end

vmf.mod_state_changed = function (mod_name, is_enabled)

  local mod = get_mod(mod_name)

  if not mod:get_internal_data("is_togglable") or is_enabled == mod:is_enabled() then
    return
  end

  if mod:get_internal_data("is_mutator") then
    vmf.set_mutator_state(mod, is_enabled, false)
  else
    vmf.set_mod_state(mod, is_enabled, false)
  end
end
