local vmf = get_mod("VMF")

local _ingame_ui = nil
-- There's no direct access to local variable 'transitions' in ingame_ui.
local _ingame_ui_transitions = require("scripts/ui/views/ingame_ui_settings").transitions
local _views_data = {}

local ERRORS = {
  THROWABLE = {
    -- inject_view:
    view_already_exists = "view with name '%s' already persists in original game.",
    transition_already_exists = "transition with name '%s' already persists in original game.",
    view_initializing_failed = "view initialization failed due to error during 'init_view_function' execution.",
    -- validate_view_data:
    view_name_wrong_type = "'view_name' must be a string, not %s.",
    view_transitions_wrong_type = "'view_transitions' must be a table, not %s.",
    view_settings_wrong_type = "'view_settings' must be a table, not %s.",
    transition_wrong_type = "all transitions inside 'view_transitions' must be functions, but '%s' transition is %s.",
    transition_name_taken = "transition name '%s' is already used by '%s' mod for '%s' view.",
    init_view_function_wrong_type = "'view_settings.init_view_function' must be a function, not %s.",
    active_wrong_type = "'view_settings.active' must be a table, not %s.",
    active_missing_element = "'view_settings.active' must contain 2 elements: 'inn' and 'ingame'.",
    active_element_wrong_name = "the only allowed names for 'view_settings.active' elements are 'inn' and 'ingame'; " ..
                                 "you can't name your element '%s'.",
    active_element_wrong_type = "'view_settings.active.%s' must be boolean, not %s.",
    blocked_transitions_wrong_type = "'view_settings.blocked_transitions' (optional) must be a table, not %s.",
    blocked_transitions_missing_element = "'view_settings.blocked_transitions' must contain 2 table elements: " ..
                                           "'inn' and 'ingame'.",
    blocked_transitions_element_wrong_name = "the only allowed names for 'view_settings.active' elements are " ..
                                              "'inn' and 'ingame'; you can't name your element '%s'.",
    blocked_transitions_element_wrong_type = "'view_settings.blocked_transitions.%s' must be a table, not %s.",
    blocked_transition_invalid = "you can't put transition '%s' into 'view_settings.blocked_transitions.%s', " ..
                                  "because it's not listed in 'view_transitions'.",
    blocked_transition_wrong_value = "invalid value for 'view_settings.blocked_transitions.%s.%s'; must be 'true'."
  },
  REGULAR = {
    view_data_wrong_type = "[Custom Views] (register_view) Loading view data file '%s': returned view data must be " ..
                            "a table, not %s.",
    view_not_registered = "[Custom Views] Toggling view with keybind: view '%s' wasn't registered for this mod.",
    transition_not_registered = "[Custom Views] Toggling view with keybind: transition '%s' wasn't registered for " ..
                                 "'%s' view."
  },
  PREFIX = {
    view_initializing = "[Custom Views] Calling 'init_view_function'",
    view_destroying = "[Custom Views] Destroying view '%s'",
    register_view_open_file = "[Custom Views] (register_view) Opening view data file '%s'",
    register_view_validating = "[Custom Views] (register_view) View data validating '%s'",
    register_view_injection = "[Custom Views] (register_view) View injection '%s'",
    ingameui_hook_injection = "[Custom Views] View injection '%s'",
    handle_transition_fade = "[Custom Views] (handle_transition) executing 'ingame_ui.transition_with_fade' for " ..
                              "transition '%s'",
    handle_transition_no_fade = "[Custom Views] (handle_transition) executing 'ingame_ui.handle_transition' for " ..
                                 "transition '%s'"
  }
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function is_view_active_for_current_level(view_name)
  local active = _views_data[view_name].view_settings.active
  if _ingame_ui.is_in_inn and active.inn or not _ingame_ui.is_in_inn and active.ingame then
    return true
  end
end


-- @THROWS_ERRORS
local function inject_view(view_name)
  if not is_view_active_for_current_level(view_name) then
    return
  end

  local view_settings = _views_data[view_name].view_settings

  local mod                 = _views_data[view_name].mod
  local init_view_function  = view_settings.init_view_function
  local transitions         = _views_data[view_name].view_transitions
  local blocked_transitions = view_settings.blocked_transitions[_ingame_ui.is_in_inn and "inn" or "ingame"]

  -- Check for collisions.
  if _ingame_ui.views[view_name] then
    vmf.throw_error(ERRORS.THROWABLE["view_already_exists"], view_name)
  end
  for transition_name, _ in pairs(transitions) do
    if _ingame_ui_transitions[transition_name] then
      vmf.throw_error(ERRORS.THROWABLE["transition_already_exists"], transition_name)
    end
  end

  -- Initialize and inject view.
  local success, view = vmf.safe_call(mod, ERRORS.PREFIX["view_initializing"], init_view_function,
                                                                                _ingame_ui.ingame_ui_context)
  if success then
    _ingame_ui.views[view_name] = view
  else
    vmf.throw_error(ERRORS.THROWABLE["view_initializing_failed"], view_name)
  end

  -- Inject view transitions.
  for transition_name, transition_function in pairs(transitions) do
    _ingame_ui_transitions[transition_name] = transition_function
  end

  -- Inject view blocked transitions.
  for blocked_transition_name, _ in pairs(blocked_transitions) do
    _ingame_ui.blocked_transitions[blocked_transition_name] = true
  end
end


local function remove_injected_views(on_reload)
  -- These elements should be removed only on_reload, because, otherwise, they will be deleted automatically.
  if on_reload then
    -- If some custom view is active, close it.
    if _views_data[_ingame_ui.current_view] then
      _ingame_ui:handle_transition("exit_menu")
    end

    for view_name, view_data in pairs(_views_data) do
      -- Remove injected views.
      local view = _ingame_ui.views[view_name]
      if view then
        if type(view.destroy) == "function" then
          vmf.safe_call_nr(view_data.mod, {ERRORS.PREFIX["view_destroying"], view_name}, view.destroy)
        end
        _ingame_ui.views[view_name] = nil
      end
    end
  end

  for _, view_data in pairs(_views_data) do
    -- Remove injected transitions.
    for transition_name, _ in pairs(view_data.view_transitions) do
      _ingame_ui_transitions[transition_name] = nil
    end

    -- Remove blocked transitions
    local blocked_transitions = view_data.view_settings.blocked_transitions[_ingame_ui.is_in_inn and "inn" or "ingame"]
    for blocked_transition_name, _ in pairs(blocked_transitions) do
      _ingame_ui.blocked_transitions[blocked_transition_name] = nil
    end
  end
end


-- @THROWS_ERRORS
local function validate_view_data(view_data)
  -- Basic checks.
  if type(view_data.view_name) ~= "string" then
    vmf.throw_error(ERRORS.THROWABLE["view_name_wrong_type"], type(view_data.view_name))
  end
  if type(view_data.view_transitions) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE["view_transitions_wrong_type"], type(view_data.view_transitions))
  end
  if type(view_data.view_settings) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE["view_settings_wrong_type"], type(view_data.view_settings))
  end

  -- VIEW TRANSITIONS

  local view_transitions = view_data.view_transitions
  for transition_name, transition_function in pairs(view_transitions) do
    if type(transition_function) ~= "function" then
      vmf.throw_error(ERRORS.THROWABLE["transition_wrong_type"], transition_name, type(transition_function))
    end
    for another_view_name, another_view_data in pairs(_views_data) do
      for another_transition_name, _ in pairs(another_view_data.view_transitions) do
        if transition_name == another_transition_name then
          vmf.throw_error(ERRORS.THROWABLE["transition_name_taken"], transition_name, another_view_data.mod:get_name(),
                                                                      another_view_name)
        end
      end
    end
  end

  -- VIEW SETTINGS

  local view_settings = view_data.view_settings

  -- Use default values for optional fields if they are not defined.
  view_settings.blocked_transitions = view_settings.blocked_transitions or {inn = {}, ingame = {}}

  -- Verify everything.
  if type(view_settings.init_view_function) ~= "function" then
    vmf.throw_error(ERRORS.THROWABLE["init_view_function_wrong_type"], type(view_settings.init_view_function))
  end

  local active = view_settings.active
  if type(active) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE["active_wrong_type"], type(active))
  end
  if active.inn == nil or active.ingame == nil then
    vmf.throw_error(ERRORS.THROWABLE["active_missing_element"])
  end
  for level_name, value in pairs(active) do
    if level_name ~= "inn" and level_name ~= "ingame" then
      vmf.throw_error(ERRORS.THROWABLE["active_element_wrong_name"], level_name)
    end
    if type(value) ~= "boolean" then
      vmf.throw_error(ERRORS.THROWABLE["active_element_wrong_type"], level_name, type(value))
    end
  end

  local blocked_transitions = view_settings.blocked_transitions
  if type(blocked_transitions) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE["blocked_transitions_wrong_type"], type(blocked_transitions))
  end
  if not blocked_transitions.inn or not blocked_transitions.ingame then
    vmf.throw_error(ERRORS.THROWABLE["blocked_transitions_missing_element"])
  end
  for level_name, level_blocked_transitions in pairs(blocked_transitions) do
    if level_name ~= "inn" and level_name ~= "ingame" then
      vmf.throw_error(ERRORS.THROWABLE["blocked_transitions_element_wrong_name"], level_name)
    end
    if type(level_blocked_transitions) ~= "table" then
      vmf.throw_error(ERRORS.THROWABLE["blocked_transitions_element_wrong_type"], level_name,
                                                                                   type(level_blocked_transitions))
    end
    for transition_name, value in pairs(level_blocked_transitions) do
      if not view_transitions[transition_name] then
        vmf.throw_error(ERRORS.THROWABLE["blocked_transition_invalid"], transition_name, level_name)
      end
      if value ~= true then
        vmf.throw_error(ERRORS.THROWABLE["blocked_transition_wrong_value"], level_name, transition_name)
      end
    end
  end
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Wraps ingame_ui transition handling calls in a lot of safety checks. Returns 'true', if call is successful.
  * transition_name    [string]  : name of a transition that should be perfomed
  * ignore_active_menu [boolean] : if 'ingame_ui.menu_active' should be ignored
  * fade               [boolean] : if transition should be performed with fade
  * transition_params  [anything]: parameter, which will be passed to callable transition function, 'on_exit' method of
                                   the old view and 'on_enter' method of the new view
