local mod = new_mod("vmf_options_view") -- @TODO: replace it with VMF later


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
--table.remove(menu_widgets_definition.scrollbar.element.passes, 7)






--████████╗███████╗███╗   ███╗██████╗
--╚══██╔══╝██╔════╝████╗ ████║██╔══██╗
--   ██║   █████╗  ██╔████╔██║██████╔╝
--   ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝
--   ██║   ███████╗██║ ╚═╝ ██║██║
--   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝


script_data.ui_debug_hover = false

local DEBUG_WIDGETS = false

local SETTINGS_LIST_BIG_WIDGET_SIZE = {1194, 70}
local SETTINGS_LIST_REGULAR_WIDGET_SIZE = {1194, 50}


--[[alright, this is it]]

local function create_header_widget(text, scenegraph_id, offset_y)

  base_offset[2] = base_offset[2] - SETTINGS_LIST_BIG_WIDGET_SIZE[2]

  local definition = {
    element = {
      passes = {
        {
          style_id = "checkbox",
          pass_type = "hotspot",
          content_id = "hotspot"
        },
        {
          pass_type = "hotspot",
          content_id = "highlight_hotspot"
        },
        {
          pass_type = "texture",
          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.is_highlighted
          end
        },
        {
          pass_type = "local_offset",
          offset_function = function (ui_scenegraph, ui_style, ui_content, ui_renderer)
            if ui_content.hotspot.on_release then
              ui_content.flag = not ui_content.flag
            end

            local flag = ui_content.flag

            if flag then
              ui_content.checkbox = "checkbox_checked"
            else
              ui_content.checkbox = "checkbox_unchecked"
            end

            return
          end
        },
        {
          pass_type = "texture",
          style_id = "checkbox",
          texture_id = "checkbox"
        },
        {
          style_id = "text",
          pass_type = "text",
          text_id = "text"
        },
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
          style_id = "debug_middle_line",
          pass_type = "rect",
          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      flag = false,
      checkbox = "checkbox_unchecked", --just a texture name
      highlight_texture = "playerlist_hover",
      hotspot = {},
      highlight_hotspot = {},
      text = text,
      hotspot_content_ids = {
        "hotspot"
      }
    },
    style = {
      highlight_texture = {
        masked = true,
        offset = {
          base_offset[1],
          base_offset[2],
          base_offset[3]
        },
        color = Colors.get_table("white"),
        size = {
          SETTINGS_LIST_BIG_WIDGET_SIZE[1],
          SETTINGS_LIST_BIG_WIDGET_SIZE[2]
        }
      },
      checkbox = {
        masked = true,
        offset = {
          base_offset[1] + 642,
          base_offset[2] + 17,
          base_offset[3]
        },
        size = {
          16,
          16
        }
      },
      text = {
        font_type = "hell_shark_masked",
        dynamic_font = true,
        localize = true,
        font_size = 28,
        offset = {
          base_offset[1] + 2,
          base_offset[2] + 5,
          base_offset[3]
        },
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },
      offset = {
        base_offset[1],
        base_offset[2],
        base_offset[3]
      },
      size = table.clone(SETTINGS_LIST_BIG_WIDGET_SIZE),
      color = {
        50,
        255,
        255,
        255
      },
      debug_middle_line = {
        offset = {
          base_offset[1],
          (base_offset[2] + SETTINGS_LIST_BIG_WIDGET_SIZE[2]/2) - 1,
          base_offset[3] + 10
        },
        size = {
          SETTINGS_LIST_BIG_WIDGET_SIZE[1],
          2
        },
        color = {
          200,
          0,
          255,
          0
        }
      }
    },
    scenegraph_id = scenegraph_id
  }

  return UIWidget.init(definition)
end


local function build_header_widget (element, scenegraph_id, base_offset)
  --local callback_name = element.callback
  --local callback_func = self.make_callback(self, callback_name)
  --local saved_value_cb_name = element.saved_value
  --local saved_value_cb = callback(self, saved_value_cb_name)
  --local setup_name = element.setup
  --local flag, text, default_value = self[setup_name](self)

  --fassert(type(flag) == "boolean", "Flag type is wrong, need boolean, got %q", type(flag))

  local text = "Whatever"

  local widget = create_header_widget(text, scenegraph_id, base_offset)
  local content = widget.content
  content.flag = true
  --content.callback = callback_func
  --content.saved_value_cb = saved_value_cb
  --content.default_value = default_value
  content.callback = function ()
    return
  end
  content.saved_value_cb = function ()
    return
  end

  return widget
end











------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

local CHECKBOX_WIDGET_SIZE = {
  795,
  50
}

local function create_checkbox_widget(text, scenegraph_id, base_offset)
  base_offset[2] = base_offset[2] - CHECKBOX_WIDGET_SIZE[2]
  local definition = {
    element = {
      passes = {
        {
          style_id = "checkbox",
          pass_type = "hotspot",
          content_id = "hotspot"
        },
        {
          pass_type = "hotspot",
          content_id = "highlight_hotspot"
        },
        {
          pass_type = "texture",
          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.is_highlighted
          end
        },
        {
          pass_type = "local_offset",
          offset_function = function (ui_scenegraph, ui_style, ui_content, ui_renderer)
            if ui_content.hotspot.on_release then
              ui_content.flag = not ui_content.flag
            end

            local flag = ui_content.flag

            if flag then
              ui_content.checkbox = "checkbox_checked"
            else
              ui_content.checkbox = "checkbox_unchecked"
            end

            return
          end
        },
        {
          pass_type = "texture",
          style_id = "checkbox",
          texture_id = "checkbox"
        },
        {
          style_id = "text",
          pass_type = "text",
          text_id = "text"
        },
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
          style_id = "debug_middle_line",
          pass_type = "rect",
          content_check_function = function (content)
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      flag = false,
      checkbox = "checkbox_unchecked", --just a texture name
      highlight_texture = "playerlist_hover",
      hotspot = {},
      highlight_hotspot = {},
      text = text,
      hotspot_content_ids = {
        "hotspot"
      }
    },
    style = {
      highlight_texture = {
        masked = true,
        offset = {
          base_offset[1],
          base_offset[2],
          base_offset[3]
        },
        color = Colors.get_table("white"),
        size = {
          CHECKBOX_WIDGET_SIZE[1],
          CHECKBOX_WIDGET_SIZE[2]
        }
      },
      checkbox = {
        masked = true,
        offset = {
          base_offset[1] + 642,
          base_offset[2] + 17,
          base_offset[3]
        },
        size = {
          16,
          16
        }
      },
      text = {
        font_type = "hell_shark_masked",
        dynamic_font = true,
        localize = true,
        font_size = 28,
        offset = {
          base_offset[1] + 2,
          base_offset[2] + 5,
          base_offset[3]
        },
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },
      offset = {
        base_offset[1],
        base_offset[2],
        base_offset[3]
      },
      size = table.clone(CHECKBOX_WIDGET_SIZE),
      color = {
        50,
        255,
        255,
        255
      },
      debug_middle_line = {
        offset = {
          base_offset[1],
          (base_offset[2] + CHECKBOX_WIDGET_SIZE[2]/2) - 1,
          base_offset[3] + 10
        },
        size = {
          CHECKBOX_WIDGET_SIZE[1],
          2
        },
        color = {
          200,
          0,
          255,
          0
        }
      }
    },
    scenegraph_id = scenegraph_id
  }

  return UIWidget.init(definition)
end


local function build_checkbox_widget (element, scenegraph_id, base_offset)
  --local callback_name = element.callback
  --local callback_func = self.make_callback(self, callback_name)
  --local saved_value_cb_name = element.saved_value
  --local saved_value_cb = callback(self, saved_value_cb_name)
  --local setup_name = element.setup
  --local flag, text, default_value = self[setup_name](self)

  --fassert(type(flag) == "boolean", "Flag type is wrong, need boolean, got %q", type(flag))

  local text = "Whatever"

  local widget = create_checkbox_widget(text, scenegraph_id, base_offset)
  local content = widget.content
  content.flag = true
  --content.callback = callback_func
  --content.saved_value_cb = saved_value_cb
  --content.default_value = default_value
  content.callback = function ()
    return
  end
  content.saved_value_cb = function ()
    return
  end

  return widget
end


local function create_simple_texture_widget(texture, texture_size, scenegraph_id, base_offset)
  base_offset[2] = base_offset[2] - texture_size[2]
  local definition = {
    element = {
      passes = {
        {
          texture_id = "texture_id",
          style_id = "texture_id",
          pass_type = "texture"
        }
      }
    },
    content = {
      texture_id = texture
    },
    style = {
      size = {
        texture_size[1],
        texture_size[2]
      },
      offset = {
        base_offset[1],
        base_offset[2],
        base_offset[3]
      },
      texture_id = {
        masked = true, -- GOD DAMN IT THIS IS THE FUCKING REASON!
        color = {
          255,
          255,
          255,
          255
        },
        offset = {
          base_offset[1],
          base_offset[2],
          base_offset[3]
        },
        size = {
          texture_size[1],
          texture_size[2]
        }
      }
    },
    scenegraph_id = scenegraph_id
  }

  return UIWidget.init(definition)
end

local function build_image(element, scenegraph_id, base_offset)
  local widget = create_simple_texture_widget(element.image, element.image_size, scenegraph_id, base_offset)
  local content = widget.content
  content.callback = function ()
    return
  end
  content.saved_value_cb = function ()
    return
  end
  content.disabled = true

  return widget
end

local settings_list_definition = {
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "checkbox"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "header"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "header"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  },
  {
    image = "stance_bar_blue",
    image_size = {1194, 60},
    callback = "cb_mouse_look_invert_y",
    widget_type = "image"
  }
}



-- ██████╗██╗      █████╗ ███████╗███████╗
--██╔════╝██║     ██╔══██╗██╔════╝██╔════╝
--██║     ██║     ███████║███████╗███████╗
--██║     ██║     ██╔══██║╚════██║╚════██║
--╚██████╗███████╗██║  ██║███████║███████║
-- ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝




VMFOptionsView = class(VMFOptionsView)
VMFOptionsView.init = function (self, ingame_ui_context)

  self.current_setting_list_offset_y = 0 -- [int]
  self.max_setting_list_offset_y = nil   -- [int]
  self.setting_list_mask_size_y = nil    -- [int]
  self.scroll_step = 10                  -- [int]

  self.menu_widgets = nil                -- [table]
  self.settings_list_widgets = nil       -- [table]

  -- get necessary things for rendering
  self.ui_renderer = ingame_ui_context.ui_renderer
  self.render_settings = {snap_pixel_positions = true}
  self.ingame_ui = ingame_ui_context.ingame_ui

  -- create input service
  local input_manager = ingame_ui_context.input_manager
  input_manager:create_input_service("vmf_options_menu", "IngameMenuKeymaps", "IngameMenuFilters")
  input_manager:map_device_to_service("vmf_options_menu", "keyboard")
  input_manager:map_device_to_service("vmf_options_menu", "mouse")
  input_manager:map_device_to_service("vmf_options_menu", "gamepad")
  self.input_manager = input_manager

  -- wwise_world is used for making sounds (for opening menu, closing menu etc)
  local world = ingame_ui_context.world_manager:world("music_world")
  self.wwise_world = Managers.world:wwise_world(world)

  self:create_ui_elements()
end


VMFOptionsView.create_ui_elements = function (self)

  self.menu_widgets = {}

  for name, definition in pairs(menu_widgets_definition) do
    self.menu_widgets[name] = UIWidget.init(definition)
  end

  self.settings_list_widgets = self:build_settings_list(settings_list_definition)

  self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)

  self.setting_list_mask_size_y = self.ui_scenegraph.sg_settings_list_mask.size[2]

  self:calculate_scrollbar_size()
