local vmf = get_mod("VMF")

local _ingame_hud
local _components_data = {}

local COMPONENT_STATUS = table.enum("REGISTERED", "INJECTED")

local ERRORS = {
  THROWABLE = {
    -- inject_hud_component:
    component_already_exists = "hud component with class_name '%s' already exists.",
    -- validate_component_data:
    class_name_wrong_type = "'class_name' must be a string, not %s.",
    visibility_groups_wrong_type = "'visibility_groups' must be a table, not %s.",
    visibility_groups_key_wrong_type = "'visibility_groups' table keys must be a number, not %s.",
    visibility_groups_value_wrong_type = "'visibility_groups' table values must be a string, not %s.",
    use_hud_scale_wrong_type = "'use_hud_scale' must be a boolean or nil, not %s.",
    validation_func_wrong_type = "'validation_function' must be a function or nil, not %s."
  },
  PREFIX = {
    component_validation = "[Custom HUD Components] (register_hud_component) Hud component data validation '%s'",
    component_injection = "[Custom HUD Components] (inject_hud_component) Hud component injection '%s' ",
    ingamehud_hook_injection = "[Custom HUD Components] Hud component injection '%s'"
  }
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function get_mod_hud_components(mod)
  return table.filter(_components_data, function(component_data)
    return component_data.mod == mod
  end)
end

local function remove_injected_hud_components(mod)

  local visibility_groups_lookup = _ingame_hud._definitions.visibility_groups_lookup

  local components_to_remove = mod and get_mod_hud_components(mod) or _components_data
  for component_name, component_data in pairs(components_to_remove) do
    if component_data.status == COMPONENT_STATUS.INJECTED and _ingame_hud._component_list[component_name] then
      _ingame_hud:_remove_component(_ingame_hud._component_list,
                                    _ingame_hud._components,
                                    _ingame_hud._components_array,
                                    _ingame_hud._components_array_id_lookup,
                                    component_name)

      local component_settings = component_data.component_settings
      for _, visibility_group in ipairs(component_settings.visibility_groups) do
          visibility_groups_lookup[visibility_group].visible_components[component_name] = nil
      end
      _ingame_hud._components_hud_scale_lookup[component_name] = nil
      _ingame_hud._component_list[component_name] = nil

      component_data.status = COMPONENT_STATUS.REGISTERED
    end
  end

end

-- @ THROWS_ERRORS
local function inject_hud_component(component_name)
  local component_data = _components_data[component_name]
  local component_settings = component_data.component_settings

  if not component_data.mod:is_enabled() or component_data.status == COMPONENT_STATUS.INJECTED then
    return
  end

  -- Check for collisions.
  if _ingame_hud._component_list[component_name] then
    vmf.throw_error(ERRORS.THROWABLE.component_already_exists, component_name)
  end

  if component_settings.use_hud_scale then
    _ingame_hud._components_hud_scale_lookup[component_name] = true
  end

  local visibility_groups_lookup = _ingame_hud._definitions.visibility_groups_lookup
  for _, visibility_group in ipairs(component_settings.visibility_groups) do
      visibility_groups_lookup[visibility_group].visible_components[component_name] = true
  end

  if table.contains(component_settings.visibility_groups, _ingame_hud._current_group_name) then
    _ingame_hud._currently_visible_components[component_name] = true
  end

  _ingame_hud._component_list[component_name] = component_settings
  _ingame_hud:_add_component(_ingame_hud._component_list,
                             _ingame_hud._components,
                             _ingame_hud._components_array,
                             _ingame_hud._components_array_id_lookup,
                             component_name)

  component_data.status = COMPONENT_STATUS.INJECTED

  return true
end

-- @ THROWS_ERRORS
local function validate_component_data(component_settings)
  if type(component_settings.class_name) ~= "string" then
    vmf.throw_error(ERRORS.THROWABLE.class_name_wrong_type, type(component_settings.class_name))
  end
  if component_settings.use_hud_scale and type(component_settings.use_hud_scale) ~= "boolean" then
    vmf.throw_error(ERRORS.THROWABLE.use_hud_scale_wrong_type, type(component_settings.use_hud_scale))
  end
  if type(component_settings.visibility_groups) ~= "table" then
    vmf.throw_error(ERRORS.THROWABLE.visibility_groups_wrong_type, type(component_settings.visibility_groups))
  end
  if component_settings.validation_function and type(component_settings.validation_function) ~= "function" then
    vmf.throw_error(ERRORS.THROWABLE.validation_func_wrong_type, type(component_settings.validation_function))
  end

  local visibility_groups = component_settings.visibility_groups
  for key, visibility_group in pairs(visibility_groups) do
    if type(key) ~= "number" then
      vmf.throw_error(ERRORS.THROWABLE.visibility_groups_key_wrong_type, type(key))
    end
    if type(visibility_group) ~= "string" then
      vmf.throw_error(ERRORS.THROWABLE.visibility_groups_value_wrong_type, type(visibility_group))
    end
  end

end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Validates provided component settings, injects the component, and returns 'true' if everything is correct.
  * component_settings    [table]                          : Settings of the component to register
  ** class_name           [string]              (required) : Name of the class containing the component logic.
  ** visibility_groups    [table<number,string] (required) : Array of visibility group names for the component to be
                                                             included in. "alive" is most common.
  ** use_hud_scale        [boolean]             (optional) : Set to 'true' if ingame_hud should scale the component.
  ** validation_function  [function]            (optional) : Function called by ingame_hud to determine whether to
                                                             create the component.
                                                             Return 'true' to enable.
                                                             Set to nil to always enable.
--]]
function VMFMod:register_hud_component(component_settings)
  if vmf.check_wrong_argument_type(self, "register_hud_component", "component_data", component_settings, "table") then
    return
  end

  component_settings = table.clone(component_settings)

  local component_name = component_settings.class_name

  if not vmf.safe_call_nrc(self,
                           {
                             ERRORS.PREFIX.component_validation,
                             component_name
                           },
                           validate_component_data,
                           component_settings
  ) then
    return
  end

  _components_data[component_name] = {
    mod = self,
    component_settings = component_settings,
    status = COMPONENT_STATUS.REGISTERED
  }

  if _ingame_hud then
    if not vmf.safe_call_nrc(self,
                             {
                               ERRORS.PREFIX.component_injection,
                               component_name
                             },
                             inject_hud_component,
                             component_name
    ) then
      _components_data[component_name] = nil

      return
    end
  end

  return true
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

vmf:hook_safe(IngameHud, "_setup_components", function(self)
  _ingame_hud = self
  for component_name, component_data in pairs(_components_data) do
    if not vmf.safe_call_nrc(self,
                             {
                               ERRORS.PREFIX.ingamehud_hook_injection,
                               component_name
                             },
                             inject_hud_component,
                             component_name
    ) then
      _components_data[component_name] = nil
    end
  end
end)

vmf:hook_safe(IngameHud, "destroy", function()
  _ingame_hud = nil
end)

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################
function vmf.inject_hud_components(mod)
  if _ingame_hud then
    local components_to_inject = get_mod_hud_components(mod)

    for component_name, component_data in pairs(components_to_inject) do
      if not vmf.safe_call_nrc(mod,
                               {
                                 ERRORS.PREFIX.component_injection,
                                 component_name
                               },
                               inject_hud_component,
                               component_name
      ) then
        _components_data[component_name] = nil
      end
    end
  end
end

function vmf.remove_injected_hud_components(mod)
  if _ingame_hud then
    remove_injected_hud_components(mod)
  end
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- If VMF is reloaded mid-game, get ingame_hud.
_ingame_hud = Managers.ui and Managers.ui._ingame_ui.ingame_hud