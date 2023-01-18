local dmf = get_mod("DMF")

--[[
  Notify players of enabled mutators via chat and tab menu
--]]

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Assembles a list of enabled mutators
local function add_enabled_mutators_titles_to_string(separator, is_short)
  local enabled_mutators = {}
  for _, mutator in ipairs(dmf.mutators) do
    if mutator:is_enabled() then
      table.insert(enabled_mutators, mutator)
    end
  end
  return dmf.add_mutator_titles_to_string(enabled_mutators, separator, is_short)
end


-- Sets the lobby name
local function set_lobby_data()
  -- @TODO: Add mutator titles to lobby name in matchmaking
end


local function get_peer_id_from_cookie(client_cookie)
  return string.match(client_cookie, "%[(.-)%]")
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- @TODO: Hook to update difficulty name

-- @TODO: Hook to notify strike team of enabled mutators

-- @TODO: Hook to whisper incoming players about enabled mutators

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return set_lobby_data
