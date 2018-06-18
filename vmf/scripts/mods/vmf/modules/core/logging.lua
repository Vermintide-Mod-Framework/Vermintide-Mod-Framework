local vmf = get_mod("VMF")

local _unsent_chat_messages = {}
local _logging_settings

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function add_chat_message(message)
  local chat_manager = Managers.chat
  local new_message = {
		channel_id = 1,
		message_sender = "System",
		message = message,
    is_system_message = VT1 and true,
    type = not VT1 and Irc.SYSTEM_MSG, -- luacheck: ignore Irc
		pop_chat = true,
		is_dev = false
  }

  table.insert(chat_manager.chat_messages, new_message)
  if not VT1 then
    table.insert(chat_manager.global_messages, new_message)
  end
end


local function safe_format(mod, str, ...)
  -- the game still crash with unknown error if there is non-standard character after '%'
  local success, message = pcall(string.format, str, ...)
  if success then
    return message
  else
    mod:error("(logging) string.format: " .. tostring(message))
  end
end


local function send_to_chat(self, msg_type, message)

  if msg_type ~= "echo" then
    message = string.format("[%s][%s] %s", self:get_name(), string.upper(msg_type), message)
  end

  if Managers.chat and Managers.chat:has_channel(1) then
    add_chat_message(message)
  else
    table.insert(_unsent_chat_messages, message)
  end
end


local function send_to_log(self, msg_type, message)
  printf("[MOD][%s][%s] %s", self:get_name(), string.upper(msg_type), message)
end


local function log_message(self, msg_type, message, ...)

  message = safe_format(self, tostring(message), ...)
  if message then
    if _logging_settings[msg_type].send_to_chat then
      send_to_chat(self, msg_type, message)
    end
    if _logging_settings[msg_type].send_to_log then
      send_to_log(self, msg_type, message)
    end
  end
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

function VMFMod:echo(message, ...)
  if _logging_settings.echo.enabled then
    log_message(self, "echo", message, ...)
  end
end


function VMFMod:error(message, ...)
  if _logging_settings.error.enabled then
    log_message(self, "error", message, ...)
  end
end


function VMFMod:warning(message, ...)
  if _logging_settings.warning.enabled then
    log_message(self, "warning", message, ...)
  end
end


function VMFMod:info(message, ...)
  if _logging_settings.info.enabled then
    log_message(self, "info", message, ...)
  end
end


function VMFMod:debug(message, ...)
  if _logging_settings.debug.enabled then
    log_message(self, "debug", message, ...)
  end
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Can't be hooked right away, since hooking module is not initialized yet
-- Sends unsent messages to chat when chat channel is finally created
function vmf.delayed_chat_messages_hook()
  vmf:hook_safe("ChatManager", "register_channel", function (self, channel_id)
    if (channel_id == 1) and (#_unsent_chat_messages > 0) then
      for _, message in ipairs(_unsent_chat_messages) do
        add_chat_message(message)
      end

      for i, _ in ipairs(_unsent_chat_messages) do
        _unsent_chat_messages[i] = nil
      end
    end
  end)
end

function vmf.load_logging_settings()

  _logging_settings = {
    echo    = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_echo")    or 3,
    error   = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_error")   or 3,
    warning = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_warning") or 3,
    info    = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_info")    or 1,
    debug   = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_debug")   or 0,
  }

  for method_name, logging_mode in pairs(_logging_settings) do
    _logging_settings[method_name] = {
      send_to_chat = logging_mode and logging_mode >= 2,
      send_to_log  = logging_mode and logging_mode % 2 == 1,
      enabled      = logging_mode and logging_mode > 0
    }
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

vmf.load_logging_settings()