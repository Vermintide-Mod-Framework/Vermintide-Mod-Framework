local vmf = get_mod("VMF")

local _VMF_USERS = {}
local _RPC_CALLBACKS = {}

local _LOCAL_MODS_MAP = {}
local _LOCAL_RPCS_MAP = {}

local _SHARED_MODS_MAP = ""
local _SHARED_RPCS_MAP = ""

local _NETWORK_MODULE_IS_INITIALIZED = false

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function is_rpc_registered(mod_name, rpc_name)

  local success = pcall(function() return _RPC_CALLBACKS[mod_name][rpc_name] end)
  return success
end

-- CONVERTING

local function convert_names_to_numbers(peer_id, mod_name, rpc_name)

  local user_rpcs_dictionary = _VMF_USERS[peer_id]
  if user_rpcs_dictionary then

    local mod_number = user_rpcs_dictionary[1][mod_name]
    if mod_number then

      local rpc_number = user_rpcs_dictionary[2][mod_number][rpc_name]
      if rpc_number then

        return mod_number, rpc_number
      end
    end
  end
  return nil
end

local function convert_numbers_to_names(mod_number, rpc_number)

  local mod_name = _LOCAL_MODS_MAP[mod_number]
  if mod_name then

    local rpc_name = _LOCAL_RPCS_MAP[mod_number][rpc_number]
    if rpc_name then

      return mod_name, rpc_name

    end
  end
  return nil
end

-- SERIALIZATION

local function serialize_data(...)

  return cjson.encode({...})
end

local function deserialize_data(data)

  data = cjson.decode(data)

  local args_number = #data

  for i, _ in ipairs(data) do
    if type(data[i]) == "userdata" then -- userdata [nullptr (deleted)] -> nil
      data[i] = nil
    end
  end

  return unpack(data, 1, args_number)
end

-- DEBUG

local function network_debug(rpc_type, action_type, peer_id, mod_name, rpc_name, data)

  if vmf.network_debug then

    local debug_message = nil

    if action_type == "local" then
      debug_message = "[NETWORK][LOCAL]"
    else
      debug_message = "[NETWORK][" .. peer_id .. " (" .. tostring(Managers.player:player_from_peer_id(peer_id)) .. ")]" .. (action_type == "sent" and "<-" or "->")
    end

    if rpc_type == "ping" then

      debug_message = debug_message .. "[PING]"

    elseif rpc_type == "pong" then

      debug_message = debug_message .. "[PONG]"

    elseif rpc_type == "data" then

      debug_message = debug_message .. "[DATA][" .. mod_name .. "][" .. rpc_name .. "]: "

      if type(data) == "string" then
        debug_message = debug_message .. data
      else
        local success, serialized_data = pcall(serialize_data, unpack(data))
        if success then
          debug_message = debug_message .. serialized_data
        end
      end
    end

    vmf:info(debug_message)
  end
end

-- NETWORK

local function send_rpc_vmf_ping(peer_id)

  network_debug("ping", "sent", peer_id)
  RPC.rpc_chat_message(peer_id, 3, Network.peer_id(), "", "", false, true, false)
end

local function send_rpc_vmf_pong(peer_id)

  network_debug("pong", "sent", peer_id)
  RPC.rpc_chat_message(peer_id, 4, Network.peer_id(), _SHARED_MODS_MAP, _SHARED_RPCS_MAP, false, true, false)
end

local function send_rpc_vmf_data(peer_id, mod_name, rpc_name, ...)

  local mod_number, rpc_number = convert_names_to_numbers(peer_id, mod_name, rpc_name)
  if mod_number then

    local rpc_info = cjson.encode({mod_number, rpc_number})
    local success, data = pcall(serialize_data, ...)
    if success then
      network_debug("data", "sent", peer_id, mod_name, rpc_name, data)
      RPC.rpc_chat_message(peer_id, 5, Network.peer_id(), rpc_info, data, false, true, false)
    end
  end
end

local function send_rpc_vmf_data_local(mod_name, rpc_name, ...)

  if get_mod(mod_name):is_enabled() then
    network_debug("data", "local", nil, mod_name, rpc_name, {...})

    local success, error_message = pcall(_RPC_CALLBACKS[mod_name][rpc_name], Network.peer_id(), ...)
    if not success then
      get_mod(mod_name):error("(local rpc) in rpc '%s': %s", tostring(rpc_name), tostring(error_message))
    end
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.network_register = function (self, rpc_name, rpc_function)

  if _NETWORK_MODULE_IS_INITIALIZED then
    self:error("(network_register): you can't register new rpc after mod initialization")
    return
  end

  if type(rpc_name) ~= "string" then
    self:error("(network_register): rpc_name should be the string, not %s", type(rpc_name))
    return
  end

  if type(rpc_function) ~= "function" then
    self:error("(network_register): rpc_function should be the function, not %s", type(rpc_name))
    return
  end

  _RPC_CALLBACKS[self:get_name()] = _RPC_CALLBACKS[self:get_name()] or {}

  _RPC_CALLBACKS[self:get_name()][rpc_name] = rpc_function
end

