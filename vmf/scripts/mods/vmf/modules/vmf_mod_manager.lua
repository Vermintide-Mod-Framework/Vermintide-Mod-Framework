local vmf = nil

local _mods = {}
local _mods_unloading_order = {}

local ERRORS = {
  REGULAR = {
    -- create_mod:
    duplicate_mod_name = "[VMF Mod Manager] (new_mod) Creating mod object: you can't use name '%s' for your mod " ..
                          "because mod with the same name already exists.",
    -- new_mod:
    mod_name_wrong_type = "[VMF Mod Manager] (new_mod): first argument ('mod_name') should be a string, not %s.",
    mod_resources_wrong_type = "[VMF Mod Manager] (new_mod) '%s': second argument ('mod_resources') should be a " ..
                                "table, not %s.",
    too_late_for_mod_creation = "[VMF Mod Manager] (new_mod) '%s': you can't create mods after vanilla mod manager " ..
                                 "finishes loading mod bundles.",
    -- vmf.initialize_mod_data:
    mod_data_wrong_type = "[VMF Mod Manager] (new_mod) 'mod_data' initialization: mod_data file should return " ..
                           "table, not %s.",
    mod_options_initializing_failed = "[VMF Mod Manager] (new_mod) mod options initialization: could not initialize " ..
                                       "mod's options. %s",
  },
  PREFIX = {
    mod_localization_initialization = "[VMF Mod Manager] (new_mod) 'mod_localization' initialization",
    mod_data_initialization = "[VMF Mod Manager] (new_mod) 'mod_data' initialization",
    mod_script_initialization = "[VMF Mod Manager] (new_mod) 'mod_script' initialization",
  },
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function create_mod(mod_name)
  if _mods[mod_name] then
    vmf:error(ERRORS.REGULAR.duplicate_mod_name, mod_name)
    return
  end

  table.insert(_mods_unloading_order, 1, mod_name)

  local mod = VMFMod:new(mod_name)
  _mods[mod_name] = mod

  return mod
end

-- Resolves a value. If it's a function, executes it. If it's a string, loads the file at that path.
local function resolve_resource(mod, error_prefix_data, resource, resource_value)
  local type_value = type(resource_value)

  if type_value == "string" then
    return vmf.safe_call_dofile(mod, error_prefix_data, resource_value)
  elseif type_value == "function" then
    return vmf.safe_call(mod, error_prefix_data, resource_value, mod)
  elseif type_value == "table" then
    return true, type_value
  end

  mod:warning("%s: 'mod_%s' (optional) should be a string, function or table; not %s",
              error_prefix_data, resource, type_value)
  return false
end

local function load_mod_resource(mod, mod_resources, resource)
  local error_prefix_data = ERRORS.PREFIX["mod_" .. resource .. "_initialization"]
  local resource_value = mod_resources["mod_" .. resource]

  -- All resources can be optionally be nil.
  if resource_value == nil then
    return true
  end

  -- Resolve the value and obtain the result
  local success, return_value = resolve_resource(mod, error_prefix_data, resource, resource_value)

  -- Could not resolve the file. An error will already have been printed.
  if not success then
    return false
  end

  -- Check if there's a VMF initializator for this resource, and execute it if it exists.
  local vmf_initializator = vmf["initialize_mod_" .. resource]
  if not vmf_initializator then
    return true
  end

  return vmf_initializator(mod, return_value)
end

-- #####################################################################################################################
-- ##### Public functions ##############################################################################################
-- #####################################################################################################################

function new_mod(mod_name, mod_resources)
  if type(mod_name) ~= "string" then
    vmf:error(ERRORS.REGULAR.mod_name_wrong_type, type(mod_name))
    return
  end
  if type(mod_resources) ~= "table" then
    vmf:error(ERRORS.REGULAR.mod_resources_wrong_type, mod_name, type(mod_resources))
    return
  end

  if vmf.all_mods_were_loaded then
    vmf:error(ERRORS.REGULAR.too_late_for_mod_creation, mod_name)
    return
  end

  -- Create a mod object
  local mod = create_mod(mod_name)
  if not mod then
    return
  end

  -- Load mod components: localization, data and script. NOTE: Order here is important.
  if not (
    load_mod_resource(mod, mod_resources, "localization") and
    load_mod_resource(mod, mod_resources, "data") and
    load_mod_resource(mod, mod_resources, "script") -- @TODO: Check that this isn't a table.
  )
  then
    return
  end

  -- Initialize mod state
  if mod:get_internal_data("is_togglable") then
    vmf.initialize_mod_state(mod)
  end

  return mod
end


function get_mod(mod_name)
  return _mods[mod_name]
end

-- #####################################################################################################################
-- ##### VMF Initialization ############################################################################################
-- #####################################################################################################################

vmf = create_mod("VMF")

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- MOD DATA INITIALIZATION

function vmf.initialize_mod_data(mod, mod_data)
  if type(mod_data) ~= "table" then
    mod:error(ERRORS.REGULAR.mod_data_wrong_type, type(mod_data))
    return
  end

  -- Set internal mod data
  if mod_data.name then
    vmf.set_internal_data(mod, "readable_name", mod_data.name)
  end
  vmf.set_internal_data(mod, "description",     mod_data.description)
  vmf.set_internal_data(mod, "is_togglable",    mod_data.is_togglable or mod_data.is_mutator)
  vmf.set_internal_data(mod, "is_mutator",      mod_data.is_mutator)
  vmf.set_internal_data(mod, "allow_rehooking", mod_data.allow_rehooking)

  local vanilla_mod_data = Managers.mod._mods[Managers.mod._mod_load_index]
  vmf.set_internal_data(mod, "workshop_id",   vanilla_mod_data.id)
  vmf.set_internal_data(mod, "workshop_name", vanilla_mod_data.name)
  vmf.set_internal_data(mod, "mod_handle",    vanilla_mod_data.handle)

  -- Register mod as mutator @TODO: calling this after options initialization would be better, I guess?
  if mod_data.is_mutator then
    vmf.register_mod_as_mutator(mod, mod_data.mutator_settings)
  end

  -- Mod's options initialization (with legacy widget definitions support)
  if mod_data.options or ((mod_data.is_togglable and not mod_data.is_mutator) and not mod_data.options_widgets) then
    local success, error_message = pcall(vmf.initialize_mod_options, mod, mod_data.options)
    if not success then
      mod:error(ERRORS.REGULAR.mod_options_initializing_failed, error_message)
      return
    end
  elseif mod_data.options_widgets then
    vmf.initialize_mod_options_legacy(mod, mod_data.options_widgets)
  end

  -- Textures initialization @TODO: move to a separate function
  if type(mod_data.custom_gui_textures) == "table" then
    local custom_gui_textures = mod_data.custom_gui_textures

    if type(custom_gui_textures.textures) == "table" then
      vmf.custom_textures(mod, unpack(custom_gui_textures.textures))
    end

    if type(custom_gui_textures.atlases) == "table" then
      for _, atlas_settings in ipairs(custom_gui_textures.atlases) do
        if type(atlas_settings) == "table" then
          vmf.custom_atlas(mod, unpack(atlas_settings))
        end
      end
    end

    if type(custom_gui_textures.ui_renderer_injections) == "table" then
      for _, injection_settings in ipairs(custom_gui_textures.ui_renderer_injections) do
        if type(injection_settings) == "table" then
          vmf.inject_materials(mod, unpack(injection_settings))
        end
      end
    end
  end

  return true
end

-- VARIABLES

vmf.mods = _mods
vmf.mods_unloading_order = _mods_unloading_order
