--[[
  * chat commands
  * chat history
  * ctrl + c, ctrl + v
]]
local vmf = get_mod("VMF")

local _chat_opened = false

local _commands_list = {}
local _command_index = 0 -- 0 => nothing selected

local _commands_list_gui_draw

local _chat_history = {}
local _chat_history_index = 0
local _chat_history_enabled = true
local _chat_history_save = true
local _chat_history_max = 50
local _chat_history_remove_dups_last = false
local _chat_history_remove_dups_all = false
local _chat_history_save_commands_only = false

local _queued_command -- is a workaround for VT2 where raycast is blocked during ui update

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function initialize_drawing_function()
  _commands_list_gui_draw = dofile("scripts/mods/vmf/modules/ui/chat/commands_list_gui")
end

local function clean_chat_history()
  _chat_history = {}
  _chat_history_index = 0
end

local function set_chat_message(chat_gui, message)
  chat_gui.chat_message = message
  chat_gui.chat_index   = KeystrokeHelper.num_utf8chars(chat_gui.chat_message) + 1
  chat_gui.chat_input_widget.content.text_index = 1
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook_safe(WorldManager, "create_world", function(self_, name)
  if name == "top_ingame_view" then
    initialize_drawing_function()
  end
end)


vmf:hook_safe("ChatGui", "block_input", function()
  _chat_opened = true
end)


