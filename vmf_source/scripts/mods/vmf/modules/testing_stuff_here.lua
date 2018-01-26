local mod = new_mod("test_mod")
--[[
    mod:hook("GenericAmmoUserExtension.update", function(func, self, unit, input, dt, context, t)
      func(self, unit, input, dt, context, t)
      print("333")
      end)
    --mod:hook_disable("GenericAmmoUserExtension.update")
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
          ["default_value"] = true, -- Default first option is enabled. In this case Below
          ["sub_widgets"] = {
            {
              ["setting_name"] = "whatever",
              ["widget_type"] = "checkbox",
              ["text"] = "Whatever",
              ["tooltip"] = "Whatever," .. "\n" ..
                            "whatever",
              ["default_value"] = true -- Default first option is enabled. In this case Below
            }
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
      ["default_value"] = true -- Default first option is enabled. In this case Below
    }
  }
--[[
  mod:create_options(options_widgets, true, "Salvage on the Loottable", "Mod description")

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