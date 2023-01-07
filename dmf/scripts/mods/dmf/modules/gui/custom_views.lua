local dmf = get_mod("DMF")

local _custom_view_persistent_data = dmf:persistent_table("custom_view_data")

local _custom_views_data = {}

local _ingame_ui
local _loaded_views = {}

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
    view_not_registered = "[Custom Views] Toggling view with keybind: view '%s' wasn't registered for this mod.",
    transition_not_registered = "[Custom Views] Toggling view with keybind: transition '%s' wasn't registered for " ..
                                 "'%s' view."
  },
  PREFIX = {
    view_initializing = "[Custom Views] Calling 'init_view_function'",
    view_destroying = "[Custom Views] Destroying view '%s'",
    register_view_validation = "[Custom Views] (register_view) View data validating '%s'",
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
  -- @TODO: Add active setting per mechanism type
  return true
end


-- @THROWS_ERRORS
local function inject_view(view_name)
  if not is_view_active_for_current_level(view_name) then
    return
  end

  local view_settings = _custom_views_data[view_name].view_settings
  local mod           = _custom_views_data[view_name].mod

  local init_view_function = view_settings.init_view_function

  -- Check for collisions. @TODO: Check for collisions by mod
  --if _ingame_ui._view_list[view_name] then
  --  dmf.throw_error(ERRORS.THROWABLE.view_already_exists, view_name)
  --end
  --for transition_name, _ in pairs(transitions) do
  --  if _ingame_ui_transitions[transition_name] then
  --    dmf.throw_error(ERRORS.THROWABLE.transition_already_exists, transition_name)
  --  end
  --end

  -- Initialize and inject view.
  local success = dmf.safe_call(mod, ERRORS.PREFIX.view_initializing, init_view_function,
                                                                             view_settings, {})
  if success then
    _ingame_ui._view_list[view_name] = view_settings
  else
    dmf.throw_error(ERRORS.THROWABLE.view_initializing_failed)
  end

  -- Inject view transitions.
  --for transition_name, transition_function in pairs(transitions) do
  --  _ingame_ui_transitions[transition_name] = transition_function
  --end

  -- Inject view blocked transitions.
  --for blocked_transition_name, _ in pairs(blocked_transitions) do
  --  _ingame_ui.blocked_transitions[blocked_transition_name] = true
  --end
end


local function remove_injected_views(on_reload)
  -- These elements should be removed only on_reload, because, otherwise, they will be deleted automatically.
  if on_reload then

    for view_name, _ in pairs(_custom_views_data) do

      -- Close the view if active
      if Managers.ui:view_active(view_name) then
        
        local force_close = true
        Managers.ui:close_view(view_name, force_close)
      end

      -- Remove the injected view
      _ingame_ui._view_list[view_name] = nil
    end
  end

  --for _, view_data in pairs(_custom_views_data) do
    -- Remove injected transitions.
  --  for transition_name, _ in pairs(view_data.view_transitions) do
  --    _ingame_ui_transitions[transition_name] = nil
  --  end

    -- Remove blocked transitions
  --  local blocked_transitions = view_data.view_settings.blocked_transitions[_ingame_ui.is_in_inn and "inn" or "ingame"]
  --  for blocked_transition_name, _ in pairs(blocked_transitions) do
  --    _ingame_ui.blocked_transitions[blocked_transition_name] = nil
  --  end
  --end
end


-- @THROWS_ERRORS
local function validate_view_data(view_data)
  -- Basic checks.
  if type(view_data.view_name) ~= "string" then
    dmf.throw_error(ERRORS.THROWABLE.view_name_wrong_type, type(view_data.view_name))
  end
  if type(view_data.view_transitions) ~= "table" then
    dmf.throw_error(ERRORS.THROWABLE.view_transitions_wrong_type, type(view_data.view_transitions))
  end
  if type(view_data.view_settings) ~= "table" then
    dmf.throw_error(ERRORS.THROWABLE.view_settings_wrong_type, type(view_data.view_settings))
  end

  -- VIEW TRANSITIONS

  local view_transitions = view_data.view_transitions
  for transition_name, transition_function in pairs(view_transitions) do
    if type(transition_function) ~= "function" then
      dmf.throw_error(ERRORS.THROWABLE.transition_wrong_type, transition_name, type(transition_function))
    end
    for another_view_name, another_view_data in pairs(_custom_views_data) do
      for another_transition_name, _ in pairs(another_view_data.view_transitions) do
        if transition_name == another_transition_name then
          dmf.throw_error(ERRORS.THROWABLE.transition_name_taken, transition_name, another_view_data.mod:get_name(),
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
    dmf.throw_error(ERRORS.THROWABLE.init_view_function_wrong_type, type(view_settings.init_view_function))
  end

  -- Verify active if present
  local active = view_settings.active
  if active then
    if type(active) ~= "table" then
      dmf.throw_error(ERRORS.THROWABLE.active_wrong_type, type(active))
    end
    if active.inn == nil or active.ingame == nil then
      dmf.throw_error(ERRORS.THROWABLE.active_missing_element)
    end
    for level_name, value in pairs(active) do
      if level_name ~= "inn" and level_name ~= "ingame" then
        dmf.throw_error(ERRORS.THROWABLE.active_element_wrong_name, level_name)
      end
      if type(value) ~= "boolean" then
        dmf.throw_error(ERRORS.THROWABLE.active_element_wrong_type, level_name, type(value))
      end
    end
  end

  -- Verify blocked transitions if present
  local blocked_transitions = view_settings.blocked_transitions
  if blocked_transitions then
    if type(blocked_transitions) ~= "table" then
      dmf.throw_error(ERRORS.THROWABLE.blocked_transitions_wrong_type, type(blocked_transitions))
    end
    if not blocked_transitions.inn or not blocked_transitions.ingame then
      dmf.throw_error(ERRORS.THROWABLE.blocked_transitions_missing_element)
    end
    for level_name, level_blocked_transitions in pairs(blocked_transitions) do
      if level_name ~= "inn" and level_name ~= "ingame" then
        dmf.throw_error(ERRORS.THROWABLE.blocked_transitions_element_wrong_name, level_name)
      end
      if type(level_blocked_transitions) ~= "table" then
        dmf.throw_error(ERRORS.THROWABLE.blocked_transitions_element_wrong_type, level_name,
                                                                                  type(level_blocked_transitions))
      end
      for transition_name, value in pairs(level_blocked_transitions) do
        if not view_transitions[transition_name] then
          dmf.throw_error(ERRORS.THROWABLE.blocked_transition_invalid, transition_name, level_name)
        end
        if value ~= true then
          dmf.throw_error(ERRORS.THROWABLE.blocked_transition_wrong_value, level_name, transition_name)
        end
      end
    end
  end
end


-- Checks:
--   * View registered
--   * View is loaded/loadable
--   * View is not already active
--   * View is not in the middle of closing
local function can_open_view(view_name)

  if _ingame_ui then
    if
      _custom_views_data[view_name]                   and
      _custom_view_persistent_data.loader_initialized and
      not Managers.ui:view_active(view_name)          and
      not Managers.ui:is_view_closing(view_name)
    then
      return true
    end
  end

  return false
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Wraps ingame_ui transition handling calls in a lot of safety checks. Returns 'true', if call is successful.
  * transition_name    [string]  : name of a transition that should be perfomed
  * ignore_active_menu [boolean] : if 'ingame_ui.menu_active' should be ignored
  * fade               [boolean] : if transition should be performed with fade
  * transition_params  [anything]: parameter, which will be passed to callable transition function, 'on_exit' method of
                                   the old view and 'on_enter' method of the new view
--]]
function DMFMod:handle_transition()
  return true
