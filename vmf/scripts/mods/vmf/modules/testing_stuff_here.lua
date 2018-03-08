local mod = new_mod("test_mod")

local options_widgets = {
  {
    ["setting_name"] = "game_mode",
    ["widget_type"] = "dropdown",
    ["text"] = "Game mode",
    ["tooltip"] = "Game mode",
    ["options"] = {
      {--[[1]] text = "Vanilla",       value = "vanilla"},
      {--[[2]] text = "Onslaught",     value = "onslaught"},
      {--[[3]] text = "Hide'and'Seek", value = "hide_n_seek"},
      {--[[4]] text = "Death Wish",    value = "deathwish"},
      {--[[5]] text = "Legendary",     value = "legendary"},
    },
    ["default_value"] = "hide_n_seek",
    ["sub_widgets"] = {
      {
        ["show_widget_condition"] = {3, 4, 5},

        ["setting_name"] = "enable_god_mode",
        ["widget_type"] = "checkbox",
        ["text"] = "Enable God Mode",
        ["tooltip"] = "Enable God Mode",
        ["default_value"] = false
      },
      {
        ["show_widget_condition"] = {2, 3, 4, 5},

        ["setting_name"] = "warn_others",
        ["widget_type"] = "checkbox",
        ["text"] = "Warn joining players about game mode",
        ["tooltip"] = "Warn joining players about game mode",
        ["default_value"] = true,
        ["sub_widgets"] = {
          {
            ["setting_name"] = "whatever",
            ["widget_type"] = "checkbox",
            ["text"] = "Whatever",
            ["tooltip"] = "Whatever," .. "\n" ..
                          "whatever",
            ["default_value"] = true
          }
        }
      }
    }
  },
  {
    ["setting_name"] = "the_keybind",
    ["widget_type"] = "keybind",
    ["text"] = "Some keybind",
    ["tooltip"] = "Probably keybind",
    ["default_value"] = {"g", "ctrl"},
    ["action"] = "whatever"
  },
  {
    ["setting_name"] = "the_keybind2",
    ["widget_type"] = "keybind",
    ["text"] = "Some keybind [toggle]",
    ["tooltip"] = "Probably keybind",
    ["default_value"] = {"f", "ctrl"},
    ["action"] = "toggle_mod"
  },
  {
    ["setting_name"] = "game_mode2",
    ["widget_type"] = "dropdown",
    ["text"] = "Game mode",
    ["tooltip"] = "Ублюдок, мать твою," .. "\n" ..
                  "а-ну иди сюда!",
    ["options"] = {
      {--[[1]] text = "Vanilla",       value = "vanilla"},
      {--[[2]] text = "Onslaught",     value = "onslaught"},
      {--[[3]] text = "Hide'and'Seek", value = "hide_n_seek"},
      {--[[4]] text = "Death Wish",    value = "deathwish"},
      {--[[5]] text = "Legendary",     value = "legendary"},
    }
  },
  {
    ["setting_name"] = "some_weight",
    ["widget_type"] = "numeric",
    ["text"] = "Your weight gain after visiting your granny",
    ["unit_text"] = " kg",
    ["tooltip"] = "Some" .. "\n" ..
                  "description",
    ["range"] = {-5, 60},
    ["default_value"] = 42
  },
  {
    ["setting_name"] = "some_percent",
    ["widget_type"] = "numeric",
    ["text"] = "Your Vermintide II hype level",
    ["unit_text"] = "%",
    ["tooltip"] = "Some" .. "\n" ..
                  "description",
    ["range"] = {0, 146.8},
    ["decimals_number"] = 1,
    ["default_value"] = 100
  },
  {
    ["setting_name"] = "some_number",
    ["widget_type"] = "numeric",
    ["text"] = "Just some boring number",
    ["tooltip"] = "Some" .. "\n" ..
                  "description",
    ["range"] = {-10000, 10000},
    ["default_value"] = 0
  }
}

mod:create_options(options_widgets, true, "Test", "Mod description")

-- chat_broadcast
mod.whatever = function ()
  --mod:echo("whatever")

