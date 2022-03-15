local vmf = get_mod("VMF")

-- Steam user ID == peer_id. Cache it to avoid extra calls.
local LOCAL_PEER_ID = Steam.user_id()

-- Table for storing mod RPC callbacks. Is used for:
-- * Safety checks.
-- * Generating encode/decode dictionaries.
local _rpc_callbacks = {}
--    _rpc_callbacks[mod][rpc_name] = rpc_callback

-- Instead of sending plain mod name and RPC name to clients every time some RPC
-- needs to be executed, this module uses pair of short unique numbers (IDs)
-- for RPC identification. These IDs are generated once all mods are loaded and
-- do not change unless VMF is reloaded. It is done to save bandwidth.
-- Initially, only mod name was used as a mod unique identifier, but it could
-- lead to weird collisions if 2 VMF clients had 2 different mods with the same
-- name so it was decided to use workshop_id as well.
-- Generated IDs are unique and will differ for every VMF client so they have
-- to be exchanged between clients to be able to communicate with each other.
local _own_mod_and_rpc_ids
--    _own_mod_and_rpc_ids.mod_ids[mod_id] = {mod_name, mod_workshop_id}
--    _own_mod_and_rpc_ids.rpc_ids[mod_id][rpc_id] = rpc_name

-- Dictionaries are used to quickly replace outgoing RPCs info with the pair of
-- short IDs (encode dictionary) and to quickly retrieve original RPC info for
-- incoming RPCs (decode dictionary).
-- * Encode dictionary is generated only locally to encode all outgoing RPCs.
-- * Decode dictionary is generated for every VMF user once they send their IDs
--   to decode incoming RPCs.
local _rpc_encode_dictionary
--    _rpc_encode_dictionary[mod][rpc_name] = {mod_id, rpc_id}
local _rpc_decode_dictionaries = {}
--    _rpc_decode_dictionaries[peer_id][mod_id][rpc_id] = {mod=, name=, callback=}

-- Keeps track of users of every network mod, excluding local player.
local _mods_users_list = {}
--    _mods_users_list[mod][peer_id] = true

local _module_is_initialized = false

local ERRORS = {
  REGULAR = {
    rpc_registering_too_late = "[Network] (network_register) '%s': RPCs can not be registered after all mods " ..
                                "are initialized.",
    rpc_registering_duplicate = "[Network] (network_register) '%s': RPC with the same name is already registered.",
    rpc_sending_too_early = "[Network] (network_send) '%s': RPCs can not be sent until all mods are loaded.",
    non_registered_rpc = "[Network] (network_send): attempt to send non-registered RPC '%s'.",
    incorrect_peer_id = "[Network] (network_send) '%s': attempt to send RPC to the player with peer_id '%s'" ..
                         "who does not have this mod installed.",
  },
  PREFIX = {
    sending_mod_rpc = "[Network] (network_send) Sending '%s' RPC to '%s'",
    executing_rpc_callback = "[Network] Executing '%s' RPC callback sent by '%s'"
  }
}

-- =============================================================================
-- Local functions
-- =============================================================================

local function is_rpc_registered(mod, rpc_name)
  local mod_callbacks = _rpc_callbacks[mod]
  return mod_callbacks and mod_callbacks[rpc_name]
end


local function generate_own_mod_and_rpc_ids()
  local mod_ids = {}
  local rpc_ids = {}

  local mod_id = 0
  for mod, mod_rpcs_data in pairs(_rpc_callbacks) do
    mod_id = mod_id + 1

    mod_ids[mod_id] = {mod:get_name(), mod:get_internal_data("workshop_id")}
    rpc_ids[mod_id] = {}

    local rpc_id = 0
    for rpc_name in pairs(mod_rpcs_data) do
      rpc_id = rpc_id + 1

      rpc_ids[mod_id][rpc_id] = rpc_name
    end
  end

  _own_mod_and_rpc_ids = {
    mod_ids = mod_ids,
    rpc_ids = rpc_ids
  }
