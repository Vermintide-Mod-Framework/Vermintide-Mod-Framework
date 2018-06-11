local vmf = nil

local _mods = {}
local _mods_unloading_order = {}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function create_mod(mod_name)

  if _mods[mod_name] then
    vmf:error("(new_mod): you can't use name \"%s\" for your mod, because " ..
               "the mod with the same name already exists.", mod_name)
    return
  end

  table.insert(_mods_unloading_order, 1, mod_name)

  local mod = VMFMod:new()
  _mods[mod_name] = mod

  mod._data = {}
  mod._data.name = mod_name
  mod._data.readable_name = mod_name
  mod._data.is_enabled = true
  mod._data.is_togglable = false
  mod._data.is_mutator = false

  return mod
end

-- #####################################################################################################################
-- ##### Public functions ##############################################################################################
-- #####################################################################################################################

function new_mod(mod_name, mod_resources)

  -- Checking for correct arguments
  if type(mod_name) ~= "string" then
    vmf:error("(new_mod): the mod name should be the string, not '%s'.", type(mod_name))
    return
  end

  if type(mod_resources) ~= "table" then
    vmf:error("(new_mod): 'mod_resources' argument should have the 'table' type, not '%s'", type(mod_resources))
    return
  end

  if not mod_resources.mod_script then
    vmf:error("(new_mod): 'mod_resources' table should have 'mod_script' field.", type(mod_name))
    return
  end

  -- Creating a mod object
  local mod = create_mod(mod_name)
  if not mod then
    return
  end

  -- Load localization data file
  if mod_resources.mod_localization then
    local success, localization_table = vmf.xpcall_dofile(mod, "(new_mod)('mod_localization' initialization)",
                                                           mod_resources.mod_localization)
    if success then
      vmf.load_mod_localization(mod, localization_table)
    else
      return
    end
  end

  -- Load mod data file
  if mod_resources.mod_data then
    local success, mod_data_table = vmf.xpcall_dofile(mod, "(new_mod)('mod_data' initialization)",
                                                       mod_resources.mod_data)
    if success then
      vmf.initialize_mod_data(mod, mod_data_table)
    else
      return
    end
  end

  -- Load mod
  if not vmf.xpcall_dofile(mod, "(new_mod)('mod_script' initialization)", mod_resources.mod_script) then
    return
  end

  -- Initialize mod state
  if mod:is_togglable() then
    vmf.initialize_mod_state(mod)
  end
end


function get_mod(mod_name)
  return _mods[mod_name]
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

VMFMod = class(VMFMod)

-- DATA

function VMFMod:get_name()
  return self._data.name
end

function VMFMod:get_readable_name()
  return self._data.readable_name
end

function VMFMod:get_description()
  return self._data.description
end

function VMFMod:is_enabled()
  return self._data.is_enabled
end

function VMFMod:is_togglable()
    return self._data.is_togglable
end

function VMFMod:is_mutator()
  return self._data.is_mutator
end

function VMFMod:get_config()
  return self._data.config
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
    mod:error("(new_mod)(mod_data initialization): mod_data file should return a 'table' value.")
    return
  end

  if mod_data.name then
    mod._data.readable_name = mod_data.name
  end
  mod._data.description  = mod_data.description
  mod._data.is_togglable = mod_data.is_togglable or mod_data.is_mutator
  mod._data.is_mutator   = mod_data.is_mutator

  if mod_data.is_mutator then
    vmf.register_mod_as_mutator(mod, mod_data.mutator_settings)
  end

  if mod_data.options_widgets or (mod_data.is_togglable and not mod_data.is_mutator) then
    vmf.create_options(mod, mod_data.options_widgets)
  end

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
end

-- VARIABLES

vmf.mods = _mods
vmf.mods_unloading_order = _mods_unloading_order