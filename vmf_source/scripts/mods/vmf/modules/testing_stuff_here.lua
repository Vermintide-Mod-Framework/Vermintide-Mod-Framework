local mod = new_mod("test_mod")
--[[
    mod:hook("GenericAmmoUserExtension.update", function(func, self, unit, input, dt, context, t)
      func(self, unit, input, dt, context, t)
      print("333")
      end)
    mod:hook_disable("GenericAmmoUserExtension.update")

    mod:hook("MatchmakingManager.all_peers_ready", function(func, ...)
  --if not mod:is_suspended() then
  --  return true
  --else
  --  return func(...)
  --end
  mod:echo("whatever")
  return true
end)
    mod:disable_all_hooks()
]]

--[[
    --mod:hook_enable("GenericAmmoUserExtension.update")
    --mod:hook_disable("GenericAmmoUserExtension.update")
    --mod:hook_remove("GenericAmmoUserExtension.update")
    mod:hook("MatchmakingManager.update", function(func, ...)
      func(...)
      print("555")
      end)
--]]
    --mod:disable_all_hooks()
    --mod:enable_all_hooks()
    --mod:remove_all_hooks()

    --mod:hook_remove("GenericAmmoUserExtension.update")
    --mod:hook_remove("MatchmakingManager.update")
    --table.dump(HOOKED_FUNCTIONS, "HOOKED_FUNCTIONS", 3)


    --mod.unload = function()
    --  print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    --end

    --mod:pcall(function()
    --    return assert(loadstring("return bla.bla"))()
    --  end)


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
    ["default_value"] = {"f", "ctrl"},
    ["action"] = "whatever"
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
mod.whatever = function(message)
  mod:echo("whatever")
end

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

--[[
  local mod = new_mod("test_mod2")
  mod:create_options(options_widgets, true, "Bots Improvements", "Mod description")

  local mod = new_mod("test_mod3")
  mod:create_options(options_widgets, true, "Show Healhbars", "Mod description")

  local mod = new_mod("test_mod4")
  mod:create_options(options_widgets, true, "Ammo Meter", "Mod description")

  local mod = new_mod("test_mod5")
  mod:create_options(options_widgets, true, "Show Damage", "Mod description")

  local mod = new_mod("test_mod6")
  mod:create_options(options_widgets, true, "Kick & Ban", "Mod description")
]]
