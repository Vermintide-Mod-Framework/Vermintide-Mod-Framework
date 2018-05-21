local vmf = get_mod("VMF")


local scenegraph_definition = {

  sg_root = {
    size = {1920, 1080},
    position = {0, 0, UILayer.default},

    is_root = true,
  },

    -- Fix for FullHD windowed (not fullscreen) mode (if everything else will inherit from sg_root, its children will
    -- stick to the window border instead of the black gap)
    sg_placeholder = {
      size = {1920, 1080},
      position = {0, 0, 1},

      parent = "sg_root",

      horizontal_alignment = "center",
      vertical_alignment = "center"
    },

      sg_mutators_list_background = {
        size = {547, 313},
        position = {-2, -2, 2}, -- @TODO: fix the actual image (-2 px plus image overlaping text)

        parent = "sg_placeholder",

        horizontal_alignment = "left",
        vertical_alignment = "bottom"
      },

      sg_mutators_button = {
        size = {64, 64},
        position = {87, 430.5, 2},

        parent = "sg_placeholder",

        horizontal_alignment = "left",
        vertical_alignment = "bottom"
      },

      sg_mutators_list = {
        size = {370, 265},
        position = {80, 61, 3},

        parent = "sg_placeholder",

        vertical_alignment = "bottom",
        horizontal_alignment = "left"
      },

        sg_mutators_list_start = {
          size = {1, 1},
          offset = {0, 0, 3},

          parent = "sg_mutators_list",

          vertical_alignment = "top",
          horizontal_alignment = "left"
        },

        sg_no_mutators_text = {
          size = {310, 30},
          position = {0, 10, 1},

          parent = "sg_mutators_list",

          vertical_alignment = "center",
          horizontal_alignment = "center",
        },

      sg_scrollbar = {
        size = {0, 290}, -- X size doesn't affect scrollbar width
        position = {452, 52, 3},

        parent = "sg_placeholder",

        vertical_alignment = "bottom",
        horizontal_alignment = "left"
      },
}


local widgets_definition = {

  -- That photoshopped background texture which expands displayed list area
  mutator_list_background = {
    scenegraph_id = "sg_root",
    element = {
      passes = {
        {
          pass_type = "texture",
          style_id  = "mutators_list_background",
          texture_id = "mutators_list_background_texture_id"
        }
      }
    },
    content = {
      mutators_list_background_texture_id = "map_view_mutators_area",
    },
    style = {
      mutators_list_background = {
        scenegraph_id = "sg_mutators_list_background"
      }
    }
  },

  -- Widgets that detects mousewheel scrolls inside itself
  mousewheel_scroll_area = {
    scenegraph_id = "sg_mutators_list",
    element = {
      passes = {
        {
          pass_type = "scroll",
          scroll_function = function (ui_scenegraph_, style_, content, input_service_, scroll_axis)
            content.scroll_value = content.scroll_value - scroll_axis.y
          end
        }
      }
    },
    content = {
      scroll_value = 0
    },
    style = {}
  },

  -- Scrollbar
  scrollbar = UIWidgets.create_scrollbar(scenegraph_definition.sg_scrollbar.size[2], "sg_scrollbar")
}
widgets_definition.scrollbar.content.disable_frame = true -- Hide scrollbar frame


-- The 4th button, which will toggle old "Party" view (which is replaced by "Mutators" view)
local party_button_widget_defenition = UIWidgets.create_octagon_button(
  {
    "map_view_party_button",
    "map_view_party_button_lit"
  },
  {
    "map_party_title",
    "map_party_title"
  },
  "sg_mutators_button"
)


-- Text displayed when user has 0 mutators
local no_mutators_text_widget = {
  scenegraph_id = "sg_no_mutators_text",
  element = {
    passes = {
      {
        pass_type = "text",

        style_id = "text",
        text_id = "text"
      },
      {
        pass_type = "hotspot",

        content_id = "tooltip_hotspot"
      },
      {
        pass_type = "tooltip_text",

        style_id = "tooltip_text",
        text_id = "tooltip_text",
        content_check_function = function (ui_content)
          return ui_content.tooltip_hotspot.is_hover
        end
      }
    }
  },
  content = {
    text = vmf:localize("no_mutators"),
    tooltip_text = vmf:localize("no_mutators_tooltip"),
    tooltip_hotspot = {},
    color = Colors.get_color_table_with_alpha("slate_gray", 255)
  },
  style = {

    text = {
      vertical_alignment = "center",
      horizontal_alignment = "center",
      font_size = 22,
      localize = false,
      word_wrap = true,
      font_type = "hell_shark",
      text_color = Colors.get_color_table_with_alpha("slate_gray", 255),
      offset = {0, 2, 4}
    },

    tooltip_text = {
      font_size = 24,
      max_width = 500,
      localize = false,
      horizontal_alignment = "left",
      vertical_alignment = "top",
      font_type = "hell_shark",
      text_color = Colors.get_color_table_with_alpha("white", 255),
      line_colors = {},
      offset = {0, 0, 50}
    }
  }
}


-- Creates a widget for every mutator (that string with checkbox)
local function create_mutator_widget(mutator, offset_function_callback)
  return {
    scenegraph_id = "sg_mutators_list_start",
    element = {
      passes = {
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        {
          pass_type = "local_offset",

          -- The function is executed inside of 'mutators_gui.lua', since it has to interact with mutator list a lot
          offset_function = offset_function_callback
        },
        {
          pass_type = "texture",

          style_id = "hover_texture",
          texture_id = "hover_texture",
          content_check_function = function (content)
            return content.can_be_enabled and content.highlight_hotspot.is_hover
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },
        {
          pass_type = "texture",

          style_id = "checkbox_style",
          texture_id = "checkbox_texture"
        },
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover
          end
        },
      }
    },
    content = {
      mutator = nil, -- is added after creation (i can't add mutator here now, becuase UIWidget.init() clones tables)

      text = mutator:get_readable_name(),
      description = mutator:get_description() or vmf:localize("mutator_no_description_provided"),

      can_be_enabled = false,

      highlight_hotspot = {},

      tooltip_text = "", -- always changes in local_offset pass

      hover_texture = "playerlist_hover",

      checkbox_texture = "checkbox_unchecked", -- always changes in local_offset pass

      -- Presets
      checkbox_unchecked_texture = "checkbox_unchecked",
      checkbox_checked_texture = "checkbox_checked",

      text_color_disabled = Colors.get_color_table_with_alpha("white", 255),
      text_color_enabled = Colors.get_color_table_with_alpha("cheeseburger", 255),
      text_color_inactive = Colors.get_color_table_with_alpha("slate_gray", 255),
    },
    style = {

      text = {
        offset = {10, -2, 2},
        font_size = 24,
        font_type = "hell_shark",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)  -- always changes in local_offset pass
      },

      hover_texture = {
        size = {370, 32},
        offset = {0, 0, 1}
      },

      checkbox_style = {
        size = {20, 20},
        offset = {340, 6, 2},
        color = {255, 255, 255, 255}
      },

      tooltip_text = {
        font_type = "hell_shark",
        font_size = 18,
        cursor_side = "right",
        max_width = 425,
        cursor_offset = {0, 0}, -- always changes in local_offset pass
        cursor_default_offset = {27, -27}
      },

      size = {370, 32}
    }
  }
end


return {
  scenegraph_definition = scenegraph_definition,
  widgets_definition = widgets_definition,
  party_button_widget_defenition = party_button_widget_defenition,
  no_mutators_text_widget = no_mutators_text_widget,
  create_mutator_widget = create_mutator_widget
}