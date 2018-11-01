local vmf = get_mod("VMF")

local _ingame_ui = nil
-- There's no direct access to local variable 'transitions' in ingame_ui.
local _ingame_ui_transitions = require("scripts/ui/views/ingame_ui_settings").transitions
local _views_data = {}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function find_view_owner(view_name)
end


local function find_transition_owner(transition_name)
end


-- Throws error.
local function inject_elements(view_name)
  local view_settings = _views_data[view_name].view_settings

  local mod                 = _views_data[view_name].mod
  local init_view_function  = view_settings.init_view_function
  local transitions         = _views_data[view_name].view_transitions
  local blocked_transitions = view_settings.blocked_transitions[_ingame_ui.is_in_inn and "inn" or "ingame"]

  -- Check for collisions.
  if _ingame_ui.views[view_name] then
    -- @TODO: throw error
  end
  for transition_name, _ in pairs(transitions) do
    if _ingame_ui_transitions[transition_name] then
      -- @TODO: throw error
    end
  end

  -- Initialize and inject view.
  local success, view = vmf.xpcall(mod, "calling init_view_function", init_view_function, _ingame_ui.ingame_ui_context)
  if success then
    _ingame_ui.views[view_name] = view
  else
    -- @TODO: throw error
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


local function remove_injected_elements(on_reload)
  -- These elements should be removed only on_reload, because, otherwise, they will be deleted automatically.
  if on_reload and _ingame_ui then
    -- If some custom view is active, close it.
    if _views_data[_ingame_ui.current_view] then
      _ingame_ui:handle_transition("exit_menu")
    end

    for view_name, view_data in pairs(_views_data) do
      -- Remove injected views.
      local view = _ingame_ui.views[view_name]
      if view then
        if type(view.destroy) == "function" then
          vmf.xpcall_no_return_values(view_data.mod, "(custom menus) destroy view", view.destroy)
        end
        _ingame_ui.views[view_name] = nil
      end

      -- Remove blocked transitions
      local blocked_transitions = view_data.view_settings.blocked_transitions[_ingame_ui.is_in_inn and "inn" or
                                                                                                        "ingame"]
      for blocked_transition_name, _ in pairs(blocked_transitions) do
        _ingame_ui.blocked_transitions[blocked_transition_name] = nil
      end
    end
  end

  -- Remove injected transitions.
  for _, view_data in pairs(_views_data) do
    for transition_name, _ in pairs(view_data.view_transitions) do
      _ingame_ui_transitions[transition_name] = nil
    end
  end
end


-- Throws error.
-- Make, so blocked transitions can be only the one from this view, so they won't need further checks
local function validate_view_data(view_data)
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

function VMFMod:handle_transition(transition_name, transition_params, fade)
  if _ingame_ui
     and not _ingame_ui:pending_transition()
     and not _ingame_ui:end_screen_active()
     and not _ingame_ui.menu_active
     and not _ingame_ui.leave_game
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
      _ingame_ui:transition_with_fade(transition_name, transition_params)
    else
      _ingame_ui:handle_transition(transition_name, transition_params)
    end
    return true
  end
end


function VMFMod:register_view(view_data)
  if vmf.check_wrong_argument_type(self, "register_view", "view_data", view_data, "table") then
    return
  end

  if vmf.catch_errors(self, "(register_view) view data validating: %s", validate_view_data, view_data) then
    return
  end

  _views_data[view_data.view_name] = {
    mod              = self,
    view_settings    = table.clone(view_data.view_settings),
    view_transitions = table.clone(view_data.view_transitions)
  }

  if _ingame_ui then
    if vmf.catch_errors(self, "(custom views) view injection: %s", inject_elements, view_data.view_name) then
      _views_data[view_data.view_name] = nil
    end
  end
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

vmf:hook_safe(IngameUI, "init", function(self)
  _ingame_ui = self
  for view_name, _ in pairs(_views_data) do
    if vmf.catch_errors(self, "(custom views) view injection: %s", inject_elements, view_name) then
      _views_data[view_name] = nil
    end
  end
end)


vmf:hook_safe(IngameUI, "destroy", function()
  _ingame_ui = nil
  remove_injected_elements(false)
end)

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function vmf.remove_custom_views()
  remove_injected_elements(true)
end


function vmf.keybind_toggle_view(view_name, can_be_opened)
  --@TODO: check if there's the custom view at all. If not, show error.

  if _ingame_ui then
    local mod                 = _views_data[view_name].mod
    local keybind_transitions = _views_data[view_name].view_settings.keybind_transitions
    if not _ingame_ui.menu_suspended then
      if _ingame_ui.current_view == view_name then
        if keybind_transitions.close_view_transition then
          mod:handle_transition(keybind_transitions.close_view_transition, keybind_transitions.close_view_transition_params, keybind_transitions.transition_fade)
        end
      elseif can_be_opened then
        if keybind_transitions.open_view_transition then
          mod:handle_transition(keybind_transitions.open_view_transition, keybind_transitions.close_view_transition_params, keybind_transitions.transition_fade)
        end
      end
    end
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- If VMF is reloaded mid-game, get ingame_ui.
local ingame_ui_exists, ingame_ui_return
if VT1 then
  ingame_ui_exists, ingame_ui_return = pcall(function()
    return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui
  end)
else
  ingame_ui_exists, ingame_ui_return = pcall(function()
    return Managers.player.network_manager.matchmaking_manager._ingame_ui
  end)
end
if ingame_ui_exists then
  _ingame_ui = ingame_ui_return
end