--]]
function VMFMod:handle_transition(transition_name, ignore_active_menu, fade, transition_params)
  if vmf.check_wrong_argument_type(self, "handle_transition", "transition_name", transition_name, "string") then
    return
  end

  if _ingame_ui
     and not _ingame_ui:pending_transition()
     and not _ingame_ui:end_screen_active()
     and (not _ingame_ui.menu_active or ignore_active_menu)
     and not _ingame_ui.leave_game
     and not _ingame_ui.menu_suspended
     and not _ingame_ui.return_to_title_screen
     and (
       VT1
          and not _ingame_ui.popup_join_lobby_handler.visible
       or not VT1
          and not _ingame_ui.ingame_hud.ingame_player_list_ui:is_active()
          and not Managers.transition:in_fade_active()
          and not _ingame_ui:cutscene_active()
          and not _ingame_ui:unavailable_hero_popup_active()
     )
  then
    if fade then
      vmf.safe_call_nr(self, ERRORS.PREFIX["handle_transition_fade"], _ingame_ui.transition_with_fade, _ingame_ui,
                                                                       transition_name, transition_params)
    else
      vmf.safe_call_nr(self, ERRORS.PREFIX["handle_transition_no_fade"], _ingame_ui.handle_transition, _ingame_ui,
                                                                          transition_name, transition_params)
    end
    return true
  end
