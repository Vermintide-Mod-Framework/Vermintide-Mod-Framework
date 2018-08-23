local vmf = get_mod("VMF")

-- Constants used as parameters in some 'chat_manager's functions
local CHANNEL_ID = 1
local MESSAGE_SENDER = ""
local LOCAL_PLAYER_ID = 0 -- VT2 only
local LOCALIZATION_PARAM = ""
local IS_SYSTEM_MESSAGE = false
local POP_CHAT = true
local IS_DEV = true

-- @TODO: remove it after VT2 1.2 release
local OLD_RPC_CHAT_MESSAGE = VT1 or (tonumber(script_data.settings.content_revision) <= 120239)

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function send_system_message(peer_id, message)
  if OLD_RPC_CHAT_MESSAGE then
    RPC.rpc_chat_message(peer_id, CHANNEL_ID, MESSAGE_SENDER, message, LOCALIZATION_PARAM, IS_SYSTEM_MESSAGE, POP_CHAT,
                          IS_DEV)
  else
    RPC.rpc_chat_message(peer_id, CHANNEL_ID, MESSAGE_SENDER, LOCAL_PLAYER_ID, message, LOCALIZATION_PARAM,
                          IS_SYSTEM_MESSAGE, POP_CHAT, IS_DEV)
  end
end

local function add_system_message_to_chat(chat_manager, message)
  if OLD_RPC_CHAT_MESSAGE then
    chat_manager:_add_message_to_list(CHANNEL_ID, MESSAGE_SENDER, message, IS_SYSTEM_MESSAGE, POP_CHAT, IS_DEV)
  else
    chat_manager:_add_message_to_list(CHANNEL_ID, MESSAGE_SENDER, LOCAL_PLAYER_ID, message, IS_SYSTEM_MESSAGE, POP_CHAT,
                                       IS_DEV)
  end
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Broadcasts the message to all players in a lobby.
  * message [string]: message to broadcast
--]]
function VMFMod:chat_broadcast(message)
  local chat = Managers.chat
  if chat and chat:has_channel(1) then
    if chat.is_server then
      local members = chat:channel_members(CHANNEL_ID)
      local my_peer_id = chat.my_peer_id
      for _, member_peer_id in pairs(members) do
        if member_peer_id ~= my_peer_id then
          send_system_message(member_peer_id, message)
        end
      end
    else
      local host_peer_id = chat.host_peer_id
      if host_peer_id then
        send_system_message(host_peer_id, message)
      end
    end
    add_system_message_to_chat(chat, message)
  end
end

--[[
  Sends the message to a selected player. Only the host can use this method.
  * peer_id [peer_id]: peer_id of the player who will recieve the message (can't be host's peer_id)
  * message [string] : message to send
--]]
function VMFMod:chat_whisper(peer_id, message)
  local chat = Managers.chat
  if chat and chat:has_channel(1) and chat.is_server and peer_id ~= chat.host_peer_id then
    send_system_message(peer_id, message)
  end
end