-- recipient = "all", "local", "others", peer_id
VMFMod.network_send = function (self, rpc_name, recipient, ...)

  if not is_rpc_registered(self:get_name(), rpc_name) then

    self:error("(network_send): attempt to send non-registered rpc")
    return
  end

  if recipient == "all" then

    for peer_id, _ in pairs(_VMF_USERS) do
        send_rpc_vmf_data(peer_id, self:get_name(), rpc_name, ...)
    end

    send_rpc_vmf_data_local(self:get_name(), rpc_name, ...)

  elseif recipient == "others" then

    for peer_id, _ in pairs(_VMF_USERS) do
      send_rpc_vmf_data(peer_id, self:get_name(), rpc_name, ...)
    end

  elseif recipient == "local" or recipient == Network.peer_id() then

    send_rpc_vmf_data_local(self:get_name(), rpc_name, ...)

  else -- recipient == peer_id

    send_rpc_vmf_data(recipient, self:get_name(), rpc_name, ...)
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("ChatManager.rpc_chat_message", function(func, self, sender, channel_id, message_sender, message, localization_param, ...)

  if channel_id == 1 then

    func(self, sender, channel_id, message_sender, message, localization_param, ...)
  else

    if not _NETWORK_MODULE_IS_INITIALIZED then
      return
    end

    if channel_id == 3 then -- rpc_vmf_request

      network_debug("ping", "received", sender)

      send_rpc_vmf_pong(sender)

    elseif channel_id == 4 then -- rpc_vmf_responce (@TODO: maybe I should protect it from sending by the player who's not in the game?)

      network_debug("pong", "received", sender)
      if vmf.network_debug then
        vmf:info("[RECEIVED MODS TABLE]: " .. message)
        vmf:info("[RECEIVED RPCS TABLE]: " .. localization_param)
      end

      pcall(function()

        local user_rpcs_dictionary = {}

        user_rpcs_dictionary[1] = cjson.decode(message) -- mods
        user_rpcs_dictionary[2] = cjson.decode(localization_param) -- rpcs

        _VMF_USERS[sender] = user_rpcs_dictionary

        vmf:info("Added %s to the VMF users list.", sender)

        -- event
        local player = Managers.player:player_from_peer_id(sender)
        if player then

          for mod_name, _ in pairs(user_rpcs_dictionary[1]) do
            local mod = get_mod(mod_name)
            if mod then
              vmf.mod_user_joined_the_game(mod, player)
            end
          end
        end
      end)

    elseif channel_id == 5 then

      local mod_number, rpc_number = unpack(cjson.decode(message))

      local mod_name, rpc_name = convert_numbers_to_names(mod_number, rpc_number)
      if mod_name and get_mod(mod_name):is_enabled() then

        network_debug("data", "received", sender, mod_name, rpc_name, localization_param)

        -- can be error in both callback_function() and deserialize_data()
        local success, error_message = pcall(function() _RPC_CALLBACKS[mod_name][rpc_name](sender, deserialize_data(localization_param)) end)
        if not success then
          get_mod(mod_name):error("(network) in rpc function '%s': %s", rpc_name, tostring(error_message))
        end
      end
    end
	end
end)

vmf:hook("PlayerManager.add_remote_player", function (func, self, peer_id, player_controlled, local_player_id, clan_tag)

  if player_controlled then
    send_rpc_vmf_ping(peer_id)
  end

  return func(self, peer_id, player_controlled, local_player_id, clan_tag)
end)

vmf:hook("PlayerManager.remove_player", function (func, self, peer_id, local_player_id)

  if _VMF_USERS[peer_id] then

    -- make sure it's not the bot
    for _, player in pairs(Managers.player:human_players()) do
      if player.peer_id == peer_id then

        vmf:info("Removed %s from the VMF users list.", peer_id)

        -- event
        for mod_name, _ in pairs(_VMF_USERS[peer_id][1]) do
          local mod = get_mod(mod_name)
          if mod then
            vmf.mod_user_left_the_game(mod, player)
          end
        end

        _VMF_USERS[peer_id] = nil
        break
      end
    end
  end

  func(self, peer_id, local_player_id)
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.network_debug = vmf:get("developer_mode") and vmf:get("show_network_debug_info")

vmf.create_network_dictionary = function()

  _SHARED_MODS_MAP = {}
  _SHARED_RPCS_MAP = {}

  local i = 0
  for mod_name, mod_rpcs in pairs(_RPC_CALLBACKS) do

    i = i + 1

    _SHARED_MODS_MAP[mod_name] = i
    _LOCAL_MODS_MAP[i] = mod_name

    _SHARED_RPCS_MAP[i] = {}
    _LOCAL_RPCS_MAP[i] = {}

    local j = 0
    for rpc_name, _ in pairs(mod_rpcs) do

      j = j + 1

      _SHARED_RPCS_MAP[i][rpc_name] = j
      _LOCAL_RPCS_MAP[i][j] = rpc_name
    end
  end

  _SHARED_MODS_MAP = cjson.encode(_SHARED_MODS_MAP)
  _SHARED_RPCS_MAP = cjson.encode(_SHARED_RPCS_MAP)

  _NETWORK_MODULE_IS_INITIALIZED = true
end

vmf.ping_vmf_users = function()

  if Managers.player then
    for _, player in pairs(Managers.player:human_players()) do
      if player.peer_id ~= Network.peer_id() then

        send_rpc_vmf_ping(player.peer_id)
        send_rpc_vmf_pong(player.peer_id)
      end
    end
  end
end