vmf:hook("ChatGui", "_update_input", function(func, self, input_service, menu_input_service, dt, no_unblock,
                                               chat_enabled, ...)

  local command_executed = false

  -- if ENTER was pressed
  if Keyboard.pressed(Keyboard.button_index("enter")) then

    -- chat history
    if _chat_history_enabled
       and self.chat_message ~= ""
       and not (_chat_history_remove_dups_last and (self.chat_message == _chat_history[1]))
       and (not _chat_history_save_commands_only or (_command_index ~= 0)) then
      table.insert(_chat_history, 1, self.chat_message)

      if #_chat_history == _chat_history_max + 1 then
        table.remove(_chat_history, #_chat_history)
      end

      if _chat_history_remove_dups_all then

        for i = 2, #_chat_history do
          if _chat_history[i] == self.chat_message then
            table.remove(_chat_history, i)
            break
          end
        end
      end
    end

    -- command execution
    if _command_index ~= 0 then
      local args = {}
      for arg in string.gmatch(self.chat_message, "%S+") do
        table.insert(args, arg)
      end
      table.remove(args, 1)

      _queued_command = {
        name = _commands_list[_command_index].name,
        args = args
      }

      _commands_list = {}
      _command_index = 0

      set_chat_message(self, "")

      command_executed = true
    end
  end

  local old_chat_message = self.chat_message

  local chat_focused, chat_closed, chat_close_time = func(self, input_service, menu_input_service,
                                                                dt, no_unblock, chat_enabled, ...)

  if chat_closed then
    set_chat_message(self, "")

    _chat_opened = false

    _commands_list = {}
    _command_index = 0
    _chat_history_index = 0

    if command_executed then
      chat_closed = false
      chat_close_time = nil
    end
  end

  if _chat_opened then

    -- getting state of 'tab', 'arrow up' and 'arrow down' buttons
    local tab_pressed = false
    local arrow_up_pressed = false
    local arrow_down_pressed = false
    for _, stroke in ipairs(Keyboard.keystrokes()) do
      if stroke == Keyboard.TAB then
        tab_pressed = true
        -- game considers some "ctrl + [something]" combinations as arrow buttons,
        -- so I have to check for ctrl not pressed
      elseif stroke == Keyboard.UP and Keyboard.button(Keyboard.button_index("left ctrl")) == 0 then
        arrow_up_pressed = true
      elseif stroke == Keyboard.DOWN and Keyboard.button(Keyboard.button_index("left ctrl")) == 0 then
        arrow_down_pressed = true
      end
    end

    -- chat history
    if _chat_history_enabled then

      -- reverse result of native chat history in VT2
      if not VT1 and input_service.get(input_service, "chat_next_old_message") or
                     input_service.get(input_service, "chat_previous_old_message") then
        set_chat_message(self, old_chat_message)
      end

      -- message was modified by player
      if self.chat_message ~= self.previous_chat_message then
        _chat_history_index = 0
      end
      if arrow_up_pressed or arrow_down_pressed then

        local new_index = _chat_history_index + (arrow_up_pressed and 1 or -1)
        new_index = math.clamp(new_index, 0, #_chat_history)

        if _chat_history_index ~= new_index then
          if _chat_history[new_index] then

            set_chat_message(self, _chat_history[new_index])

            self.previous_chat_message = self.chat_message

            _chat_history_index = new_index
          else -- new_index == 0
            set_chat_message(self, "")
          end
        end
      end
    end

    -- ctrl + v
    if Keyboard.pressed(Keyboard.button_index("v")) and Keyboard.button(Keyboard.button_index("left ctrl")) == 1 then
      local new_chat_message = self.chat_message
      
      -- remove carriage returns
      local clipboard_data = tostring(Clipboard.get()):gsub("\r", "")
      
      -- remove invalid characters
      if Utf8.valid(clipboard_data) then
        new_chat_message = new_chat_message .. clipboard_data
      else
        local valid_data = ""
        clipboard_data:gsub(".", function(c)
          if Utf8.valid(c) then
            valid_data = valid_data .. c
          end
        end)
        new_chat_message = new_chat_message .. valid_data
      end
      
      set_chat_message(self, new_chat_message)
    end

    -- ctrl + c
    if Keyboard.pressed(Keyboard.button_index("c")) and Keyboard.button(Keyboard.button_index("left ctrl")) == 1 then
      Clipboard.put(self.chat_message)
    end

    -- entered chat message starts with "/"
    if string.sub(self.chat_message, 1, 1) == "/" then

      -- if there's no space after '/part_of_command_name' and if TAB was pressed
      if not string.find(self.chat_message, " ") and tab_pressed and
         -- if TAB was pressed with caret at the end of the string
         (string.len(self.chat_message) + 1) == self.chat_index and
         -- if there are any commands matching entered '/part_of_command_name
         (#_commands_list > 0) then

        _command_index = _command_index % #_commands_list + 1

        set_chat_message(self, "/" .. _commands_list[_command_index].name)

        -- so the next block won't update the commands list
        old_chat_message = self.chat_message
      end


      if self.chat_message ~= old_chat_message then

        -- get '/part_of_command_name' without '/'
        local command_name_contains = self.chat_message:match("%S+"):sub(2, -1)

        if string.find(self.chat_message, " ") then
          _commands_list = vmf.get_commands_list(command_name_contains, true)
        else
          _commands_list = vmf.get_commands_list(command_name_contains)
        end

        _command_index = 0

        if #_commands_list > 0 and command_name_contains:lower() == _commands_list[1].name then
          _command_index = 1
        end
      end


    -- chat message was modified and doesn't start with '/'
    elseif self.chat_message ~= old_chat_message and #_commands_list > 0 then
      _commands_list = {}
      _command_index = 0
    end

    if #_commands_list > 0 then
      _commands_list_gui_draw(_commands_list, _command_index)
    end
  end

  return chat_focused, chat_closed, chat_close_time
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_chat_history_settings = function(clean_chat_history_)

  _chat_history_enabled            = vmf:get("chat_history_enable")
  _chat_history_save               = vmf:get("chat_history_save")
  _chat_history_max                = vmf:get("chat_history_buffer_size")
  _chat_history_remove_dups_last   = vmf:get("chat_history_remove_dups")
  _chat_history_remove_dups_all    = vmf:get("chat_history_remove_dups") and
                                    (vmf:get("chat_history_remove_dups_mode") == "all")
  _chat_history_save_commands_only = vmf:get("chat_history_commands_only")

  if _chat_history_enabled then
    vmf:command("clean_chat_history", vmf:localize("clean_chat_history"), clean_chat_history)
  else
    vmf:command_remove("clean_chat_history")
  end

  if not _chat_history_save then
    vmf:set("chat_history", nil)
  end

  if clean_chat_history_ then
    clean_chat_history()
  end
end

vmf.save_chat_history = function()
  if _chat_history_save then
    vmf:set("chat_history", _chat_history)
  end
end

vmf.execute_queued_chat_command = function()
  if _queued_command then
    vmf.run_command(_queued_command.name, unpack(_queued_command.args))
    _queued_command = nil
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_chat_history_settings()

if _chat_history_save then
  _chat_history = vmf:get("chat_history") or _chat_history
end

if Managers.world and Managers.world:has_world("top_ingame_view") then
  initialize_drawing_function()
end