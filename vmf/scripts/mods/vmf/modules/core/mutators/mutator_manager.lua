local vmf = get_mod("VMF")

-- Map-like table containing pairs for all mutators.
-- k [mod]  : Mutator instance
-- v [table]: (required, but can be empty) List of mutators that are dependant
--            on 'k' mutator and, if enabled, should be disabled in order to
--            toggle 'k' mutator, and then be enabled again
-- Used:
-- * In toggling module to toggle mutators in right order.
vmf.mutators = {
  --[[
  this_mutator = {
    will_always_be_toggled,
    only_when_these_two_are_disabled
  },
  --]]
}

local ERRORS = {
  THROWABLE = {
    -- validate_mutator_data:
    mutator_data_wrong_type = "'mutator_data' must be a table, not %s.",
    required_on_clients_wrong_type = "'required_on_clients' must be a boolean, not %s.",
    enable_before_wrong_type = "'enable_before' must be a table, not %s.",
    enable_before_element_wrong_type = "'enable_before[%s]' must be a string, not %s.",
    enable_after_wrong_type = "'enable_after' must be a table, not %s.",
    enable_after_element_wrong_type = "'enable_after[%s]' must be a string, not %s.",
    dice_wrong_type = "'dice' must be a table, not %s.",
    dice_missing_field = "'dice' table must contain 'bonus', 'tomes', and 'grims' fields.",
    dice_field_wrong_type = "'dice.%s' must be a number, not %s.",
    wrong_dice_number = "'dice.%s' can not be less than 0 and greater than 7.",
  }
}

-- =============================================================================
-- Local functions
-- =============================================================================

-- [THROWS ERRORS]
local function validate_mutator_data(data)
  -- Initial check.
  if type(data) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE.mutator_data_wrong_type, type(data))
  end

  -- Add missing data.
  if data.required_on_clients == nil then data.required_on_clients = false                             end
  if data.enable_before       == nil then data.enable_before       = {}                                end
  if data.enable_after        == nil then data.enable_after        = {}                                end
  if data.dice                == nil then data.dice                = {bonus = 0, tomes = 0, grims = 0} end

  -- Other checks.
  if type(data.required_on_clients) ~= "boolean" then
    vmf.throw_error(ERRORS.THROWABLE.required_on_clients_wrong_type, type(data.required_on_clients))
  end

  if type(data.enable_before) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE.enable_before_wrong_type, type(data.enable_before))
  end
  for i, mutator_name in ipairs(data.enable_before) do
    if type(mutator_name) ~= "string" then
      vmf.throw_error(ERRORS.THROWABLE.enable_before_element_wrong_type, i, type(mutator_name))
    end
  end

  if type(data.enable_after) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE.enable_after_wrong_type, type(data.enable_after))
  end
  for i, mutator_name in ipairs(data.enable_after) do
    if type(mutator_name) ~= "string" then
      vmf.throw_error(ERRORS.THROWABLE.enable_after_element_wrong_type, i, type(mutator_name))
    end
  end

  if type(data.dice) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE.dice_wrong_type, type(data.dice))
  end
  for _, die_name in ipairs({"bonus", "tomes", "grims"}) do
    local dice_number = data.dice[die_name]
    if dice_number == nil then
      vmf.throw_error(ERRORS.THROWABLE.dice_missing_field)
    end
    if type(dice_number) ~= "number" then
      vmf.throw_error(ERRORS.THROWABLE.dice_field_wrong_type, die_name, type(dice_number))
    end
    if dice_number < 0 or dice_number > 7 then
      vmf.throw_error(ERRORS.THROWABLE.wrong_dice_number, die_name)
    end
  end
end

-- =============================================================================
-- VMF internal functions
-- =============================================================================

function vmf.initialize_mutator_data(mod, mutator_data)
  mutator_data = mutator_data or {}

  validate_mutator_data(mutator_data)

  vmf.mutators[mod] = {}
end

function vmf.on_mutator_state_changed(mutator, enabled, initial_call)
end
