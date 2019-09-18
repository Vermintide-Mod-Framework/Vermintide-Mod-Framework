local vmf = get_mod("VMF")

-- VMF inner RPC implementation is based on Vermintide chat message RPC which
-- has `channel_id` argument. If this argument is not equal '1', this RPC
-- is ignored by the game which is perfect for implementing custom RPC behavior
-- for different channels.
-- Reserverd channels:
-- [1] - Vermintide chat channel
-- [2] - Old-VMF / QoL rpc channel in VT1
local INNER_RPC_DICTIONARY = {
  [3] = "VMF_PING",   -- Request for VMF data [Plus check if VMF user]
  [4] = "VMF_PONG",   -- Response with VMF data [Is indeed VMF user]
  [5] = "VMF_RELOAD",
  [6] = "MOD_RPC",    -- Custom mod RPC with serialized arguments
  [7] = "MOD_TOGGLE",

  VMF_PING   = 3,
  VMF_PONG   = 4,
  VMF_RELOAD = 5,
  MOD_RPC    = 6,
  MOD_TOGGLE = 7,
}

-- Callback functions for different VMF inner RPCs.
-- Callbacks have to be safe to execute.
local INNER_RPC_CALLBACKS

-- Steam user ID == peer_id. Cache it to avoid extra calls.
local LOCAL_PEER_ID = Steam.user_id()

-- peer_ids of other VMF clients who successfully exchanged their VMF network
-- data with local client.
local _other_peers = {}

local _module_is_initialized = false

local ERRORS = {
  THROWABLE = {
    serialization_failure = "RPC data serialization failed. %s",
    local_rpc_execution_failure = "local RPC execution failed. %s",
    rpc_sending_failure = "failed sending %s to '%s'. %s. Inspect logs for more info.",
  }
}

local WARNINGS = {
  incoming_rpc_when_not_initialized = "[Network] Received inner VMF RPC '%s' from peer %s while Inner RPC module is " ..
                                       "inactive. Ignoring it.",
}

-- =============================================================================
-- Local functions
-- =============================================================================

-- [THROWS ERRORS]
local function serialize_data(...)
  local success, result = pcall(cjson.encode, {...})
  if success then
    return cjson.encode({...})
  else
    vmf.throw_error(ERRORS.THROWABLE.serialization_failure, result)
  end
end


-- It is assumed that this function always gets correct serialized data
-- and never throws errors.
local function deserialize_data(data)
  return unpack(cjson.decode(data))
end


-- [THROWS ERRORS]
local function send_rpc(peer_id, rpc_id, rpc_data)
  local success, error
  if VT1 then
    success, error = pcall(RPC.rpc_chat_message, peer_id, rpc_id, "", rpc_data, "", true, true, true)
  else
    success, error = pcall(RPC.rpc_chat_message, peer_id, rpc_id, "", 0, rpc_data, {}, true, true, true, true, true)
  end
  if not success then
    vmf:dump(deserialize_data(rpc_data), "RPC DATA", 3)
    vmf.throw_error(ERRORS.THROWABLE.rpc_sending_failure, INNER_RPC_DICTIONARY[rpc_id], peer_id, error)
  end
end


-- [THROWS ERRORS]
-- '...' is used instead of 'rpc_data' to skip serialization-deserialization
-- step which is not necessary for local RPCs.
local function send_rpc_local(rpc_type, ...)
  -- @TODO: Remove pcall, error message, [T...] when everything is proven safe.
  local success, error = pcall(INNER_RPC_CALLBACKS[rpc_type], LOCAL_PEER_ID, ...)
  if not success then
    vmf.throw_error(ERRORS.THROWABLE.local_rpc_execution_failure, error)
  end
end

-- =============================================================================
-- Hooks
-- =============================================================================

vmf:hook("ChatManager", "rpc_chat_message", function(func, self, sender, channel_id, message_sender, arg1, arg2, ...)
  -- Channel IDs 3-16 are reserverd for VMF needs.
  if channel_id < 3 or channel_id > 16 then
    return func(self, sender, channel_id, message_sender, arg1, arg2, ...)
  end

  if not _module_is_initialized then
    vmf:warning(WARNINGS.incoming_rpc_when_not_initialized, INNER_RPC_DICTIONARY[channel_id], sender)
    return
  end

  local rpc_data     = VT1 and arg1 or arg2
  local rpc_type     = INNER_RPC_DICTIONARY[channel_id]
  local rpc_callback = INNER_RPC_CALLBACKS[rpc_type]

  if rpc_callback then
    -- @TODO: Remove pcall when everything is proven safe.
    vmf:pcall(function()
      rpc_callback(sender, deserialize_data(rpc_data))
    end)
  end
end)

-- =============================================================================
-- Return
-- =============================================================================

return {
  initialize = function()
    _module_is_initialized = true
  end,
  shutdown = function()
    _module_is_initialized = false
  end,


  register_inner_rpc_callbacks = function(callbacks)
    INNER_RPC_CALLBACKS = callbacks
  end,


  add_peer = function(peer_id)
    _other_peers[peer_id] = true
    vmf:info("Added %s to the VMF users list.", peer_id)
  end,
  remove_peer = function(peer_id)
    _other_peers[peer_id] = nil
    vmf:info("Removed %s from the VMF users list.", peer_id)
  end,

  -- [THROWS ERRORS]
  -- Allowed 'recipient' values:
  -- * string: "all", "others", "local", peer_id
  -- * table: {["local"] = true, [peer_id1] = true, [peer_id2] = true, ...}
  -- It is assumed that 'recipient' is always correct. If 'recipient' is a table:
  -- * It should not contain local peer_id. (string "local" should be used instead)
  -- * All peer_ids should be valid (existing).
  -- * 'false' should not be used for values. It's either 'true' or 'nil'.
  rpc_send = function(recipient, rpc_type, ...)
    local rpc_send_locally
    local rpc_other_recipients

    -- recipient == "all"/"others"/"local"/peer_id
    if type(recipient) == "string" then
      if recipient == "all" then
        rpc_send_locally = true
        rpc_other_recipients = _other_peers
      elseif recipient == "others" then
        rpc_other_recipients = _other_peers
      elseif recipient == "local"then
        rpc_send_locally = true
      else
        rpc_other_recipients = {[recipient] = true}
      end

    -- recipient == {peer_id1 = true, peer_id2 = true, ...}
    else
      if recipient["local"] then
        recipient["local"] = nil
        rpc_send_locally = true
      end
      rpc_other_recipients = recipient
    end

    if rpc_send_locally then
      send_rpc_local(rpc_type, ...) -- [throws errors]
    end

    if next(rpc_other_recipients) then
      local rpc_id   = INNER_RPC_DICTIONARY[rpc_type]
      local rpc_data = serialize_data(...) -- [throws errors]
      for peer_id in pairs(rpc_other_recipients) do
        send_rpc(peer_id, rpc_id, rpc_data) -- [throws errors]
      end
    end
  end
}
