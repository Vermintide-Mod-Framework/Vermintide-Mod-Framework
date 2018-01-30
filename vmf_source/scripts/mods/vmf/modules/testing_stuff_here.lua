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
      ["widget_type"] = "stepper",
      ["text"] = "Game mode",
      ["tooltip"] = "Pick the goddamn game mode" .. "\n" ..
                    "you litle bitch",
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
          ["tooltip"] = "Can't do it without cheats," .. "\n" ..
                        "you poor guy?",
          ["default_value"] = false
        },
        {
          ["show_widget_condition"] = {2, 3, 4, 5},

          ["setting_name"] = "warn_others",
          ["widget_type"] = "checkbox",
          ["text"] = "Warn joining players about game mode",
          ["tooltip"] = "You don't want others to ruin your game," .. "\n" ..
                        "do you?",
          ["default_value"] = true,
          ["sub_widgets"] = {
            {
              ["setting_name"] = "whatever",
              ["widget_type"] = "checkbox",
              ["text"] = "Whatever",
              ["tooltip"] = "Whatever," .. "\n" ..
                            "whatever",
              ["default_value"] = true
            },
            {
              ["setting_name"] = "the_keybind",
              ["widget_type"] = "keybind",
              ["text"] = "Some keybind",
              ["tooltip"] = "Probably keybind",
              ["default_value"] = {"b"},
              ["action"] = "whatever"
            },
          }
        }
      }
    },
    {
      ["setting_name"] = "git_gut",
      ["widget_type"] = "checkbox",
      ["text"] = "Git Gut",
      ["tooltip"] = "Get better at this game," .. "\n" ..
                    "mkay?",
      ["default_value"] = true
    }
  }

  mod:create_options(options_widgets, true, "Test your keybind", "Mod description")

  mod.whatever = function()
    mod:echo("It is working, my dudes!")
  end

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
