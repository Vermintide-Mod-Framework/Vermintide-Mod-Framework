local vmf = get_mod("VMF")

local ingame_ui = nil

-- needed to protect opened menus from being closed right away and vice versa
local closing_keybind_is_pressed = false
local opening_keybind_is_pressed = true

local views_settings = {}

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.register_new_view = function (self, new_view_data)

  new_view_data.view_settings.mod_name = self:get_name()

  views_settings[new_view_data.view_name] = new_view_data.view_settings

  -- there's no direct access to local variable 'transitions' in ingame_ui
  local transitions = require("scripts/ui/views/ingame_ui_settings").transitions

  for transition_name, transition_function in pairs(new_view_data.view_transitions) do
    transitions[transition_name] = transition_function
  end

  if new_view_data.view_settings.hotkey_action_name then
    -- create function mod.hotkey_action_name()
    -- so the menu will open when the keybind is pressed
    self[new_view_data.view_settings.hotkey_action_name] = function()

      if not closing_keybind_is_pressed
         and ingame_ui
         and not ingame_ui:pending_transition()
         and not ingame_ui:end_screen_active()
         and not ingame_ui.menu_active
         and not ingame_ui.leave_game
         and not ingame_ui.return_to_title_screen
         and not (ingame_ui.popup_join_lobby_handler and ingame_ui.popup_join_lobby_handler.visible) -- V2 doesn't have 'popup_join_lobby_handler'
      then
        ingame_ui:handle_transition(new_view_data.view_settings.hotkey_transition_name)
      end

      closing_keybind_is_pressed = false
    end
  end

  -- if reloading mods, ingame_ui exists and hook "IngameUI.setup_views" won't work
  -- so set new variables and create new menu manually
  if ingame_ui then

    -- set 'ingame_ui.views'
    local new_view_name = new_view_data.view_name
    local new_view_init_function = new_view_data.view_settings.init_view_function

    --if new_view_name ~= "vmf_options_view" then
      ingame_ui.views[new_view_name] = new_view_init_function(ingame_ui.ingame_ui_context)
    --end
    -- set 'ingame_ui.blocked_transitions'
    local blocked_transitions = new_view_data.view_settings.blocked_transitions
    local current_blocked_transitions = ingame_ui.is_in_inn and blocked_transitions.inn or blocked_transitions.ingame

    for blocked_transition_name, _ in pairs(current_blocked_transitions) do
      ingame_ui.blocked_transitions[blocked_transition_name] = true
    end
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("IngameUI.setup_views", function(func, self, ingame_ui_context)
  func(self, ingame_ui_context)

  for view_name, view_settings in pairs(views_settings) do

    if self.is_in_inn then
      if view_settings.active.inn then
        self.views[view_name] = view_settings.init_view_function(ingame_ui_context)
      end

      for blocked_transition_name, _ in pairs(view_settings.blocked_transitions.inn) do
        self.blocked_transitions[blocked_transition_name] = true
      end
    else
      if view_settings.active.ingame then
        self.views[view_name] = view_settings.init_view_function(ingame_ui_context)
      end

      for blocked_transition_name, _ in pairs(view_settings.blocked_transitions.ingame) do
        self.blocked_transitions[blocked_transition_name] = true
      end
    end
  end
end)

vmf:hook("IngameUI.init", function(func, self, ingame_ui_context)
  func(self, ingame_ui_context)

  ingame_ui = self
end)

vmf:hook("IngameUI.destroy", function(func, self)
  func(self)

  ingame_ui = nil
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.check_custom_menus_close_keybinds = function()
  if ingame_ui then
    if views_settings[ingame_ui.current_view] then
      local opened_view_settings = views_settings[ingame_ui.current_view]
      local mod_name = opened_view_settings.mod_name
      local hotkey_name = opened_view_settings.hotkey_name

      if not hotkey_name then
        return
      end

      local close_keybind = get_mod(mod_name):get(hotkey_name)

      -- vmf keybinds input service
      local input_service = Managers.input:get_service("VMFMods")
      local original_is_blocked = input_service:is_blocked()

      if original_is_blocked then
        Managers.input:device_unblock_service("keyboard", 1, "VMFMods")
      end

      if opening_keybind_is_pressed and not input_service:get(close_keybind[1]) then
        opening_keybind_is_pressed = false
      end

      local close_menu = false
      if not opening_keybind_is_pressed then
        if input_service:get(close_keybind[1]) and
          (not close_keybind[2] and not input_service:get("ctrl") or close_keybind[2] and input_service:get("ctrl")) and
          (not close_keybind[3] and not input_service:get("alt") or close_keybind[3] and input_service:get("alt")) and
          (not close_keybind[4] and not input_service:get("shift") or close_keybind[4] and input_service:get("shift")) then

          close_menu = not ingame_ui.views[ingame_ui.current_view]:input_service():is_blocked()
        end
      end

      if original_is_blocked then
        Managers.input:device_block_service("keyboard", 1, "VMFMods")
      end

      if close_menu then
        ingame_ui:handle_transition("exit_menu")

        closing_keybind_is_pressed = true
      end
    else
      opening_keybind_is_pressed = true
    end
  end
end

vmf.close_opened_custom_menus = function()
  if ingame_ui then
    local current_view = ingame_ui.current_view
    if views_settings[current_view] then
        ingame_ui:handle_transition("exit_menu")

      --if current_view ~= "vmf_options_view" then
        if ingame_ui.views[current_view].destroy and get_mod(views_settings[ingame_ui.current_view].mod_name) then

          get_mod(views_settings[ingame_ui.current_view].mod_name):pcall(ingame_ui.views[current_view].destroy)
        end

        ingame_ui.views[current_view] = nil
      --end
    end
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################


local ingame_ui_exists, ingame_ui_return
if VT1 then
  ingame_ui_exists, ingame_ui_return = pcall(function () return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui end)
else
  ingame_ui_exists, ingame_ui_return = pcall(function () return Managers.player.network_manager.matchmaking_manager._ingame_ui end)
end

-- if VMF is reloaded mid-game
if ingame_ui_exists then
  ingame_ui = ingame_ui_return
end