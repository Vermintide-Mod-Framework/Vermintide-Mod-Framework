local vmf = get_mod("VMF")

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("ChatManager.register_channel", function (func, self, channel_id, members_func)

  func(self, channel_id, members_func)

  if (channel_id == 1) and (#vmf.unsent_chat_messages > 0) then
    for _, message in ipairs(vmf.unsent_chat_messages) do
      self:add_local_system_message(1, message, true)
    end

    for i, _ in ipairs(vmf.unsent_chat_messages) do
      vmf.unsent_chat_messages[i] = nil
    end
  end
end)