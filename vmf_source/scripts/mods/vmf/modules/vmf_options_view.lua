--[[
  Don't set settings to the values which aren't defined in options

  Glitch I won't fix soon: widget is collapsed, setting were changed not from .. whatever



  VMFOptionsView.update_picked_option_for_settings_list_widgets
]]
local vmf = get_mod("VMF")

inject_material("materials/header_background", "header_background", "ingame_ui")
inject_material("materials/header_background_lit", "header_background_lit", "ingame_ui")
inject_material("materials/common_widgets_background_lit", "common_widgets_background_lit", "ingame_ui")
inject_material("materials/header_fav_icon", "header_fav_icon", "ingame_ui")
inject_material("materials/header_fav_icon_lit", "header_fav_icon_lit", "ingame_ui")
inject_material("materials/header_fav_arrow", "header_fav_arrow", "ingame_ui")

--███████╗ ██████╗███████╗███╗   ██╗███████╗ ██████╗ ██████╗  █████╗ ██████╗ ██╗  ██╗███████╗
--██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██║  ██║██╔════╝
--███████╗██║     █████╗  ██╔██╗ ██║█████╗  ██║  ███╗██████╔╝███████║██████╔╝███████║███████╗
--╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══██║██╔═══╝ ██╔══██║╚════██║
--███████║╚██████╗███████╗██║ ╚████║███████╗╚██████╔╝██║  ██║██║  ██║██║     ██║  ██║███████║
--╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝

local scenegraph_definition = {

  sg_root = {
    size = {1920, 1080},
    position = {0, 0, UILayer.default + 10},
    is_root = true
  },

    sg_background_border = {
      size = {1206, 1056},
      position = {357, 12, 0},

      parent = "sg_root"
    },

    sg_background_settings_list = {
      size = {1200, 1000},
      position = {360, 65, 1},

      parent = "sg_root"
    },

      sg_mousewheel_scroll_area = {
        size = {1200, 1000},
        position = {0, 0, 0},

        parent = "sg_background_settings_list"
      },

      sg_settings_list_mask = {
        size = {1200, 1000},
        position = {0, 0, 2},

        parent = "sg_background_settings_list"
      },

      sg_settings_list_mask_edge_fade_top = {
        size = {1200, 15},
        position = {0, 985, 3},

        parent = "sg_background_settings_list"
      },

      sg_settings_list_mask_edge_fade_bottom = {
        size = {1200, 15},
        position = {0, 0, 3},

        parent = "sg_background_settings_list"
      },

    sg_background_search_bar = {
      size = {1200, 47},
      position = {360, 15, 1},

      parent = "sg_root"
    },

    sg_scrollbar = {
      size = {360, 1050},
      position = {1560, 40, 0},

      parent = "sg_root"
    },

  sg_dead_space_filler = {
    size = {1920, 1080},
    position = {0, 0, 0},
    scale = "fit" -- WHY?
  }
}


--███╗   ███╗███████╗███╗   ██╗██╗   ██╗    ██╗    ██╗██╗██████╗  ██████╗ ███████╗████████╗███████╗
--████╗ ████║██╔════╝████╗  ██║██║   ██║    ██║    ██║██║██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝██╔════╝
--██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║    ██║ █╗ ██║██║██║  ██║██║  ███╗█████╗     ██║   ███████╗
--██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║    ██║███╗██║██║██║  ██║██║   ██║██╔══╝     ██║   ╚════██║
--██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝    ╚███╔███╔╝██║██████╔╝╚██████╔╝███████╗   ██║   ███████║
--╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝      ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝

local menu_widgets_definition = {


  static_menu_elements = {
    scenegraph_id = "sg_root",
    element = {
      passes = {
          {
            pass_type = "rect",

            style_id  = "background_border"
          },
          {
            pass_type = "rect",

            style_id  = "background_search_bar"
          },
          {
            pass_type = "rect",

            style_id  = "background_settings_list"
          },
          {
            pass_type = "texture",

            style_id  = "settings_list_mask",
            texture_id = "settings_list_mask_texture_id"
          },
          {
            pass_type = "texture_uv",

            style_id = "settings_list_mask_edge_fade_top",
            content_id = "settings_list_mask_edge_fade_top"
          },
          {
            pass_type = "texture_uv",

            style_id = "settings_list_mask_edge_fade_bottom",
            content_id = "settings_list_mask_edge_fade_bottom"
          },
          {
            pass_type = "rect",

            style_id  = "dead_space_filler"
          }
      }
    },
    content = {
      settings_list_mask_texture_id = "mask_rect",

      settings_list_mask_edge_fade_top = {
        texture_id = "mask_rect_edge_fade",
        uvs = {{0, 0}, {1, 1}}
      },

      settings_list_mask_edge_fade_bottom = {
        texture_id = "mask_rect_edge_fade",
        uvs = {{0, 1}, {1, 0}}
      }
    },
    style = {

      background_border = {
        scenegraph_id = "sg_background_border",
        color = {255, 140, 100, 50}
      },

      background_search_bar = {
        scenegraph_id = "sg_background_search_bar",
        color = {255, 0, 0, 0}
      },

      background_settings_list = {
        scenegraph_id = "sg_background_settings_list",
        color = {255, 0, 0, 0}
      },

      settings_list_mask = {
        scenegraph_id = "sg_settings_list_mask",
        color = {255, 255, 255, 255}
      },

      settings_list_mask_edge_fade_top = {
        scenegraph_id = "sg_settings_list_mask_edge_fade_top",
        color = {255, 255, 255, 255}
      },

      settings_list_mask_edge_fade_bottom = {
        scenegraph_id = "sg_settings_list_mask_edge_fade_bottom",
        color = {255, 255, 255, 255}
      },

      dead_space_filler = {
        scenegraph_id = "sg_dead_space_filler",
        color = {150, 0, 0, 0}
      }
    }
  },

  mousewheel_scroll_area = {
    scenegraph_id = "sg_mousewheel_scroll_area",
    element = {
      passes = {
        {
          pass_type = "scroll",
          -- the function is being called only during scrolls
          scroll_function = function (ui_scenegraph, ui_style, ui_content, input_service, scroll_axis)
            local scroll_step          = ui_content.scroll_step
            local current_scroll_value = ui_content.internal_scroll_value

            --current_scroll_value = current_scroll_value + scroll_step*-scroll_axis.y
            --ui_content.internal_scroll_value = math.clamp(current_scroll_value, 0, 1)

            ui_content.internal_scroll_value = ui_content.internal_scroll_value - scroll_axis.y
          end
        }
      }
    },
    content = {
      internal_scroll_value = 0,
      scroll_step = 0.01
    },
    style = {
    }
  },

  scrollbar = UIWidgets.create_scrollbar(scenegraph_definition.sg_scrollbar.size[2], "sg_scrollbar")
}


-- @TODO: make scrollbar full windowed o_O

menu_widgets_definition.scrollbar.content.scroll_bar_info.bar_height_percentage = 0.5
menu_widgets_definition.scrollbar.content.scroll_bar_info.old_value = 0
menu_widgets_definition.scrollbar.content.disable_frame = true
menu_widgets_definition.scrollbar.style.scroll_bar_box.size[1] = 360 -- don't change visual scrollbox size

