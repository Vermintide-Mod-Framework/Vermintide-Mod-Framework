local scenegraph_definition = {

	sg_root = {
		is_root = true,
		size = {1920, 1080},
		position = {0, 0, UILayer.default}
  },

  sg_mutators_list_background = {
		vertical_alignment = "bottom",
		parent = "sg_root",
		horizontal_alignment = "left",
		size = {547, 313},
		position = {-2, -2, 10} -- @TODO: fix the actual image
  },

  sg_mutators_button = {
		vertical_alignment = "bottom",
		parent = "sg_root",
		horizontal_alignment = "left",
		size = {64, 64},
		position = {87, 430.5, 10}
  },

  sg_mutators_list = {
    vertical_alignment = "bottom",
    horizontal_alignment = "left",

    size = {370, 265},
    position = {80, 61, 11}, --122

    parent = "sg_root"
  },

    sg_mutators_list_start = {
      vertical_alignment = "top",
      horizontal_alignment = "left",

      size = {1, 1},
      offset = {0, 0, 1},

      parent = "sg_mutators_list"
    },
}


local widgets_definition = {

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
--[[

  mutators_list_debug = {
    scenegraph_id = "sg_mutators_list",
    element = {
      passes = {
        {
          pass_type = "rect",
          style_id  = "mutators_list_background",
        }
      }
    },
    content = {},
    style = {
      mutators_list_background = {
        scenegraph_id = "sg_mutators_list",
        color = {255, 0, 0, 0}
      },
    }
  },

  ]]
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
}


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


local function create_mutator_widget(mutator)
  return {
    scenegraph_id = "sg_mutators_list_start",
    element = {
      passes = {
        -- {
        --   pass_type = "rect",

        --   style_id  = "mutators_list_background",
        --   --texture_id = "mutators_list_background_texture_id"
        -- },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },

      }
    },
    content = {
      mutators_list_background_texture_id = "map_view_mutators_area",
      mutator = mutator,
      text = mutator:get_readable_name(),
      --text = "bIbIbI(rus)",
    },
    style = {

      mutators_list_background = {
        --scenegraph_id = "sg_mutators_list_start",
        color = {math.random(255), math.random(255), math.random(255), 255},
        size = {370, 32}
      },

      text = {
        offset = {0, -2, 2},
        font_size = 24,
        font_type = "hell_shark",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },
    }
  }
end


return {
  scenegraph_definition = scenegraph_definition,
  widgets_definition = widgets_definition,
  party_button_widget_defenition = party_button_widget_defenition,
  create_mutator_widget = create_mutator_widget
}