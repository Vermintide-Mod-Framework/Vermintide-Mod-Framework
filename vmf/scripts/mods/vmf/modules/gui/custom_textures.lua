local vmf = get_mod("VMF")

local _ui_renderers = vmf:persistent_table("_ui_renderers")

local _custom_none_atlas_textures = {}
local _custom_ui_atlas_settings = {}

local _injected_materials = {}

local _show_debug_info = false

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local original_gasbtn_function = UIAtlasHelper.get_atlas_settings_by_texture_name
local function check_texture_availability(mod, texture_name)

  local texture_exists, texture_settings = pcall(original_gasbtn_function, texture_name)
  if texture_exists then

    if type(texture_settings) == "nil" then
      mod:error("(custom texture/atlas): texture name '%s' is already used by Fatshark in 'none_atlas_textures'",
                texture_name)
    else
      mod:error("(custom texture/atlas): texture name '%s' is already used by Fatshark in atlas '%s'",
                texture_name, tostring(texture_settings.material_name))
    end

    return false
  end

  if _custom_none_atlas_textures[texture_name] then
    mod:error("(custom texture/atlas): texture name '%s' is already used by the mod '%s' as none atlas texture",
              texture_name, _custom_none_atlas_textures[texture_name])
    return false
  end

  if _custom_ui_atlas_settings[texture_name] then
    texture_settings = _custom_ui_atlas_settings[texture_name]
    mod:error("(custom texture/atlas): texture name '%s' is already used by the mod '%s' in atlas '%s'",
              texture_name, texture_settings.mod_name, tostring(texture_settings.material_name))
    return false
  end

  return true
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

vmf.custom_textures = function (mod, ...)

  for i, texture_name in ipairs({...}) do
    if type(texture_name) == "string" then
      if check_texture_availability(mod, texture_name) then
        _custom_none_atlas_textures[texture_name] = mod:get_name()
      end
    else
      mod:error("(custom_textures): all arguments should have the string type, but the argument #%s is %s",
                i, type(texture_name))
    end
  end
end

vmf.custom_atlas = function (mod, material_settings_file, material_name, masked_material_name,
                                    point_sample_material_name, masked_point_sample_material_name,
                                    saturated_material_name)

  if vmf.check_wrong_argument_type(mod, "custom_atlas", "material_settings_file",
                                                         material_settings_file, "string") or
     vmf.check_wrong_argument_type(mod, "custom_atlas", "material_name",
                                                         material_name, "string", "nil") or
     vmf.check_wrong_argument_type(mod, "custom_atlas", "masked_material_name",
                                                         masked_material_name, "string", "nil") or
     vmf.check_wrong_argument_type(mod, "custom_atlas", "point_sample_material_name",
                                                         point_sample_material_name, "string", "nil") or
     vmf.check_wrong_argument_type(mod, "custom_atlas", "masked_point_sample_material_name",
                                                         masked_point_sample_material_name, "string", "nil") or
     vmf.check_wrong_argument_type(mod, "custom_atlas", "saturated_material_name",
                                                         saturated_material_name, "string", "nil") then
    return
  end

  local material_settings = mod:dofile(material_settings_file)
  if material_settings then

    local mod_name = mod:get_name()

    for texture_name, texture_settings in pairs(material_settings) do
      if check_texture_availability(mod, texture_name) then
        texture_settings.mod_name                          = mod_name

        texture_settings.material_name                     = material_name
        texture_settings.masked_material_name              = masked_material_name
        texture_settings.point_sample_material_name        = point_sample_material_name
        texture_settings.masked_point_sample_material_name = masked_point_sample_material_name
        texture_settings.saturated_material_name           = saturated_material_name

        _custom_ui_atlas_settings[texture_name] = texture_settings
      end
    end

  else
    mod:error("(custom_atlas): can't load 'material_settings'")
  end
end

