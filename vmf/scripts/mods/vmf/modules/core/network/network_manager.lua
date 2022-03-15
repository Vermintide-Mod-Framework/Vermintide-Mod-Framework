local vmf = get_mod("VMF")

-- @TODO: remove when everything is proven safe
vmf:pcall(function()

local _INNER_RPC_MANAGER = vmf:dofile("scripts/mods/vmf/modules/core/network/network_rpc_inner")
local _MODS_RPC_MANAGER  = vmf:dofile("scripts/mods/vmf/modules/core/network/network_rpc_mods")

local ERRORS = {
  PREFIX = {
    rpc_sending_failure = "[Network] Sending %s RPC",
  }
}

-- =============================================================================
-- Local functions
-- =============================================================================

-- -----------------------------------------------------------------------------
-- RPC sending
-- -----------------------------------------------------------------------------

local function send_rpc_safe(recipient, rpc_type, ...)
  vmf.safe_call_nr(vmf, {ERRORS.PREFIX.rpc_sending_failure, rpc_type}, vmf.rpc_send, recipient, rpc_type, ...)
end


local function send_rpc_vmf_ping(peer_id)
  send_rpc_safe(peer_id, "VMF_PING")
end


local function send_rpc_vmf_pong(peer_id, on_reload)
  local mod_and_rpc_ids = _MODS_RPC_MANAGER.get_own_mod_and_rpc_ids();
  send_rpc_safe(peer_id, "VMF_PONG", on_reload, mod_and_rpc_ids)
end


local function send_rpc_vmf_reload()
  send_rpc_safe("others", "VMF_RELOAD")
end

-- -----------------------------------------------------------------------------
-- RPC callbacks
-- -----------------------------------------------------------------------------

local function callback_rpc_ping(peer_id)
  send_rpc_vmf_pong(peer_id, false)
end


local function callback_rpc_pong(peer_id, on_reload, mod_and_rpc_ids)
  _INNER_RPC_MANAGER.add_peer(peer_id)
  _MODS_RPC_MANAGER.add_peer(peer_id, on_reload, mod_and_rpc_ids)
end


local function callback_rpc_reload(peer_id)
  _INNER_RPC_MANAGER.remove_peer(peer_id)
  _MODS_RPC_MANAGER.remove_peer(peer_id, true)
end


local function callback_rpc_mod_rpc(...)
  _MODS_RPC_MANAGER.execute_mod_rpc_callback(...)
end

-- =============================================================================
-- Hooks
-- =============================================================================

vmf:hook(PlayerManager, "add_remote_player", function (func, self, peer_id, player_controlled, ...)
  if player_controlled then
    send_rpc_vmf_ping(peer_id)
  end
  return func(self, peer_id, player_controlled, ...)
end)


vmf:hook(PlayerManager, "remove_player", function (func, self, peer_id, local_player_id)
  local player = self:player_from_peer_id(peer_id, local_player_id)
  if player and not (player.bot_player or player.local_player) then
    _INNER_RPC_MANAGER.remove_peer(peer_id)
    _MODS_RPC_MANAGER.remove_peer(peer_id, false)
  end
  return func(self, peer_id, local_player_id)
end)

-- =============================================================================
-- VMF internal functions
-- =============================================================================

function vmf.network_initialize()
  _INNER_RPC_MANAGER.initialize()
  _MODS_RPC_MANAGER.initialize()

  -- Sync network data with other VMF users if VMF was reloaded in the middle
  -- of the game.
  local player_manager = Managers.player
  if not player_manager then
    return
  end

  -- `Network.peer_id()` throws an error when called at game startup since
  -- Stingray network module is not yet initialized.
  if pcall(Network.peer_id) then
    local local_peer_id = Network.peer_id()
    for _, player in pairs(player_manager:human_players()) do
      if player.peer_id ~= local_peer_id then
        send_rpc_vmf_ping(player.peer_id)
        send_rpc_vmf_pong(player.peer_id, true)
      end
    end
  end
end


function vmf.network_shutdown()
  send_rpc_vmf_reload()
  -- Shutting down inner RPC manager ensures no network communication between
  -- VMF clients till mods are reloaded. So there's no need to shut down other
  -- modules.
  _INNER_RPC_MANAGER.shutdown()
end


function vmf.network_update()
  -- * update pending clients inside 'network_game_alteration_sync'
end


-- [THROWS ERRORS]
function vmf.rpc_send(recipient, rpc_type, ...)
  _INNER_RPC_MANAGER.rpc_send(recipient, rpc_type, ...) -- [throws errors]
end

-- =============================================================================
-- Script
-- =============================================================================

_INNER_RPC_MANAGER.register_inner_rpc_callbacks({
  VMF_PING   = callback_rpc_ping,
  VMF_PONG   = callback_rpc_pong,
  VMF_RELOAD = callback_rpc_reload,
  MOD_RPC    = callback_rpc_mod_rpc,
})

end)