end


VMFOptionsView.build_settings_list = function (self, setting_list_widgets_definition)

  --local scenegraph_definition = definitions.scenegraph_definition
  local scenegraph_id = "sg_settings_list"
  local scenegraph_id_start = "sg_settings_list_start"
  local list_size_y = 0
  local widgets = {}

  for i, definition in ipairs(setting_list_widgets_definition) do

    local element = definition
    local base_offset = {0, -list_size_y, 0}
    local widget = nil
    local size_y = 0
    local widget_type = element.widget_type

    --if widget_type == "drop_down" then
    --  widget = self.build_drop_down_widget(self, element, scenegraph_id_start, base_offset)
    --elseif widget_type == "slider" then
    --  widget = self.build_slider_widget(self, element, scenegraph_id_start, base_offset)
    if widget_type == "checkbox" then
      widget = build_checkbox_widget(element, scenegraph_id_start, base_offset)
    --elseif widget_type == "stepper" then
    --  widget = self.build_stepper_widget(self, element, scenegraph_id_start, base_offset)
    --elseif widget_type == "keybind" then
    --  widget = self.build_keybind_widget(self, element, scenegraph_id_start, base_offset)
    elseif widget_type == "image" then
      widget = build_image(element, scenegraph_id_start, base_offset)
    elseif widget_type == "header" then
      widget = build_header_widget(element, scenegraph_id_start, base_offset)
    --elseif widget_type == "gamepad_layout" then
    --  widget = self.build_gamepad_layout(self, element, scenegraph_id_start, base_offset)
    --  self.gamepad_layout_widget = widget
    --  local using_left_handed_option = assigned(self.changed_user_settings.gamepad_left_handed, Application.user_setting("gamepad_left_handed"))

    --  self.update_gamepad_layout_widget(self, DefaultGamepadLayoutKeymaps, using_left_handed_option)
    --elseif widget_type == "empty" then
    --  size_y = element.size_y
    --else
     -- error("[OptionsView] Unsupported widget type")
    end

    if widget then
      local name = element.callback
      size_y = widget.style.size[2]
      widget.type = widget_type
      widget.name = name
    end

    list_size_y = list_size_y + size_y

    if widget then
      if element.name then
        widget.name = element.name
      end

      table.insert(widgets, widget)
    end
  end

  local mask_size = scenegraph_definition.sg_settings_list_mask.size
  local size_x = mask_size[1]

  scenegraph_definition[scenegraph_id] = {
    size = {size_x, list_size_y},
    position = {0, 0, -1}, -- changed -1 to 100. nothing changed. seems like it doesn't matter
    offset = {0, 0, 0},

    vertical_alignment = "top",
    horizontal_alignment = "center",

    parent = "sg_settings_list_mask"
  }

  scenegraph_definition[scenegraph_id_start] = {
    size = {1, 1},
    position = {3, 0, 10},

    vertical_alignment = "top",
    horizontal_alignment = "left",

    parent = scenegraph_id
  }

  local scrollbar = false
  local max_offset_y = 0

  if mask_size[2] < list_size_y then
    scrollbar = true
    max_offset_y = list_size_y - mask_size[2]
  end

  self.max_setting_list_offset_y = max_offset_y
  self.settings_list_size_y = list_size_y

  local widget_list = {
    scenegraph_id = scenegraph_id,
    scenegraph_id_start = scenegraph_id_start,
    scrollbar = scrollbar,
    max_offset_y = max_offset_y,
    widgets = widgets
  }

  return widget_list