menu_widgets_definition.scrollbar.content.button_up_hotspot.disable_button = true
menu_widgets_definition.scrollbar.content.button_down_hotspot.disable_button = true

-- removing up and down buttons
table.remove(menu_widgets_definition.scrollbar.element.passes, 7)
table.remove(menu_widgets_definition.scrollbar.element.passes, 7)
table.remove(menu_widgets_definition.scrollbar.element.passes, 8)
table.remove(menu_widgets_definition.scrollbar.element.passes, 8)








script_data.ui_debug_hover = false

local DEBUG_WIDGETS = false

local SETTINGS_LIST_BIG_WIDGET_SIZE = {1194, 80}
local SETTINGS_LIST_REGULAR_WIDGET_SIZE = {1194, 50}


--██╗  ██╗███████╗ █████╗ ██████╗ ███████╗██████╗
--██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
--███████║█████╗  ███████║██║  ██║█████╗  ██████╔╝
--██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗
--██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║
--╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝


local function create_header_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_BIG_WIDGET_SIZE
  local offset_y = - widget_size[2]

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "background_texture"
        },
        {
          pass_type = "texture",

          style_id   = "highlight_texture",
          texture_id = "highlight_texture",

          content_check_function = function (content)
            return content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "texture",

          style_id   = "fav_icon",
          texture_id = "fav_icon_texture",

          content_check_function = function (content)
            return content.is_favorited or content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "texture",

          style_id   = "fav_arrow_up",
          texture_id = "fav_arrow_texture",

          content_check_function = function (content)
            return content.is_favorited and content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "rotated_texture",

          style_id   = "fav_arrow_down",
          texture_id = "fav_arrow_texture",

          content_check_function = function (content)
            return content.is_favorited and content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },
        {
          pass_type = "texture",

          style_id   = "checkbox",
          texture_id = "checkbox_texture",

          content_check_function = function (content)
            return content.is_checkbox_visible
          end
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          style_id   = "fav_icon_hotspot",
          content_id = "fav_icon_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id   = "fav_arrow_up_hotspot",
          content_id = "fav_arrow_up_hotspot",

          content_check_function = function (content)
            return content.parent.is_favorited
          end
        },
        {
          pass_type = "hotspot",

          style_id   = "fav_arrow_down_hotspot",
          content_id = "fav_arrow_down_hotspot",

          content_check_function = function (content)
            return content.parent.is_favorited
          end
        },
        {
          pass_type = "hotspot",

          style_id   = "checkbox_hotspot",
          content_id = "checkbox_hotspot",

          content_check_function = function (content)
            return content.parent.is_checkbox_visible
          end
        },
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph, ui_style, ui_content, ui_renderer)

            if ui_content.highlight_hotspot.is_hover and ui_content.tooltip_text then
              ui_style.tooltip_text.cursor_offset = ui_content.callback_fit_tooltip_to_the_screen(ui_content, ui_style.tooltip_text, ui_renderer)
            end

            if ui_content.highlight_hotspot.on_release and not ui_content.checkbox_hotspot.on_release and not ui_content.fav_icon_hotspot.on_release
              and not ui_content.fav_arrow_up_hotspot.on_release and not ui_content.fav_arrow_down_hotspot.on_release then

              ui_content.callback_hide_sub_widgets(ui_content)
            end

            if ui_content.fav_icon_hotspot.on_release then
              ui_content.callback_favorite(ui_content)
            end

            if ui_content.fav_arrow_up_hotspot.on_release then
              ui_content.callback_move_favorite(ui_content, true)
            end

            if ui_content.fav_arrow_down_hotspot.on_release then
              ui_content.callback_move_favorite(ui_content, false)
            end


            if ui_content.checkbox_hotspot.on_release then

              if ui_content.is_widget_collapsed then
                ui_content.callback_hide_sub_widgets(ui_content)
              end

              local mod_name         = ui_content.mod_name
              local is_mod_suspended = ui_content.is_checkbox_checked

              ui_content.is_checkbox_checked = not ui_content.is_checkbox_checked

              ui_content.callback_mod_suspend_state_changed(mod_name, is_mod_suspended)
            end

            ui_content.fav_icon_texture = ui_content.is_favorited and "header_fav_icon_lit" or "header_fav_icon"
            ui_content.background_texture = ui_content.is_widget_collapsed and "header_background_lit" or "header_background"
            ui_content.checkbox_texture = ui_content.is_checkbox_checked and "checkbox_checked" or "checkbox_unchecked"
            ui_style.fav_arrow_up.color[1] = ui_content.fav_arrow_up_hotspot.is_hover and 255 or 90
            ui_style.fav_arrow_down.color[1] = ui_content.fav_arrow_down_hotspot.is_hover and 255 or 90
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover
          end
        },
        -- DEBUG
        {
          pass_type = "border",

          content_check_function = function (content, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_checkbox_checked = true,
      is_checkbox_visible = false,
      is_widget_visible = true, -- for header it will always be 'true', but I need this variable anyways
      is_widget_collapsed = widget_definition.is_widget_collapsed,
      is_favorited = widget_definition.is_favorited,

      fav_icon_texture   = "header_fav_icon",
      checkbox_texture   = "checkbox_unchecked",
      highlight_texture  = "playerlist_hover",
      background_texture = "header_background",
      fav_arrow_texture  = "header_fav_arrow",

      fav_icon_hotspot        = {},
      fav_arrow_up_hotspot    = {},
      fav_arrow_down_hotspot  = {},
      checkbox_hotspot        = {},
      highlight_hotspot       = {},

      text = widget_definition.readable_mod_name,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      widget_type = widget_definition.widget_type,
    },
    style = {

      -- VISUALS

      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 1}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 2},
        color = {255, 255, 255, 255},
        masked = true
      },

      fav_icon = {
        size = {30, 30},
        offset = {15, offset_y + 25, 3}
      },

      fav_arrow_up = {
        size = {20, 20},
        offset = {20, offset_y + 57, 3},
        color = {90, 255, 255, 255}
      },

      fav_arrow_down = {
        size = {20, 20},
        offset = {20, offset_y + 3, 3},
        angle = math.pi,
        pivot = {10, 10},
        color = {90, 255, 255, 255}
      },

      text = {
        offset = {60, offset_y + 18, 3},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      checkbox = {
        size = {30, 30},
        offset = {widget_size[1] - 180, offset_y + 25, 3},
        masked = true
      },

      -- HOTSPOTS

      fav_icon_hotspot = {
        size = {30, 30},
        offset = {15, offset_y + 25, 3}
      },

      fav_arrow_up_hotspot = {
        size = {20, 20},
        offset = {20, offset_y + 60, 3}
      },

      fav_arrow_down_hotspot = {
        size = {20, 20},
        offset = {20, offset_y, 3}
      },

      checkbox_hotspot = {
        size = {80, 80},
        offset = {widget_size[1] - 205, offset_y, 0}
      },

      -- TOOLTIP

      tooltip_text = {
        font_type = "hell_shark",
        font_size = 18,
        horizontal_alignment = "left",
        vertical_alignment = "top",
        cursor_side = "right",
        max_width = 600,
        cursor_offset = {27, 27},
        cursor_offset_bottom = {27, 27},
        cursor_offset_top = {27, -27},
        line_colors = {
          Colors.get_color_table_with_alpha("cheeseburger", 255),
          Colors.get_color_table_with_alpha("white", 255)
        }
      },

      -- DEBUG

      debug_middle_line = {
        size = {widget_size[1], 1},
        offset = {0, (offset_y + widget_size[2]/2) - 1, 3},
        color = {200, 0, 255, 0}
      },

      offset = {0, offset_y, 0},
      size = {widget_size[1], widget_size[2]},
      color = {50, 255, 255, 255}
    },
    scenegraph_id = scenegraph_id,
    offset = {0, 0, 0}
  }

  return UIWidget.init(definition)
