--[[ Notify players of enabled mutators via chat and tab menu --]]
local vmf = get_mod("VMF")

local mutators = vmf.mutators

local were_enabled_before = false

-- Assembles a list of enabled mutators
local function add_enabled_mutators_titles_to_string(str, separator, short)
	local _mutators = {}
	for _, mutator in ipairs(mutators) do
		if mutator:is_enabled() then
			table.insert(_mutators, mutator)
		end
	end
	return vmf.add_mutator_titles_to_string(_mutators, str, separator, short)
end

-- Sets the lobby name
local function set_lobby_data()

	if (
		not Managers.matchmaking or
		not Managers.matchmaking.lobby or
		not Managers.matchmaking.lobby.set_lobby_data or
		not Managers.matchmaking.lobby.get_stored_lobby_data
	) then return end

	local name = add_enabled_mutators_titles_to_string("", " ", true)

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

--@TODO: maybe rewrite?
local function get_peer_id_from_cookie(client_cookie)
	local peer_id = tostring(client_cookie)
	for _ = 1, 3 do
		peer_id = string.sub(peer_id, 1 + tonumber(tostring(string.find(peer_id,"-"))))
	end
	peer_id = string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)
	peer_id = string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)

	return peer_id
end

-- Append difficulty name with enabled mutators' titles
vmf:hook("IngamePlayerListUI.update_difficulty", function(func, self)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local difficulty_name =  difficulty_settings.display_name

	--local name = not self.is_in_inn and Localize(difficulty_name) or ""
	--name = add_enabled_mutators_titles_to_string(name, ", ", true)

	local name = add_enabled_mutators_titles_to_string("", ", ", true)
	local localized_difficulty_name = not self.is_in_inn and Localize(difficulty_name) or ""
	if name == "" then -- no mutators
		name = localized_difficulty_name
	elseif localized_difficulty_name ~= "" then -- no difficulty (inn)
		name = name .. " (" .. localized_difficulty_name .. ")"
	end

	self.set_difficulty_name(self, name)

	self.current_difficulty_name = difficulty_name
end)

-- Notify everybody about enabled/disabled mutators when Play button is pressed on the map screen
vmf:hook("MatchmakingStateHostGame.host_game", function(func, self, ...)
	func(self, ...)
	set_lobby_data()
	local names = add_enabled_mutators_titles_to_string("", ", ")
	if string.len(names) > 0 then
		vmf:chat_broadcast(vmf:localize("broadcast_enabled_mutators") .. ": " .. names)
		were_enabled_before = true
	elseif were_enabled_before then
		vmf:chat_broadcast(vmf:localize("broadcast_all_disabled"))
		were_enabled_before = false
	end
end)

-- Send special messages with enabled mutators list to players just joining the lobby
vmf:hook("MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
	local name = add_enabled_mutators_titles_to_string("", ", ")
	if string.len(name) > 0 then
		local message = vmf:localize("whisper_enabled_mutators") .. ": " .. name
		vmf:chat_whisper(get_peer_id_from_cookie(client_cookie), message)
	end
	func(self, sender, client_cookie, host_cookie, lobby_id, friend_join)
end)

return set_lobby_data
