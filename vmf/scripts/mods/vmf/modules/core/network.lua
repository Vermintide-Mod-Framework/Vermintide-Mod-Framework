local vmf = get_mod("VMF")

local _vmf_users = {}
local _rpc_callbacks = {}

local _local_mods_map = {}
local _local_rpcs_map = {}

local _shared_mods_map = ""
local _shared_rpcs_map = ""

local _network_module_is_initialized = false
local _network_debug = false

local VT2_PORT_NUMBER = 0

local VERMINTIDE_CHANNEL_ID = 1
local RPC_VMF_REQUEST_CHANNEL_ID = 3
local RPC_VMF_RESPONCE_CHANNEL_ID = 4
local RPC_VMF_UNKNOWN_CHANNEL_ID = 5 -- Note(Siku): No clue what 5 is supposed to mean.

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function is_rpc_registered(mod_name, rpc_name)

  local success = pcall(function() return _rpc_callbacks[mod_name][rpc_name] end)
  return success
end

-- CONVERTING

local function convert_names_to_numbers(peer_id, mod_name, rpc_name)

  local user_rpcs_dictionary = _vmf_users[peer_id]
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

  local mod_name = _local_mods_map[mod_number]
  if mod_name then

    local rpc_name = _local_rpcs_map[mod_number][rpc_number]
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

  if _network_debug then

    local debug_message

    if action_type == "local" then
      debug_message = "[NETWORK][LOCAL]"
    else
      local msg_direction = (action_type == "sent" and "<-" or "->")
      local player_string = tostring(Managers.player:player_from_peer_id(peer_id))
      --NOTE (Siku): Multiple concatenation requires the creation of multiple strings, look into it.
      --debug_message = string.format("[NETWORK][%s (%s)] %s", peer_id, player_string, msg_direction)
      debug_message = "[NETWORK][" .. peer_id .. " (" .. player_string .. ")]" .. msg_direction
    end

    if rpc_type == "ping" then

      debug_message = debug_message .. "[PING]"

    elseif rpc_type == "pong" then

      debug_message = debug_message .. "[PONG]"

    elseif rpc_type == "data" then

      --debug_message = string.format("%s[DATA][%s][%s]: ", debug_message, mod_name, rpc_name)
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

local rpc_chat_message
if VT1 then
  rpc_chat_message = function(member, channel_id, message_sender, message, localization_param,
                                  is_system_message, pop_chat, is_dev)
    RPC.rpc_chat_message(member, channel_id, message_sender, message, localization_param,
                          is_system_message, pop_chat, is_dev)
  end
else
  local _payload = {"","",""}
  rpc_chat_message = function(member, channel_id, _, rpc_data1, rpc_data2)
    _payload[1] = tostring(channel_id)
    _payload[2] = rpc_data1
    _payload[3] = rpc_data2
    Managers.mod:network_send(member, VT2_PORT_NUMBER, _payload)
  end
end

local function send_rpc_vmf_ping(peer_id)

  network_debug("ping", "sent", peer_id)
  rpc_chat_message(peer_id, 3, Network.peer_id(), "", "", false, true, false)
end

local function send_rpc_vmf_pong(peer_id)

  network_debug("pong", "sent", peer_id)
  rpc_chat_message(peer_id, 4, Network.peer_id(), _shared_mods_map, _shared_rpcs_map, false, true, false)
end

local function send_rpc_vmf_data(peer_id, mod_name, rpc_name, ...)

  local mod_number, rpc_number = convert_names_to_numbers(peer_id, mod_name, rpc_name)
  if mod_number then

    local rpc_info = cjson.encode({mod_number, rpc_number})
    local success, data = pcall(serialize_data, ...)
    if success then
      network_debug("data", "sent", peer_id, mod_name, rpc_name, data)
      rpc_chat_message(peer_id, 5, Network.peer_id(), rpc_info, data, false, true, false)
    end
  end
end

local function send_rpc_vmf_data_local(mod_name, rpc_name, ...)

  local mod = get_mod(mod_name)

  if mod:is_enabled() then
    network_debug("data", "local", nil, mod_name, rpc_name, {...})

    local error_prefix = "(local rpc) " .. tostring(rpc_name)
    vmf.safe_call_nr(mod, error_prefix, _rpc_callbacks[mod_name][rpc_name], Network.peer_id(), ...)
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.network_register = function (self, rpc_name, rpc_function)

  if _network_module_is_initialized then
    self:error("(network_register): you can't register new rpc after mod initialization")
    return
  end

  if vmf.check_wrong_argument_type(self, "network_register", "rpc_name", rpc_name, "string") or
     vmf.check_wrong_argument_type(self, "network_register", "rpc_function", rpc_function, "function") then
    return
  end

  _rpc_callbacks[self:get_name()] = _rpc_callbacks[self:get_name()] or {}

  _rpc_callbacks[self:get_name()][rpc_name] = rpc_function
end