end


--[[
  Opens a file with a view data and validates it. Registers the view and returns 'true' if everything is correct.
  * view_data_file_path [string]: path to a file returning view_data table
--]]
function DMFMod:register_view(view_data)
  if dmf.check_wrong_argument_type(self, "register_view", "view_data", view_data, "table") then
    return
  end

  view_data = table.clone(view_data)

  local view_name = view_data.view_name
  view_data.view_settings.name = view_name

  if view_data.view_settings.close_on_hotkey_pressed == nil then
    view_data.view_settings.close_on_hotkey_pressed = true
  end

  if not dmf.safe_call_nrc(self, {ERRORS.PREFIX.register_view_validation, view_name}, validate_view_data,
                                                                                                         view_data) then
    return
  end

  _custom_views_data[view_name] = {
    mod              = self,
    view_settings    = view_data.view_settings,
    view_transitions = view_data.view_transitions,
    view_options     = view_data.view_options,
  }

  if _ingame_ui then
    if not dmf.safe_call_nrc(self, {ERRORS.PREFIX.register_view_injection, view_name}, inject_view, view_name) then
      _custom_views_data[view_data.view_name] = nil
    end
  end

  return true
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################


-- Track the creation of the view loader
dmf:hook_safe(ViewLoader, "init", function()
  _custom_view_persistent_data.loader_initialized = true
end)


