local dmf = get_mod("DMF")

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function broadcast_message(message, channel_tag)
  local chat_manager = Managers.chat

  if chat_manager and channel_tag then
    for channel_handle, channel in pairs(chat_manager:connected_chat_channels()) do
      if channel and channel.tag == channel_tag then
        chat_manager:send_channel_message(channel_handle, tostring(message))
      end
    end
  end
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Broadcasts the message to all players in a lobby.
  * message [string]: message to broadcast
  * channel_tag [string]: tag of target chat channel
--]]
function DMFMod:chat_broadcast(message, channel_tag)
  broadcast_message(message, channel_tag)
end

--[[
  Sends the message to a selected player. Only the host can use this method.
  * peer_id [peer_id]: peer_id of the player who will recieve the message (can't be host's peer_id)
  * message [string] : message to send
--]]
function DMFMod:chat_whisper(peer_id, message)
  -- @TODO: Rewrite for Darktide
  dmf:notify("Chat whisper is not yet implemented!")
end
