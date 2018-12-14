--[[
  Notify players of enabled mutators via chat and tab menu
--]]
local vmf = get_mod("VMF")

local _were_enabled_before = false

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Assembles a list of enabled mutators
local function add_enabled_mutators_titles_to_string(separator, is_short)
  local enabled_mutators = {}
  for _, mutator in ipairs(vmf.mutators) do
    if mutator:is_enabled() then
      table.insert(enabled_mutators, mutator)
    end
  end
  return vmf.add_mutator_titles_to_string(enabled_mutators, separator, is_short)
end


-- Sets the lobby name
local function set_lobby_data()

  if not Managers.matchmaking or
     not Managers.matchmaking.lobby or
     not Managers.matchmaking.lobby.set_lobby_data or
     not Managers.matchmaking.lobby.get_stored_lobby_data
  then
    return
  end

  local name = add_enabled_mutators_titles_to_string(" ", true) -- @TODO: change separator?

  local default_name = LobbyAux.get_unique_server_name()
  if string.len(name) > 0 then
    name = "||" .. name .. "|| " .. default_name
  else
    name = default_name
  end

  local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
  lobby_data.unique_server_name = name

  Managers.matchmaking.lobby:set_lobby_data(lobby_data)
end


local function get_peer_id_from_cookie(client_cookie)
  return string.match(client_cookie, "%[(.-)%]")
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- Append difficulty name with enabled mutators' titles
vmf:hook_origin(IngamePlayerListUI, "update_difficulty", function(self)
  local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
  local difficulty_name =  difficulty_settings.display_name

  local name = add_enabled_mutators_titles_to_string(", ", true)
  local localized_difficulty_name = not self.is_in_inn and Localize(difficulty_name) or ""
  if name == "" then -- no mutators
    name = localized_difficulty_name
  elseif localized_difficulty_name ~= "" then -- it can be "" if player is in the inn with no selected level
    name = name .. " (" .. localized_difficulty_name .. ")"
  end

  self.set_difficulty_name(self, name)

  self.current_difficulty_name = difficulty_name
end)


-- Notify everybody about enabled/disabled mutators when Play button is pressed on the map screen
vmf:hook_safe(MatchmakingStateHostGame, "host_game", function()
  set_lobby_data()
  local names = add_enabled_mutators_titles_to_string(", ")
  if names ~= "" then
    vmf:chat_broadcast(vmf:localize("broadcast_enabled_mutators") .. ": " .. names)
    _were_enabled_before = true
  elseif _were_enabled_before then
    vmf:chat_broadcast(vmf:localize("broadcast_all_disabled"))
    _were_enabled_before = false
  end
end)


-- @TODO: can't I do it with hook_safe? Also can't I just use 'sender' intead of extracting peer_id form cookie?
-- Send special messages with enabled mutators list to players just joining the lobby
vmf:hook(MatchmakingManager, "rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, ...)
  local name = add_enabled_mutators_titles_to_string(", ")
  if name ~= "" then
    local message = vmf:localize("whisper_enabled_mutators") .. ": " .. name
    vmf:chat_whisper(get_peer_id_from_cookie(client_cookie), message)
  end
  func(self, sender, client_cookie, ...)
end)

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return set_lobby_data
