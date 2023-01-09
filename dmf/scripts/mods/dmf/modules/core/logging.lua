local dmf = get_mod("DMF")

local ChatManagerConstants = require("scripts/foundation/managers/chat/chat_manager_constants")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

-- Global backup of original print() method
local print = __print

local _chat_element

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

local _notification_types = {
  achievement = true,
  alert = true,
  contract = true,
  currency = true,
  default = true,
  dev = true,
  item_granted = true,
  matchmaking = true,
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function add_chat_notification(message, notification_type, sound_event, replay_to_chat_on_error)
  if Managers.event then
    Managers.event:trigger(
      "event_add_notification_message",
      _notification_types[notification_type] and notification_type or "default",
      message or "",
      nil,
      sound_event or UISoundEvents.default_click
    )

  elseif replay_to_chat_on_error then
    table.insert(_unsent_chat_messages, {message, "NOTIFICATION"})
  end
end


local function add_chat_message(message, sender)
  local channel_sender = sender or "SYSTEM"

  -- Send to our stored chat element if it exists
  if _chat_element then
    _chat_element:_add_message(message, channel_sender, ChatManagerConstants.ChannelTag.PRIVATE)

  else
    -- Otherwise play the message as a notification for now, and replay it later
    add_chat_notification(message, nil, nil, false)
    table.insert(_unsent_chat_messages, {message, sender})
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


local function send_to_notifications(self, message, notification_type, sound_event)
  add_chat_notification(message, notification_type, sound_event, true)
end


local function send_to_chat(self, msg_type, message)

  if msg_type ~= "echo" then
    message = string.format("[%s] %s", string.upper(msg_type), message)
  end

  local sender = self and self:get_name() and string.format("[%s]", self:get_name())
  add_chat_message(message, sender)
end


local string_format = string.format
local function printf(f, ...)
	print(string_format(f, ...))
end


local function send_to_log(self, msg_type, message)
  printf("[MOD][%s][%s] %s", self:get_name(), string.upper(msg_type), message)
end


local function log_message(self, msg_type, message, ...)

  message = safe_format(self, tostring(message), ...)
  if message then
    if _logging_settings[msg_type].send_to_notifications then
      if msg_type == "error" then
        send_to_notifications(self, {text = message}, "alert", UISoundEvents.notification_matchmaking_failed)
      else
        send_to_notifications(self, message)
      end
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
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

function DMFMod:notify(message, ...)
  if _logging_settings.notification.enabled then
    log_message(self, "notification", message, ...)
  end
end


function DMFMod:echo(message, ...)
  if _logging_settings.echo.enabled then
    log_message(self, "echo", message, ...)
  end
end
function DMFMod:echo_localized(localization_id, ...)
  if _logging_settings.echo.enabled then
    log_message(self, "echo", self:localize(localization_id, ...))
  end
end


function DMFMod:error(message, ...)
  if _logging_settings.error.enabled then
    log_message(self, "error", message, ...)
  end
end


function DMFMod:warning(message, ...)
  if _logging_settings.warning.enabled then
    log_message(self, "warning", message, ...)
  end
end


function DMFMod:info(message, ...)
  if _logging_settings.info.enabled then
    log_message(self, "info", message, ...)
  end
end


function DMFMod:debug(message, ...)
  if _logging_settings.debug.enabled then
    log_message(self, "debug", message, ...)
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Can't be hooked right away, since hooking module is not initialized yet
-- Sends unsent messages to chat when chat channel is finally created
function dmf.delayed_chat_messages_hook()
  dmf:hook_safe("ConstantElementChat", "_handle_input", function (self)

    -- Store the chat element for adding messages directly
    _chat_element = self

    if #_unsent_chat_messages > 0 then
      for _, message in ipairs(_unsent_chat_messages) do
        add_chat_message(message[1], message[2])
      end

      for i, _ in ipairs(_unsent_chat_messages) do
        _unsent_chat_messages[i] = nil
      end
    end
  end)
end

function dmf.load_logging_settings()

  _logging_settings = {
    notification = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_notification") or 5,
    echo         = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_echo")         or 4,
    error        = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_error")        or 7,
    warning      = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_warning")      or 4,
    info         = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_info")         or 1,
    debug        = dmf:get("logging_mode") == "custom" and dmf:get("output_mode_debug")        or 0,
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

dmf.load_logging_settings()