end

--  ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗██████╗  ██████╗ ██╗  ██╗
-- ██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗╚██╗██╔╝
-- ██║     ███████║█████╗  ██║     █████╔╝ ██████╔╝██║   ██║ ╚███╔╝
-- ██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ██╔══██╗██║   ██║ ██╔██╗
-- ╚██████╗██║  ██║███████╗╚██████╗██║  ██╗██████╔╝╚██████╔╝██╔╝ ██╗
--  ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝

local function create_checkbox_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = - widget_size[2]

  local show_widget_condition = nil
  if widget_definition.show_widget_condition then
    show_widget_condition = {}
    for _, i in ipairs(widget_definition.show_widget_condition) do
      show_widget_condition[i] = true
    end
  end

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "background_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id = "text"
        },
        {
          pass_type = "texture",

          style_id = "checkbox",
          texture_id = "checkbox_texture"
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          style_id = "checkbox_hotspot",
          content_id = "checkbox_hotspot"
        },
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph, ui_style, ui_content, ui_renderer)

            if ui_content.highlight_hotspot.is_hover and ui_content.tooltip_text then
              ui_style.tooltip_text.cursor_offset = ui_content.callback_fit_tooltip_to_the_screen(ui_content, ui_style.tooltip_text, ui_renderer)
            end

            if ui_content.highlight_hotspot.on_release and not ui_content.checkbox_hotspot.on_release then
              ui_content.callback_hide_sub_widgets(ui_content)
            end

            if ui_content.checkbox_hotspot.on_release then

              if ui_content.is_widget_collapsed then
                ui_content.callback_hide_sub_widgets(ui_content)
              end

              local mod_name = ui_content.mod_name
              local setting_name = ui_content.setting_name
              local old_value = ui_content.is_checkbox_checked
              local new_value = not old_value

              ui_content.is_checkbox_checked = new_value

              ui_content.callback_setting_changed(mod_name, setting_name, old_value, new_value)
            end

            ui_content.checkbox_texture = ui_content.is_checkbox_checked and "checkbox_checked" or "checkbox_unchecked"
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_checkbox_checked = false,
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_widget_collapsed,

      checkbox_texture = "checkbox_unchecked",
      highlight_texture = "playerlist_hover",
      background_texture = "common_widgets_background_lit",

      checkbox_hotspot = {},
      highlight_hotspot = {},

      text = widget_definition.text,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      setting_name = widget_definition.setting_name,
      widget_type = widget_definition.widget_type,
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_widget_number,
      show_widget_condition = show_widget_condition,
    },
    style = {

      -- VISUALS
      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 1},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.widget_level * 40, offset_y + 5, 2},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      checkbox = {
        size = {30, 30},
        offset = {widget_size[1] - 180, offset_y + 10, 2},
        masked = true
      },

      -- HOTSPOTS

      checkbox_hotspot = {
        size = {30, 30},
        offset = {widget_size[1] - 180, offset_y + 10, 0},
      },

      -- TOOLTIP

      tooltip_text = {
        font_type = "hell_shark",
        font_size = 18,
        horizontal_alignment = "left",
        vertical_alignment = "top",
        cursor_side = "right",
        max_width = 600,
        cursor_offset = {27, 27},
        cursor_offset_bottom = {27, 27},
        cursor_offset_top = {27, -27},
        line_colors = {
          Colors.get_color_table_with_alpha("cheeseburger", 255),
          Colors.get_color_table_with_alpha("white", 255)
        }
      },

      -- DEBUG

      debug_middle_line = {
        size = {widget_size[1], 2},
        offset = {0, (offset_y + widget_size[2]/2) - 1, 10},
        color = {200, 0, 255, 0}
      },

      offset = {0, offset_y, 0},
      size = {widget_size[1], widget_size[2]},
      color = {50, 255, 255, 255}
    },
    scenegraph_id = scenegraph_id,
    offset = {0, 0, 0}
  }

  return UIWidget.init(definition)
end


--███████╗████████╗███████╗██████╗ ██████╗ ███████╗██████╗
--██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
--███████╗   ██║   █████╗  ██████╔╝██████╔╝█████╗  ██████╔╝
--╚════██║   ██║   ██╔══╝  ██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗
--███████║   ██║   ███████╗██║     ██║     ███████╗██║  ██║
--╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝

--[[
      new_widget_definition.widget_index = new_widget_index
      new_widget_definition.widget_level = level
      new_widget_definition.mod_name     = self._name
      new_widget_definition.setting_name = current_widget.setting_name
      new_widget_definition.text         = current_widget.text
      new_widget_definition.tooltip      = current_widget.tooltip
      new_widget_definition.options      = current_widget.options
      new_widget_definition.default      = current_widget.default
      new_widget_definition.show_widget_condition = current_widget.show_widget_condition
      new_widget_definition.parent_widget_number  = parent_number
]]

