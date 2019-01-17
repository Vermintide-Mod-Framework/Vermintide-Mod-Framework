local vmf = get_mod("VMF")

-- Legacy definitions can't be stripped because it will break following mods.
-- Warning for these mods is not shown and their authors were notified about the update.
-- However, new mods should not use legacy definitions.
local LEGACY_MODS_VT2 = {
  ["FBA"] = true, -- Full Body Awareness (by 🔰SkacikPL🗾)
  ["crosshairs"] = true, -- Crosshairs Fix (by Skwuruhl)
  ["BuffInfo"] = true, -- Buff Info (by 🔰SkacikPL🗾)
  ["Spooktober"] = true, -- Spooktober (by 🔰SkacikPL🗾)
  ["fly"] = true, -- Aussiemon's Free Flight Mod (by tour.dlang.org/)
  ["Console"] = true, -- Console (by 🔰SkacikPL🗾)
  ["lootRatAmmo"] = true, -- Sack Rat drops ammo (by NonzeroGeoduck7)
  ["ff_notifier"] = true, -- The Not-So-Friendly-Fire Snitch (by Zaphio)
  ["NoGlow"] = true, -- No Glow On Unique Weapons (by prop joe)
  ["StreamingInfo"] = true, -- Info Dump For Streaming (by prop joe)
  ["keyPickupMessage"] = true, -- Notice Key Pickup (by NonzeroGeoduck7)
  ["oldTorch"] = true, -- Torch is not a weapon (by NonzeroGeoduck7)
  ["color"] = true, -- Colorful Unique Weapons (by tour.dlang.org/)
  ["zoom sens"] = true, -- Customizable Zoom Sensitivity (by Skwuruhl)
  ["item_filter"] = true, -- Item Filter (by Gohas)
  ["QuickGameMapSelect"] = true, -- Quick Play - select maps in random order (by NonzeroGeoduck7)
  ["deedNoPickup"] = true, -- Deeds - Tomes / Grims in No-Pickup Mutation (by NonzeroGeoduck7)
  ["hostQuickPlay"] = true, -- Host Solo Quick Play Games (by NonzeroGeoduck7)
  ["RerollImprovements"] = true, -- Reroll Improvements (by prop joe)
  ["bots_impulse_control"] = true, -- Bot Improvements - Impulse Control (by Squatting Bear)
  ["Headshot Only"] = true, -- Headshot Only Mode (by Gohas)
  ["convenience_key_actions"] = true, -- Convenience Key Actions (by Squatting Bear)
  ["Stances"] = true, -- Stances (by 🔰SkacikPL🗾)
  ["bloodyWeapons"] = true, -- Blood for the blood god (by ElCamino)
  ["HideBuffs"] = true, -- UI Tweaks (by prop joe)
  ["Pause"] = true, -- Pause (by prop joe)
  ["armory"] = true, -- Armory (by Fracticality)
  ["InstaKick"] = true, -- Instant Kick (by NonzeroGeoduck7)
  ["AimLines"] = true, -- Aim Lines (by 🔰SkacikPL🗾)
  ["ChatWheel"] = true, -- Chat Wheel (by NonzeroGeoduck7)
  ["traps"] = true, -- Traps (by 🔰SkacikPL🗾)
  ["BossTimer"] = true, -- BossKillTimer (by NonzeroGeoduck7)
  ["Parry Indicator"] = true, -- Parry Indicator (by Gohas)
  ["MMONames"] = true, -- MMO Names (by 🔰SkacikPL🗾)
  ["lumberfoots"] = true, -- Handmaiden has a limited vocabulary (by raindish)
  ["NoWobble"] = true, -- No Wobble (by 🔰SkacikPL🗾)
  ["Weapon Zoom"] = true, -- Weapon Zoom (by Fracticality)
  ["RTAT"] = true, -- Game Speed Changer (by Seelixh 🐥🦆)
  ["loadout_manager_vt2"] = true, -- Loadout Manager (by Squatting Bear)
  ["toggle-crits"] = true, -- Toggle Crits (by Orange Chris)
  ["VermintideReloaded"] = true, -- Vermintide: Reloaded (by Alone and Afraid)
  ["Instagib"] = true, -- Instagib (by Seelixh 🐥🦆)
  ["fb"] = true, -- Fortress Brawl + Melee Friendly Fire (by tour.dlang.org/)
  ["SPF"] = true, -- Single Player Framework (by 🔰SkacikPL🗾)
  ["disco"] = true, -- Disco Lights! (by tour.dlang.org/)
  ["Characters"] = true, -- Any Character! (by tour.dlang.org/)
  ["Bestiary"] = true, -- Bestiary (by Fracticality)
  ["Fleeting time"] = true, -- Fleeting time (by th-om)
  ["gm"] = true, -- Red Shell Disabler + God Mode (by tour.dlang.org/)
  ["GiveWeapon"] = true, -- Give Weapon (by prop joe)
  ["MoreItemsLibrary"] = true, -- More Items Library (by Aussiemon)
  ["Mission timer"] = true, -- Mission timer (by th-om)
  ["feigndeath"] = true, -- Feign Death (by 🔰SkacikPL🗾)
  ["UltReset"] = true, -- Ready Ult (by prop joe)
  ["NerfBats"] = true, -- Nerf Bats (by dragonman68)
  ["perfectdark"] = true, -- Perfect Dark (by 🔰SkacikPL🗾)
  ["Extra-Sensory Deprivation"] = true, -- Extra-Sensory Deprivation (by Dwarf3d)
  ["NoUltCooldown"] = true, -- No Ult Cooldown (by ThePageMan)
  ["DiscordRichVermintide"] = true, -- Discord Rich Presence (by ScrappyCocco97)
  ["BoltStaffTweaks"] = true, -- Bolt Staff Tweaks (by dragonman68)
  ["preparations"] = true, -- Adaptation (Access inventory in match) (by 🔰SkacikPL🗾)
  ["Less Annoying Friendly Fire"] = true, -- Less Annoying Friendly Fire (by pixaal)
  ["RestartLevelCommand"] = true, -- Restart Level Command (by prop joe)
  ["D-Lang"] = true, -- D-Lang (by tour.dlang.org/)
  ["Larger Hordes"] = true, -- Larger Hordes (by \҉/̵i͏cto̡r͘ S̛al͡t̕zpy̵r͏e̢)
  ["Barrels"] = true, -- Barrels Spawns For The Memes! aka the Barrel Meta (by tour.dlang.org/)
  ["Fail Level Hotkey"] = true, -- Restart Level or Return to Keep Hotkeys (by \҉/̵i͏cto̡r͘ S̛al͡t̕zpy̵r͏e̢)
  ["Needii"] = true, -- Needii (by Tomoko 👿)
  ["LockedAndLoaded"] = true, -- LockedAndLoaded (by Badwin)
  ["StickyGrim"] = true, -- StickyGrim (by Badwin)
  ["Dofile"] = true, -- Execute External Lua File (by prop joe)
  ["SoundEventMonitor"] = true, -- [Tool] Sound Event Monitor (by Aussiemon)
  ["E308TestMod"] = true, -- Ammo Decimal Leftovers (by Sgt. Buttersworth [E-308])
  ["Waypoints"] = true, -- Waypoints (by Badwin)
  ["BotImprovements_HeroSelection"] = true, -- Bot Improvements - Hero Selection (by Grimalackt)
  ["NumericUI"] = true, -- Numeric UI (by Necrossin)
  ["BotImprovements_Combat"] = true, -- Bot Improvements - Combat (by Grimalackt)
  ["CreatureSpawner"] = true, -- Creature Spawner (by Aussiemon)
  ["SpawnTweaks"] = true, -- Spawn Tweaks (by prop joe)
  ["MutatorsSelector"] = true, -- Mutators Selector (by prop joe)
  ["FailLevelCommand"] = true, -- Fail/Win/Restart Level Command (by prop joe)
  ["ItemSpawner"] = true, -- Item Spawner (by prop joe)
  ["ui_improvements"] = true, -- UI Improvements (by grasmann)
  ["SkipCutscenes"] = true, -- Skip Cutscenes (by Aussiemon)
  ["HeatIndicator"] = true, -- Heat Indicator (by grasmann)
  ["Healthbars"] = true, -- Healthbars (by grasmann)
  ["ChatBlock"] = true, -- Chat Block (by grasmann)
  ["ShowDamage"] = true, -- Show Damage (by grasmann)
  ["Killbots"] = true, -- Killbots (by prop joe)
  ["CustomHUD"] = true, -- Custom HUD (by prop joe)
  ["ThirdPersonEquipment"] = true, -- Third Person Equipment (by grasmann)
  ["CrosshairCustomization"] = true, -- Crosshair Customization (by prop joe)
  ["TrueSoloQoL"] = true, -- True Solo QoL Tweaks (by prop joe)
  ["NeuterUltEffects"] = true, -- Neuter Ult Effects (by prop joe)
  ["PositiveReinforcementTweaks"] = true, -- Killfeed Tweaks (by prop joe)
  ["ThirdPerson"] = true, -- Third Person (by grasmann)
}

