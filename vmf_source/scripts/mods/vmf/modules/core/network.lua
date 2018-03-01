-- @TODO: when recieving maps of other users, check for consistency
local vmf = get_mod("VMF")

local _VMF_USERS = {}
local _RPC_CALLBACKS = {}

local _LOCAL_MODS_MAP = {}
local _LOCAL_RPCS_MAP = {}

local _SHARED_MODS_MAP = ""
local _SHARED_RPCS_MAP = ""

local _NETWORK_MODULE_IS_INITIALIZED = false

-- converting

local function convert_names_to_numbers(user_rpcs_dictionary, mod_name, rpc_name)

  local mod_number = user_rpcs_dictionary[1][mod_name]
  if mod_number then

    local rpc_number = user_rpcs_dictionary[2][mod_number][rpc_name]
    if rpc_number then

      return mod_number, rpc_number
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

-- serialization

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

-- rpcs

local function send_rpc_vmf_ping(peer_id)

  RPC.rpc_chat_message(peer_id, 3, Network.peer_id(), "", "", false, true, false)

  vmf:info("[NETWORK][SENT PING] %s", peer_id) -- @DEBUG:
end

local function send_rpc_vmf_pong(peer_id)

  RPC.rpc_chat_message(peer_id, 4, Network.peer_id(), _SHARED_MODS_MAP, _SHARED_RPCS_MAP, false, true, false)

  vmf:info("[NETWORK][SENT PONG] %s", peer_id) -- @DEBUG:
end

local function send_rpc_vmf_data(peer_id, mod_number, rpc_number, ...)

  local rpc_info = cjson.encode({mod_number, rpc_number})
  local success, data = pcall(serialize_data, ...)
  if success then
    RPC.rpc_chat_message(peer_id, 5, Network.peer_id(), rpc_info, data, false, true, false)
    vmf:info("[NETWORK][SENT RPC] '%s' [%s]: %s", _VMF_USERS[peer_id][mod_number][rpc_number], peer_id, data) -- @DEBUG:
  end
end

local function send_rpc_vmf_data_local(mod_name, rpc_name, ...)

  local success, error_message = pcall(_RPC_CALLBACKS[mod_name][rpc_name], ...)

  if not success then
    get_mod(mod_name):error("(local rpc) in rpc '%s': %s", rpc_name, error_message)

    local success, data = pcall(serialize_data, ...) -- @DEBUG:
    if success then -- @DEBUG:
      vmf:info("[NETWORK][LOCAL RPC] '%s': %s", rpc_name, data) -- @DEBUG:
    end -- @DEBUG:
  end
end

local function is_rpc_registered(mod_name, rpc_name)

  local success = pcall(function() return _RPC_CALLBACKS[mod_name][rpc_name] end)
  return success
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.rpc_register = function (self, rpc_name, rpc_function)

  if _NETWORK_MODULE_IS_INITIALIZED then
    self:error("(rpc_register): you can't register new rpc after mod initialization")
    return
  end

  if type(rpc_name) ~= "string" then
    self:error("(rpc_register): rpc_name should be the string, not %s", type(rpc_name))
    return
  end

  if type(rpc_function) ~= "function" then
    self:error("(rpc_register): rpc_function should be the function, not %s", type(rpc_name))
    return
  end

  _RPC_CALLBACKS[self:get_name()] = _RPC_CALLBACKS[self:get_name()] or {}

  _RPC_CALLBACKS[self:get_name()][rpc_name] = rpc_function
end

-- recipient = "all", "local", "others", peer_id
VMFMod.rpc_send = function (self, recipient, rpc_name, ...)

  if not is_rpc_registered(self:get_name(), rpc_name) then

    self:error("(rpc_send): attempt to send non-registered rpc")
    return
  end

  if recipient == "all" then

    for peer_id, user_rpcs_dictionary in pairs(_VMF_USERS) do

      local mod_number, rpc_number = convert_names_to_numbers(user_rpcs_dictionary, self:get_name(), rpc_name)
      if mod_number then

        send_rpc_vmf_data(peer_id, mod_number, rpc_number, ...)
      end
    end

    send_rpc_vmf_data_local(self:get_name(), rpc_name, ...)

  elseif recipient == "others" then

    for peer_id, user_rpcs_dictionary in pairs(_VMF_USERS) do

      local mod_number, rpc_number = convert_names_to_numbers(user_rpcs_dictionary, self:get_name(), rpc_name)
      if mod_number then

        send_rpc_vmf_data(peer_id, mod_number, rpc_number, ...)
      end
    end

  elseif recipient == "local" then

    send_rpc_vmf_data_local(self:get_name(), rpc_name, ...)

  else -- recipient == peer_id

    local user_rpcs_dictionary = _VMF_USERS[recipient]
    if user_rpcs_dictionary then

      local mod_number, rpc_number = convert_names_to_numbers(user_rpcs_dictionary, self:get_name(), rpc_name)
      if mod_number then

        send_rpc_vmf_data(recipient, mod_number, rpc_number, ...)
      end
    end
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("ChatManager.rpc_chat_message", function(func, self, sender, channel_id, message_sender, message, localization_param, ...)

  if not _NETWORK_MODULE_IS_INITIALIZED then
    return
  end

  if channel_id == 1 then

    func(self, sender, channel_id, message_sender, message, localization_param, ...)
  else

    if channel_id == 3 then -- rpc_vmf_request

      send_rpc_vmf_pong(sender)

      vmf:info("[NETWORK][RECIEVED PING] %s", sender) -- @DEBUG:

    elseif channel_id == 4 then -- rpc_vmf_responce

      _VMF_USERS[sender] = {}

      _VMF_USERS[sender][1] = cjson.decode(message) -- mods
      _VMF_USERS[sender][2] = cjson.decode(localization_param) -- rpcs

      vmf:info("[NETWORK][RECIEVED PONG] %s", sender) -- @DEBUG:
      vmf:info("[RECEIVED MODS TABLE]: " .. message) -- @DEBUG:
      vmf:info("[RECEIVED RPCS TABLE]: " .. localization_param) -- @DEBUG:
      vmf:info("Added %s to the VMF users list.", sender)

    elseif channel_id == 5 then

      local mod_number, rpc_number = unpack(cjson.decode(message))

      local mod_name, rpc_name = convert_numbers_to_names(mod_number, rpc_number)
      if mod_name then

        vmf:info("[NETWORK][RECEIVED RPC] '%s.%s' [%s]: %s", mod_name, rpc_name, sender, message) -- @DEBUG:

        -- can be error in both callback_function() and deserialize_data()
        local success, error_message = pcall(function() _RPC_CALLBACKS[mod_name][rpc_name](deserialize_data(localization_param)) end)
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

        _VMF_USERS[peer_id] = nil
        vmf:info("Removed %s from the VMF users list.", peer_id)
        break
      end
    end
  end

  func(self, peer_id, local_player_id)
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

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

  for _, player in pairs(Managers.player:human_players()) do
    if player.peer_id ~= Network.peer_id() then

      send_rpc_vmf_ping(player.peer_id)
      send_rpc_vmf_pong(player.peer_id)
    end
  end
end