local function create_stepper_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = - widget_size[2]

  local show_widget_condition = nil
  if widget_definition.show_widget_condition then
    show_widget_condition = {}
    for _, i in ipairs(widget_definition.show_widget_condition) do
      show_widget_condition[i] = true
    end
  end

  local options_texts  = {}
  local options_values = {}

  for _, option in ipairs(widget_definition.options) do
    table.insert(options_texts, option.text)
    table.insert(options_values, option.value)
  end

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "background_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id = "text"
        },
        {
          pass_type = "texture",

          style_id = "left_arrow",
          texture_id = "left_arrow_texture"
        },
        {
          pass_type = "text",

          style_id = "current_option_text",
          text_id = "current_option_text"
        },
        {
          pass_type = "rotated_texture",

          style_id = "right_arrow",
          texture_id = "right_arrow_texture"
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id = "left_arrow_hotspot",
          content_id = "left_arrow_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id = "right_arrow_hotspot",
          content_id = "right_arrow_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph, ui_style, ui_content, ui_renderer)

            if ui_content.highlight_hotspot.is_hover and ui_content.tooltip_text then
              ui_style.tooltip_text.cursor_offset = ui_content.callback_fit_tooltip_to_the_screen(ui_content, ui_style.tooltip_text, ui_renderer)
            end

            if ui_content.highlight_hotspot.on_release and not ui_content.left_arrow_hotspot.on_release and not ui_content.right_arrow_hotspot.on_release then
              ui_content.callback_hide_sub_widgets(ui_content)
            end

            if ui_content.left_arrow_hotspot.on_release or ui_content.right_arrow_hotspot.on_release then

              if ui_content.is_widget_collapsed then
                ui_content.callback_hide_sub_widgets(ui_content)
              end

              local mod_name     = ui_content.mod_name
              local setting_name = ui_content.setting_name
              local old_value    = ui_content.options_values[ui_content.current_option_number]
              local new_option_number = nil

              if ui_content.left_arrow_hotspot.on_release then
                new_option_number = ((ui_content.current_option_number - 1) == 0) and ui_content.total_options_number or (ui_content.current_option_number - 1)
              else
                new_option_number = ((ui_content.current_option_number + 1) == (ui_content.total_options_number + 1)) and 1 or (ui_content.current_option_number + 1)
              end

              ui_content.current_option_number = new_option_number
              ui_content.current_option_text = ui_content.options_texts[new_option_number]

              local new_value = ui_content.options_values[new_option_number]
              ui_content.callback_setting_changed(mod_name, setting_name, old_value, new_value)
            end

            ui_content.left_arrow_texture = ui_content.left_arrow_hotspot.is_hover and "settings_arrow_clicked" or "settings_arrow_normal"
            ui_content.right_arrow_texture = ui_content.right_arrow_hotspot.is_hover and "settings_arrow_clicked" or "settings_arrow_normal"
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content, style)
            return content.tooltip_text and content.highlight_hotspot.is_hover
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_widget_collapsed,

      highlight_texture = "playerlist_hover", -- texture name
      left_arrow_texture = "settings_arrow_normal",
      right_arrow_texture = "settings_arrow_normal",
      background_texture = "common_widgets_background_lit",

      highlight_hotspot = {},
      left_arrow_hotspot = {},
      right_arrow_hotspot = {},

      text = widget_definition.text,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      setting_name = widget_definition.setting_name,
      widget_type = widget_definition.widget_type,

      options_texts  = options_texts,
      options_values = options_values,
      total_options_number = #options_texts,
      current_option_number = 1,
      current_option_text = options_texts[1],
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_widget_number,
      show_widget_condition = show_widget_condition,
    },
    style = {

      -- VISUALS

      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.widget_level * 40, offset_y + 5, 2},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      left_arrow = {
        size = {28, 34},
        offset = {widget_size[1] - 300, offset_y + 8, 2},
        --color = {255, 255, 255, 255},
        masked = true
      },

      right_arrow = {
        size = {28, 34},
        offset = {widget_size[1] - 60, offset_y + 8, 2},
        masked = true,
        --color = {255, 255, 255, 255},
        angle = math.pi,
        pivot = {14, 17}
      },

      current_option_text = {
        offset = {widget_size[1] - 165, offset_y + 4, 3},
        horizontal_alignment = "center",
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
      },
      -- HOTSPOTS

      left_arrow_hotspot = {
        size = {28, 34},
        offset = {widget_size[1] - 300, offset_y + 7, 0}
      },

      right_arrow_hotspot = {
        size = {28, 34},
        offset = {widget_size[1] - 60, offset_y + 7, 0}
      },

      -- TOOLTIP

      tooltip_text = {
        font_type = "hell_shark",
        font_size = 18,
        horizontal_alignment = "left",
        vertical_alignment = "top",
        cursor_side = "right",
        max_width = 600,
        cursor_offset = {27, 27},
        cursor_offset_bottom = {27, 27},
        cursor_offset_top = {27, -27},
        line_colors = {
          Colors.get_color_table_with_alpha("cheeseburger", 255),
          Colors.get_color_table_with_alpha("white", 255)
        }
      },

      -- DEBUG

      debug_middle_line = {
        size = {widget_size[1], 2},
        offset = {0, (offset_y + widget_size[2]/2) - 1, 10},
        color = {200, 0, 255, 0}
      },

      offset = {0, offset_y, 0},
      size = {widget_size[1], widget_size[2]},
      color = {50, 255, 255, 255}
    },
    scenegraph_id = scenegraph_id,
    offset = {0, 0, 0}
  }

  return UIWidget.init(definition)
end




































-- ██████╗██╗      █████╗ ███████╗███████╗
--██╔════╝██║     ██╔══██╗██╔════╝██╔════╝
--██║     ██║     ███████║███████╗███████╗
--██║     ██║     ██╔══██║╚════██║╚════██║
--╚██████╗███████╗██║  ██║███████║███████║
-- ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝

local SETTINGS_LIST_WIDGETS_DEFINITIONS = {} -- numerical sorting [ipairs]


VMFOptionsView = class(VMFOptionsView)
VMFOptionsView.init = function (self, ingame_ui_context)

  self.current_setting_list_offset_y = 0 -- [int]
  self.max_setting_list_offset_y = nil   -- [int]
  self.setting_list_mask_size_y = nil    -- [int]
  self.scroll_step = 40                  -- [int]

  self.is_setting_changes_applied_immidiately = true

  self.menu_widgets = nil                -- [table]
  self.settings_list_widgets = nil       -- [table]

  self.definitions = {}
  self.definitions.scenegraph            = scenegraph_definition
  self.definitions.menu_widgets          = menu_widgets_definition
  self.definitions.settings_list_widgets = SETTINGS_LIST_WIDGETS_DEFINITIONS

  -- get necessary things for the rendering
  self.ui_renderer     = ingame_ui_context.ui_renderer
  self.render_settings = {snap_pixel_positions = true}
  self.ingame_ui       = ingame_ui_context.ingame_ui

  -- create the input service
  local input_manager = ingame_ui_context.input_manager
  input_manager:create_input_service("vmf_options_menu", "IngameMenuKeymaps", "IngameMenuFilters")
  input_manager:map_device_to_service("vmf_options_menu", "keyboard")
  input_manager:map_device_to_service("vmf_options_menu", "mouse")
  input_manager:map_device_to_service("vmf_options_menu", "gamepad")
  self.input_manager = input_manager

  -- wwise_world is used for making sounds (for opening menu, closing menu, etc.)
  local world = ingame_ui_context.world_manager:world("music_world")
  self.wwise_world = Managers.world:wwise_world(world)

  self:create_ui_elements()
end


VMFOptionsView.create_ui_elements = function (self)

  self.menu_widgets = {}

  for name, definition in pairs(self.definitions.menu_widgets) do
    self.menu_widgets[name] = UIWidget.init(definition)
  end

  self.settings_list_widgets = self:build_settings_list()

  self.ui_scenegraph = UISceneGraph.init_scenegraph(self.definitions.scenegraph)

  self.setting_list_mask_size_y = self.ui_scenegraph.sg_settings_list_mask.size[2]

  self:calculate_scrollbar_size()
end