end


local temp_pos_table = {
  x = 0,
  y = 0
}
VMFOptionsView.update_settings_list = function (self, settings_list, ui_renderer, ui_scenegraph, input_service, dt)

  --self.update_scrollbar(self, settings_list, ui_scenegraph)


  -- instead of self.update_scrollbar:
  local scenegraph = ui_scenegraph[settings_list.scenegraph_id]
  scenegraph.offset[2] = self.current_setting_list_offset_y
  ------------------------------------

  local scenegraph_id_start = settings_list.scenegraph_id_start
  local list_position = UISceneGraph.get_world_position(ui_scenegraph, scenegraph_id_start)
  local mask_pos = Vector3.deprecated_copy(UISceneGraph.get_world_position(ui_scenegraph, "sg_settings_list_mask"))
  local mask_size = UISceneGraph.get_size(ui_scenegraph, "sg_settings_list_mask")
  --local selected_widget = self.selected_widget

  for i, widget in ipairs(settings_list.widgets) do

    local style = widget.style
    local widget_name = widget.name
    local size = style.size
    local offset = style.offset
    temp_pos_table.x = list_position[1] + offset[1]
    temp_pos_table.y = list_position[2] + offset[2]
    local lower_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
    temp_pos_table.y = temp_pos_table.y + size[2]/2
    local middle_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
    temp_pos_table.y = temp_pos_table.y + size[2]/2
    local top_visible = math.point_is_inside_2d_box(temp_pos_table, mask_pos, mask_size)
    local visible = lower_visible or top_visible
    widget.content.visible = visible

    UIRenderer.draw_widget(ui_renderer, widget)
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


