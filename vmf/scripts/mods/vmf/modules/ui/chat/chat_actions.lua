--[[
  * chat commands
  * chat history
  * ctrl + c, ctrl + v
]]
local vmf = get_mod("VMF")

local _CHAT_OPENED = false

local _COMMANDS_LIST = {}
local _COMMAND_INDEX = 0 -- 0 => nothing selected

local _COMMANDS_LIST_GUI_DRAW = nil

local _CHAT_HISTORY = {}
local _CHAT_HISTORY_INDEX = 0
local _CHAT_HISTORY_ENABLED = true
local _CHAT_HISTORY_SAVE = true
local _CHAT_HISTORY_MAX = 50
local _CHAT_HISTORY_REMOVE_DUPS_LAST = false
local _CHAT_HISTORY_REMOVE_DUPS_ALL = false
local _CHAT_HISTORY_SAVE_COMMANDS_ONLY = false

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function initialize_drawing_function()
  _COMMANDS_LIST_GUI_DRAW = dofile("scripts/mods/vmf/modules/ui/chat/commands_list_gui")
end

local function clean_chat_history()
  _CHAT_HISTORY = {}
  _CHAT_HISTORY_INDEX = 0
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("WorldManager.create_world", function(func, self, name, ...)
  local world = func(self, name, ...)

  if name == "top_ingame_view" then
    initialize_drawing_function()
  end

  return world
end)


vmf:hook("ChatGui.block_input", function(func, ...)
  func(...)

  _CHAT_OPENED = true
end)


