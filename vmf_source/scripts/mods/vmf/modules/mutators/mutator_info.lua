--[[ Notify players of enabled mutators via chat and tab menu --]]

local manager = get_mod("vmf_mutator_manager")
local mutators = manager.mutators

local were_enabled_before = false

-- Assembles a list of enabled mutators
local function get_enabled_mutators_names(separator, short)
	local name = nil
	for _, mutator in ipairs(mutators) do
		local config = mutator:get_config()
		if mutator:is_enabled() then
			local added_name = (short and config.short_title or config.title or mutator:get_name())
			if name then
				name = name .. separator .. added_name
			else
				name = added_name
			end
		end
	end
	return name
end

-- Sets the lobby name
local function set_lobby_data()

	if not Managers.matchmaking then return end

	local name = get_enabled_mutators_names(" ", true)

	local default_name = LobbyAux.get_unique_server_name()
	if name then
		name = "||" .. name .. "|| " .. default_name
	else
		name = default_name
	end

	local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
	lobby_data.unique_server_name = name

	Managers.matchmaking.lobby:set_lobby_data(lobby_data)
end

-- Return a function for chat system to only send messages to specific client
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
manager:hook("IngamePlayerListUI.update_difficulty", function(func, self)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local difficulty_name =  difficulty_settings.display_name

	local name = not self.is_in_inn and Localize(difficulty_name) or nil
	local mutators_name = get_enabled_mutators_names(" ", true)
	if mutators_name then
		if name then name = name .. " " else name = "" end
		name = name .. mutators_name
	else
		name = "" 
	end
	self.set_difficulty_name(self, name)

	self.current_difficulty_name = difficulty_name
end)

-- Notify everybody about enabled/disabled mutators when Play button is pressed on the map screen
manager:hook("MatchmakingStateHostGame.host_game", function(func, self, ...)
	func(self, ...)
	set_lobby_data()
	local names = get_enabled_mutators_names(", ")
	manager:echo("TEST")
	if names then
		manager:chat_broadcast("ENABLED MUTATORS: " .. names)
		were_enabled_before = true
	elseif were_enabled_before then
		manager:chat_broadcast("ALL MUTATORS DISABLED")
		were_enabled_before = false
	end
end)

-- Send special messages with enabled mutators list to players just joining the lobby
manager:hook("MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
	local name = get_enabled_mutators_names(", ")
	if name then
		local message = "[Automated message] This lobby has the following difficulty mod active : " .. name
		manager:chat_whisper(get_peer_id_from_cookie(client_cookie), message)
	end
	func(self, sender, client_cookie, host_cookie, lobby_id, friend_join)
end)

return set_lobby_data