VMFOptionsView.build_settings_list = function (self)

  local scenegraph_id = "sg_settings_list"
  local scenegraph_id_start = "sg_settings_list_start"
  local list_size_y = 0

  local all_widgets = {}
  local mod_widgets = nil

  for _, mod_settings_list_definition in ipairs(self.definitions.settings_list_widgets) do

    mod_widgets = {}

    for _, definition in ipairs(mod_settings_list_definition) do

      local widget = nil
      local size_y = 0
      local widget_type = definition.widget_type

      if widget_type == "checkbox" then
        widget = self:build_checkbox_widget(definition, scenegraph_id_start)
      elseif widget_type == "stepper" then
        widget = self:build_stepper_widget(definition, scenegraph_id_start)
      elseif widget_type == "header" then
        widget = self:build_header_widget(definition, scenegraph_id_start)
      end

      if widget then
        list_size_y = list_size_y + widget.style.size[2]

        table.insert(mod_widgets, widget)
      end
    end

    table.insert(all_widgets, mod_widgets)
  end

  local mask_size = self.definitions.scenegraph.sg_settings_list_mask.size
  local mask_size_x = mask_size[1]
  local mask_size_y = mask_size[2]

  self.definitions.scenegraph[scenegraph_id] = {
    size = {mask_size_x, list_size_y},
    position = {0, 0, -1}, -- changed -1 to 100. nothing changed. seems like it doesn't matter
    offset = {0, 0, 0},

    vertical_alignment = "top",
    horizontal_alignment = "center",

    parent = "sg_settings_list_mask"
  }

  self.definitions.scenegraph[scenegraph_id_start] = {
    size = {1, 1},
    position = {3, 0, 10},

    vertical_alignment = "top",
    horizontal_alignment = "left",

    parent = scenegraph_id
  }

  local is_scrolling_enabled = false
  local max_offset_y = 0

  if mask_size_y < list_size_y then
    is_scrolling_enabled = true
    max_offset_y = list_size_y - mask_size_y
  end

  self.menu_widgets["scrollbar"].content.visible = is_scrolling_enabled
  self.menu_widgets["mousewheel_scroll_area"].content.visible = is_scrolling_enabled

  self.max_setting_list_offset_y = max_offset_y
  self.settings_list_size_y = list_size_y
  self.original_settings_list_size_y = list_size_y
  self.settings_list_scenegraph_id = scenegraph_id
  self.settings_list_scenegraph_id_start = scenegraph_id_start
  self.is_scrolling_enabled = is_scrolling_enabled

  return all_widgets
end

VMFOptionsView.build_header_widget = function (self, definition, scenegraph_id)

  local widget = create_header_widget(definition, scenegraph_id)
  local content = widget.content
  content.is_checkbox_checked = definition.is_mod_toggable
  content.is_checkbox_visible = definition.is_mod_toggable

  content.callback_favorite = callback(self, "callback_favorite")
  content.callback_move_favorite = callback(self, "callback_move_favorite")
  content.callback_mod_suspend_state_changed = callback(self, "callback_mod_suspend_state_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")

  return widget
end

