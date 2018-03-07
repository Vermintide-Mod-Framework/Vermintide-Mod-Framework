local vmf = get_mod("VMF")

local _CUSTOM_NONE_ATLAS_TEXTURES = {}
local _CUSTOM_UI_ATLAS_SETTINGS = {}

local _UI_RENDERERS = {}
local _INJECTED_MATERIALS = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local original_gasbtn_function = UIAtlasHelper.get_atlas_settings_by_texture_name
local function check_texture_availability(mod, texture_name)

  local texture_exists, texture_settings = pcall(original_gasbtn_function, texture_name)
  if texture_exists then

    if type(texture_settings) == "nil" then
      mod:error("(custom texture/atlas): texture name '%s' is already used by Fatshark in 'none_atlas_textures'", texture_name)
    else
      mod:error("(custom texture/atlas): texture name '%s' is already used by Fatshark in atlas '%s'", texture_name, tostring(texture_settings.material_name))
    end

    return false
  end

  if _CUSTOM_NONE_ATLAS_TEXTURES[texture_name] then
    mod:error("(custom texture/atlas): texture name '%s' is already used by the mod '%s' as none atlas texture", texture_name, _CUSTOM_NONE_ATLAS_TEXTURES[texture_name])
    return false
  end

  if _CUSTOM_UI_ATLAS_SETTINGS[texture_name] then
    texture_settings = _CUSTOM_UI_ATLAS_SETTINGS[texture_name]
    mod:error("(custom texture/atlas): texture name '%s' is already used by the mod '%s' in atlas '%s'", texture_name, texture_settings.mod_name, tostring(texture_settings.material_name))
    return false
  end

  return true
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.custom_textures = function (self, ...)

  for i, texture_name in ipairs({...}) do
    if type(texture_name) == "string" then
      if check_texture_availability(self, texture_name) then
        _CUSTOM_NONE_ATLAS_TEXTURES[texture_name] = self:get_name()
      end
    else
      self:error("(custom_textures): all arguments should have the string type, but the argument #%s is %s", i, type(texture_name))
    end
  end
end

VMFMod.custom_atlas = function (self, material_settings_file, material_name, masked_material_name, point_sample_material_name,
                                      masked_point_sample_material_name, saturated_material_name)

  -- @TODO: this check is legit... is it?
  if type(material_settings_file)            ~= "string" or
     type(material_name)                     ~= "string" or
     type(masked_material_name)              ~= "string" or
     type(point_sample_material_name)        ~= "string" or
     type(masked_point_sample_material_name) ~= "string" or
     type(saturated_material_name)           ~= "string" then
    self:error("(custom_atlas): all the arguments have to have the string type")
    return
  end

  local material_settings = self:dofile(material_settings_file)
  if material_settings then

    local mod_name = self:get_name()

    for texture_name, texture_settings in pairs(material_settings) do
      if check_texture_availability(self, texture_name) then
        texture_settings.mod_name                          = mod_name

        texture_settings.material_name                     = material_name
        texture_settings.masked_material_name              = masked_material_name
        texture_settings.point_sample_material_name        = point_sample_material_name
        texture_settings.masked_point_sample_material_name = masked_point_sample_material_name
        texture_settings.saturated_material_name           = saturated_material_name

        _CUSTOM_UI_ATLAS_SETTINGS[texture_name] = texture_settings
      end
    end

  else
    self:error("(custom_atlas): can't load 'material_settings'")
  end
end

VMFMod.inject_materials = function (self, ui_renderer_creator, ...)

  if type(ui_renderer_creator) ~= "string" then
    self:error("(inject_materials): argument 'ui_renderer_creator' should have the string type, not %s", type(ui_renderer_creator))
    return
  end

  local injected_materials_list = _INJECTED_MATERIALS[ui_renderer_creator] or {}

  local can_inject = true
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
      self:error("(inject_materials): all arguments should have the string type, but the argument #%s is %s", i + 1, type(new_injected_material))
    end
  end

  _INJECTED_MATERIALS[ui_renderer_creator] = injected_materials_list

  -- recreate GUIs with injected materials for ui_renderers created by 'ui_renderer_creator'
  for ui_renderer, _ in pairs(_UI_RENDERERS) do
    if ui_renderer.vmf_data.ui_renderer_creator == ui_renderer_creator then

      local new_materials_list = table.clone(ui_renderer.vmf_data.original_materials)

      for _, injected_material in ipairs(injected_materials_list) do
        table.insert(new_materials_list, "material")
        table.insert(new_materials_list, injected_material)
      end

      World.destroy_gui(ui_renderer.world, ui_renderer.gui)
      World.destroy_gui(ui_renderer.world, ui_renderer.gui_retained)

      ui_renderer.gui = World.create_screen_gui(ui_renderer.world, "immediate", unpack(new_materials_list))
      ui_renderer.gui_retained = World.create_screen_gui(ui_renderer.world, unpack(new_materials_list))
    end
  end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

local ui_renderer_creating = false
vmf:hook("UIRenderer.create", function(func, world, ...)

  -- FINDING OUT WHO CREATED UI_RENDERER

  local ui_renderer_creator =  nil

  local callstack = debug.traceback()
  -- get the name of lua script which called 'UIRenderer.create'
  -- it's always the 3rd string of the 'debug.traceback()' output
  local i = 0
  for s in callstack:gmatch("(.-)\n") do
    i = i + 1
    if i == 3 then
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

  if _INJECTED_MATERIALS[ui_renderer_creator] then
    for _, injected_material in ipairs(_INJECTED_MATERIALS[ui_renderer_creator]) do
      table.insert(ui_renderer_materials, "material")
      table.insert(ui_renderer_materials, injected_material)
    end
  end

  -- DEBUG INFO

  print("UI_RENDERER CREATED BY: " .. ui_renderer_creator) -- @DEBUG
  vmf:dump(ui_renderer_materials, "UI_RENDERER MATERIALS", 1) -- @DEBUG


  -- CREATING THE NEW UI_RENDERER AND SAVING SOME DATA INSIDE OF IT

  ui_renderer_creating = true
  local ui_renderer = func(world, unpack(ui_renderer_materials))

  _UI_RENDERERS[ui_renderer] = true

  ui_renderer.vmf_data.original_materials = {...}
  ui_renderer.vmf_data.ui_renderer_creator = ui_renderer_creator

  return ui_renderer
end)


vmf:hook("MakeTableStrict", function(func, t)

  if ui_renderer_creating then
    t.vmf_data = {}
    ui_renderer_creating = false
  end

  return func(t)
end)


vmf:hook("UIRenderer.destroy", function(func, self, world)

  _UI_RENDERERS[self] = nil

  func(self, world)
end)


vmf:hook("UIAtlasHelper.has_atlas_settings_by_texture_name", function(func, texture_name)

  if _CUSTOM_UI_ATLAS_SETTINGS[texture_name] then
    return true
  end

  return func(texture_name)
end)


vmf:hook("UIAtlasHelper.get_atlas_settings_by_texture_name", function(func, texture_name)

  if _CUSTOM_NONE_ATLAS_TEXTURES[texture_name] then
    return
  end

  if _CUSTOM_UI_ATLAS_SETTINGS[texture_name] then
    return _CUSTOM_UI_ATLAS_SETTINGS[texture_name]
  end

  return func(texture_name)
end)