end


-- * Generate encode and decode dictionaries for provided peer_id based on their
--   mod and rpc IDs.
--   - After generation is done, save dictionaries. Encode dictionary is saved
--   only for local player.
--   - Entries inside dictionaries are created only for locally existing mods.
-- * Populate `_mods_users_list`.
-- * Fire 'mod.on_user_joined' event for all locally existing mods if peer_id is
--   not local.
local function initialize_peer(peer_id, mod_and_rpc_ids, on_reload)
  local is_local_peer_id = peer_id == LOCAL_PEER_ID

  local mod_ids = mod_and_rpc_ids.mod_ids
  local rpc_ids = mod_and_rpc_ids.rpc_ids

  local encode_dictionary = {}
  local decode_dictionary = {}

  -- Populate dictionaries and `_mods_users_list`.
  for mod_id, mod_data in ipairs(mod_ids) do
    local mod = get_mod(mod_data[1])
    -- Make sure this mod exists locally and this is the exact same mod.
    -- And only then create entry in dictionaries.
    if mod and mod:get_internal_data("workshop_id") == mod_data[2] then
      if not is_local_peer_id then
        _mods_users_list[mod][peer_id] = true
      end

      encode_dictionary[mod]    = {}
      decode_dictionary[mod_id] = {}
      for rpc_id, rpc_name in ipairs(rpc_ids[mod_id]) do
        encode_dictionary[mod][rpc_name]  = {mod_id, rpc_id}
        decode_dictionary[mod_id][rpc_id] = {mod = mod, name = rpc_name, callback = _rpc_callbacks[mod][rpc_name]}
      end
    end
  end

  -- Save generated decode dictionary.
  _rpc_decode_dictionaries[peer_id] = decode_dictionary
  -- Save generated encode dictionary, but only for local player.
  if is_local_peer_id then
    _rpc_encode_dictionary = encode_dictionary
  -- Fire 'mod.on_user_joined' events for all mods remote and local players
  -- have in common.
  else
    local player = Managers.player:player_from_peer_id(peer_id)
    for mod, mod_users in pairs(_mods_users_list) do
      if mod_users[peer_id] then
        vmf.mod_user_joined_the_game(mod, player, on_reload)
      end
    end
  end
end


-- * Delete decode dictionary for given peer_id.
-- * Remove all `_mods_users_list` entries for this peer_id and fire
--   `mod.on_user_left` event for all the mods they had.
-- This function is never called for local player, because local player's
-- generated ids are persistent.
local function remove_peer(peer_id, on_reload)
  _rpc_decode_dictionaries[peer_id] = nil
  local player = Managers.player:player_from_peer_id(peer_id)
  for mod, mod_users in pairs(_mods_users_list) do
    if mod_users[peer_id] then
      mod_users[peer_id] = nil
      vmf.mod_user_left_the_game(mod, player, on_reload)
    end
  end
end

-- ============================================================================
-- VMFMod
-- ============================================================================

-- Register a new remote procedure call.
-- * rpc_name     [string]  : RPC name
-- * rpc_callback [function]: RPC callback
function VMFMod:network_register(rpc_name, rpc_callback)
  if vmf.check_wrong_argument_type(self, "network_register", "rpc_name", rpc_name, "string")
  or vmf.check_wrong_argument_type(self, "network_register", "rpc_callback", rpc_callback, "function")
  then return end

  if _module_is_initialized then
    self:error(ERRORS.REGULAR.rpc_registering_too_late, rpc_name)
    return
  end

  _rpc_callbacks[self] = _rpc_callbacks[self] or {}
  if _rpc_callbacks[self][rpc_name] then
    self:error(ERRORS.REGULAR.rpc_registering_duplicate, rpc_name)
  else
    _rpc_callbacks[self][rpc_name] = rpc_callback
    if not _mods_users_list[self] then
      _mods_users_list[self] = {}
    end
  end
end