VMFOptionsView.build_stepper_widget = function (self, definition, scenegraph_id)

  local widget = create_stepper_widget(definition, scenegraph_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")

  return widget
end

VMFOptionsView.build_checkbox_widget = function (self, definition, scenegraph_id)

  local widget = create_checkbox_widget(definition, scenegraph_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")

  return widget
end

VMFOptionsView.rearrange_settings_list = function (self)

  local offset_y = 0

  for _, mod_widgets in ipairs(self.settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do
      if widget.content.is_widget_visible then

        widget.offset[2] = -offset_y
        offset_y = offset_y + ((widget.content.widget_type == "header") and SETTINGS_LIST_BIG_WIDGET_SIZE[2] or SETTINGS_LIST_REGULAR_WIDGET_SIZE[2])
      end
    end
  end

  local list_size_y = offset_y
  local mask_size_y = self.setting_list_mask_size_y
  local is_scrolling_enabled = false
  local max_offset_y = 0

  if mask_size_y < list_size_y then
    is_scrolling_enabled = true
    max_offset_y = list_size_y - mask_size_y
  end

  self.ui_scenegraph[self.settings_list_scenegraph_id].size[2] = list_size_y

  self.max_setting_list_offset_y = max_offset_y
  self.settings_list_size_y = list_size_y
  self.current_setting_list_offset_y = math.clamp(self.current_setting_list_offset_y, 0, max_offset_y)


  self.menu_widgets["scrollbar"].content.visible = is_scrolling_enabled
  self.menu_widgets["mousewheel_scroll_area"].content.visible = is_scrolling_enabled

  if is_scrolling_enabled then
    self:calculate_scrollbar_size()
  end
end


VMFOptionsView.sort_settings_list_widgets = function (self)

  local sorted_settings_list_widgets = {}

  local favorited_mods_widgets = {}
  local favorited_mods_names = {}

  local regular_mods_widgets = {}
  local regular_mods_names = {}

  for _, mod_widgets in ipairs(self.settings_list_widgets) do

    if mod_widgets[1].content.is_favorited then
      favorited_mods_widgets[mod_widgets[1].content.mod_name] = mod_widgets
      table.insert(favorited_mods_names, mod_widgets[1].content.mod_name)
    else

    -- if there are 2 (or more) mods with the absolutely same name
    if regular_mods_widgets[mod_widgets[1].content.text] then
      local random_number = tostring(math.random(10000))

      regular_mods_widgets[mod_widgets[1].content.text .. random_number] = mod_widgets
      table.insert(regular_mods_names, mod_widgets[1].content.text .. random_number)
    else
      regular_mods_widgets[mod_widgets[1].content.text] = mod_widgets
      table.insert(regular_mods_names, mod_widgets[1].content.text)
    end
    end
  end

  -- favorite mods sorting + cleaning up the favs list

  local favorite_mods_list = vmf:get("options_menu_favorite_mods")
  if favorite_mods_list then

    local new_favorite_mods_list = {}

    for _, mod_name in ipairs(favorite_mods_list) do
        if favorited_mods_widgets[mod_name] then
          table.insert(sorted_settings_list_widgets, favorited_mods_widgets[mod_name])
          table.insert(new_favorite_mods_list, mod_name)
        end
    end

    vmf:set("options_menu_favorite_mods", new_favorite_mods_list)
  end


  -- regular mods sorting (ABC order)

  table.sort(regular_mods_names, function(a, b) return a:upper() < b:upper() end)

  for _, mod_name in ipairs(regular_mods_names) do
    table.insert(sorted_settings_list_widgets, regular_mods_widgets[mod_name])
  end

  self.settings_list_widgets = sorted_settings_list_widgets
end


VMFOptionsView.callback_fit_tooltip_to_the_screen = function (self, widget_content, widget_style, ui_renderer)

  local cursor_offset_bottom = widget_style.cursor_offset_bottom

  if ui_renderer.input_service then

    local cursor_position = UIInverseScaleVectorToResolution(ui_renderer.input_service.get(ui_renderer.input_service, "cursor"))
    if cursor_position then

      local text = widget_content.tooltip_text
      local max_width = widget_style.max_width

      local font, font_size = UIFontByResolution(widget_style)
      local font_name = font[3]
      local font_material = font[1]

      local _, font_min, font_max = UIGetFontHeight(ui_renderer.gui, font_name, font_size)



      local texts = UIRenderer.word_wrap(ui_renderer, text, font_material, font_size, max_width)
      local num_texts = #texts
      local full_font_height = (font_max + math.abs(font_min)) * RESOLUTION_LOOKUP.inv_scale

      local tooltip_height = full_font_height * num_texts

      if((cursor_offset_bottom[2] / UIResolutionScale() + tooltip_height) > cursor_position[2]) then

        local cursor_offset_top = {}
        cursor_offset_top[1] = widget_style.cursor_offset_top[1]
        cursor_offset_top[2] = widget_style.cursor_offset_top[2] - (tooltip_height * UIResolutionScale())

        return cursor_offset_top
      else
        return cursor_offset_bottom
      end
    end
  end

  return cursor_offset_bottom
end


VMFOptionsView.callback_favorite = function (self, widget_content)

  local mod_name = widget_content.mod_name
  local is_favorited = not widget_content.is_favorited

  local favorite_mods_list = vmf:get("options_menu_favorite_mods")
  favorite_mods_list = favorite_mods_list or {}

  if is_favorited then
    table.insert(favorite_mods_list, mod_name)
  else
    for i, current_mod_name in ipairs(favorite_mods_list) do
      if current_mod_name == mod_name then
        table.remove(favorite_mods_list, i)
        break
      end
    end
  end

  vmf:set("options_menu_favorite_mods", favorite_mods_list)

  widget_content.is_favorited = is_favorited

  self:sort_settings_list_widgets()
  self:rearrange_settings_list()
end


VMFOptionsView.callback_move_favorite = function (self, widget_content, is_moved_up)

  local mod_name = widget_content.mod_name

  local new_index = nil

  local favorite_mods_list = vmf:get("options_menu_favorite_mods")

  for i, current_mod_name in ipairs(favorite_mods_list) do
    if current_mod_name == mod_name then

      new_index = is_moved_up and (i - 1) or (i + 1)
      new_index = math.min(math.max(new_index, 1), #favorite_mods_list)

      table.insert(favorite_mods_list, new_index, table.remove(favorite_mods_list, i))
      break
    end
  end

  vmf:set("options_menu_favorite_mods", favorite_mods_list)

  self:sort_settings_list_widgets()
  self:rearrange_settings_list()
end


VMFOptionsView.callback_hide_sub_widgets = function (self, widget_content)

  local mod_name               = widget_content.mod_name
  local setting_name           = widget_content.setting_name
  local is_widget_collapsed = widget_content.is_widget_collapsed

  local widget_number = not setting_name and 1 -- if (setting_name == nil) -> it's header -> #1

  local are_there_visible_sub_widgets = false

  if not is_widget_collapsed then

    for _, mod_widgets in ipairs(self.settings_list_widgets) do

      if mod_widgets[1].content.mod_name == mod_name then

        for i, widget in ipairs(mod_widgets) do

          if widget_number then
            if widget.content.parent_widget_number == widget_number then
              --vmf:echo(tostring(i))
              are_there_visible_sub_widgets = are_there_visible_sub_widgets or widget.content.is_widget_visible
            end
          else
            if widget.content.setting_name == setting_name then
              widget_number = i
            end
          end
        end
      end
    end
  end

  widget_content.is_widget_collapsed = not is_widget_collapsed and are_there_visible_sub_widgets


  setting_name = setting_name or mod_name -- header

  local all_collapsed_widgets = vmf:get("options_menu_collapsed_widgets")
  all_collapsed_widgets = all_collapsed_widgets or {}

  local mod_collapsed_widgets = all_collapsed_widgets[mod_name]

  if widget_content.is_widget_collapsed then

    mod_collapsed_widgets = mod_collapsed_widgets or {}
    mod_collapsed_widgets[setting_name] = true

    all_collapsed_widgets[mod_name] = mod_collapsed_widgets
  else
    if mod_collapsed_widgets then
      mod_collapsed_widgets[setting_name] = nil

      local is_collapsed_widgets_list_empty = true

      for _, _ in pairs(mod_collapsed_widgets) do
        is_collapsed_widgets_list_empty = false
      end

      if is_collapsed_widgets_list_empty then
        all_collapsed_widgets[mod_name] = nil
      end
    end
  end

  vmf:set("options_menu_collapsed_widgets", all_collapsed_widgets)

  --vmf:echo(tostring(are_there_visible_sub_widgets))

  self:update_settings_list_widgets_visibility(mod_name)
  self:rearrange_settings_list()
end

VMFOptionsView.callback_setting_changed = function (self, mod_name, setting_name, old_value, new_value)
  --vmf:echo("CHANGED: " .. mod_name .. " " .. setting_name .. " " .. tostring(old_value) .. " " .. tostring(new_value))

  if self.is_setting_changes_applied_immidiately then
    get_mod(mod_name):set(setting_name, new_value, true)
  end

  self:update_settings_list_widgets_visibility(mod_name)
  self:rearrange_settings_list()
end

VMFOptionsView.callback_mod_suspend_state_changed = function (self, mod_name, is_suspended)
  --vmf:echo("SUSPENDED: " .. mod_name .. " " .. tostring(is_suspended))

  local mod_suspend_state_list = vmf:get("mod_suspend_state_list")

  if is_suspended then
    mod_suspend_state_list[mod_name] = true
  else
    mod_suspend_state_list[mod_name] = nil
  end

  vmf:set("mod_suspend_state_list", mod_suspend_state_list)

  local mod = get_mod(mod_name)

  if is_suspended then
    if mod.suspended then
      mod.suspended()
    else
      mod:echo("ERROR: suspending from options menu is specified, but function 'mod.suspended()' is not defined", true)
    end
  else
    if mod.unsuspended then
      mod.unsuspended()
    else
      mod:echo("ERROR: suspending from options menu is specified, but function 'mod.unsuspended()' is not defined", true)
    end
  end

  self:update_settings_list_widgets_visibility(mod_name)
  self:rearrange_settings_list()
end


VMFOptionsView.update_picked_option_for_settings_list_widgets = function (self)

  local widget_content = nil
  local widget_type = nil
  local loaded_setting_value = nil

  for _, mod_widgets in ipairs(self.settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do

      widget_content = widget.content
      widget_type = widget_content.widget_type

      if widget_type == "checkbox" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_name)

        if type(loaded_setting_value) == "boolean" then
          widget_content.is_checkbox_checked = loaded_setting_value
        else
          -- @TODO: echo error?
          widget_content.is_checkbox_checked = widget_content.default_value
          get_mod(widget_content.mod_name):set(widget_content.setting_name, widget_content.default_value)
        end

      elseif widget_type == "stepper" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_name)

        local success = false

        for i, option_value in ipairs(widget_content.options_values) do

          if loaded_setting_value == option_value then
            widget_content.current_option_number = i
            widget_content.current_option_text   = widget_content.options_texts[i]
            success = true
          end
        end

        if not success then
          for i, option_value in ipairs(widget_content.options_values) do

            if widget_content.default_value == option_value then
              widget_content.current_option_number = i
              widget_content.current_option_text   = widget_content.options_texts[i]
              get_mod(widget_content.mod_name):set(widget_content.setting_name, widget_content.default_value)
            end
          end
        end

      elseif widget_type == "header" then

        loaded_setting_value = vmf:get("mod_suspend_state_list")

        widget_content.is_checkbox_checked = not loaded_setting_value[widget_content.mod_name]
      end
    end
  end
end


VMFOptionsView.update_settings_list_widgets_visibility = function (self, mod_name)

  --table.dump(self.settings_list_widgets, "WIDGETSSSSSSSS", 3)

  for _, mod_widgets in ipairs(self.settings_list_widgets) do

    if not mod_name or mod_widgets[1].content.mod_name == mod_name then

      for _, widget in ipairs(mod_widgets) do

        if widget.content.parent_widget_number then
          local parent_widget = mod_widgets[widget.content.parent_widget_number]

          -- if 'header' or 'checkbox'
          if parent_widget.style.checkbox then

            widget.content.is_widget_visible = parent_widget.content.is_checkbox_checked and parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed

          -- if 'stepper'
          else
            if widget.content.show_widget_condition then
              widget.content.is_widget_visible = widget.content.show_widget_condition[parent_widget.content.current_option_number] and parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed
            else
              get_mod(widget.content.mod_name):echo("ERROR: the stepper widget in the options menu has sub_widgets, but some of its sub_widgets doesn't have 'show_widget_condition'", true)
            end
          end
        end

      end
    end

  end
end








VMFOptionsView.update = function (self, dt)
  if self.suspended then
    return
  end

  if self.is_scrolling_enabled then
    self:update_scrollbar()

    self:update_mouse_scroll_input(false)
  end

  self.draw_widgets(self, dt)



  local input_manager = self.input_manager
  local input_service = input_manager:get_service("vmf_options_menu")
  if input_service.get(input_service, "toggle_menu") then
    --self.ingame_ui:transition_with_fade("ingame_menu")
    self.ingame_ui:handle_transition("exit_menu")
  end

  return
end


VMFOptionsView.draw_widgets = function (self, dt)
  local ui_renderer = self.ui_renderer
  local ui_scenegraph = self.ui_scenegraph
  local input_manager = self.input_manager
  local input_service = input_manager.get_service(input_manager, "vmf_options_menu")

  UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

  local menu_widgets = self.menu_widgets

  for _, widget in pairs(menu_widgets) do
    UIRenderer.draw_widget(ui_renderer, widget)
  end

  self:update_settings_list(self.settings_list_widgets, ui_renderer, ui_scenegraph, input_service, dt)


  UIRenderer.end_pass(ui_renderer)
end



VMFOptionsView.update_settings_list = function (self, settings_list_widgets, ui_renderer, ui_scenegraph, input_service, dt)

  --self.update_scrollbar(self, settings_list, ui_scenegraph)


  -- instead of self.update_scrollbar:
  local scenegraph = ui_scenegraph[self.settings_list_scenegraph_id]
  scenegraph.offset[2] = self.current_setting_list_offset_y
  ------------------------------------
  local temp_pos_table = {x = 0, y = 0}



  local scenegraph_id_start = self.settings_list_scenegraph_id_start
  local list_position = UISceneGraph.get_world_position(ui_scenegraph, scenegraph_id_start)
  local mask_pos = Vector3.deprecated_copy(UISceneGraph.get_world_position(ui_scenegraph, "sg_settings_list_mask"))
  local mask_size = UISceneGraph.get_size(ui_scenegraph, "sg_settings_list_mask")

  for _, mod_widgets in ipairs(settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do
      if widget.content.is_widget_visible then
        local style = widget.style
        local widget_name = widget.name
        local size = style.size
        local offset = style.offset
        --offset[2] = offset[2] + widget.offset[2]
        temp_pos_table.x = list_position[1] + offset[1]
        temp_pos_table.y = list_position[2] + offset[2] + widget.offset[2]
        local lower_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
        temp_pos_table.y = temp_pos_table.y + size[2]/2
        local middle_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
        temp_pos_table.y = temp_pos_table.y + size[2]/2
        local top_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
        local visible = lower_visible or top_visible
        --widget.content.visible = visible
        if visible then
          UIRenderer.draw_widget(ui_renderer, widget)
        end
      end
    end
  end
end

--@TODO: refactor
-- 'ignore_mousewheel_scroll' - 'true' if user is changing the scrollbar in the meantime
VMFOptionsView.update_mouse_scroll_input = function (self, ignore_mousewheel_scroll)
  local widget_content = self.menu_widgets["mousewheel_scroll_area"].content

  local mouse_scroll_value = widget_content.internal_scroll_value

  if mouse_scroll_value ~= 0 then

    local new_offset = self.current_setting_list_offset_y + mouse_scroll_value * self.scroll_step

    self.current_setting_list_offset_y = math.clamp(new_offset, 0, self.max_setting_list_offset_y)

    widget_content.internal_scroll_value = 0

    self:set_scrollbar_value()
  end
end

-- @TODO: refactor
VMFOptionsView.set_scrollbar_value = function (self)

  local widget_content = self.menu_widgets["scrollbar"].content

  local percentage = self.current_setting_list_offset_y / self.max_setting_list_offset_y

  widget_content.scroll_bar_info.value = percentage
  widget_content.scroll_bar_info.old_value = percentage
end

-- @TODO: refactor

VMFOptionsView.calculate_scrollbar_size = function (self)

  local widget_content = self.menu_widgets["scrollbar"].content

  local percentage = self.setting_list_mask_size_y / self.settings_list_size_y

  widget_content.scroll_bar_info.bar_height_percentage = percentage
end

-- if scrollbar was moved, change offset_y
VMFOptionsView.update_scrollbar = function (self)
  local scrollbar_info = self.menu_widgets["scrollbar"].content.scroll_bar_info
  local value = scrollbar_info.value
  local old_value = scrollbar_info.old_value

  if value ~= old_value then
    self.current_setting_list_offset_y = self.max_setting_list_offset_y * value
    scrollbar_info.old_value = value
  end

  return
end




VMFOptionsView.input_service = function (self)
  return self.input_manager:get_service("vmf_options_menu")
end

VMFOptionsView.on_enter = function (self)

  local input_manager = self.input_manager
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "keyboard", 1)
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "mouse", 1)
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "gamepad", 1)

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_map_open")

  self.menu_active = true

  self:sort_settings_list_widgets()
  self:update_picked_option_for_settings_list_widgets()
  self:update_settings_list_widgets_visibility()
  self:rearrange_settings_list()
end

VMFOptionsView.on_exit = function (self)

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_map_close")

  self.exiting = nil
  self.menu_active = nil

  return
end

VMFOptionsView.exit = function (self, return_to_game)

  local exit_transition = (return_to_game and "exit_menu") or "ingame_menu"

  self.ingame_ui:transition_with_fade(exit_transition)

  self.exiting = true

  return
end


-- i'm not really sure if suspend and unsuspend are needed:
--
-- StateInGameRunning.gm_event_end_conditions_met ->
-- IngameUI.suspend_active_view ->
-- XXXXXXX.suspend
VMFOptionsView.suspend = function (self)
  self.suspended = true

  self.input_manager:device_unblock_all_services("keyboard", 1)
  self.input_manager:device_unblock_all_services("mouse", 1)
  self.input_manager:device_unblock_all_services("gamepad", 1)

  return
end
VMFOptionsView.unsuspend = function (self)
  self.suspended = nil

  self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1)
  self.input_manager:block_device_except_service("vmf_options_menu", "mouse", 1)
  self.input_manager:block_device_except_service("vmf_options_menu", "gamepad", 1)

  return