end


--[[
  Opens a file with a view data and validates it. Registers the view and returns 'true' if everything is correct.
  * view_data_file_path [string]: path to a file returning view_data table
--]]
function VMFMod:register_view(view_data)
  if vmf.check_wrong_argument_type(self, "register_view", "view_data", view_data, "table") then
    return
  end

  view_data = table.clone(view_data)

  local view_name = view_data.view_name

  if not vmf.safe_call_nrc(self, {ERRORS.PREFIX["register_view_validating"], view_name}, validate_view_data,
                                                                                                         view_data) then
    return
  end

  _views_data[view_name] = {
    mod              = self,
    view_settings    = view_data.view_settings,
    view_transitions = view_data.view_transitions
  }

  if _ingame_ui then
    if not vmf.safe_call_nrc(self, {ERRORS.PREFIX["register_view_injection"], view_name}, inject_view, view_name) then
      _views_data[view_data.view_name] = nil
    end
  end

  return true
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

vmf:hook_safe(IngameUI, "init", function(self)
  _ingame_ui = self
  for view_name, _ in pairs(_views_data) do
    if not vmf.safe_call_nrc(self, {ERRORS.PREFIX["ingameui_hook_injection"], view_name}, inject_view, view_name) then
      _views_data[view_name] = nil
    end
  end
end)


