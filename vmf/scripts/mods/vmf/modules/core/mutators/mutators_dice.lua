--[[
  Add additional dice to end game roll
--]]
local vmf = get_mod("VMF")

-- List of all die types
local MISSIONS = {
  "bonus_dice_hidden_mission",
  "tome_bonus_mission",
  "grimoire_hidden_mission"
}

-- Amounts of additional dice to be added at level completion
local _num_dice_per_mission = {
  bonus_dice_hidden_mission = 0,
  tome_bonus_mission = 0,
  grimoire_hidden_mission = 0
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Adds/remove dice
local function adjustDice(grims, tomes, bonus, multiplier)
  if grims then
    _num_dice_per_mission.grimoire_hidden_mission = _num_dice_per_mission.grimoire_hidden_mission + grims * multiplier
  end
  if tomes then
    _num_dice_per_mission.tome_bonus_mission = _num_dice_per_mission.tome_bonus_mission + tomes * multiplier
  end
  if bonus then
    _num_dice_per_mission.bonus_dice_hidden_mission = _num_dice_per_mission.bonus_dice_hidden_mission + bonus *
                                                                                                         multiplier
  end
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

vmf:hook("GameModeManager.complete_level", function(func, ...)
  local num_dice = 0
  local max_dice = 7
  local mission_system = Managers.state.entity:system("mission_system")
  local active_mission = mission_system.active_missions

  -- Add additional dice
  for _, mission in ipairs(MISSIONS) do
    for _ = 1, _num_dice_per_mission[mission] do
      mission_system:request_mission(mission, nil, Network.peer_id())
      mission_system:update_mission(mission, true, nil, Network.peer_id(), nil, true)
    end
  end

  -- Get total number of dice
  for name, obj in pairs(active_mission) do
    if table.contains(MISSIONS, name) then
      num_dice = num_dice + obj.current_amount
    end
  end

  -- Remove excess dice
  for _, mission in ipairs(MISSIONS) do
    if active_mission[mission] then
      for _ = 1, active_mission[mission].current_amount do
        if num_dice > max_dice then
          mission_system:request_mission(mission, nil, Network.peer_id())
          mission_system:update_mission(mission, false, nil, Network.peer_id(), nil, true)
          num_dice = num_dice - 1
        else break end
      end
    end
    if num_dice <= max_dice then break end
  end

  func(...)
end)

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return {
  addDice = function(dice)
    adjustDice(dice.grims, dice.tomes, dice.bonus, 1)
  end,

  removeDice = function(dice)
    adjustDice(dice.grims, dice.tomes, dice.bonus, -1)
  end
}
