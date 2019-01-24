local vmf = get_mod("VMF")

local _button_injection_data = vmf:persistent_table("button_injection_data")


if VT1 then


  -- Disable Mod Options button during mods reloading
  vmf:hook_safe(IngameView, "update_menu_options", function (self)
    for _, button_info in ipairs(self.active_button_data) do
      if button_info.transition == "vmf_options_view_open" then
        button_info.widget.content.disabled = _button_injection_data.mod_options_button_disabled
        button_info.widget.content.button_hotspot.disabled = _button_injection_data.mod_options_button_disabled
      end
    end
  end)


  -- Inject Mod Options button in current ESC-menu layout
  -- Disable localization for button widget
  vmf:hook(IngameView, "setup_button_layout", function (func, self, layout_data, ...)
    local mods_options_button = {
      display_name = vmf:localize("mods_options"),
      transition = "vmf_options_view_open",
      fade = false
    }
    for i = 1, #layout_data do
      if layout_data[i].transition == "options_menu" and layout_data[i + 1].transition ~= "vmf_options_view_open" then
        table.insert(layout_data, i + 1, mods_options_button)
        break
      end
    end

    func(self, layout_data, ...)

    for _, button_info in ipairs(self.active_button_data) do
      if button_info.transition == "vmf_options_view_open" then
        button_info.widget.style.text.localize = false
        button_info.widget.style.text_disabled.localize = false
        button_info.widget.style.text_click.localize = false
        button_info.widget.style.text_hover.localize = false
        button_info.widget.style.text_selected.localize = false
      end
    end
  end)


else


  local function get_mod_options_button_index(layout_logic)
    for button_index, button_data in ipairs(layout_logic.active_button_data) do
      if button_data.transition == "vmf_options_view_open" then
        return button_index
      end
    end
  end


  -- Disable localization for Mod Options button widget for pc version of ESC-menu
  -- Widget definition: ingame_view_definitions.lua -> UIWidgets.create_default_button
  vmf:hook_safe(IngameView, "on_enter", function (self)
    self.layout_logic._ingame_view = self
  end)
  vmf:hook_safe(IngameViewLayoutLogic, "setup_button_layout", function (self)
    if self._ingame_view then
      local mod_options_button_index = get_mod_options_button_index(self)
      local button_widget = self._ingame_view.stored_buttons[mod_options_button_index]
      button_widget.style.title_text.localize = false
      button_widget.style.title_text_shadow.localize = false
      button_widget.style.title_text_disabled.localize = false
    end
  end)


  -- Disable localization for Mod Options button widget for console version of ESC-menu
  -- Widget definition: hero_window_ingame_view_definitions.lua -> create_title_button
  vmf:hook_safe(HeroWindowIngameView, "on_enter", function (self)
    local button_widget = self._title_button_widgets[get_mod_options_button_index(self.layout_logic)]
    button_widget.style.text.localize = false
    button_widget.style.text_hover.localize = false
    button_widget.style.text_shadow.localize = false
    button_widget.style.text_disabled.localize = false
  end)


  -- Disable Mod Options button during mods reloading
  vmf:hook_safe(IngameViewLayoutLogic, "_update_menu_options_enabled_states", function (self)
    local mod_options_button_index = get_mod_options_button_index(self)
    local mod_options_button_data = self.active_button_data[mod_options_button_index]
    mod_options_button_data.disabled = _button_injection_data.mod_options_button_disabled
  end)


  -- Inject Mod Options button in all possible ESC-menu layouts (except for developer's one, because it will increase
  -- the number of buttons to 10, when the hard limit is 9, which will crash the game)
  vmf:hook_safe(IngameViewLayoutLogic, "init", function (self)
    local mod_options_button = {
      display_name = vmf:localize("mods_options"),
      transition = "vmf_options_view_open",
      fade = false
    }
    for _, layout in pairs(self.layout_list) do
      for i = 1, #layout do
        if layout[i].transition == "options_menu" and layout[i + 1].transition ~= "vmf_options_view_open" then
          table.insert(layout, i + 1, mod_options_button)
          break
        end
      end
    end
  end)


end


vmf.initialize_vmf_options_view = function ()
  vmf:dofile("scripts/mods/vmf/modules/ui/options/vmf_options_view")
  _button_injection_data.mod_options_button_disabled = false
end


vmf.disable_mods_options_button = function ()
  _button_injection_data.mod_options_button_disabled = true
end