VMFOptionsView.update = function (self, dt)
  if self.suspended then
    return
  end

  self:update_scrollbar()

  self:update_mouse_scroll_input(false)

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
  return
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



























































mod:hook("IngameUI.update", function(func, self, dt, t, disable_ingame_ui, end_of_level_ui)
  func(self, dt, t, disable_ingame_ui, end_of_level_ui)

  local end_screen_active = self.end_screen_active(self)
  local gdc_build = Development.parameter("gdc")
  local input_service = self.input_manager:get_service("ingame_menu")

  if not self.pending_transition(self) and not end_screen_active and not self.menu_active and not self.leave_game and not self.return_to_title_screen and not gdc_build and not self.popup_join_lobby_handler.visible and input_service.get(input_service, "open_vmf_options", true) then
    self.handle_transition(self, "vmf_options_view_force")
    --mod:echo("F10")
    --MOOD_BLACKBOARD.menu = true
  end
--mod:echo("F10")
end)
--mod:echo("F10")

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
      ingame = false
    },
    blocked_transitions = {
      inn = {},
      ingame = {
        vmf_options_view = true,
        vmf_options_view_force = true
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

mod:register_new_view(view_data)


local ingame_ui_exists, ingame_ui = pcall(function () return Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui end)
if ingame_ui_exists then
  ingame_ui.handle_transition(ingame_ui, "leave_group")
end


--[[
mod:hook("OptionsView.update", function(func, self, dt)
  func(self, dt)
  --self.scroll_field_widget.style.edge_fade_bottom_id.color = {0,0,0,0}
  self.scroll_field_widget.style.edge_fade_bottom_id.color = {0,0,0,0}
  self.ui_scenegraph["list_mask"].size[2] = 850
end)


mod:hook("InputManager.change_keybinding", function(func, self, keybinding_table_name, keybinding_table_key, keymap_name, new_button_index, new_device_type, new_state_type)
  mod:echo("keybinding_table_name: " .. keybinding_table_name)
  mod:echo("keybinding_table_key: " .. keybinding_table_key)
  mod:echo("keymap_name: " .. keymap_name)
  mod:echo("new_button_index: " .. new_button_index)
  mod:echo("new_device_type: " .. new_device_type)
  mod:echo("new_state_type: " .. new_state_type)

  local keymaps_data = self.keymaps_data(self, keybinding_table_name)

  --table.dump(keymaps_data, "keymaps_data", 2)

  func(self, keybinding_table_name, keybinding_table_key, keymap_name, new_button_index, new_device_type, new_state_type)
end)]]