-- Track the loading of views, set the loader flag if class selection is reached
dmf:hook_safe(UIManager, "load_view", function(self, view_name)
  if view_name == "class_selection_view" then
    _custom_view_persistent_data.loader_initialized = true
  end
  _loaded_views[view_name] = true
end)

-- Track the unloading of views
dmf:hook_safe(UIManager, "unload_view", function(self, view_name)
  _loaded_views[view_name] = nil
end)


-- Store the view handler for later use and inject views
dmf:hook_safe(UIViewHandler, "init", function(self)
  _ingame_ui = self
  for view_name, _ in pairs(_custom_views_data) do
    if not dmf.safe_call_nrc(self, {ERRORS.PREFIX.ingameui_hook_injection, view_name}, inject_view, view_name) then
      _custom_views_data[view_name] = nil
    end
  end
end)

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function dmf.remove_custom_views()
  if _ingame_ui then
    remove_injected_views(true)
  end
end


-- Opens/closes a view if all conditions are met. Since keybinds module can't do UI-related checks, all the cheks are
-- done in this function. This function is called every time some view-toggling keybind is pressed.
function dmf.keybind_toggle_view(mod, view_name, keybind_transition_data, can_perform_action, is_keybind_pressed)

  if _ingame_ui then

    -- Check that the view is registered
    local view_data = _custom_views_data[view_name]
    if not view_data or (view_data.mod ~= mod) then
      mod:error(ERRORS.REGULAR.view_not_registered, view_name)
      return
    end

    -- If the view is open, this is a toggle close
    if Managers.ui:view_active(view_name) then

      -- Don't close the view if it's already closing
      if not Managers.ui:is_view_closing(view_name) then
        local force_close = true
        Managers.ui:close_view(view_name, force_close)
      end

    -- Otherwise, this is a toggle open
    elseif can_perform_action and is_keybind_pressed then
      
      local validation_function = view_data.view_settings.validation_function
      local can_open_and_validated = can_open_view(view_name) and (not validation_function or validation_function())

      -- Checks for inactive, not closing, no other open view, loaded/loadable, and validation
      if not can_open_and_validated then
        return
      end

      local view_options = view_data.view_options
      local close_all = view_options and view_options.close_all or false
      local close_previous = view_options and view_options.close_previous or false
      local close_transition_time = view_options and view_options.close_transition_time or nil
      local transition_time = view_options and view_options.transition_time or nil

      local view_context = {}
      local use_transition_ui = view_data.view_settings.use_transition_ui
      local no_transition_ui = use_transition_ui == false
      local view_settings_override = no_transition_ui and {
        use_transition_ui = false
      }

      -- Open the view with default parameters
      Managers.ui:open_view(view_name, transition_time, close_previous,
                                      close_all, close_transition_time, view_context, view_settings_override)

    end
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- If DMF is reloaded mid-game, get ingame_ui.
_ingame_ui = Managers.ui and Managers.ui._view_handler
