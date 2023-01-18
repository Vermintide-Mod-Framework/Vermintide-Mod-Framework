local dmf = get_mod("DMF")

--[[
  Add additional reward to end game results
--]]

-- Amounts of additional rewards to be added at level completion
local _num_reward = {
  credits = 0,
  plasteel = 0,
  diamantine = 0
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Adds/removes reward modifiers
local function adjustReward(credits, plasteel, diamantine, multiplier)
  if credits then
    _num_reward.credits = _num_reward.credits + credits * multiplier
  end
  if plasteel then
    _num_reward.plasteel = _num_reward.plasteel + plasteel * multiplier
  end
  if diamantine then
    _num_reward.diamantine = _num_reward.diamantine + diamantine * multiplier
  end
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- @TODO: Hook to increase mission's reward according to enabled mutators

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return {
  addReward = function(reward)
    adjustReward(reward.credits, reward.plasteel, reward.diamantine, 1)
  end,

  removeReward = function(reward)
    adjustReward(reward.credits, reward.plasteel, reward.diamantine, -1)
  end
}
