local dmf = get_mod("DMF")

local _disabled_mods = dmf:get("disabled_mods_list") or {}

-- ####################################################################################################################
-- ##### DMF internal functions and variables #########################################################################
-- ####################################################################################################################

dmf.set_mod_state = function (mod, is_enabled, initial_call)

  dmf.set_internal_data(mod, "is_enabled", is_enabled)

  if is_enabled then
    mod:enable_all_hooks()
    dmf.mod_enabled_event(mod, initial_call)
  else
    mod:disable_all_hooks()
    dmf.mod_disabled_event(mod, initial_call)
  end

  if not (initial_call or mod:get_internal_data("is_mutator")) then
    if is_enabled then
      _disabled_mods[mod:get_name()] = nil
    else
      _disabled_mods[mod:get_name()] = true
    end
    dmf:set("disabled_mods_list", _disabled_mods)
  end
end

-- Called when mod is loaded for the first time using mod:initialize()
dmf.initialize_mod_state = function (mod)

  local state
  if mod:get_internal_data("is_mutator") then
    -- if DMF was reloaded and mutator was activated
    if dmf.is_mutator_enabled(mod:get_name()) then
      state = true
    else
      state = false
    end
    dmf.set_mutator_state(mod, state, true)
  else
    state = not _disabled_mods[mod:get_name()]
    dmf.set_mod_state(mod, state, true)
  end
end

dmf.mod_state_changed = function (mod_name, is_enabled)

  local mod = get_mod(mod_name)

  if not mod:get_internal_data("is_togglable") or is_enabled == mod:is_enabled() then
    return
  end

  if mod:get_internal_data("is_mutator") then
    dmf.set_mutator_state(mod, is_enabled, false)
  else
    dmf.set_mod_state(mod, is_enabled, false)
  end
end