end






-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

if not vmf:get("mod_suspend_state_list") then
  vmf:set("mod_suspend_state_list", {})
end

local function check_widget_definition(mod, widget)

end

--[[

--]]
VMFMod.create_options = function (self, widgets_definition, is_mod_toggable, readable_mod_name, mod_description)
  -- Yeah, it's kinda complicated, but it's working, mkay?
  --table.dump(widgets_definition, "options_widgets", 3) -- @TODO: remove it later

  local mod_settings_list_widgets_definitions = {}

  local new_widget_definition = nil
  local new_widget_index      = nil

  local options_menu_favorite_mods     = vmf:get("options_menu_favorite_mods")
  local options_menu_collapsed_widgets = vmf:get("options_menu_collapsed_widgets")
  local mod_collapsed_widgets = nil
  if options_menu_collapsed_widgets then
    mod_collapsed_widgets = options_menu_collapsed_widgets[self._name]
  end


  -- defining header widget

  new_widget_index = 1

  new_widget_definition = {}

  new_widget_definition.widget_type       = "header"
  new_widget_definition.widget_index      = new_widget_index
  new_widget_definition.mod_name          = self._name
  new_widget_definition.readable_mod_name = readable_mod_name or self._name
  new_widget_definition.tooltip           = mod_description
  new_widget_definition.default           = true
  new_widget_definition.is_mod_toggable   = is_mod_toggable

  if mod_collapsed_widgets then
    new_widget_definition.is_widget_collapsed = mod_collapsed_widgets[self._name]
  end

  if options_menu_favorite_mods then
    for _, current_mod_name in pairs(options_menu_favorite_mods) do
      if current_mod_name == self._name then
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

    while new_widget_index <= 256 do

      -- if 'nil', we reached the end of the current level widgets list and need to go up
      if current_widget then

        new_widget_index = new_widget_index + 1

        new_widget_definition = {}

        new_widget_definition.widget_type   = current_widget.widget_type
        new_widget_definition.widget_index  = new_widget_index
        new_widget_definition.widget_level  = level
        new_widget_definition.mod_name      = self._name
        new_widget_definition.setting_name  = current_widget.setting_name
        new_widget_definition.text          = current_widget.text
        new_widget_definition.tooltip       = current_widget.tooltip
        new_widget_definition.options       = current_widget.options
        new_widget_definition.default_value = current_widget.default_value
        new_widget_definition.show_widget_condition = current_widget.show_widget_condition
        new_widget_definition.parent_widget_number  = parent_number

        if mod_collapsed_widgets then
          new_widget_definition.is_widget_collapsed = mod_collapsed_widgets[current_widget.setting_name]
        end

        check_widget_definition(self, new_widget_definition)

        if type(self:get(current_widget.setting_name)) == "nil" then
          self:set(current_widget.setting_name, current_widget.default_value)
        end

        table.insert(mod_settings_list_widgets_definitions, new_widget_definition)
      end

      if current_widget and (current_widget.widget_type == "header" or current_widget.widget_type == "checkbox"
        or current_widget.widget_type == "stepper") and current_widget.sub_widgets then

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

    if new_widget_index == 257 then -- @TODO: remove it later
      vmf:echo("The limit of options was reached. Something's wrong")
    end
  end
  --table.dump(mod_settings_list_widgets_definitions, "mod_settings_list_widgets_definitions", 3) -- @TODO: remove it later

  table.insert(SETTINGS_LIST_WIDGETS_DEFINITIONS, mod_settings_list_widgets_definitions)
