local vmf = get_mod("VMF")

-- Map-like table containing pairs for all mutators.
-- k [mod]  : Mutator instance
-- v [table]: (required, but can be empty) List of mutators that are dependant
--            on 'k' mutator and, if enabled, should be disabled in order to
--            toggle 'k' mutator, and then be enabled again
vmf.mutators = {
  --[[
  this_mutator = {
    will_always_be_toggled,
    only_when_these_two_are_disabled
  },
  --]]
}

-- =============================================================================
-- VMF internal functions
-- =============================================================================

function vmf.register_mod_as_mutator(mod, raw_config)
  vmf.mutators[mod] = {}
end

function vmf.on_mutator_state_changed(mutator, enabled, initial_call)
end