--[[
  mod:pcall(function()

    local some_table = {1, 2, 3, nil, 4}

    local some_string = ""

    some_table[5] = nil
    for i = 1, #some_table do
      some_string = some_string .. tostring(some_table[i])
    end

    mod:echo(some_string)
    mod:echo(#some_table)

    for _, member in pairs(Managers.chat:channel_members(1)) do
      RPC.rpc_chat_message(member, 3, Network.peer_id(), table.serialize(some_table), "", false, true, false)
    end
  end)]]

  --mod:network_send("rpc_whatever", "all", 1, "yay", true, nil, {4, 5})

  mod:pcall(function()
    RPC.rpc_play_simple_particle_with_vector_variable(Managers.player:local_player().peer_id, 27, Vector3(-3.72465, -1.52876, 2.02713), 32, Vector3(5, 1, 1))
  end)


  --mod.simulate(1, "yay", true, Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.wwise_world, {4, 5})
  --mod.simulate(1, "yay", true, nil, {4, 5})



  --mod.custom_mod_rpc()
end
  --ingame_ui.handle_transition(ingame_ui, "leave_group")

function mod.simulate(...)

  --mod:echo("ONE: " .. select("#", ...))

  local jtable = {
    something = 5,
    well = "asd",
    yay = "s"
  }

  jtable.what = nil



  local tbl = {...}
  --tbl[4] = "what"
  --tbl[5] = tbl[5]
  --tbl[4] = nil
  tbl[10] = 4
  tbl[12] = 4
  --tbl["hmm"] = "hmm"

  --mod:echo("777: " .. cjson.encode(tbl))

 -- mod:echo("ONE: " .. #tbl)
  --mod:echo("ONE: " .. tostring(tbl[5]))

  --local data = table.serialize({...})
  local data = cjson.encode(tbl)

  --data[10] = 3
  mod:echo("XXX:" .. data)
  --data = data:gsub('null','')
  --local data2 = table.deserialize(data)
  local data2 = cjson.decode(data)

  mod.custom_mod_rpc(unpack(data2))

  for i,v in ipairs(data2) do
    if type(data2[i]) == "userdata" then
      data2[i] = nil
      break
    end
  end

  mod:echo("ONE: " .. select("#", unpack(data2)))

  mod.game_state_changed(unpack(data2, 1, 5))
end

mod.game_state_changed = function (a1, a2, a3, a4, a5)
  mod:echo("RECEIVED PARAMETERS: [1: " .. tostring (a1) .. "], [2:" .. tostring (a2) .. "], [3:" .. tostring (a3) .. "], [4:" .. tostring (a4) .. "], [5:" .. tostring (a5) .. "]")
end


mod.custom_mod_rpc = function (...)
  local args = {...}
  local result = "You recieved custom RPC: "
  for i = 1, #args do
    result = result .. tostring(args[i]) .. " (" .. type(args[i]) .. "), "
  end
  mod:echo(result .. "[%s arguments]" .. tostring(args[5]), #args)
  --local srt = "s" .. nil
end

mod:pcall(
  function()
    --Managers.state.network._event_delegate:unregister(mod, "custom_mod_rpc")
    --Managers.state.network._event_delegate:register(mod, "custom_mod_rpc")
    --Managers.state.network:register_rpc_callbacks(mod, "custom_mod_rpc")
  end
)


mod:network_register("rpc_whatever", mod.game_state_changed)
mod:network_register("yo",mod.game_state_changed)
mod:network_register("test", mod.game_state_changed)

--mod:hook("bla.bla", mod.game_state_changed)
--mod:hook("bla.bla2", mod.game_state_changed)
--mod:hook("bla.bla3", mod.game_state_changed)

local mod3 = new_mod("test_mod3")
--mod3:hook("bla.bla", mod.game_state_changed)
--mod3:hook("bla.bla2", mod.game_state_changed)
--mod3:hook("bla.bla3", mod.game_state_changed)
mod3:network_register("what", mod.game_state_changed)

--[[
mod:hook("ChatManager.rpc_chat_message", function (func, self, sender, channel_id, message_sender, message, localization_param, is_system_message, pop_chat, is_dev)

  if channel_id > 1 then
    mod:echo(message)
  else
    func(self, sender, channel_id, message_sender, message, localization_param, is_system_message, pop_chat, is_dev)
  end
end)
]]

--[[ USEFULL STUFF



mod:hook("ProfileSynchronizer.register_rpcs", function (func, self, network_event_delegate, network_transmit)
  func(self, network_event_delegate, network_transmit)

  network_event_delegate:register(mod, "custom_mod_rpc")
  mod:echo("It's called, ffs")
end)



mod:hook("ProfileSynchronizer.unregister_network_events", function (func, self)

  if self._network_event_delegate then
    self._network_event_delegate:unregister(mod)
  end

  func(self)
end)





--StateIngame.on_enter:
--  ScriptBackendSession.init(network_event_delegate, disable_backend_sessions)
--    backend_session:register_rpcs(network_event_delegate)

--mod:dtf(Managers.state.network._event_delegate.event_table, "RPC", 2)
--mod:dtf(Managers.state.network._event_delegate, "_event_delegate", 2)

mod:dtf(Network, "Network", 2)



mod:hook("PlayerManager.add_remote_player", function (func, self, peer_id, player_controlled, local_player_id, clan_tag)

  mod:echo("PlayerManager.add_remote_player: " .. tostring(peer_id) .. ", " .. tostring(local_player_id))
  return func(self, peer_id, player_controlled, local_player_id, clan_tag)
end)

mod:hook("PlayerManager.add_player", function (func, self, input_source, viewport_name, viewport_world_name, local_player_id)

  mod:echo("PlayerManager.add_player: " .. tostring(local_player_id))
  return func(self, input_source, viewport_name, viewport_world_name, local_player_id)
end)

mod:hook("PlayerManager.remove_player", function (func, self, peer_id, local_player_id)

  func(self, peer_id, local_player_id)
  mod:echo("PlayerManager.remove_player: " .. tostring(peer_id) .. ", " .. tostring(local_player_id))
end)
--]]









--[[
mod:hook("PeerStateMachine.create", function (func, server, peer_id, xb1_preconnect)

  mod:echo("PeerStateMachine.create: " .. tostring(server) .. ", " .. tostring(peer_id))
  return func(server, peer_id, xb1_preconnect)
end)
]]





















--[[
mod:hook("KeystrokeHelper.parse_strokes", function(func, text, index, mode, keystrokes)
  print(tostring(text) .. " " .. tostring(index) .. " " .. tostring(mode) .. " " .. tostring(keystrokes))
  return func(text, index, mode, keystrokes)
end)
]]


  --table.dump(Steam, "Steam", 2)


--[[
local gui = nil

mod:pcall(function()
  local world = Managers.world:world("top_ingame_view")

  -- Generate the GUI
  gui = World.create_screen_gui(
    world,
    "immediate",
    "material", "materials/header_background" -- Load the material we made with the mod SDK
  )
end)

mod:hook("MatchmakingManager.update", function(func, ...)
  func(...)
  mod:pcall(function()
    Gui.bitmap(
      gui,            -- Gui

      -- This is the material name we defined in materials/vmf.material
      "header_background",

      Vector3(400, 400, 300),   -- Position
      Vector2(65, 97),      -- Size
      0)              -- Color
  end)
end)

--[[
--vermintide stress test

  local lots_of_widgets = {}

  for i = 1,256 do
    local some_widget =     {
      ["setting_name"] = "game_mode" .. tostring(i),
      ["widget_type"] = "stepper",
      ["text"] = "Game mode" .. tostring(i),
      ["tooltip"] = "Pick the goddamn game mode" .. "\n" ..
                    "you litle bitch",
      ["options"] = {
        {text = "Vanilla",       value = "vanilla"},
        {text = "Onslaught",     value = "onslaught"},
        {text = "Hide'and'Seek", value = "hide_n_seek"},
        {text = "Death Wish",    value = "deathwish"},
        {text = "Legendary",     value = "legendary"},
      },
      ["default_value"] = "hide_n_seek",
      ["sub_widgets"] = {
        {
          ["show_widget_condition"] = {3, 4, 5},

          ["setting_name"] = "enable_god_mode" .. tostring(i),
          ["widget_type"] = "checkbox",
          ["text"] = "Enable God Mode",
          ["tooltip"] = "Can't do it without cheats," .. "\n" ..
                        "you poor guy?",
          ["default_value"] = false
        },
        {
          ["show_widget_condition"] = {2, 3, 4, 5},

          ["setting_name"] = "warn_others" .. tostring(i),
          ["widget_type"] = "checkbox",
          ["text"] = "Warn joining players about game mode",
          ["tooltip"] = "You don't want others to ruin your game," .. "\n" ..
                        "do you?",
          ["default_value"] = true, -- Default first option is enabled. In this case Below
          ["sub_widgets"] = {
            {
              ["setting_name"] = "whatever" .. tostring(i),
              ["widget_type"] = "checkbox",
              ["text"] = "Whatever",
              ["tooltip"] = "Whatever," .. "\n" ..
                            "whatever",
              ["default_value"] = true -- Default first option is enabled. In this case Below
            }
          }
        }
      }
    }
    table.insert(lots_of_widgets, some_widget)
  end]]

--[[
  mod:keybind("show_message", "show_message", {"s", "ctrl", "alt", "shift"})
  mod:keybind("ohh", "show_message", {"g"})

  local mod = new_mod("test_mod2")
  mod:keybind("show_message", "show_message", {"browser forward"})
  mod.show_message = function()
    mod:echo("YAY")
  end]]

local mod2 = new_mod("SkipSplashScreen")

mod2:hook("StateSplashScreen.on_enter", function(func, self)
  self._skip_splash = true
  func(self)
end)

mod2:hook("StateSplashScreen.setup_splash_screen_view", function(func, self)
  func(self)
  self.splash_view = nil
end)