local vmf = get_mod("VMF")

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.chat_broadcast = function(self, message)

  local chat = Managers.chat
  if chat and chat:has_channel(1) then
    local channel_id = 1
    local my_peer_id = chat.my_peer_id
    local localization_param = ""
    local is_system_message = true
    local pop_chat = true
    local is_dev = false

    if chat.is_server then
      local members = chat:channel_members(channel_id)

      for _, member in pairs(members) do
        if member ~= my_peer_id then
          RPC.rpc_chat_message(member, channel_id, my_peer_id, message, localization_param, is_system_message, pop_chat, is_dev)
        end
      end
    else
      local host_peer_id = chat.host_peer_id

      if host_peer_id then
        RPC.rpc_chat_message(host_peer_id, channel_id, my_peer_id, message, localization_param, is_system_message, pop_chat, is_dev)
      end
    end

    message = Localize(message)

    chat:_add_message_to_list(channel_id, "SYSTEM", message, is_system_message, pop_chat, is_dev)
  end
end

VMFMod.chat_whisper = function(self, peer_id, message)

  local chat = Managers.chat
  if chat and chat:has_channel(1) and chat.is_server then
    local channel_id = 1
    local my_peer_id = chat.my_peer_id
    local localization_param = ""
    local is_system_message = true
    local pop_chat = true
    local is_dev = false

    RPC.rpc_chat_message(peer_id, channel_id, my_peer_id, message, localization_param, is_system_message, pop_chat, is_dev)
  end
end