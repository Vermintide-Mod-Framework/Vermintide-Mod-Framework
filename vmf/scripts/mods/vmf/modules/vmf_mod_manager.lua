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
    mod_localization_path_wrong_type = "[VMF Mod Manager] (new_mod) '%s': 'mod_localization' (optional) should be a " ..
                                        "string, not %s.",
    mod_data_path_wrong_type = "[VMF Mod Manager] (new_mod) '%s': 'mod_data' (optional) should be a string, not %s.",
    mod_script_path_wrong_type = "[VMF Mod Manager] (new_mod) '%s': 'mod_script' should be a string, not %s.",
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
  if type(mod_resources.mod_localization) ~= "string" and type(mod_resources.mod_localization) ~= "nil" then
    vmf:error(ERRORS.REGULAR.mod_localization_path_wrong_type, mod_name, type(mod_resources.mod_localization))
    return
  end
  if type(mod_resources.mod_data) ~= "string" and type(mod_resources.mod_data) ~= "nil" then
    vmf:error(ERRORS.REGULAR.mod_data_path_wrong_type, mod_name, type(mod_resources.mod_localization))
    return
  end
  if type(mod_resources.mod_script) ~= "string" then
    vmf:error(ERRORS.REGULAR.mod_script_path_wrong_type, mod_name, type(mod_resources.mod_localization))
    return
  end

  if vmf.all_mods_were_loaded then
    vmf:error(ERRORS.REGULAR.too_late_for_mod_creation, mod_name, type(mod_resources.mod_localization))
    return
  end

  -- Create a mod object
  local mod = create_mod(mod_name)
  if not mod then
    return
  end

  -- Load localization data file
  if mod_resources.mod_localization then
    local success, localization_table = vmf.safe_call_dofile(mod, ERRORS.PREFIX.mod_localization_initialization,
                                                              mod_resources.mod_localization)
    if success then
      vmf.load_mod_localization(mod, localization_table) -- @TODO: return here if not sucessful? rename to "initialize_"
    else
      return
    end
  end

  -- Load mod data file
  if mod_resources.mod_data then
    local success, mod_data_table = vmf.safe_call_dofile(mod, ERRORS.PREFIX.mod_data_initialization,
                                                          mod_resources.mod_data)
    if success and not vmf.initialize_mod_data(mod, mod_data_table) then
      return
    end
  end

  -- Load mod
  if not vmf.safe_call_dofile(mod, ERRORS.PREFIX.mod_script_initialization, mod_resources.mod_script) then
    return
  end

  -- Initialize mod state
  if mod:get_internal_data("is_togglable") then
    vmf.initialize_mod_state(mod)
  end
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

  local mod_manager = Managers.mod
  local current_mod_load_index = mod_manager._mod_load_index
  if current_mod_load_index then
    vmf.set_internal_data(mod, "mod_handle", mod_manager._mods[current_mod_load_index].handle)
  else
    mod:warning("Could not determine current mod load index. Package management won't be available for this mod.")
  end

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
