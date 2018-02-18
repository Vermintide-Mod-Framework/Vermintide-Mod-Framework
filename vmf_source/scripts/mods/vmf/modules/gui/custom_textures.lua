local vmf = get_mod("VMF")

local injected_materials = {}
local none_atlas_textures = {}

-- @TODO: can several materials be specified via 1 material file? Figure it out.
function inject_material(material_path, material_name, ...)

  --print("[FUCK]: Mods.gui.inject_material " .. material_path .. material_name)

  local material_users = {...}
  if #material_users == 0 then
    material_users = {"all"}
  end

  for _, material_user in ipairs(material_users) do
    if not injected_materials[material_user] then
      injected_materials[material_user] = {}
    end

    table.insert(injected_materials[material_user], material_path)
  end

  none_atlas_textures[material_name] = true
end


--table.dump(injected_materials, "injected_materials", 2)

vmf:hook("UIRenderer.create", function(func, world, ...)

  local ui_renderer_creator =  nil

  -- extract the part with actual callstack
  local callstack = Script.callstack():match('Callstack>(.-)<')
  if callstack then

    -- get the name of lua script which called 'UIRenderer.create'
    -- it's always the 4th string of callstack ([ ] [0] [1] >[2]<)
    -- print(callstack) -- @DEBUG
    local i = 0
    for s in callstack:gmatch("(.-)\n") do
      i = i + 1
      if i == 4 then
        ui_renderer_creator = s:match("([^%/]+)%.lua")
        break --@TODO: uncomment after debugging or ... (?)
      end
        --EchoConsole(s)  -- @DELETEME
    end
  end

  if ui_renderer_creator then
    print("UI_RENDERER CREATED BY: " .. ui_renderer_creator) -- @DEBUG
  else
    --EchoConsole("You're never supposed to see this.")
    --assert(true, "That's not right. That's not right at all!")
    --EchoConsole(callstack)
    return func(world, ...)
  end

  local ui_renderer_materials = {...}

  if injected_materials[ui_renderer_creator] then
    for _, material in ipairs(injected_materials[ui_renderer_creator]) do
      table.insert(ui_renderer_materials, "material")
      table.insert(ui_renderer_materials, material)
    end
  end

  if injected_materials["all"] then
    for _, material in ipairs(injected_materials["all"]) do
      table.insert(ui_renderer_materials, "material")
      table.insert(ui_renderer_materials, material)
    end
  end

  table.dump(ui_renderer_materials, "UI_RENDERER MATERIALS", 2) -- @DEBUG

  return func(world, unpack(ui_renderer_materials))
end)


vmf:hook("UIAtlasHelper.get_atlas_settings_by_texture_name", function(func, texture_name)

  if none_atlas_textures[texture_name] then
    return
  end

  return func(texture_name)
end)