vmf.inject_materials = function (mod, ui_renderer_creator, ...)

  if vmf.check_wrong_argument_type(mod, "inject_materials", "ui_renderer_creator", ui_renderer_creator, "string") then
    return
  end

  local injected_materials_list = _injected_materials[ui_renderer_creator] or {}

  local can_inject
  for i, new_injected_material in ipairs({...}) do
    if type(new_injected_material) == "string" then

      can_inject = true

      -- check if injected_materials_list already contains current material
      for _, injected_material in ipairs(injected_materials_list) do
        if new_injected_material == injected_material then
          can_inject = false
          break
        end
      end

      if can_inject then
        table.insert(injected_materials_list, new_injected_material)
      end

    else
      mod:error("(inject_materials): all arguments should have the string type, but the argument #%s is %s",
                i + 1, type(new_injected_material) )
    end
  end

  _injected_materials[ui_renderer_creator] = injected_materials_list

  -- recreate GUIs with injected materials for ui_renderers created by 'ui_renderer_creator'
  local vmf_data

  for ui_renderer, _ in pairs(_ui_renderers) do

    vmf_data = rawget(ui_renderer, "vmf_data")

    if vmf_data.ui_renderer_creator == ui_renderer_creator then

      local new_materials_list = table.clone(vmf_data.original_materials)

      for _, injected_material in ipairs(injected_materials_list) do
        table.insert(new_materials_list, "material")
        table.insert(new_materials_list, injected_material)
      end

      World.destroy_gui(ui_renderer.world, ui_renderer.gui)
      World.destroy_gui(ui_renderer.world, ui_renderer.gui_retained)

      ui_renderer.gui = World.create_screen_gui(ui_renderer.world, "immediate", unpack(new_materials_list))
      ui_renderer.gui_retained = World.create_screen_gui(ui_renderer.world, unpack(new_materials_list))

      vmf_data.is_modified = true
    end
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

local LUA_SCRIPT_CALLER_POSITION = 4
vmf:hook("UIRenderer.create", function(func, world, ...)

  local is_modified = false

  -- FINDING OUT WHO CREATED UI_RENDERER

  local ui_renderer_creator =  nil

  local callstack = debug.traceback()
  -- get the name of lua script which called 'UIRenderer.create'
  -- it's the 4th string of the 'debug.traceback()' output
  local i = 0
  for s in callstack:gmatch("(.-)\n") do
    i = i + 1
    if i == LUA_SCRIPT_CALLER_POSITION then
      ui_renderer_creator = s:match("([^%/]+)%.lua:")
      break
    end
  end

  if not ui_renderer_creator then
    print(Script.callstack())
    vmf:error("(UIRenderer.create): ui_renderer_creator not found. You're never supposed to see this message. " ..
  "If you see this, please, save the game log and report about this incident to the VMF team.")
    return func(world, ...)
  end

  -- CREATING THE LIST OF TEXTURES FOR THE NEW UI_RENDERER

  local ui_renderer_materials = {...}

  if _injected_materials[ui_renderer_creator] then
    for _, injected_material in ipairs(_injected_materials[ui_renderer_creator]) do
      table.insert(ui_renderer_materials, "material")
      table.insert(ui_renderer_materials, injected_material)
    end
    is_modified = true
  end

  -- DEBUG INFO

  if _show_debug_info then
    vmf:info("UI_RENDERER CREATED BY:")
    vmf:info("   %s", ui_renderer_creator)
    vmf:info("UI_RENDERER MATERIALS:")
    for n, material in ipairs(ui_renderer_materials) do
      vmf:info("   [%s]: %s:", n, material)
    end
  end

  -- CREATING THE NEW UI_RENDERER AND SAVING SOME DATA INSIDE OF IT

  local ui_renderer = func(world, unpack(ui_renderer_materials))

  _ui_renderers[ui_renderer] = true

  local vmf_data = {}
  vmf_data.original_materials = {...}
  vmf_data.ui_renderer_creator = ui_renderer_creator
  vmf_data.is_modified = is_modified
  rawset(ui_renderer, "vmf_data", vmf_data)

  return ui_renderer
end)


vmf:hook("UIRenderer.destroy", function(func, self, world)

  _ui_renderers[self] = nil

  func(self, world)
end)


vmf:hook("UIAtlasHelper.has_atlas_settings_by_texture_name", function(func, texture_name)

  if _custom_ui_atlas_settings[texture_name] then
    return true
  end

  return func(texture_name)
end)


vmf:hook("UIAtlasHelper.get_atlas_settings_by_texture_name", function(func, texture_name)

  if _custom_none_atlas_textures[texture_name] then
    return
  end

  if _custom_ui_atlas_settings[texture_name] then
    return _custom_ui_atlas_settings[texture_name]
  end

  return func(texture_name)
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_custom_textures_settings = function()
  _show_debug_info = vmf:get("developer_mode") and vmf:get("log__ui_renderers_info")
end

vmf.reset_guis = function()
  for ui_renderer, _ in pairs(_ui_renderers) do
    local vmf_data = rawget(ui_renderer, "vmf_data")
    if vmf_data.is_modified then
      World.destroy_gui(ui_renderer.world, ui_renderer.gui)
      World.destroy_gui(ui_renderer.world, ui_renderer.gui_retained)
      ui_renderer.gui = World.create_screen_gui(ui_renderer.world, "immediate", unpack(vmf_data.original_materials))
      ui_renderer.gui_retained = World.create_screen_gui(ui_renderer.world, unpack(vmf_data.original_materials))
      vmf_data.is_modified = false
    end
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_custom_textures_settings()