-- Execute a remote procedure call locally or on a remote peer.
-- * rpc_name  [string]          : RPC name
-- * recipient [string/peer_id]  : RPC recipient; valid values: "all", "local", "others", peer_id
-- * ...       [any serializable]: Serializable RPC arguments
function VMFMod:network_send(rpc_name, recipient, ...)
  if not _module_is_initialized then
    self:error(ERRORS.REGULAR.rpc_sending_too_early, rpc_name)
    return
  end

  if not is_rpc_registered(self, rpc_name) then
    self:error(ERRORS.REGULAR.non_registered_rpc, rpc_name)
    return
  end

  local recipient_original = recipient

  if recipient == "all" then
    recipient = table.clone(_mods_users_list[self])
    recipient["local"] = true
  elseif recipient == "others" then
    recipient = table.clone(_mods_users_list[self])
  elseif recipient == "local" or recipient == LOCAL_PEER_ID then
    recipient = {["local"] = true}
  elseif _mods_users_list[self][recipient] then
    recipient = {[recipient] = true}
  else
    self:error(ERRORS.REGULAR.incorrect_peer_id, rpc_name, recipient)
    return
  end

  local mod_id, rpc_id = unpack(_rpc_encode_dictionary[self][rpc_name])
  vmf.safe_call_nr(self, {ERRORS.PREFIX.sending_mod_rpc, rpc_name, recipient_original},
                          vmf.rpc_send, recipient, "MOD_RPC", mod_id, rpc_id, {...})
end


-- Returns an array-like table containing peer_ids of all currently connected
-- mod users excluding local user. Returns nil, if called by a non-network mod.
function VMFMod:get_connections()
  if _mods_users_list[self] then
    local mod_users = {}
    for peer_id in pairs(_mods_users_list[self]) do
      table.insert(mod_users, peer_id)
    end
    return mod_users
  end
end


-- Returns a boolean value indicating if the player with passed peer_id has
-- this mod installed and is connected. Returns nil, if called by a non-network
-- mod.
function VMFMod:is_connected(peer_id)
  if _mods_users_list[self] then
    return not not _mods_users_list[self][peer_id]
  end
end

-- ============================================================================
-- Return
-- ============================================================================

return {
  initialize = function()
    generate_own_mod_and_rpc_ids()
    initialize_peer(LOCAL_PEER_ID, _own_mod_and_rpc_ids)
    _module_is_initialized = true
  end,


  add_peer = function(peer_id, on_reload, mod_and_rpc_ids)
    initialize_peer(peer_id, mod_and_rpc_ids, on_reload)
  end,


  remove_peer = function(peer_id, on_reload)
    remove_peer(peer_id, on_reload)
  end,


  get_own_mod_and_rpc_ids = function()
    return _own_mod_and_rpc_ids
  end,


  -- Executes RPC callback for recieved mod RPC. It is assumed that IDs and
  -- RPC data are always valid.
  execute_mod_rpc_callback = function(sender, mod_id, rpc_id, rpc_data)
    local args_number = #rpc_data
    -- When serializing array-like tables `cjson` module replaces nils with
    -- `userdata [nullptr (deleted)]`. Change it back to nil. It makes sense
    -- to do this only for the top level of received table which stores packed
    -- arguments. Going deeper could be pretty costly so it's on the modder to
    -- avoid nils in array-like tables or to correctly detect userdata fields.
    for i, v in ipairs(rpc_data) do
      if type(v) == "userdata" then
        rpc_data[i] = nil
      end
    end

    local rpc_info     = _rpc_decode_dictionaries[sender][mod_id][rpc_id]
    local mod          = rpc_info.mod
    local rpc_name     = rpc_info.name
    local rpc_callback = rpc_info.callback
    vmf.safe_call_nr(mod, {ERRORS.PREFIX.executing_rpc_callback, rpc_name, sender},
                           rpc_callback, sender, unpack(rpc_data, 1, args_number))
  end,
}