vmf:hook_safe(IngameUI, "destroy", function()
  remove_injected_views(false)
  _ingame_ui = nil
end)

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function vmf.remove_custom_views()
  if _ingame_ui then
    remove_injected_views(true)
  end
end


-- Opens/closes a view if all conditions are met. Since keybinds module can't do UI-related checks, all the cheks are
-- done in this function. This function is called every time some view-toggling keybind is pressed.
function vmf.keybind_toggle_view(mod, view_name, keybind_transition_data, can_be_opened, is_keybind_pressed)
  if _ingame_ui then
    local view_data = _views_data[view_name]
    if not view_data or (view_data.mod ~= mod) then
      mod:error(ERRORS.REGULAR["view_not_registered"], view_name)
      return
    end

    if is_view_active_for_current_level(view_name) then
      if _ingame_ui.current_view == view_name then
        if keybind_transition_data.close_view_transition_name and not Managers.chat:chat_is_focused() then
          if view_data.view_transitions[keybind_transition_data.close_view_transition_name] then
            mod:handle_transition(keybind_transition_data.close_view_transition_name, true,
                                  keybind_transition_data.transition_fade,
                                    keybind_transition_data.close_view_transition_params)
          else
            mod:error(ERRORS.REGULAR["transition_not_registered"], keybind_transition_data.close_view_transition_name,
                                                                    view_name)
          end
        end
      -- Can open views only when keybind is pressed.
      elseif can_be_opened and is_keybind_pressed then
        if keybind_transition_data.open_view_transition_name then
          if view_data.view_transitions[keybind_transition_data.open_view_transition_name] then
            mod:handle_transition(keybind_transition_data.open_view_transition_name, true,
                                   keybind_transition_data.transition_fade,
                                    keybind_transition_data.open_view_transition_params)
          else
            mod:error(ERRORS.REGULAR["transition_not_registered"], keybind_transition_data.open_view_transition_name,
                                                                    view_name)
          end
        end
      end
    end
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- If VMF is reloaded mid-game, get ingame_ui.
local ingame_ui_exists, ingame_ui_return = pcall(function()
if VT1 then
    return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui
else
    return Managers.player.network_manager.matchmaking_manager._ingame_ui
  end
  end)
if ingame_ui_exists then
  _ingame_ui = ingame_ui_return
end