-- recipient = "all", "local", "others", peer_id
VMFMod.network_send = function (self, rpc_name, recipient, ...)

  if not is_rpc_registered(self:get_name(), rpc_name) then

    self:error("(network_send): attempt to send non-registered rpc")
    return
  end

  if recipient == "all" then

    for peer_id, _ in pairs(_vmf_users) do
      send_rpc_vmf_data(peer_id, self:get_name(), rpc_name, ...)
    end

    send_rpc_vmf_data_local(self:get_name(), rpc_name, ...)

  elseif recipient == "others" then

    for peer_id, _ in pairs(_vmf_users) do
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

local function vmf_network_recv(sender, channel_id, rpc_data1, rpc_data2)
  if not _network_module_is_initialized then
    return
  end

  if channel_id == RPC_VMF_REQUEST_CHANNEL_ID then -- rpc_vmf_request

    network_debug("ping", "received", sender)

    send_rpc_vmf_pong(sender)

  elseif channel_id == RPC_VMF_RESPONCE_CHANNEL_ID then -- rpc_vmf_responce
    -- @TODO: maybe I should protect it from sending by the player who's not in the game?

    network_debug("pong", "received", sender)
    if _network_debug then
      vmf:info("[RECEIVED MODS TABLE]: " .. rpc_data1)
      vmf:info("[RECEIVED RPCS TABLE]: " .. rpc_data2)
    end

    pcall(function()

      local user_rpcs_dictionary = {}

      user_rpcs_dictionary[1] = cjson.decode(rpc_data1) -- mods
      user_rpcs_dictionary[2] = cjson.decode(rpc_data2) -- rpcs

      _vmf_users[sender] = user_rpcs_dictionary

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

  elseif channel_id == RPC_VMF_UNKNOWN_CHANNEL_ID then
    local mod_number, rpc_number = unpack(cjson.decode(rpc_data1))

    local mod_name, rpc_name = convert_numbers_to_names(mod_number, rpc_number)
    if mod_name and get_mod(mod_name):is_enabled() then

      network_debug("data", "received", sender, mod_name, rpc_name, rpc_data2)

      -- can be error in both callback_function() and deserialize_data()
      local error_prefix = "(network) " .. tostring(rpc_name)
      vmf.safe_call_nr(
        get_mod(mod_name),
        error_prefix,
        function() _rpc_callbacks[mod_name][rpc_name](sender, deserialize_data(rpc_data2)) end
      )
    end
  end
end

if VT1 then
  vmf:hook("ChatManager", "rpc_chat_message",
          function(func, self, sender, channel_id, message_sender, arg1, arg2, ...)
    if channel_id == VERMINTIDE_CHANNEL_ID then
      func(self, sender, channel_id, message_sender, arg1, arg2, ...)
    else
      vmf_network_recv(sender, channel_id, arg1, arg2)
    end
  end)
end
-- VT2 uses the networking API provided by the ModManager.

vmf:hook(PlayerManager, "add_remote_player", function (func, self, peer_id, player_controlled, ...)

  if player_controlled then
    send_rpc_vmf_ping(peer_id)
  end

  return func(self, peer_id, player_controlled, ...)
end)

vmf:hook(PlayerManager, "remove_player", function (func, self, peer_id, ...)

  if _vmf_users[peer_id] then

    -- make sure it's not the bot
    for _, player in pairs(Managers.player:human_players()) do
      if player.peer_id == peer_id then

        vmf:info("Removed %s from the VMF users list.", peer_id)

        -- event
        for mod_name, _ in pairs(_vmf_users[peer_id][1]) do
          local mod = get_mod(mod_name)
          if mod then
            vmf.mod_user_left_the_game(mod, player)
          end
        end

        _vmf_users[peer_id] = nil
        break
      end
    end
  end

  func(self, peer_id, ...)
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.create_network_dictionary = function()

  _shared_mods_map = {}
  _shared_rpcs_map = {}

  local i = 0
  for mod_name, mod_rpcs in pairs(_rpc_callbacks) do
    i = i + 1

    _shared_mods_map[mod_name] = i
    _local_mods_map[i] = mod_name

    _shared_rpcs_map[i] = {}
    _local_rpcs_map[i] = {}

    local j = 0
    for rpc_name, _ in pairs(mod_rpcs) do
      j = j + 1

      _shared_rpcs_map[i][rpc_name] = j
      _local_rpcs_map[i][j] = rpc_name
    end
  end

  _shared_mods_map = cjson.encode(_shared_mods_map)
  _shared_rpcs_map = cjson.encode(_shared_rpcs_map)

  if not VT1 then
    Managers.mod:network_bind(VT2_PORT_NUMBER, function(sender, payload)
      vmf_network_recv(sender, tonumber(payload[1]), payload[2], payload[3])
    end)
  end

  _network_module_is_initialized = true
end

vmf.network_unload = function()
  if not VT1 then
    Managers.mod:network_unbind(VT2_PORT_NUMBER)
  end
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

vmf.load_network_settings = function()
  _network_debug = vmf:get("developer_mode") and vmf:get("show_network_debug_info")
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_network_settings()
