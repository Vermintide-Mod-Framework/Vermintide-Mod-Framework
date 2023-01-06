local vmf = get_mod("VMF")

local _unsent_chat_messages = {}
local _logging_settings
local _logging_settings_lookup = {
  [0] = {[1] = false, [2] = false, [3] = false}, -- Disabled
  [1] = {[1] = true,  [2] = false, [3] = false}, -- Log only
  [2] = {[1] = false, [2] = true,  [3] = false}, -- Chat only
  [3] = {[1] = false, [2] = false, [3] = true},  -- Notification only
  [4] = {[1] = true,  [2] = true,  [3] = false}, -- Log and chat
  [5] = {[1] = true,  [2] = false, [3] = true},  -- Log and Notification
  [6] = {[1] = false, [2] = true,  [3] = true},  -- Chat and Notification
  [7] = {[1] = true,  [2] = true,  [3] = true},  -- All
}
local _notification_sound = "wwise/events/ui/play_ui_click"

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function add_chat_notification(message)
  local event_manager = Managers.event
  
  if event_manager then
    event_manager:trigger("event_add_notification_message", "default", message, nil, _notification_sound)
  end
end


local function add_chat_message(message, sender)
  local chat_manager = Managers.chat
  local event_manager = Managers.event
  
  if chat_manager and event_manager then
    local message_obj = {
      message_body = message,
      is_current_user = false,
    }
    
    local participant = {
      displayname = sender or "SYSTEM",
    }
    
    local message_sent = false
    
    local channel_handle, channel = next(chat_manager:connected_chat_channels())
    if channel then
      event_manager:trigger("chat_manager_message_recieved", channel_handle, participant, message_obj)
      message_sent = true
    end
    
    if not message_sent then
      table.insert(_unsent_chat_messages, message)
    end
  end
end


local function safe_format(mod, str, ...)
  -- the game still crash with unknown error if there is non-standard character after '%'
  local success, message = pcall(string.format, str, ...)
  if success then
    return message
  else
    mod:error("(logging) string.format: %s", message)
  end
end


local function send_to_notifications(self, message)
  add_chat_notification(message)
end


local function send_to_chat(self, msg_type, message)

  if msg_type ~= "echo" then
    message = string.format("[%s][%s] %s", self:get_name(), string.upper(msg_type), message)
  end

  add_chat_message(message)
end


local function send_to_log(self, msg_type, message)
  printf("[MOD][%s][%s] %s", self:get_name(), string.upper(msg_type), message)
end


local function log_message(self, msg_type, message, ...)

  message = safe_format(self, tostring(message), ...)
  if message then
    if _logging_settings[msg_type].send_to_notifications then
      send_to_notifications(self, message)
    end
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

function VMFMod:notify(message, ...)
  if _logging_settings.notification.enabled then
    log_message(self, "notification", message, ...)
  end
end


function VMFMod:echo(message, ...)
  if _logging_settings.echo.enabled then
    log_message(self, "echo", message, ...)
  end
end
function VMFMod:echo_localized(localization_id, ...)
  if _logging_settings.echo.enabled then
    log_message(self, "echo", self:localize(localization_id, ...))
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
  vmf:hook_safe("VivoxManager", "join_chat_channel", function (self)
    if #_unsent_chat_messages > 0 and #self:connected_chat_channels() > 0 then
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
    notification = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_notification") or 5,
    echo         = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_echo")         or 4,
    error        = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_error")        or 4,
    warning      = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_warning")      or 4,
    info         = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_info")         or 1,
    debug        = vmf:get("logging_mode") == "custom" and vmf:get("output_mode_debug")        or 0,
  }

  for method_name, logging_mode in pairs(_logging_settings) do
    _logging_settings[method_name] = {
      send_to_notifications = logging_mode and _logging_settings_lookup[logging_mode][3],
      send_to_chat          = logging_mode and _logging_settings_lookup[logging_mode][2],
      send_to_log           = logging_mode and _logging_settings_lookup[logging_mode][1],
      enabled               = logging_mode and logging_mode > 0
    }
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

vmf.load_logging_settings()