vmf.initialize_mod_options_legacy = function (mod, widgets_definition)
  if VT1 or LEGACY_MODS_VT2[mod:get_name()] then
    mod:info("Using deprecated widget definitions. Please, update your mod.")
  else
    mod:warning("Using deprecated widget definitions. Please, update your mod.")
  end

  local mod_settings_list_widgets_definitions = {}

  local new_widget_definition
  local new_widget_index

  local options_menu_favorite_mods     = vmf:get("options_menu_favorite_mods")
  local options_menu_collapsed_widgets = vmf:get("options_menu_collapsed_widgets")
  local mod_collapsed_widgets = nil
  if options_menu_collapsed_widgets then
    mod_collapsed_widgets = options_menu_collapsed_widgets[mod:get_name()]
  end

  -- defining header widget

  new_widget_index = 1

  new_widget_definition = {}

  new_widget_definition.type              = "header"
  new_widget_definition.index             = new_widget_index
  new_widget_definition.mod_name          = mod:get_name()
  new_widget_definition.readable_mod_name = mod:get_readable_name()
  new_widget_definition.tooltip           = mod:get_description()
  new_widget_definition.default           = true
  new_widget_definition.is_togglable      = mod:get_internal_data("is_togglable") and
                                             not mod:get_internal_data("is_mutator")
  new_widget_definition.is_collapsed      = vmf:get("options_menu_collapsed_mods")[mod:get_name()]


  if options_menu_favorite_mods then
    for _, current_mod_name in pairs(options_menu_favorite_mods) do
      if current_mod_name == mod:get_name() then
        new_widget_definition.is_favorited = true
        break
      end
    end
  end

  table.insert(mod_settings_list_widgets_definitions, new_widget_definition)

  -- defining its subwidgets

  if widgets_definition then
    local level                = 1
    local parent_number        = new_widget_index
    local parent_widget        = {["widget_type"] = "header", ["sub_widgets"] = widgets_definition}
    local current_widget       = widgets_definition[1]
    local current_widget_index = 1

    local parent_number_stack        = {}
    local parent_widget_stack        = {}
    local current_widget_index_stack = {}

    while new_widget_index <= 1024 do

      -- if 'nil', we reached the end of the current level widgets list and need to go up
      if current_widget then

        new_widget_index = new_widget_index + 1

        new_widget_definition = {}

        new_widget_definition.type            = current_widget.widget_type     -- all
        new_widget_definition.index           = new_widget_index               -- all [gen]
        new_widget_definition.depth           = level                          -- all [gen]
        new_widget_definition.mod_name        = mod:get_name()                 -- all [gen]
        new_widget_definition.setting_id      = current_widget.setting_name    -- all
        new_widget_definition.title           = current_widget.text            -- all
        new_widget_definition.tooltip         = current_widget.tooltip and (current_widget.text .. "\n" ..
                                                                             current_widget.tooltip)  -- all [optional]
        new_widget_definition.unit_text       = current_widget.unit_text       -- numeric [optional]
        new_widget_definition.range           = current_widget.range           -- numeric
        new_widget_definition.decimals_number = current_widget.decimals_number -- numeric [optional]
        new_widget_definition.options         = current_widget.options         -- dropdown
        new_widget_definition.default_value   = current_widget.default_value   -- all
        new_widget_definition.function_name   = current_widget.action          -- keybind [optional?]
        new_widget_definition.show_widget_condition = current_widget.show_widget_condition -- all
        new_widget_definition.parent_index = parent_number -- all [gen]

        if mod_collapsed_widgets then
          new_widget_definition.is_collapsed = mod_collapsed_widgets[current_widget.setting_name]
        end

        if type(mod:get(current_widget.setting_name)) == "nil" then
          mod:set(current_widget.setting_name, current_widget.default_value)
        end

        if current_widget.widget_type == "keybind" then
          new_widget_definition.keybind_trigger = "pressed"
          if current_widget.action == "toggle_mod_state" then
            new_widget_definition.keybind_type = "mod_toggle"
            new_widget_definition.function_name = nil
          else
            new_widget_definition.keybind_type = "function_call"
          end

          local keybind = mod:get(current_widget.setting_name)
          if current_widget.action then
            vmf.add_mod_keybind(
              mod,
              new_widget_definition.setting_id,
              nil,
              new_widget_definition.keybind_trigger,
              new_widget_definition.keybind_type,
              keybind,
              new_widget_definition.function_name
            )
          end
        end

        table.insert(mod_settings_list_widgets_definitions, new_widget_definition)
      end

      if current_widget and (
        current_widget.widget_type == "header" or
        current_widget.widget_type == "group" or
        current_widget.widget_type == "checkbox" or
        current_widget.widget_type == "dropdown"
      ) and current_widget.sub_widgets then

        -- going down to the first subwidget

        level = level + 1

        table.insert(parent_number_stack, parent_number)
        parent_number = new_widget_index

        table.insert(parent_widget_stack, parent_widget)
        parent_widget = current_widget

        table.insert(current_widget_index_stack, current_widget_index)
        current_widget_index = 1
        current_widget = current_widget.sub_widgets[1]

      else
        current_widget_index = current_widget_index + 1
        if parent_widget.sub_widgets[current_widget_index] then
          -- going to the next widget
          current_widget = parent_widget.sub_widgets[current_widget_index]
        else

          -- going up to the widget next to the parent one
          level = level - 1
          parent_number = table.remove(parent_number_stack)
          parent_widget = table.remove(parent_widget_stack)
          current_widget_index = table.remove(current_widget_index_stack)
          if not current_widget_index then
            break
          end
          current_widget_index = current_widget_index + 1
          -- widget next to parent one, or 'nil', if there are no more widgets on this level
          current_widget = parent_widget.sub_widgets[current_widget_index]
        end
      end
    end

    if new_widget_index == 1025 then
      mod:error("(vmf_options_view) The limit of 256 options widgets was reached. You can't add any more widgets.")
    end
  end

  table.insert(vmf.options_widgets_data, mod_settings_list_widgets_definitions)
end