vmf:hook("ChatGui._update_input", function(func, self, input_service, menu_input_service, dt, no_unblock, chat_enabled)

  local command_executed = false

  -- if ENTER was pressed
  if Keyboard.pressed(Keyboard.button_index("enter")) then

    -- chat history
    if _CHAT_HISTORY_ENABLED
       and self.chat_message ~= ""
       and not (_CHAT_HISTORY_REMOVE_DUPS_LAST and (self.chat_message == _CHAT_HISTORY[1]))
       and (not _CHAT_HISTORY_SAVE_COMMANDS_ONLY or (_COMMAND_INDEX ~= 0)) then
      table.insert(_CHAT_HISTORY, 1, self.chat_message)

      if #_CHAT_HISTORY == _CHAT_HISTORY_MAX + 1 then
        table.remove(_CHAT_HISTORY, #_CHAT_HISTORY)
      end

      if _CHAT_HISTORY_REMOVE_DUPS_ALL then

        for i = 2, #_CHAT_HISTORY do
          if _CHAT_HISTORY[i] == self.chat_message then
            table.remove(_CHAT_HISTORY, i)
            break
          end
        end
      end
    end

    -- command execution
    if _COMMAND_INDEX ~= 0 then
      local args = {}
      for arg in string.gmatch(self.chat_message, "%S+") do
        table.insert(args, arg)
      end
      table.remove(args, 1)

      vmf.run_command(_COMMANDS_LIST[_COMMAND_INDEX].name, unpack(args))

      _COMMANDS_LIST = {}
      _COMMAND_INDEX = 0

      self.chat_message = ""
      command_executed = true
    end
  end

  local old_chat_message = self.chat_message

  local chat_focused, chat_closed, chat_close_time = func(self, input_service, menu_input_service, dt, no_unblock, chat_enabled)

  if chat_closed then
    self.chat_message = ""

    _CHAT_OPENED = false

    _COMMANDS_LIST = {}
    _COMMAND_INDEX = 0
    _CHAT_HISTORY_INDEX = 0

    if command_executed then
      chat_closed = false
      chat_close_time = nil
    end
  end

  if _CHAT_OPENED then

    -- getting state of 'tab', 'arrow up' and 'arrow down' buttons
    local tab_pressed = false
    local arrow_up_pressed = false
    local arrow_down_pressed = false
    for _, stroke in ipairs(Keyboard.keystrokes()) do
      if stroke == Keyboard.TAB then
        tab_pressed = true
        -- game considers some "ctrl + [something]" combinations as arrow buttons, so I have to check for ctrl not pressed
      elseif stroke == Keyboard.UP and Keyboard.button(Keyboard.button_index("left ctrl")) == 0 then
        arrow_up_pressed = true
      elseif stroke == Keyboard.DOWN and Keyboard.button(Keyboard.button_index("left ctrl")) == 0 then
        arrow_down_pressed = true
      end
    end

    -- chat history
    if _CHAT_HISTORY_ENABLED then
      -- message was modified by player
      if self.chat_message ~= self.previous_chat_message then
        _CHAT_HISTORY_INDEX = 0
      end
      if arrow_up_pressed or arrow_down_pressed then

        local new_index = _CHAT_HISTORY_INDEX + (arrow_up_pressed and 1 or -1)
        new_index = math.clamp(new_index, 0, #_CHAT_HISTORY)

        if _CHAT_HISTORY_INDEX ~= new_index then
          if _CHAT_HISTORY[new_index] then

            self.chat_message = _CHAT_HISTORY[new_index]
            self.chat_index   = KeystrokeHelper.num_utf8chars(self.chat_message) + 1
            self.chat_input_widget.content.text_index = 1

            self.previous_chat_message = self.chat_message

            _CHAT_HISTORY_INDEX = new_index
          else -- new_index == 0
            self.chat_message = ""
            self.chat_index   = 1
          end
        end
      end
    end

    -- ctrl + v
    if Keyboard.pressed(Keyboard.button_index("v")) and Keyboard.button(Keyboard.button_index("left ctrl")) == 1 then
      self.chat_message = self.chat_message .. tostring(Clipboard.get()):gsub(string.char(0x0D), "") -- remove CR characters
      self.chat_index   = KeystrokeHelper.num_utf8chars(self.chat_message) + 1
    end

    -- ctrl + c
    if Keyboard.pressed(Keyboard.button_index("c")) and Keyboard.button(Keyboard.button_index("left ctrl")) == 1 then
      Clipboard.put(self.chat_message)
    end

    -- entered chat message starts with "/"
    if string.sub(self.chat_message, 1, 1) == "/" then

      if not string.find(self.chat_message, " ") -- if there's no space after '/part_of_command_name'
         and tab_pressed                         -- if TAB was pressed
         and (string.len(self.chat_message) + 1) == self.chat_index -- if TAB was pressed with caret at the end of the string
         and (#_COMMANDS_LIST > 0) then           -- if there are any commands matching entered '/part_of_command_name'

        _COMMAND_INDEX = _COMMAND_INDEX % #_COMMANDS_LIST + 1

        self.chat_message = "/" .. _COMMANDS_LIST[_COMMAND_INDEX].name
        self.chat_index   = KeystrokeHelper.num_utf8chars(self.chat_message) + 1

        -- so the next block won't update the commands list
        old_chat_message = self.chat_message
      end


      if self.chat_message ~= old_chat_message then

        -- get '/part_of_command_name' without '/'
        local command_name_contains = self.chat_message:match("%S+"):sub(2, -1)

        if string.find(self.chat_message, " ") then
          _COMMANDS_LIST = vmf.get_commands_list(command_name_contains, true)
        else
          _COMMANDS_LIST = vmf.get_commands_list(command_name_contains)
        end

        _COMMAND_INDEX = 0

        if #_COMMANDS_LIST > 0 and command_name_contains:lower() == _COMMANDS_LIST[1].name then
          _COMMAND_INDEX = 1
        end
      end


    -- chat message was modified and doesn't start with '/'
    elseif self.chat_message ~= old_chat_message and #_COMMANDS_LIST > 0 then
      _COMMANDS_LIST = {}
      _COMMAND_INDEX = 0
    end

    if #_COMMANDS_LIST > 0 then
      _COMMANDS_LIST_GUI_DRAW(_COMMANDS_LIST, _COMMAND_INDEX)
    end
  end

  return chat_focused, chat_closed, chat_close_time
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_chat_history_settings = function(clean_chat_history_)

  _CHAT_HISTORY_ENABLED            = vmf:get("chat_history_enable")
  _CHAT_HISTORY_SAVE               = vmf:get("chat_history_save")
  _CHAT_HISTORY_MAX                = vmf:get("chat_history_buffer_size")
  _CHAT_HISTORY_REMOVE_DUPS_LAST   = vmf:get("chat_history_remove_dups")
  _CHAT_HISTORY_REMOVE_DUPS_ALL    = vmf:get("chat_history_remove_dups") and (vmf:get("chat_history_remove_dups_mode") == "all")
  _CHAT_HISTORY_SAVE_COMMANDS_ONLY = vmf:get("chat_history_commands_only")

  if _CHAT_HISTORY_ENABLED then
    vmf:command("clean_chat_history", vmf:localize("clean_chat_history"), clean_chat_history)
  else
    vmf:command_remove("clean_chat_history")
  end

  if not _CHAT_HISTORY_SAVE then
    vmf:set("chat_history", nil)
  end

  if clean_chat_history_ then
    clean_chat_history()
  end
end

vmf.save_chat_history = function()
  if _CHAT_HISTORY_SAVE then
    vmf:set("chat_history", _CHAT_HISTORY)
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_chat_history_settings()

if _CHAT_HISTORY_SAVE then
  _CHAT_HISTORY = vmf:get("chat_history") or _CHAT_HISTORY
end

if Managers.world:has_world("top_ingame_view") then
  initialize_drawing_function()
end