end


VMFMod.is_suspended = function (self)

  local mod_suspend_state_list = vmf:get("mod_suspend_state_list")

  return mod_suspend_state_list[self._name]
end


-- table.insert(t, new, table.remove(t,old))

--  mod:create_options(options_widgets, true, "Readable Mod Name", "Mod description")







  --[[
    local t = {10,20,30,40,50,60}
    print(table.concat(t, ',')) -- 10,20,30,40,50,60
    table.move(t, 2, 5)
    print(table.concat(t, ',')) -- 10,30,40,50,20,60

  table.move = function(t, old_index, new_index)
    return table.insert(t, new_index, table.remove(t, old_index))
  end
]]















































vmf:hook("IngameUI.update", function(func, self, dt, t, disable_ingame_ui, end_of_level_ui)
  func(self, dt, t, disable_ingame_ui, end_of_level_ui)

  local end_screen_active = self.end_screen_active(self)
  local gdc_build = Development.parameter("gdc")
  local input_service = self.input_manager:get_service("ingame_menu")

  if not self.pending_transition(self) and not end_screen_active and not self.menu_active and not self.leave_game and not self.return_to_title_screen and not gdc_build and not self.popup_join_lobby_handler.visible and input_service.get(input_service, "open_vmf_options", true) then
    self.handle_transition(self, "vmf_options_view_force")
    --vmf:echo("F10")
    --MOOD_BLACKBOARD.menu = true
  end
--vmf:echo("F10")
end)
--vmf:echo("F10")

IngameMenuKeymaps.win32.open_vmf_options = {
      "keyboard",
      "f4",
      "pressed"
    }


local view_data = {
  view_name = "vmf_options_view",
  view_settings = {
    init_view_function = function (ingame_ui_context)
      return VMFOptionsView:new(ingame_ui_context)
    end,
    active = {
      inn = true,
      ingame = true
    },
    blocked_transitions = {
      inn = {},
      ingame = {
        --vmf_options_view = true,
        --vmf_options_view_force = true
      }
    },
    hotkey_mapping = { --@TODO: find out what the hell is this -> 'IngameUI.handle_menu_hotkeys' (only in inn -> useless)
      --view = "inventory_view",
      --error_message = "matchmaking_ready_interaction_message_inventory",
      --in_transition = "inventory_view_force", --opening from hotkey
      --in_transition_menu = "inventory_view" -- opening from esc menu
    },
    hotkey_name = "open_vmf_options",
    hotkey = {
      "keyboard",
      "f9",
      "pressed"
    },
    transition_fade = false
  },
  view_transitions = {

    vmf_options_view = function (self)
      self.current_view = "vmf_options_view"

      return
    end,

    vmf_options_view_force = function (self)
      ShowCursorStack.push()

      self.current_view = "vmf_options_view"

      self.views[self.current_view].exit_to_game = true -- why?
      return
    end
  }
}

vmf:register_new_view(view_data)



local ingame_ui_exists, ingame_ui = pcall(function () return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui end)
if ingame_ui_exists then
  ingame_ui.handle_transition(ingame_ui, "leave_group")
end


--vmf:set("what if", {255,10,10,10})

--[[
vmf:hook("OptionsView.update", function(func, self, dt)
  func(self, dt)
  --self.scroll_field_widget.style.edge_fade_bottom_id.color = {0,0,0,0}
  self.scroll_field_widget.style.edge_fade_bottom_id.color = {0,0,0,0}
  self.ui_scenegraph["list_mask"].size[2] = 850
end)


vmf:hook("InputManager.change_keybinding", function(func, self, keybinding_table_name, keybinding_table_key, keymap_name, new_button_index, new_device_type, new_state_type)
  vmf:echo("keybinding_table_name: " .. keybinding_table_name)
  vmf:echo("keybinding_table_key: " .. keybinding_table_key)
  vmf:echo("keymap_name: " .. keymap_name)
  vmf:echo("new_button_index: " .. new_button_index)
  vmf:echo("new_device_type: " .. new_device_type)
  vmf:echo("new_state_type: " .. new_state_type)

  local keymaps_data = self.keymaps_data(self, keybinding_table_name)

  --table.dump(keymaps_data, "keymaps_data", 2)

  func(self, keybinding_table_name, keybinding_table_key, keymap_name, new_button_index, new_device_type, new_state_type)
end)]]