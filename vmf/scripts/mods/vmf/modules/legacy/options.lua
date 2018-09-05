local vmf = get_mod("VMF")


vmf.initialize_mod_options_legacy = function (mod, widgets_definition)

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

    mod:info("(options): using legacy widget definitions")

    local level                = 1
    local parent_number        = new_widget_index
    local parent_widget        = {["widget_type"] = "header", ["sub_widgets"] = widgets_definition}
    local current_widget       = widgets_definition[1]
    local current_widget_index = 1

    local parent_number_stack        = {}
    local parent_widget_stack        = {}
    local current_widget_index_stack = {}

    while new_widget_index <= 256 do

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
        new_widget_definition.action_name     = current_widget.action          -- keybind [optional?]
        new_widget_definition.show_widget_condition = current_widget.show_widget_condition -- all
        new_widget_definition.parent_index = parent_number -- all [gen]

        if mod_collapsed_widgets then
          new_widget_definition.is_collapsed = mod_collapsed_widgets[current_widget.setting_name]
        end

        if type(mod:get(current_widget.setting_name)) == "nil" then
          mod:set(current_widget.setting_name, current_widget.default_value)
        end

        if current_widget.widget_type == "keybind" then
          local keybind = mod:get(current_widget.setting_name)
          if current_widget.action then
            mod:keybind(current_widget.setting_name, current_widget.action, keybind)
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

    if new_widget_index == 257 then
      mod:error("(vmf_options_view) The limit of 256 options widgets was reached. You can't add any more widgets.")
    end
  end

  table.insert(vmf.options_widgets_data, mod_settings_list_widgets_definitions)
end