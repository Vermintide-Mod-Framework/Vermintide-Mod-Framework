local manager = get_mod("vmf_mutator_manager")
local mutators = manager.mutators

local were_enabled_before = false

local function get_enabled_mutators_names(short)
	local name = nil
	for _, mutator in ipairs(mutators) do
		local config = mutator:get_config()
		if mutator:is_enabled() then
			local added_name = (short and config.short_title or config.title or mutator:get_name())
			if name then
				name = name .. " " .. added_name
			else
				name = added_name
			end
		end
	end
	return name
end

local function set_lobby_data()

	if not Managers.matchmaking then return end

	local name = get_enabled_mutators_names(true)

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

local function get_member_func(client_cookie)
	local peer_id = tostring(client_cookie)
	for _ = 1, 3 do
		peer_id = string.sub(peer_id, 1 + tonumber(tostring(string.find(peer_id,"-"))))
	end
	peer_id = string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)
	peer_id = string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)

	return function()
		for _, v in ipairs(Managers.matchmaking.lobby:members():get_members()) do
			if v == peer_id then
				return {v}
			end
		end
		return Managers.matchmaking.lobby:members():get_members()
	end
end


manager:hook("IngamePlayerListUI.set_difficulty_name", function(func, self, name)
	local mutators_name = get_enabled_mutators_names(true)
	if mutators_name then
		name = name .. " " .. mutators_name
	end
	self.headers.content.game_difficulty = name
end)

manager:hook("MatchmakingStateHostGame.host_game", function(func, self, ...)
	func(self, ...)
	set_lobby_data()
	local names = get_enabled_mutators_names()
	if names then
		Managers.chat:send_system_chat_message(1, "ENABLED MUTATORS: " .. names, 0, true)
		were_enabled_before = true
	elseif were_enabled_before then
		Managers.chat:send_system_chat_message(1, "ALL MUTATORS DISABLED", 0, true)
		were_enabled_before = false
	end
end)

manager:hook("MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
	local name = get_enabled_mutators_names()
	if name then
		local message = "[Automated message] This lobby has the following difficulty mod active : " .. name
		manager:hook("Managers.chat.channels[1].members_func", get_member_func(client_cookie))
		Managers.chat:send_system_chat_message(1, message, 0, true)
		manager:hook_remove("Managers.chat.channels[1].members_func")
	end
	func(self, sender, client_cookie, host_cookie, lobby_id, friend_join)
end)

return set_lobby_data