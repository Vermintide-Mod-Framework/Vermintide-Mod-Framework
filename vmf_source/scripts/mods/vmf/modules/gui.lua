local vmf = get_mod("VMF")

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
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

  local wtf = func(world, unpack(ui_renderer_materials))
  print (tostring(wtf))
  return wtf
end)


vmf:hook("UIAtlasHelper.get_atlas_settings_by_texture_name", function(func, texture_name)

  if none_atlas_textures[texture_name] then
    return
  end

  return func(texture_name)
end)

--inject_material("materials/yoba_face", "yoba_face", "ui_passes", "ingame_ui")

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- @TODO: close and unload menu on_reload
-- something for hotkeys
--IngameUI.init to make hotkeys? no

local views_settings = {}
local transitions = {}

VMFMod.register_new_view = function (self, new_view_data)
  views_settings[new_view_data.view_name] = new_view_data.view_settings

  for transition_name, transition_function in pairs(new_view_data.view_transitions) do
    transitions[transition_name] = transition_function
  end

  -- @TODO: maybe there's better way to do this?
  -- can be called only on reloading vmf
  local ingame_ui_exists, ingame_ui = pcall(function () return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui end)

  if ingame_ui_exists then

    -- set 'ingame_ui.views'
    local new_view_name = new_view_data.view_name
    local new_view_init_function = new_view_data.view_settings.init_view_function

    if not ingame_ui.views[new_view_name] then --@TODO: since I do this check, close and unload custom menus while reloading
      ingame_ui.views[new_view_name] = new_view_init_function(ingame_ui.ingame_ui_context)
    end

    -- set 'ingame_ui.blocked_transitions'
    local blocked_transitions = new_view_data.view_settings.blocked_transitions
    local current_blocked_transitions = ingame_ui.is_in_inn and blocked_transitions.inn or blocked_transitions.ingame

    for blocked_transition_name, _ in pairs(current_blocked_transitions) do
      ingame_ui.blocked_transitions[blocked_transition_name] = true
    end

    vmf:echo("INGAME_UI EXISTS")
  else
    vmf:echo("INGAME_UI DOESN'T EXIST")
  end
end



--@TODO: hotkey_mapping
vmf:hook("IngameUI.setup_views", function(func, self, ingame_ui_context)
  func(self, ingame_ui_context)

  for view_name, view_settings in pairs(views_settings) do

    if self.is_in_inn then
      if view_settings.active.inn then
        self.views[view_name] = view_settings.init_view_function(ingame_ui_context)
        --self.hotkey_mapping = view_settings.hotkey_mapping
      end

      for blocked_transition_name, _ in pairs(view_settings.blocked_transitions.inn) do
        self.blocked_transitions[blocked_transition_name] = true
      end
    else
      if view_settings.active.ingame then
        self.views[view_name] = view_settings.init_view_function(ingame_ui_context)
        --self.hotkey_mapping = view_settings.hotkey_mapping
      end

      for blocked_transition_name, _ in pairs(view_settings.blocked_transitions.ingame) do
        self.blocked_transitions[blocked_transition_name] = true
      end
    end

  end
end)


vmf:hook("IngameUI.handle_transition", function(func, self, new_transition, ...)

  local successful_execution = pcall(func, self, new_transition, ...)
  if successful_execution then
    return
  else
    if not transitions[new_transition] then -- @TODO: is it right?
      vmf:echo("Some mod is trying to use non existing view transition: " .. new_transition)
      return
    end

    -- this block is pure copypasta from 'IngameUI.handle_transition'
    local blocked_transitions = self.blocked_transitions

    if blocked_transitions and blocked_transitions[new_transition] then
      return
    end

    local previous_transition = self._previous_transition

    if not self.is_transition_allowed(self, new_transition) or (previous_transition and previous_transition == new_transition) then
      return
    end

    local transition_params = {
      ...
    }

    if self.new_transition_old_view then
      return
    end

    local old_view = self.current_view

    transitions[new_transition](self, unpack(transition_params))

    local new_view = self.current_view

    if old_view ~= new_view then
      if self.views[old_view] and self.views[old_view].on_exit then
        printf("[IngameUI] menu view on_exit %s", old_view)
        self.views[old_view]:on_exit(unpack(transition_params))
      end

      if new_view and self.views[new_view] and self.views[new_view].on_enter then
        printf("[IngameUI] menu view on_enter %s", new_view)
        self.views[new_view]:on_enter(unpack(transition_params))
        Managers.state.event:trigger("ingame_ui_view_on_enter", new_view)
      end
    end

    self.new_transition = new_transition
    self.new_transition_old_view = old_view
    self.transition_params = transition_params
    self._previous_transition = new_transition


  end
end)

--[[
Mods.hook.set("whatever", "IngameUI.update", function(func, self, dt, t, disable_ingame_ui, end_of_level_ui)
  func(self, dt, t, disable_ingame_ui, end_of_level_ui)

  local end_screen_active = self.end_screen_active(self)
  local gdc_build = Development.parameter("gdc")
  local input_service = self.input_manager:get_service("ingame_menu")

  if not self.pending_transition(self) and not end_screen_active and not self.menu_active and not self.leave_game and not self.return_to_title_screen and not gdc_build and not self.popup_join_lobby_handler.visible and input_service.get(input_service, "cancel_matchmaking", true) then
    self.handle_transition(self, "vmf_options_view_force")

    --MOOD_BLACKBOARD.menu = true
  end

end)
]]

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

local mod = new_mod("SkipSplashScreen")

mod:hook("StateSplashScreen.on_enter", function(func, self)
  self._skip_splash = true
  func(self)
end)

mod:hook("StateSplashScreen.setup_splash_screen_view", function(func, self)
  func(self)
  self.splash_view = nil
end)