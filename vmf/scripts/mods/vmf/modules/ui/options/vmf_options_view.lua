--[[
  * If you're changing settings defined in widget via mod:set don't use values which aren't defined in widget
  * Don't use tables in settings defined in widgets. The widgets are build to work with
  basic datatypes (with exception of keybind widgets, but they are working differently)
  * Using tables in mod:get and mod:set for the settings that are not defined in widgets is fine though,
  but keep in mind, that every time you do it, this table will be cloned, so don't do it very frequently,
  especially if the tables are big
  * No external config files. Everything should be stored via mod:set
  * Use mod:set only if you need setting to be saved in the config file


  @TODO: [BUG] checkbox is checked at first tick after showing, since local_offset function is called after rect drawing
  @TODO: [BUG] searchbar's input will stop working after using russian character
  @TODO: [IMPROVEMENT] opened widgets are shown even behind the borders
  @TODO: [IMPROVEMENT] dropdown widget goes up if there's not enough space at the bottom
]]
local vmf = get_mod("VMF")

--vmf:custom_textures("header_fav_icon", "header_fav_icon_lit", "header_fav_arrow", "search_bar_icon")
vmf.custom_atlas(vmf, "materials/vmf/vmf_atlas", "vmf_atlas", "vmf_atlas_masked")

vmf.inject_materials(vmf, "ingame_ui", "materials/vmf/vmf_atlas")

-- ####################################################################################################################
-- ##### MENU WIDGETS DEFINITIONS #####################################################################################
-- ####################################################################################################################

-- Bandaid Fix for fancy ass ascii causing line checking errors.
-- luacheck: no max_line_length
-- Bandaid Fix for this file using lots of duplicated code and shadowed variables that could be refactored
-- luacheck: ignore 4

-- ███████╗ ██████╗███████╗███╗   ██╗███████╗ ██████╗ ██████╗  █████╗ ██████╗ ██╗  ██╗███████╗
-- ██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██║  ██║██╔════╝
-- ███████╗██║     █████╗  ██╔██╗ ██║█████╗  ██║  ███╗██████╔╝███████║██████╔╝███████║███████╗
-- ╚════██║██║     ██╔══╝  ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══██║██╔═══╝ ██╔══██║╚════██║
-- ███████║╚██████╗███████╗██║ ╚████║███████╗╚██████╔╝██║  ██║██║  ██║██║     ██║  ██║███████║
-- ╚══════╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝

local scenegraph_definition = {

  sg_root = {
    size     = {1920, 1080},
    position = {0, 0, UILayer.default + 10},
    is_root = true
  },

    sg_aligner = {
      size = {1920, 1080},
      position = {0, 0, 0},

      parent = "sg_root",

      scale = "fit",
      horizontal_alignment = "center",
      vertical_alignment = "center"
    },

      sg_background_border = {
        size = {1206, 1056},
        position = {357, 12, 0},

        parent = "sg_aligner"
      },

      sg_background_settings_list = {
        size = {1200, 1000},
        position = {360, 65, 1},

        parent = "sg_aligner"
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

      sg_search_bar = {
        size = {1200, 47},
        position = {360, 15, 1},

        parent = "sg_aligner"
      },

      sg_scrollbar = {
        size = {360, 1050},
        position = {1562, 40, 0},

        parent = "sg_aligner"
      },

  sg_dead_space_filler = {
    size = {1920, 1080},
    position = {0, 0, 0},
    scale = "fit"
  }
}



















local function create_scrollbar(height, scenegraph_id)
    return {
      element = {
        passes = {
          {
            pass_type = "texture",
            style_id = "scroll_bar_bottom",
            texture_id = "scroll_bar_bottom",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            pass_type = "texture",
            style_id = "scroll_bar_bottom_bg",
            texture_id = "scroll_bar_bottom_bg",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            pass_type = "tiled_texture",
            style_id = "scroll_bar_middle",
            texture_id = "scroll_bar_middle",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            pass_type = "tiled_texture",
            style_id = "scroll_bar_middle_bg",
            texture_id = "scroll_bar_middle_bg",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            pass_type = "texture",
            style_id = "scroll_bar_top",
            texture_id = "scroll_bar_top",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            pass_type = "texture",
            style_id = "scroll_bar_top_bg",
            texture_id = "scroll_bar_top_bg",
            content_check_function = function (content)
              return not content.disable_frame
            end
          },
          {
            style_id = "button_down",
            pass_type = "hotspot",
            content_id = "button_down_hotspot"
          },
          {
            style_id = "button_up",
            pass_type = "hotspot",
            content_id = "button_up_hotspot"
          },
          {
            pass_type = "local_offset",
            offset_function = function (ui_scenegraph_, ui_style, ui_content, input_service_)
              local scroll_bar_info = ui_content.scroll_bar_info
              local scroll_bar_box = ui_style.scroll_bar_box
              local scroll_size_y = scroll_bar_box.scroll_size_y
              local percentage = math.max(scroll_bar_info.bar_height_percentage, 0.05)
              scroll_bar_box.size[2] = scroll_size_y * percentage
              local button_up_hotspot = ui_content.button_up_hotspot

              if button_up_hotspot.is_hover and button_up_hotspot.is_clicked == 0 then
                ui_content.button_up = "scroll_bar_button_up_clicked"
              else
                ui_content.button_up = "scroll_bar_button_up"
              end

              local button_down_hotspot = ui_content.button_down_hotspot

              if button_down_hotspot.is_hover and button_down_hotspot.is_clicked == 0 then
                ui_content.button_down = "scroll_bar_button_down_clicked"
              else
                ui_content.button_down = "scroll_bar_button_down"
              end

              local button_scroll_step = ui_content.button_scroll_step or 0.1

              if button_up_hotspot.on_release then
                local size_y = scroll_bar_box.size[2]
                local scroll_size_y = scroll_bar_box.scroll_size_y
                local start_y = scroll_bar_box.start_offset[2]
                local end_y = (start_y + scroll_size_y) - size_y
                local step_ = size_y / (start_y + end_y)
                scroll_bar_info.value = math.max(scroll_bar_info.value - button_scroll_step, 0)
              elseif button_down_hotspot.on_release then
                local size_y = scroll_bar_box.size[2]
                local scroll_size_y = scroll_bar_box.scroll_size_y
                local start_y = scroll_bar_box.start_offset[2]
                local end_y = (start_y + scroll_size_y) - size_y
                local step_ = size_y / (start_y + end_y)
                scroll_bar_info.value = math.min(scroll_bar_info.value + button_scroll_step, 1)
              end

              return
            end
          },
          {
            pass_type = "texture",
            style_id = "button_down",
            texture_id = "button_down"
          },
          {
            pass_type = "texture",
            style_id = "button_up",
            texture_id = "button_up"
          },
          {
            style_id = "scroll_bar_box",
            pass_type = "hotspot",
            content_id = "scroll_bar_info"
          },
          {
            style_id = "scroll_bar_box",
            pass_type = "held",
            content_id = "scroll_bar_info",
            held_function = function (ui_scenegraph, ui_style, ui_content, input_service)
              local cursor = UIInverseScaleVectorToResolution(input_service.get(input_service, "cursor"))
              local cursor_y = cursor[2]
              local world_pos = UISceneGraph.get_world_position(ui_scenegraph, ui_content.scenegraph_id)
              local world_pos_y = world_pos[2]
              local offset = ui_style.offset
              local scroll_box_start = world_pos_y + offset[2]
              local cursor_y_norm = cursor_y - scroll_box_start

              if not ui_content.click_pos_y then
                ui_content.click_pos_y = cursor_y_norm
              end

              local click_pos_y = ui_content.click_pos_y
              local delta = cursor_y_norm - click_pos_y
              local start_y = ui_style.start_offset[2]
              local end_y = (start_y + ui_style.scroll_size_y) - ui_style.size[2]
              local offset_y = math.clamp(offset[2] + delta, start_y, end_y)
              local scroll_size = end_y - start_y
              local scroll = end_y - offset_y
              ui_content.value = (scroll ~= 0 and scroll / scroll_size) or 0

              return
            end,
            release_function = function (ui_scenegraph_, ui_style_, ui_content, input_service_)
              ui_content.click_pos_y = nil

              return
            end
          },
          {
            pass_type = "local_offset",
            content_id = "scroll_bar_info",
            offset_function = function (ui_scenegraph_, ui_style, ui_content, input_service_)
              local box_style = ui_style.scroll_bar_box
              local box_size_y = box_style.size[2]
              local start_y = box_style.start_offset[2]
              local end_y = (start_y + box_style.scroll_size_y) - box_size_y
              local scroll_size = end_y - start_y
              local value = ui_content.value
              local offset_y = start_y + scroll_size * (1 - value)
              box_style.offset[2] = offset_y
              local box_bottom = ui_style.scroll_bar_box_bottom
              local box_middle = ui_style.scroll_bar_box_middle
              local box_top = ui_style.scroll_bar_box_top
              local box_bottom_size_y = box_bottom.size[2]
              local box_top_size_y = box_top.size[2]
              box_bottom.offset[2] = offset_y
              box_top.offset[2] = (offset_y + box_size_y) - box_top_size_y
              box_middle.offset[2] = offset_y + box_bottom_size_y
              box_middle.size[2] = box_size_y - box_bottom_size_y - box_top_size_y

              return
            end
          },
          {
            pass_type = "texture",
            style_id = "scroll_bar_box_bottom",
            texture_id = "scroll_bar_box_bottom"
          },
          {
            pass_type = "tiled_texture",
            style_id = "scroll_bar_box_middle",
            texture_id = "scroll_bar_box_middle"
          },
          {
            pass_type = "texture",
            style_id = "scroll_bar_box_top",
            texture_id = "scroll_bar_box_top"
          }
        }
      },
      content = {
        scroll_bar_bottom_bg = "scroll_bar_bottom_bg",
        scroll_bar_top_bg = "scroll_bar_top_bg",
        scroll_bar_middle = "scroll_bar_middle",
        button_up = "scroll_bar_button_up",
        scroll_bar_box_bottom = "scroll_bar_box_bottom",
        scroll_bar_middle_bg = "scroll_bar_middle_bg",
        scroll_bar_bottom = "scroll_bar_bottom",
        disable_frame = false,
        scroll_bar_box_middle = "scroll_bar_box_middle",
        scroll_bar_box_top = "scroll_bar_box_top",
        button_down = "scroll_bar_button_down",
        scroll_bar_top = "scroll_bar_top",
        scroll_bar_info = {
          button_scroll_step = 0.1,
          value = 0,
          bar_height_percentage = 1,
          scenegraph_id = scenegraph_id
        },
        button_up_hotspot = {},
        button_down_hotspot = {}
      },
      style = {
        scroll_bar_bottom = {
          size = {
            26,
            116
          }
        },
        scroll_bar_bottom_bg = {
          offset = {
            0,
            0,
            -1
          },
          size = {
            26,
            116
          }
        },
        scroll_bar_middle = {
          offset = {
            0,
            116,
            0
          },
          size = {
            26,
            height - 232
          },
          texture_tiling_size = {
            26,
            44
          }
        },
        scroll_bar_middle_bg = {
          offset = {
            0,
            116,
            -1
          },
          size = {
            26,
            height - 232
          },
          texture_tiling_size = {
            26,
            44
          }
        },
        scroll_bar_top = {
          offset = {
            0,
            height - 116,
            0
          },
          size = {
            26,
            116
          }
        },
        scroll_bar_top_bg = {
          offset = {
            0,
            height - 116,
            -1
          },
          size = {
            26,
            116
          }
        },
        button_down = {
          offset = {
            5,
            4,
            0
          },
          size = {
            16,
            18
          }
        },
        button_up = {
          offset = {
            5,
            height - 22,
            0
          },
          size = {
            16,
            18
          }
        },
        scroll_bar_box = {
          offset = {
            4,
            22,
            100
          },
          size = {
            18,
            height - 44
          },
          color = {
            255,
            255,
            255,
            255
          },
          start_offset = {
            4,
            22,
            0
          },
          scroll_size_y = height - 44
        },
        scroll_bar_box_bottom = {
          offset = {
            4,
            0,
            0
          },
          size = {
            18,
            8
          }
        },
        scroll_bar_box_middle = {
          offset = {
            4,
            0,
            0
          },
          size = {
            18,
            26
          },
          texture_tiling_size = {
            18,
            26
          }
        },
        scroll_bar_box_top = {
          offset = {
            4,
            0,
            0
          },
          size = {
            18,
            8
          }
        }
      },
      scenegraph_id = scenegraph_id
    }
  end
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

  search_bar = {
    scenegraph_id = "sg_search_bar",
    element = {
      passes = {
        {
          pass_type = "hotspot",

          content_id = "hotspot"
        },
        {
          pass_type = "rect",

          style_id  = "background",

          content_check_function = function (content, style)

            if content.is_active then
              style.color[2] = 50
              style.color[3] = 50
              style.color[4] = 50
            else
              if content.hotspot.is_hover then
                style.color[2] = 25
                style.color[3] = 25
                style.color[4] = 25
              else
                style.color[2] = 0
                style.color[3] = 0
                style.color[4] = 0
              end
            end
            return true
          end
        },
        {
          pass_type = "texture",

          style_id   = "search_icon",
          texture_id = "search_icon_texture"
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        }
      }
    },
    content = {
      hotspot = {},
      text = "",
      search_icon_texture = "search_bar_icon"
    },
    style = {
      text = {
        offset = {46, 2, 3},
        font_size = 28,
        font_type = "hell_shark",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },
      search_icon = {
        size = {30, 30},
        offset = {8, 8, 3}
      },
      background = {
        color = {255, 0, 0, 0}
      }
    }
  },

  mousewheel_scroll_area = {
    scenegraph_id = "sg_mousewheel_scroll_area",
    element = {
      passes = {
        {
          pass_type = "scroll",
          -- the function is called only during scrolls
          scroll_function = function (ui_scenegraph_, style_, content, input_service_, scroll_axis)

            content.internal_scroll_value = content.internal_scroll_value - scroll_axis.y
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

  scrollbar = create_scrollbar(scenegraph_definition.sg_scrollbar.size[2], "sg_scrollbar")
}

-- @TODO: make scrollbar full windowed o_O

menu_widgets_definition.scrollbar.element.passes[15].pass_type = "rect"
menu_widgets_definition.scrollbar.style.scroll_bar_box_bottom.color = {200, 140, 100, 50}
menu_widgets_definition.scrollbar.style.scroll_bar_box_bottom.size[1] = 12

menu_widgets_definition.scrollbar.element.passes[16].pass_type = "rect"
menu_widgets_definition.scrollbar.style.scroll_bar_box_middle.color = {200, 140, 100, 50}
menu_widgets_definition.scrollbar.style.scroll_bar_box_middle.size[1] = 12

menu_widgets_definition.scrollbar.element.passes[17].pass_type = "rect"
menu_widgets_definition.scrollbar.style.scroll_bar_box_top.color = {200, 140, 100, 50}
menu_widgets_definition.scrollbar.style.scroll_bar_box_top.size[1] = 12



local original_scrollbar_function = menu_widgets_definition.scrollbar.element.passes[9].offset_function

menu_widgets_definition.scrollbar.element.passes[9].offset_function = function (scenegraph, style, content, input_service)
  original_scrollbar_function(scenegraph, style, content, input_service)

  style.scroll_bar_box_top.color = content.scroll_bar_info.is_hover and {255, 140, 100, 50} or {200, 140, 100, 50}
  style.scroll_bar_box_middle.color = content.scroll_bar_info.is_hover and {255, 140, 100, 50} or {200, 140, 100, 50}
  style.scroll_bar_box_bottom.color = content.scroll_bar_info.is_hover and {255, 140, 100, 50} or {200, 140, 100, 50}
end

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






-- ####################################################################################################################
-- ##### SETTINGS LIST WIDGETS DEFINITIONS ############################################################################
-- ####################################################################################################################

script_data.ui_debug_hover = false

local DEBUG_WIDGETS = false

local SETTINGS_LIST_HEADER_WIDGET_SIZE = {1194, 80}
local SETTINGS_LIST_REGULAR_WIDGET_SIZE = {1194, 50}


local function create_show_widget_condition(widget_definition)
  local show_widget_condition = nil
  if widget_definition.show_widget_condition then
    show_widget_condition = {}
    for _, i in ipairs(widget_definition.show_widget_condition) do
      show_widget_condition[i] = true
    end
  end
  return show_widget_condition
end

-- ██╗  ██╗███████╗ █████╗ ██████╗ ███████╗██████╗
-- ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
-- ███████║█████╗  ███████║██║  ██║█████╗  ██████╔╝
-- ██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗
-- ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║
-- ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝


local function create_header_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_HEADER_WIDGET_SIZE
  local offset_y = -widget_size[2]

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "highlight_texture",
          texture_id = "highlight_texture",

          content_check_function = function (content)
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "texture",

          style_id   = "fav_icon",
          texture_id = "fav_icon_texture",

          content_check_function = function (content)
            return content.is_favorited or content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "texture",

          style_id   = "fav_arrow_up",
          texture_id = "fav_arrow_texture",

          content_check_function = function (content)
            return content.is_favorited and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "rotated_texture",

          style_id   = "fav_arrow_down",
          texture_id = "fav_arrow_texture",

          content_check_function = function (content)
            return content.is_favorited and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },
        --[[
        {
          pass_type = "texture",

          style_id   = "checkbox",
          texture_id = "checkbox_texture",

          content_check_function = function (content)
            return content.is_checkbox_visible
          end
        },
        --]]
        ---[[
        {
          pass_type = "texture",

          style_id   = "checkbox_border",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_checkbox_visible
          end
        },
        {
          pass_type = "texture",

          style_id   = "checkbox_background",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_checkbox_visible
          end
        },
        {
          pass_type = "texture",

          style_id   = "checkbox_fill",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_checkbox_visible
          end
        },
        --]]
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

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.highlight_hotspot.on_release and not content.checkbox_hotspot.on_release and not content.fav_icon_hotspot.on_release
                and not content.fav_arrow_up_hotspot.on_release and not content.fav_arrow_down_hotspot.on_release then

                content.callback_hide_sub_widgets(content)
              end

              if content.fav_icon_hotspot.on_release and not content.fav_arrow_up_hotspot.on_release and not content.fav_arrow_down_hotspot.on_release then
                content.callback_favorite(content)
              end

              if content.fav_arrow_up_hotspot.on_release then
                content.callback_move_favorite(content, true)
              end

              if content.fav_arrow_down_hotspot.on_release then
                content.callback_move_favorite(content, false)
              end

              if content.checkbox_hotspot.on_release then

                if content.is_widget_collapsed then
                  content.callback_hide_sub_widgets(content)
                end

                local mod_name       = content.mod_name
                local is_mod_enabled = not content.is_checkbox_checked

                content.is_checkbox_checked = is_mod_enabled

                content.callback_mod_state_changed(mod_name, is_mod_enabled)
              end
            end

            content.fav_icon_texture = content.is_favorited and "header_fav_icon_lit" or "header_fav_icon"
            --content.checkbox_texture = content.is_checkbox_checked and "checkbox_checked" or "checkbox_unchecked"
            style.fav_arrow_up.color[1] = is_interactable and content.fav_arrow_up_hotspot.is_hover and 255 or 90
            style.fav_arrow_down.color[1] = is_interactable and content.fav_arrow_down_hotspot.is_hover and 255 or 90

            style.background.color = content.is_widget_collapsed and {255, 110, 78, 39} or {255, 57, 39, 21}
            if content.is_checkbox_checked then
              style.checkbox_fill.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 255, 255, 255} or {255, 255, 168, 0}
            else
              style.checkbox_fill.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 100, 100, 100} or {255, 0, 0, 0}
            end
            if content.is_widget_collapsed then
              style.checkbox_border.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 166, 118, 61} or {255, 154, 109, 55}
            else
              style.checkbox_border.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 103, 71, 38} or {255, 89, 61, 32}
            end
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_checkbox_checked = true,
      is_checkbox_visible = false,
      is_widget_visible   = true,
      is_widget_collapsed = widget_definition.is_collapsed,
      is_favorited        = widget_definition.is_favorited,

      rect_masked_texture = "rect_masked",
      fav_icon_texture    = "header_fav_icon",
      --checkbox_texture    = "checkbox_unchecked",
      highlight_texture   = "playerlist_hover",
      background_texture  = "header_background",
      fav_arrow_texture   = "header_fav_arrow",

      fav_icon_hotspot        = {},
      fav_arrow_up_hotspot    = {},
      fav_arrow_down_hotspot  = {},
      checkbox_hotspot        = {},
      highlight_hotspot       = {},

      text = widget_definition.readable_mod_name,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      widget_type = widget_definition.type
    },
    style = {

      -- VISUALS

      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0},
        color = {255, 57, 39, 21}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 2},
        color = {255, 255, 255, 255},
        masked = true
      },

      fav_icon = {
        size = {30, 30},
        offset = {15, offset_y + 25, 3},
        masked = true
      },

      fav_arrow_up = {
        size = {20, 20},
        offset = {20, offset_y + 57, 3},
        color = {90, 255, 255, 255},
        masked = true
      },

      fav_arrow_down = {
        size = {20, 20},
        offset = {20, offset_y + 3, 3},
        angle = math.pi,
        pivot = {10, 10},
        color = {90, 255, 255, 255},
        masked = true
      },

      text = {
        offset = {60, offset_y + 18, 3},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },
--[[
      checkbox = {
        size = {30, 30},
        offset = {widget_size[1] - 180, offset_y + 25, 3},
        masked = true
      },
]]
      checkbox_border = {
        offset = {widget_size[1] - 184, offset_y + 21, 1},
        size = {38, 38},
        color = {255, 89, 61, 32}
      },

      checkbox_background = {
        offset = {widget_size[1] - 176, offset_y + 29, 3},
        size = {22, 22},
        color = {255, 0, 0, 0}
      },

      checkbox_fill = {
        offset = {widget_size[1] - 174, offset_y + 31, 4},
        size = {18, 18},
        color = {255, 255, 168, 0}
      },
      -- HOTSPOTS

      fav_icon_hotspot = {
        size = {60, widget_size[2]},
        offset = {0, offset_y, 3}
      },

      fav_arrow_up_hotspot = {
        size = {60, 20},
        offset = {0, offset_y + 60, 3}
      },

      fav_arrow_down_hotspot = {
        size = {60, 20},
        offset = {0, offset_y, 3}
      },

      checkbox_hotspot = {
        size = {270, widget_size[2]},
        offset = {widget_size[1] - 300, offset_y, 0}
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
        cursor_offset_top = {27, -27}
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
  local offset_y = -widget_size[2]

  local show_widget_condition = create_show_widget_condition(widget_definition)

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id = "text"
        },
        {
          pass_type = "texture",

          style_id   = "checkbox_border",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "checkbox_background",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "checkbox_fill",
          texture_id = "rect_masked_texture"
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

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.highlight_hotspot.on_release and not content.checkbox_hotspot.on_release then
                content.callback_hide_sub_widgets(content)
              end

              if content.checkbox_hotspot.on_release then

                if content.is_widget_collapsed then
                  content.callback_hide_sub_widgets(content)
                end

                local mod_name = content.mod_name
                local setting_id = content.setting_id
                local old_value = content.is_checkbox_checked
                local new_value = not old_value

                content.is_checkbox_checked = new_value

                content.callback_setting_changed(mod_name, setting_id, old_value, new_value)
              end
            end

            if content.is_checkbox_checked then
              style.checkbox_fill.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 255, 255, 255} or {255, 255, 168, 0}
            else
              style.checkbox_fill.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 100, 100, 100} or {255, 0, 0, 0}
            end
            style.checkbox_border.color = is_interactable and content.checkbox_hotspot.is_hover and {255, 45, 45, 45} or {255, 30, 30, 30}
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_checkbox_checked = false,
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_collapsed,

      rect_masked_texture = "rect_masked",
      highlight_texture = "playerlist_hover",

      checkbox_hotspot = {},
      highlight_hotspot = {},

      text = widget_definition.title,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      setting_id = widget_definition.setting_id,
      widget_type = widget_definition.type,
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_index,
      show_widget_condition = show_widget_condition
    },
    style = {

      -- VISUALS
      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0},
        color = {255, 30, 23, 15}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 2},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.depth * 40, offset_y + 5, 3},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      checkbox_border = {
        offset = {widget_size[1] - 182, offset_y + 8, 1},
        size = {34, 34},
        color = {255, 30, 30, 30}
      },

      checkbox_background = {
        offset = {widget_size[1] - 174, offset_y + 16, 3},
        size = {18, 18},
        color = {255, 0, 0, 0}
      },

      checkbox_fill = {
        offset = {widget_size[1] - 172, offset_y + 18, 4},
        size = {14, 14},
        color = {255, 255, 168, 0}
      },

      -- HOTSPOTS

      checkbox_hotspot = {
        size = {270, widget_size[2]},
        offset = {widget_size[1] - 300, offset_y, 0}
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


--  ██████╗ ██████╗  ██████╗ ██╗   ██╗██████╗
-- ██╔════╝ ██╔══██╗██╔═══██╗██║   ██║██╔══██╗
-- ██║  ███╗██████╔╝██║   ██║██║   ██║██████╔╝
-- ██║   ██║██╔══██╗██║   ██║██║   ██║██╔═══╝
-- ╚██████╔╝██║  ██║╚██████╔╝╚██████╔╝██║
--  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝


local function create_group_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = -widget_size[2]

  local show_widget_condition = create_show_widget_condition(widget_definition)

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id   = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.highlight_hotspot.on_release then
                content.callback_hide_sub_widgets(content)
              end
            end
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_collapsed,

      highlight_texture = "playerlist_hover",
      rect_masked_texture = "rect_masked",

      highlight_hotspot = {},

      text = widget_definition.title,
      tooltip_text = widget_definition.tooltip,


      mod_name = widget_definition.mod_name,
      setting_id = widget_definition.setting_id,
      widget_type = widget_definition.type,
      parent_widget_number = widget_definition.parent_index,
      show_widget_condition = show_widget_condition
    },
    style = {

      -- VISUALS
      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0},
        color = {255, 30, 23, 15}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 1},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.depth * 40, offset_y + 5, 2},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
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

-- ██████╗ ██████╗  ██████╗ ██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗
-- ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║
-- ██║  ██║██████╔╝██║   ██║██████╔╝██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║
-- ██║  ██║██╔══██╗██║   ██║██╔═══╝ ██║  ██║██║   ██║██║███╗██║██║╚██╗██║
-- ██████╔╝██║  ██║╚██████╔╝██║     ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║
-- ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝

local function create_dropdown_menu_widget(dropdown_definition, scenegraph_2nd_layer_id)

  local offset_x = dropdown_definition.style.border_bottom.offset[1]
  local offset_y = dropdown_definition.style.border_bottom.offset[2]
  --local offset_y = dropdown_definition.style.offset[2]
  local size_x = dropdown_definition.style.border_bottom.size[1]
  local options_texts = dropdown_definition.content.options_texts
  local string_height = 35
  local size_y = #options_texts * string_height

  local definition = {
    element = {
      passes = {
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture"
        }
      }
    },
    content = {
      rect_masked_texture = "rect_masked",
    },
    style = {
      background = {
        size = {size_x, size_y},
        offset = {offset_x, offset_y - size_y, 20},
        color = {255, 10, 10, 10}
      }
    },
    scenegraph_id = scenegraph_2nd_layer_id,
    offset = {0, 0, 0}
  }

  for i, options_text in ipairs(options_texts) do

    -- HOTSPOT

    local lua_hotspot_name = "hotspot" .. tostring(i)

    -- pass
    local pass = {
      pass_type = "hotspot",

      style_id = lua_hotspot_name,
      content_id = lua_hotspot_name
    }
    table.insert(definition.element.passes, pass)

    -- content
    definition.content[lua_hotspot_name] = {}
    definition.content[lua_hotspot_name].num = i

    -- style
    definition.style[lua_hotspot_name] = {
      offset = {offset_x, offset_y - string_height * i, 21},
      size = {size_x, string_height}
    }

    -- OPTION TEXT

    local lua_text_name = "text" .. tostring(i)

    -- pass
    pass = {
      pass_type = "text",

      style_id = lua_text_name,
      text_id = lua_text_name,

      content_check_function = function (content, style)

        style.text_color = content[lua_hotspot_name].is_hover and Colors.get_color_table_with_alpha("white", 255) or Colors.get_color_table_with_alpha("cheeseburger", 255)
        return true
      end
    }
    table.insert(definition.element.passes, pass)

    -- content
    definition.content[lua_text_name] = options_text

    -- style
    definition.style[lua_text_name] = {
      offset = {offset_x + size_x / 2, offset_y - string_height * i, 21},
      horizontal_alignment = "center",
      font_size = 24,
      font_type = "hell_shark_masked",
      dynamic_font = true,
      text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
    }
  end

  return UIWidget.init(definition)
end


local function create_dropdown_widget(widget_definition, scenegraph_id, scenegraph_2nd_layer_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = -widget_size[2]

  local show_widget_condition = create_show_widget_condition(widget_definition)

  local options_texts         = {}
  local options_values        = {}
  local options_shown_widgets = {}

  for i, option in ipairs(widget_definition.options) do
    options_texts[i] = option.text
    options_values[i] = option.value
    options_shown_widgets[i] = option.show_widgets or {}
  end

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id   = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id  = "text"
        },
        {
          pass_type = "text",

          style_id = "current_option_text",
          text_id  = "current_option_text"
        },
        {
          pass_type = "texture",

          style_id   = "border_top",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "border_left",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "border_right",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "border_bottom",
          texture_id = "rect_masked_texture"
        },

        -- HOTSPOTS
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id   = "dropdown_hotspot",
          content_id = "dropdown_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.dropdown_hotspot.on_release then
                content.callback_change_dropdown_menu_visibility(content)
              end

              if content.highlight_hotspot.on_release and not content.dropdown_hotspot.on_release then
                content.callback_hide_sub_widgets(content)
              end
            end

            if content.is_dropdown_menu_opened then

              local old_value = content.options_values[content.current_option_number]

              if content.callback_draw_dropdown_menu(content) then

                if content.is_widget_collapsed then
                  content.callback_hide_sub_widgets(content)
                end

                local mod_name = content.mod_name
                local setting_id = content.setting_id
                local new_value = content.options_values[content.current_option_number]

                content.callback_setting_changed(mod_name, setting_id, old_value, new_value)
              end
            end

            style.current_option_text.text_color = (is_interactable and content.dropdown_hotspot.is_hover or content.is_dropdown_menu_opened) and Colors.get_color_table_with_alpha("white", 255) or Colors.get_color_table_with_alpha("cheeseburger", 255)

            local new_border_color = is_interactable and content.dropdown_hotspot.is_hover and {255, 45, 45, 45} or {255, 30, 30, 30}
            style.border_top.color = new_border_color
            style.border_left.color  = new_border_color
            style.border_right.color = new_border_color
            style.border_bottom.color = new_border_color
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_collapsed,

      highlight_texture = "playerlist_hover",
      rect_masked_texture = "rect_masked",
      --background_texture = "common_widgets_background_lit",

      highlight_hotspot = {},
      dropdown_hotspot = {},

      text = widget_definition.title,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      setting_id = widget_definition.setting_id,
      widget_type = widget_definition.type,

      options_texts  = options_texts,
      options_values = options_values,
      options_shown_widgets = options_shown_widgets,
      total_options_number = #options_texts,
      current_option_number = 1,
      current_option_text = options_texts[1],
      current_shown_widgets = nil, -- if nil, all subwidgets are shown
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_index,
      show_widget_condition = show_widget_condition
    },
    style = {

      -- VISUALS

      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0},
        color = {255, 30, 23, 15}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 2},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.depth * 40, offset_y + 5, 3},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      border_top = {
        size = {270, 2},
        offset = {widget_size[1] - 300, offset_y + (widget_size[2] - 10), 1},
        color = {255, 30, 30, 30}
      },

      border_left = {
        size = {2, widget_size[2] - 16},
        offset = {widget_size[1] - 300, offset_y + 8, 1},
        color = {255, 30, 30, 30}
      },

      border_right = {
        size = {2, widget_size[2] - 16},
        offset = {widget_size[1] - 32, offset_y + 8, 1},
        color = {255, 30, 30, 30}
      },

      border_bottom = {
        size = {270, 2},
        offset = {widget_size[1] - 300, offset_y + 8, 1},
        color = {255, 30, 30, 30}
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

      dropdown_hotspot = {
        size = {270, widget_size[2]},
        offset = {widget_size[1] - 300, offset_y, 0}
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

  definition.content.popup_menu_widget = create_dropdown_menu_widget(definition, scenegraph_2nd_layer_id)

  return UIWidget.init(definition)
end


-- ███╗   ██╗██╗   ██╗███╗   ███╗███████╗██████╗ ██╗ ██████╗
-- ████╗  ██║██║   ██║████╗ ████║██╔════╝██╔══██╗██║██╔════╝
-- ██╔██╗ ██║██║   ██║██╔████╔██║█████╗  ██████╔╝██║██║
-- ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗██║██║
-- ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████╗██║  ██║██║╚██████╗
-- ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝

local function create_numeric_menu_widget(dropdown_definition, scenegraph_2nd_layer_id)

  local offset_x = dropdown_definition.style.left_bracket.offset[1] - 3
  local offset_y = dropdown_definition.style.left_bracket.offset[2] + 80
  local size_x = 270
  local size_y = 100

  local definition = {
    element = {
      passes = {
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "text",

          style_id = "range_text",
          text_id = "range_text"
        },
        {
          pass_type = "text",

          style_id = "new_value_text",
          text_id = "new_value_text"
        },
        {
          pass_type = "texture",

          style_id   = "caret",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "slider_border",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "slider_background",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "slider_fill",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "texture",

          style_id   = "slider_icon",
          texture_id = "slider_icon_texture"
        },
        {
          pass_type = "hotspot",

          style_id   = "slider_hotspot",
          content_id = "slider_hotspot"
        },
        {
          pass_type = "held",

          style_id = "slider_hotspot",
          content_check_hover = "slider_hotspot",

          -- fatshark solution copypasta
          held_function = function (ui_scenegraph, ui_style, ui_content, input_service)
            local cursor = UIInverseScaleVectorToResolution(input_service.get(input_service, "cursor"))
            local scenegraph_id = ui_content.scenegraph_id
            local world_position = UISceneGraph.get_world_position(ui_scenegraph, scenegraph_id)
            local size_x_ = ui_style.size[1]
            local cursor_x = cursor[1]
            local pos_start = world_position[1] + ui_style.offset[1]
            local old_value = ui_content.internal_value
            local cursor_x_norm = cursor_x - pos_start
            local value = math.clamp(cursor_x_norm/size_x_, 0, 1)
            ui_content.internal_value = value

            if old_value ~= value then
              ui_content.changed = true
            end
          end
        }
      }
    },
    content = {
      new_value_text = "",
      range_text = "",

      rect_masked_texture = "rect_masked",
      slider_icon_texture = "slider_skull_icon",

      caret_animation_timer = 0,
      max_slider_size = 242,
      slider_icon_offset = offset_x + 4,

      scenegraph_id = scenegraph_2nd_layer_id,

      slider_hotspot = {}
    },
    style = {
      background = {
        size = {size_x, size_y},
        offset = {offset_x, offset_y - size_y, 20},
        color = {255, 20, 20, 20}
      },
      range_text = {
        offset = {offset_x + size_x / 2, offset_y - 30, 21},
        horizontal_alignment = "center",
        font_size = 20,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = {255, 100, 100, 100}
      },
      new_value_text = {
        offset = {
          dropdown_definition.style.current_value_text.offset[1],
          dropdown_definition.style.current_value_text.offset[2],
          21
        },
        horizontal_alignment = "center",
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = {255, 255, 255, 255}
      },
      caret = {
        size = {2, 25},
        offset = {offset_x, dropdown_definition.style.current_value_text.offset[2] + 10, 22},
        color = {255, 255, 255, 255}
      },
      slider_border = {
        offset = {offset_x + 10, offset_y - size_y + 10, 21},
        size = {250, 13},
        color = {255, 100, 100, 100}
      },
      slider_background = {
        offset = {offset_x + 12, offset_y - size_y + 12, 22},
        size = {246, 9},
        color = {255, 0, 0, 0}
      },
      slider_fill = {
        offset = {offset_x + 14, offset_y - size_y + 14, 23},
        size = {242, 5},
        color = {255, 255, 168, 0}
      },
      slider_icon = {
        offset = {offset_x + 4, offset_y - size_y + 7, 24},
        size = {20, 20},
        color = {255, 255, 255, 255},
        masked = true
      },
      slider_hotspot = {
        offset = {offset_x + 14, offset_y - size_y, 24},
        size = {242, 35}
      }
    },
    scenegraph_id = scenegraph_2nd_layer_id,
    offset = {0, 0, 0}
  }

  return UIWidget.init(definition)
end

local function create_numeric_widget(widget_definition, scenegraph_id, scenegraph_2nd_layer_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = -widget_size[2]

  local show_widget_condition = create_show_widget_condition(widget_definition)

  local definition = {
    element = {
      passes = {
        -- VISUALS
        {
          pass_type = "texture",

          style_id   = "background",
          texture_id = "rect_masked_texture",

          content_check_function = function (content)
            return content.is_widget_collapsed
          end
        },
        {
          pass_type = "texture",

          style_id = "highlight_texture",
          texture_id = "highlight_texture",
          content_check_function = function (content)
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id = "text"
        },
        {
          pass_type = "text",

          style_id = "left_bracket",
          text_id = "left_bracket"
        },
        {
          pass_type = "text",

          style_id = "right_bracket",
          text_id = "right_bracket"
        },
        {
          pass_type = "text",

          style_id = "current_value_text",
          text_id = "current_value_text"
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id = "dropdown_hotspot",
          content_id = "dropdown_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.dropdown_hotspot.on_release then

                content.callback_change_numeric_menu_visibility(content)
              end
            end

            if content.is_numeric_menu_opened then

              local old_value = content.current_value

              if content.callback_draw_numeric_menu(content) then

                local mod_name = content.mod_name
                local setting_id = content.setting_id
                local new_value = content.current_value

                content.callback_setting_changed(mod_name, setting_id, old_value, new_value)
              end
            end

            style.current_value_text.text_color = is_interactable and content.dropdown_hotspot.is_hover and Colors.get_color_table_with_alpha("white", 255) or Colors.get_color_table_with_alpha("cheeseburger", 255)
            style.left_bracket.text_color = is_interactable and content.dropdown_hotspot.is_hover and {255, 45, 45, 45} or {255, 30, 30, 30}
            style.right_bracket.text_color = is_interactable and content.dropdown_hotspot.is_hover and {255, 45, 45, 45} or {255, 30, 30, 30}
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_collapsed,

      highlight_texture = "playerlist_hover",
      rect_masked_texture = "rect_masked",

      highlight_hotspot = {},
      dropdown_hotspot = {},

      text = widget_definition.title,
      tooltip_text = widget_definition.tooltip,
      unit_text = widget_definition.unit_text,
      decimals_number = widget_definition.decimals_number,
      range = widget_definition.range,

      left_bracket = "[",
      right_bracket = "]",

      mod_name = widget_definition.mod_name,
      setting_id = widget_definition.setting_id,
      widget_type = widget_definition.type,

      current_value_text = "whatever",
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_index,
      show_widget_condition = show_widget_condition
    },
    style = {

      -- VISUALS

      background = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 0}
      },

      highlight_texture = {
        size = {widget_size[1], widget_size[2] - 3},
        offset = {0, offset_y + 1, 2},
        masked = true
      },

      text = {
        offset = {60 + widget_definition.depth * 40, offset_y + 5, 3},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      left_bracket = {
        offset = {widget_size[1] - 297, offset_y - 6, 1}, -- text positioning's living in its own world
        horizontal_alignment = "center",
        font_size = 39,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = {255, 30, 30, 30}
      },

      right_bracket = {
        offset = {widget_size[1] - 33, offset_y - 6, 1},
        horizontal_alignment = "center",
        font_size = 39,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = {255, 30, 30, 30}
      },

      current_value_text = {
        offset = {widget_size[1] - 165, offset_y + 4, 3},
        horizontal_alignment = "center",
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
      },

      -- HOTSPOTS

      dropdown_hotspot = {
        size = {270, widget_size[2]},
        offset = {widget_size[1] - 300, offset_y, 0}
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

  definition.content.popup_menu_widget = create_numeric_menu_widget(definition, scenegraph_2nd_layer_id)

  return UIWidget.init(definition)
end


-- ██╗  ██╗███████╗██╗   ██╗██████╗ ██╗███╗   ██╗██████╗
-- ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔══██╗██║████╗  ██║██╔══██╗
-- █████╔╝ █████╗   ╚████╔╝ ██████╔╝██║██╔██╗ ██║██║  ██║
-- ██╔═██╗ ██╔══╝    ╚██╔╝  ██╔══██╗██║██║╚██╗██║██║  ██║
-- ██║  ██╗███████╗   ██║   ██████╔╝██║██║ ╚████║██████╔╝
-- ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═════╝


local function create_keybind_widget(widget_definition, scenegraph_id)

  local widget_size = SETTINGS_LIST_REGULAR_WIDGET_SIZE
  local offset_y = -widget_size[2]

  local show_widget_condition = create_show_widget_condition(widget_definition)

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
            return content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        {
          pass_type = "text",

          style_id = "text",
          text_id = "text"
        },
        {
          pass_type = "texture",

          style_id = "keybind_background",
          texture_id = "rect_masked_texture"
        },
        {
          pass_type = "text",

          style_id = "keybind_text",
          text_id = "keybind_text"
        },
        -- HOTSPOTS
        {
          pass_type = "hotspot",

          content_id = "highlight_hotspot"
        },
        {
          pass_type = "hotspot",

          style_id = "keybind_text_hotspot",
          content_id = "keybind_text_hotspot"
        },
        -- PROCESSING
        {
          pass_type = "local_offset",

          offset_function = function (ui_scenegraph_, style, content, ui_renderer)

            local is_interactable = content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()

            if is_interactable then

              if content.highlight_hotspot.is_hover and content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.highlight_hotspot.on_release and not content.keybind_text_hotspot.on_release then
                content.callback_hide_sub_widgets(content)
              end

              if content.highlight_hotspot.is_hover and content.tooltip_text then
                style.tooltip_text.cursor_offset = content.callback_fit_tooltip_to_the_screen(content, style.tooltip_text, ui_renderer)
              end

              if content.keybind_text_hotspot.on_release then
                content.callback_change_setting_keybind_state(content)
                return
              end
            end

            if content.is_setting_keybind then
              if content.callback_setting_keybind(content) then
                content.callback_setting_changed(content.mod_name, content.setting_id, nil, content.keys)
                return
              end
            end

            style.keybind_text.text_color = is_interactable and content.keybind_text_hotspot.is_hover and Colors.get_color_table_with_alpha("white", 255) or content.is_setting_keybind and Colors.get_color_table_with_alpha("white", 100) or Colors.get_color_table_with_alpha("cheeseburger", 255)
            style.keybind_background.color = is_interactable and content.keybind_text_hotspot.is_hover and {255, 45, 45, 45} or {255, 30, 30, 30}
          end
        },
        -- TOOLTIP
        {
          pass_type = "tooltip_text",

          text_id  = "tooltip_text",
          style_id = "tooltip_text",
          content_check_function = function (content)
            return content.tooltip_text and content.highlight_hotspot.is_hover and content.callback_is_cursor_inside_settings_list()
          end
        },
        -- DEBUG
        {
          pass_type = "rect",

          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "border",

          content_check_function = function (content_, style)
            if DEBUG_WIDGETS then
              style.thickness = 1
            end

            return DEBUG_WIDGETS
          end
        },
        {
          pass_type = "rect",

          style_id = "debug_middle_line",
          content_check_function = function ()
            return DEBUG_WIDGETS
          end
        }
      }
    },
    content = {
      is_widget_visible = true,
      is_widget_collapsed = widget_definition.is_collapsed,

      highlight_texture = "playerlist_hover", -- texture name
      background_texture = "common_widgets_background_lit",
      rect_masked_texture = "rect_masked",

      highlight_hotspot = {},
      keybind_text_hotspot = {},

      text = widget_definition.title,
      tooltip_text = widget_definition.tooltip,

      mod_name = widget_definition.mod_name,
      setting_id = widget_definition.setting_id,
      widget_type = widget_definition.type,

      keybind_global = widget_definition.keybind_global,
      keybind_trigger = widget_definition.keybind_trigger,
      keybind_type = widget_definition.keybind_type,
      function_name = widget_definition.function_name,
      view_name = widget_definition.view_name,
      transition_data = widget_definition.transition_data,

      keybind_text = widget_definition.keybind_text,
      default_value = widget_definition.default_value,
      parent_widget_number = widget_definition.parent_index,
      show_widget_condition = show_widget_condition
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
        offset = {60 + widget_definition.depth * 40, offset_y + 5, 2},
        font_size = 28,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("white", 255)
      },

      keybind_background = {
        size = {270, 34},
        offset = {widget_size[1] - 300, offset_y + 8, 0},
        color = {255, 30, 30, 30}
      },

      keybind_text = {
        offset = {widget_size[1] - 165, offset_y + 6, 3},
        horizontal_alignment = "center",
        font_size = 24,
        font_type = "hell_shark_masked",
        dynamic_font = true,
        text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
      },

      -- HOTSPOTS

      keybind_text_hotspot = {
        size = {270, widget_size[2]},
        offset = {widget_size[1] - 300, offset_y, 0}
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

local _DEFAULT_SCROLL_STEP = 40
local _SCROLL_STEP


-- copypasted 'math.point_is_inside_2d_box' from VT2 source code, since VT1 and VT2 have different implementations
local function is_point_inside_2d_box(pos, lower_left_corner, size)
  if lower_left_corner[1] < pos[1] and pos[1] < lower_left_corner[1] + size[1] and lower_left_corner[2] < pos[2] and pos[2] < lower_left_corner[2] + size[2] then
    return true
  else
    return false
  end
end

-- ####################################################################################################################
-- ##### INITIALIZATION ###############################################################################################
-- ####################################################################################################################


VMFOptionsView = class(VMFOptionsView)
VMFOptionsView.init = function (self, ingame_ui_context)

  self.current_setting_list_offset_y = 0

  self.is_setting_changes_applied_immidiately = true

  self.definitions = {}
  self.definitions.scenegraph            = scenegraph_definition
  self.definitions.scenegraph_2nd_layer  = {}
  self.definitions.menu_widgets          = menu_widgets_definition
  self.definitions.settings_list_widgets = vmf.options_widgets_data

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

  input_manager:create_input_service("changing_setting", "IngameMenuKeymaps")
  input_manager:map_device_to_service("changing_setting", "keyboard")
  input_manager:map_device_to_service("changing_setting", "mouse")
  input_manager:map_device_to_service("changing_setting", "gamepad")
  self.input_manager = input_manager

  -- wwise_world is used for making sounds (for opening menu, closing menu, etc.)
  local world
  if VT1 then
    world = ingame_ui_context.world_manager:world("music_world")
  else
    world = ingame_ui_context.world_manager:world("level_world")
  end
  self.wwise_world = Managers.world:wwise_world(world)

  self:create_ui_elements()
end


-- ####################################################################################################################
-- ##### INITIALIZATION: UI ELEMENTS ##################################################################################
-- ####################################################################################################################


VMFOptionsView.create_ui_elements = function (self)

  self.menu_widgets = {}

  for name, definition in pairs(self.definitions.menu_widgets) do
    self.menu_widgets[name] = UIWidget.init(definition)
  end

  self.settings_list_widgets = self:initialize_settings_list_widgets()

  self.ui_scenegraph = UISceneGraph.init_scenegraph(self.definitions.scenegraph)
  self.ui_scenegraph_2nd_layer = UISceneGraph.init_scenegraph(self.definitions.scenegraph_2nd_layer)

  self.setting_list_mask_size_y = self.ui_scenegraph.sg_settings_list_mask.size[2]

  if self.is_scrolling_enabled then
    self:calculate_scrollbar_size()
  end
end


VMFOptionsView.initialize_settings_list_widgets = function (self)

  local scenegraph_id = "sg_settings_list"
  local scenegraph_id_start = "sg_settings_list_start"
  local scenegraph_id_start_2nd_layer = "sg_settings_list_start_2nd_layer"
  local list_size_y = 0

  local all_widgets = {}
  local mod_widgets

  for _, mod_settings_list_definitions in ipairs(self.definitions.settings_list_widgets) do

    mod_widgets = {}

    for _, definition in ipairs(mod_settings_list_definitions) do

      local widget = nil
      local widget_type = definition.type

      if widget_type == "checkbox" then
        widget = self:initialize_checkbox_widget(definition, scenegraph_id_start)
      elseif widget_type == "dropdown" then
        widget = self:initialize_dropdown_widget(definition, scenegraph_id_start, scenegraph_id_start_2nd_layer)
      elseif widget_type == "numeric" then
        widget = self:initialize_numeric_widget(definition, scenegraph_id_start, scenegraph_id_start_2nd_layer)
      elseif widget_type == "keybind" then
        widget = self:initialize_keybind_widget(definition, scenegraph_id_start)
      elseif widget_type == "header" then
        widget = self:initialize_header_widget(definition, scenegraph_id_start)
      elseif widget_type == "group" then
        widget = self:initialize_group_widget(definition, scenegraph_id_start)
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
    position = {0, 0, 0},
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

  self.definitions.scenegraph_2nd_layer[scenegraph_id_start_2nd_layer] = {
    size     = {0, 0},
    position = {0, 0, 0},
    offset   = {0, 0, 0},

    vertical_alignment = "bottom",
    horizontal_alignment = "left"
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


VMFOptionsView.initialize_header_widget = function (self, definition, scenegraph_id)

  local widget  = create_header_widget(definition, scenegraph_id)
  local content = widget.content
  content.is_checkbox_checked = definition.is_togglable
  content.is_checkbox_visible = definition.is_togglable

  content.callback_favorite = callback(self, "callback_favorite")
  content.callback_move_favorite = callback(self, "callback_move_favorite")
  content.callback_mod_state_changed = callback(self, "callback_mod_state_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")

  return widget
end


VMFOptionsView.initialize_checkbox_widget = function (self, definition, scenegraph_id)

  local widget = create_checkbox_widget(definition, scenegraph_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")

  return widget
end

VMFOptionsView.initialize_group_widget = function (self, definition, scenegraph_id)

  local widget = create_group_widget(definition, scenegraph_id)
  local content = widget.content

  --content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")

  return widget
end


VMFOptionsView.initialize_dropdown_widget = function (self, definition, scenegraph_id, scenegraph_2nd_layer_id)

  local widget = create_dropdown_widget(definition, scenegraph_id, scenegraph_2nd_layer_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")
  content.callback_change_dropdown_menu_visibility = callback(self, "callback_change_dropdown_menu_visibility")
  content.callback_draw_dropdown_menu = callback(self, "callback_draw_dropdown_menu")

  return widget
end


VMFOptionsView.initialize_numeric_widget = function (self, definition, scenegraph_id, scenegraph_2nd_layer_id)

  local widget = create_numeric_widget(definition, scenegraph_id, scenegraph_2nd_layer_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")
  content.callback_change_numeric_menu_visibility = callback(self, "callback_change_numeric_menu_visibility")
  content.callback_draw_numeric_menu = callback(self, "callback_draw_numeric_menu")

  return widget
end


VMFOptionsView.initialize_keybind_widget = function (self, definition, scenegraph_id)

  local widget = create_keybind_widget(definition, scenegraph_id)
  local content = widget.content

  content.callback_setting_changed = callback(self, "callback_setting_changed")
  content.callback_hide_sub_widgets = callback(self, "callback_hide_sub_widgets")
  content.callback_fit_tooltip_to_the_screen = callback(self, "callback_fit_tooltip_to_the_screen")
  content.callback_change_setting_keybind_state = callback(self, "callback_change_setting_keybind_state")
  content.callback_setting_keybind = callback(self, "callback_setting_keybind")
  content.callback_is_cursor_inside_settings_list = callback(self, "callback_is_cursor_inside_settings_list")

  return widget
end


-- ####################################################################################################################
-- ##### CALLBACKS ####################################################################################################
-- ####################################################################################################################


VMFOptionsView.callback_setting_changed = function (self, mod_name, setting_id, old_value, new_value)

  if self.is_setting_changes_applied_immidiately and old_value ~= new_value then
    get_mod(mod_name):set(setting_id, new_value, true)
  end

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

  self:update_settings_list_widgets_visibility(mod_name)
  self:readjust_visible_settings_list_widgets_position()
end


VMFOptionsView.callback_mod_state_changed = function (self, mod_name, is_mod_enabled)

  vmf.mod_state_changed(mod_name, is_mod_enabled)

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

  self:update_settings_list_widgets_visibility(mod_name)
  self:readjust_visible_settings_list_widgets_position()
end


VMFOptionsView.callback_is_cursor_inside_settings_list = function (self)

  local input_service = self:input_service()

  local cursor    = input_service:get("cursor")
  local mask_pos  = Vector3.deprecated_copy(UISceneGraph.get_world_position(self.ui_scenegraph, "sg_settings_list_mask"))
  local mask_size = UISceneGraph.get_size(self.ui_scenegraph, "sg_settings_list_mask")

  local cursor_position = UIInverseScaleVectorToResolution(cursor)

  local is_hover = math.point_is_inside_2d_box(cursor_position, mask_pos, mask_size)
  if is_hover then
    return true
  end
end

--                        [VT1]                [VT2]
local UIResolutionScale = UIResolutionScale or UIResolutionScale_pow2
-- @TODO: replace with `VT1` later
local USE_LEGACY_FONT_NAMES = VT1 or (tonumber(script_data.settings.content_revision) < 1296)
VMFOptionsView.callback_fit_tooltip_to_the_screen = function (self, widget_content, widget_style, ui_renderer)

  local cursor_offset_bottom = widget_style.cursor_offset_bottom

  if ui_renderer.input_service then

    local cursor_position = UIInverseScaleVectorToResolution(ui_renderer.input_service.get(ui_renderer.input_service, "cursor"))
    if cursor_position then

      local text = widget_content.tooltip_text
      local max_width = widget_style.max_width

      local font, font_size = UIFontByResolution(widget_style)
      local font_name = USE_LEGACY_FONT_NAMES and font[3] or widget_style.font_type
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

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

  self:sort_settings_list_widgets()
  self:readjust_visible_settings_list_widgets_position()
end


VMFOptionsView.callback_move_favorite = function (self, widget_content, is_moved_up)

  local mod_name = widget_content.mod_name

  local new_index

  local favorite_mods_list = vmf:get("options_menu_favorite_mods")

  for current_index, current_mod_name in ipairs(favorite_mods_list) do
    if current_mod_name == mod_name then

      new_index = is_moved_up and (current_index - 1) or (current_index + 1)
      new_index = math.clamp(new_index, 1, #favorite_mods_list)

      if current_index ~= new_index then
        table.insert(favorite_mods_list, new_index, table.remove(favorite_mods_list, current_index))

        vmf:set("options_menu_favorite_mods", favorite_mods_list)

        WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

        self:sort_settings_list_widgets()
        self:readjust_visible_settings_list_widgets_position()

        return
      end
    end
  end
end


VMFOptionsView.callback_hide_sub_widgets = function (self, widget_content)

  local mod_name            = widget_content.mod_name
  local setting_id          = widget_content.setting_id
  local is_widget_collapsed = widget_content.is_widget_collapsed

  local widget_number = not setting_id and 1 -- if (setting_id == nil) -> it's header -> #1

  local are_there_visible_sub_widgets = false

  if not is_widget_collapsed then

    for _, mod_widgets in ipairs(self.settings_list_widgets) do

      if mod_widgets[1].content.mod_name == mod_name then

        for i, widget in ipairs(mod_widgets) do

          if widget_number then
            if widget.content.parent_widget_number == widget_number then
              are_there_visible_sub_widgets = are_there_visible_sub_widgets or widget.content.is_widget_visible
            end
          else
            if widget.content.setting_id == setting_id then
              widget_number = i
            end
          end
        end
      end
    end
  end

  local is_widget_collapsed_new = not is_widget_collapsed and are_there_visible_sub_widgets

  if is_widget_collapsed_new and not is_widget_collapsed then
    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_map_close")
  elseif not is_widget_collapsed_new and is_widget_collapsed then
    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_map_open")
  end

  widget_content.is_widget_collapsed = is_widget_collapsed_new


  if setting_id then

    local all_collapsed_widgets = vmf:get("options_menu_collapsed_widgets")

    local mod_collapsed_widgets = all_collapsed_widgets[mod_name]

    if widget_content.is_widget_collapsed then

      mod_collapsed_widgets = mod_collapsed_widgets or {}
      mod_collapsed_widgets[setting_id] = true

      all_collapsed_widgets[mod_name] = mod_collapsed_widgets
    else
      if mod_collapsed_widgets then
        mod_collapsed_widgets[setting_id] = nil

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

  -- header
  else
    local collapsed_mods = vmf:get("options_menu_collapsed_mods")
    if widget_content.is_widget_collapsed then
      collapsed_mods[mod_name] = true
    else
      collapsed_mods[mod_name] = nil
    end
    vmf:set("options_menu_collapsed_mods", collapsed_mods)
  end
  self:update_settings_list_widgets_visibility(mod_name)
  self:readjust_visible_settings_list_widgets_position()
end


VMFOptionsView.callback_change_setting_keybind_state = function (self, widget_content)

  if not widget_content.is_setting_keybind then
    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("changing_setting", "keyboard", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "mouse", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "gamepad", 1, "keybind")

    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

    widget_content.is_setting_keybind = true
  else

    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "mouse", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "gamepad", 1)

    widget_content.is_setting_keybind = false
  end
end

local function set_new_keybind(keybind_widget_content)
  vmf.add_mod_keybind(
    get_mod(keybind_widget_content.mod_name),
    keybind_widget_content.setting_id,
    {
      global          = keybind_widget_content.keybind_global,
      trigger         = keybind_widget_content.keybind_trigger,
      type            = keybind_widget_content.keybind_type,
      keys            = keybind_widget_content.keys,
      function_name   = keybind_widget_content.function_name,
      view_name       = keybind_widget_content.view_name,
      transition_data = keybind_widget_content.transition_data
    }
  )
end

VMFOptionsView.callback_setting_keybind = function (self, widget_content)
  if not widget_content.first_pressed_button_id then
    if Keyboard.any_pressed() then
      widget_content.first_pressed_button_id    = vmf.get_key_id("KEYBOARD", Keyboard.any_pressed())
      widget_content.first_pressed_button_index = Keyboard.any_pressed()
      widget_content.first_pressed_button_type  = "keyboard"
    elseif Mouse.any_pressed() then
      widget_content.first_pressed_button_id    = vmf.get_key_id("MOUSE", Mouse.any_pressed())
      widget_content.first_pressed_button_index = Mouse.any_pressed()
      widget_content.first_pressed_button_type  = "mouse"
    end
  end

  local pressed_buttons = {}
  if widget_content.first_pressed_button_id then
    table.insert(pressed_buttons, widget_content.first_pressed_button_id)
  else
    table.insert(pressed_buttons, "no_button")
  end
  if Keyboard.button(Keyboard.button_index("left ctrl")) + Keyboard.button(Keyboard.button_index("right ctrl")) > 0 then
    table.insert(pressed_buttons, "ctrl")
  end
  if Keyboard.button(Keyboard.button_index("left alt")) + Keyboard.button(Keyboard.button_index("right alt")) > 0 then
    table.insert(pressed_buttons, "alt")
  end
  if Keyboard.button(Keyboard.button_index("left shift")) + Keyboard.button(Keyboard.button_index("right shift")) > 0 then
    table.insert(pressed_buttons, "shift")
  end

  local preview_string = vmf.build_keybind_string(pressed_buttons)

  widget_content.keybind_text = preview_string ~= "" and preview_string or "_"
  widget_content.keys         = pressed_buttons

  if widget_content.first_pressed_button_id then
    if widget_content.first_pressed_button_type == "keyboard" and Keyboard.released(widget_content.first_pressed_button_index) or
       widget_content.first_pressed_button_type == "mouse" and Mouse.released(widget_content.first_pressed_button_index)
    then
      widget_content.first_pressed_button_id    = nil
      widget_content.first_pressed_button_index = nil
      widget_content.first_pressed_button_type  = nil

      -- Fix accidental LMB binding for Mod Options view toggling.
      if widget_content.setting_id == "open_vmf_options" and #widget_content.keys == 1 and widget_content.keys[1] == "mouse left" then
        widget_content.keys = {}
      end

      set_new_keybind(widget_content)

      self:callback_change_setting_keybind_state(widget_content)
      return true
    end
  elseif Keyboard.released(Keyboard.button_index("esc")) then
    widget_content.keybind_text = ""
    widget_content.keys         = {}

    set_new_keybind(widget_content)

    self:callback_change_setting_keybind_state(widget_content)
    return true
  end
end


VMFOptionsView.callback_change_dropdown_menu_visibility = function (self, widget_content)

  if not widget_content.is_dropdown_menu_opened then
    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("changing_setting", "keyboard", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "mouse", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "gamepad", 1, "keybind")

    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

    widget_content.is_dropdown_menu_opened = true

    -- if not check for this, dropdown menu will close right after opening
    widget_content.wrong_mouse_on_release = true
  else

    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "mouse", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "gamepad", 1)

    widget_content.is_dropdown_menu_opened = false
  end
end


VMFOptionsView.callback_draw_dropdown_menu = function (self, widget_content)
  local ui_renderer          = self.ui_renderer
  local scenegraph           = self.ui_scenegraph_2nd_layer
  local parent_scenegraph_id = self.settings_list_scenegraph_id_start
  local input_manager        = self.input_manager
  local input_service        = input_manager:get_service("changing_setting")

  UIRenderer.begin_pass(ui_renderer, scenegraph, input_service, self.dt, parent_scenegraph_id, self.render_settings)

  UIRenderer.draw_widget(ui_renderer, widget_content.popup_menu_widget)

  UIRenderer.end_pass(ui_renderer)

  ui_renderer.input_service = input_manager:get_service("vmf_options_menu")


  for _, hotspot_content in pairs(widget_content.popup_menu_widget.content) do
    if type(hotspot_content) == "table" and hotspot_content.on_release then
      self:callback_change_dropdown_menu_visibility(widget_content)

      widget_content.current_option_number = hotspot_content.num
      widget_content.current_option_text = widget_content.options_texts[widget_content.current_option_number]
      widget_content.current_shown_widgets = widget_content.options_shown_widgets[widget_content.current_option_number]

      return true
    end
  end

  --if Left Mouse Button or Esc pressed
  if Mouse.released(0) and not widget_content.wrong_mouse_on_release or Keyboard.released(27) then
    self:callback_change_dropdown_menu_visibility(widget_content)
  end

  widget_content.wrong_mouse_on_release = nil
end


VMFOptionsView.callback_change_numeric_menu_visibility = function (self, widget_content)

  if not widget_content.is_numeric_menu_opened then
    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("changing_setting", "keyboard", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "mouse", 1, "keybind")
    self.input_manager:block_device_except_service("changing_setting", "gamepad", 1, "keybind")

    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_select")

    widget_content.is_numeric_menu_opened = true

    -- current value text

    widget_content.popup_menu_widget.content.new_value_text = widget_content.current_value_text

    -- new value

    widget_content.popup_menu_widget.content.new_value = widget_content.current_value .. ""

    -- decimals number

    local decimals_number = widget_content.decimals_number and widget_content.decimals_number or 0
    widget_content.popup_menu_widget.content.decimals_number = decimals_number

    -- range text @TODO: maybe improve it

    local min_text = widget_content.range[1] .. ""
    local max_text = widget_content.range[2] .. ""

    local min_text_has_dot = string.find(min_text, "%.")
    local max_text_has_dot = string.find(max_text, "%.")

    if decimals_number > 0 then
      if not min_text_has_dot then
        min_text = min_text .. "."

        for _ = 1, decimals_number do
          min_text = min_text .. "0"
        end
      end
      if not max_text_has_dot then
        max_text = max_text .. "."

        for _ = 1, decimals_number do
          max_text = max_text .. "0"
        end
      end
    end

    widget_content.popup_menu_widget.content.range_text  = string.format("[min: %s] [max: %s]", min_text, max_text)

    -- if not check for this, numeric menu will close right after opening
    widget_content.wrong_mouse_on_release = true
  else

    self.input_manager:device_unblock_all_services("keyboard", 1)
    self.input_manager:device_unblock_all_services("mouse", 1)
    self.input_manager:device_unblock_all_services("gamepad", 1)

    self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "mouse", 1)
    self.input_manager:block_device_except_service("vmf_options_menu", "gamepad", 1)

    widget_content.is_numeric_menu_opened = false
  end
end


VMFOptionsView.callback_draw_numeric_menu = function (self, widget_content)

  local numeric_menu_content     = widget_content.popup_menu_widget.content
  local numeric_menu_text_style  = widget_content.popup_menu_widget.style.new_value_text
  local numeric_menu_caret_style = widget_content.popup_menu_widget.style.caret

  -- calculate caret offset ---------------------------

  local font, font_size = UIFontByResolution(numeric_menu_text_style, nil)
  local font_name       = font[3]
  local font_material   = font[1]

  local new_value_text              = numeric_menu_content.new_value_text
  local new_value_text_just_numbers = numeric_menu_content.new_value

  local new_value_text_width = UIRenderer.text_size(self.ui_renderer, new_value_text, font_material, font_size, font_name)
  local new_value_text_offset = numeric_menu_text_style.offset[1] - new_value_text_width / 2

  local caret_offset = UIRenderer.text_size(self.ui_renderer, new_value_text_just_numbers, font_material, font_size, font_name)

  numeric_menu_caret_style.offset[1] = new_value_text_offset + caret_offset - 3

  -- blink caret ---------------------------------------

  numeric_menu_content.caret_animation_timer = numeric_menu_content.caret_animation_timer + self.dt

  numeric_menu_caret_style.color[1] = math.sirp(0, 0.7, numeric_menu_content.caret_animation_timer * 1.5) * 255


  -- PROCESS KEYSTROKES ################################

  local new_value = numeric_menu_content.new_value

  local can_add_more_characters = string.len(new_value) < 16

  local keystrokes = Keyboard.keystrokes()

  for _, stroke in ipairs(keystrokes) do
    if type(stroke) == "string" then

      if can_add_more_characters then

        if tonumber(stroke) then -- number

          local dot_position = string.find(new_value, "%.")

          if not dot_position or (dot_position + numeric_menu_content.decimals_number) > string.len(new_value) then

            new_value = new_value .. stroke
          end

        elseif stroke == "-" then -- minus

          if string.find(new_value, "%-") then
            new_value = string.gsub(new_value, "%-", "")
          else
            new_value = "-" .. new_value
          end

        elseif stroke == "." then -- dot

          if numeric_menu_content.decimals_number > 0 and not string.find(new_value, "%.") then
            new_value = new_value .. "."
          end
        end
      end

    elseif stroke == Keyboard.BACKSPACE then -- backspace

      if string.len(new_value) > 0 then
        new_value = string.sub(new_value, 1, -2)
      end
    end
  end

  local new_value_number = tonumber(new_value)

  if new_value_number and new_value_number >= widget_content.range[1] and new_value_number <= widget_content.range[2] then
    numeric_menu_text_style.text_color = {255, 255, 255, 255}

    -- clamp entered value according to defined range (if dot isn't the last character in the string)
    local dot_position = string.find(new_value, "%.")
    local string_length = string.len(new_value)

    if not (dot_position and dot_position == string_length) then

      new_value_number = math.clamp(new_value_number, widget_content.range[1], widget_content.range[2]) -- @TODO: remove?

      -- Lua, pls! Sometimes "tostring" returns something like "1337.5999999999999" instead of "1337.6",
      -- so I have to convert number to string this way
      -- UPD(bi) 01.01.19 I commented out following string. Rething this whole block later. Seems like it can be just removed.
      -- new_value = new_value_number .. ""
    end
  else
    -- if entered string is not convertable, change its color to red
    numeric_menu_text_style.text_color = {255, 255, 70, 70}
  end


  -- SLIDER ############################################

  if numeric_menu_content.changed then

    local full_range = widget_content.range[2] - widget_content.range[1]

    new_value_number = full_range * numeric_menu_content.internal_value + widget_content.range[1]
    new_value_number = math.round_with_precision(new_value_number, widget_content.decimals_number)

    new_value = new_value_number .. ""

    numeric_menu_content.changed = false
  end

  if new_value_number then

    local clamped_new_value_number = math.clamp(new_value_number, widget_content.range[1], widget_content.range[2])

    local full_range = widget_content.range[2] - widget_content.range[1]
    local slider_fill_percent = (clamped_new_value_number - widget_content.range[1]) / full_range

    local new_slider_fill_size = numeric_menu_content.max_slider_size * slider_fill_percent

    widget_content.popup_menu_widget.style.slider_fill.size[1] = new_slider_fill_size
    widget_content.popup_menu_widget.style.slider_icon.offset[1] = numeric_menu_content.slider_icon_offset + new_slider_fill_size
  end

  -- ASSIGNING VALUES ##################################

  numeric_menu_content.new_value      = new_value
  numeric_menu_content.new_value_text = new_value

  if widget_content.unit_text then
    numeric_menu_content.new_value_text = numeric_menu_content.new_value_text .. widget_content.unit_text
  end

  -- DRAWING WIDGET ####################################
  local ui_renderer          = self.ui_renderer
  local scenegraph           = self.ui_scenegraph_2nd_layer
  local parent_scenegraph_id = self.settings_list_scenegraph_id_start
  local input_manager        = self.input_manager
  local input_service        = input_manager:get_service("changing_setting")


  UIRenderer.begin_pass(ui_renderer, scenegraph, input_service, self.dt, parent_scenegraph_id, self.render_settings)

  UIRenderer.draw_widget(ui_renderer, widget_content.popup_menu_widget)

  UIRenderer.end_pass(ui_renderer)

  ui_renderer.input_service = input_manager:get_service("vmf_options_menu")


  -- CLOSE WITH PRESSED BUTTONS ########################

  -- Left Mouse Button or Enter pressed ----------------

  if Mouse.released(0) and not widget_content.wrong_mouse_on_release and not numeric_menu_content.slider_is_held or Keyboard.released(13) then
    self:callback_change_numeric_menu_visibility(widget_content)

    if new_value_number and new_value_number >= widget_content.range[1] and new_value_number <= widget_content.range[2] then
      widget_content.current_value = new_value_number
      widget_content.current_value_text = widget_content.current_value .. "" -- so "1337." -> "1337"

      if widget_content.unit_text then
        widget_content.current_value_text = widget_content.current_value_text .. widget_content.unit_text
      end

      return true
    end
  end

  -- Esc pressed ---------------------------------------

  if Keyboard.released(27) then
    self:callback_change_numeric_menu_visibility(widget_content)
  end

 -- Fix for closing menu when releasing LMB outside the hotspot

  if numeric_menu_content.slider_hotspot.is_held then
    numeric_menu_content.slider_is_held = true
  end

  if Mouse.released(0) and numeric_menu_content.slider_is_held then
    numeric_menu_content.slider_is_held = false
  end


  widget_content.wrong_mouse_on_release = nil
end


-- ####################################################################################################################
-- ##### MISCELLANEOUS: SETTINGS LIST WIDGETS #########################################################################
-- ####################################################################################################################


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

    -- if there are 2 (or more) mods with the same (readable) name
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

  -- favorite mods sorting + cleaning up the favs list setting

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


VMFOptionsView.update_picked_option_for_settings_list_widgets = function (self)

  local widget_content
  local widget_type
  local loaded_setting_value

  for _, mod_widgets in ipairs(self.settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do

      widget_content = widget.content
      widget_type = widget_content.widget_type

      if widget_type == "checkbox" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_id)

        if type(loaded_setting_value) == "boolean" then
          widget_content.is_checkbox_checked = loaded_setting_value
        else
          --if type(loaded_setting_value) ~= "nil" then
            -- @TODO: warning: variable of wrong type in config
          --end

          widget_content.is_checkbox_checked = widget_content.default_value
          get_mod(widget_content.mod_name):set(widget_content.setting_id, widget_content.default_value)
        end

      elseif widget_type == "dropdown" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_id)

        local setting_not_found = true
        for i, option_value in ipairs(widget_content.options_values) do

          if loaded_setting_value == option_value then
            widget_content.current_option_number = i
            widget_content.current_option_text   = widget_content.options_texts[i]
            widget_content.current_shown_widgets = widget_content.options_shown_widgets[i]

            setting_not_found = false
            break
          end
        end

        if setting_not_found then
          --if type(loaded_setting_value) ~= "nil" then
            -- @TODO: warning: variable which is not in the dropdown options list in config
          --end

          for i, option_value in ipairs(widget_content.options_values) do

            if widget_content.default_value == option_value then
              widget_content.current_option_number = i
              widget_content.current_option_text   = widget_content.options_texts[i]
              widget_content.current_shown_widgets = widget_content.options_shown_widgets[i]
              get_mod(widget_content.mod_name):set(widget_content.setting_id, widget_content.default_value)
            end
          end
        end

      elseif widget_type == "header" then

        widget_content.is_checkbox_checked = get_mod(widget_content.mod_name):is_enabled() or
                                              get_mod(widget_content.mod_name):get_internal_data("is_mutator")

      elseif widget_type == "keybind" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_id)

        if type(loaded_setting_value) == "table" then
          widget_content.keys = loaded_setting_value
        else
          -- @TODO: warning:
          widget_content.keys = widget_content.default_value
        end

        widget_content.keybind_text = vmf.build_keybind_string(widget_content.keys)

      elseif widget_type == "numeric" then

        loaded_setting_value = get_mod(widget_content.mod_name):get(widget_content.setting_id)

        if type(loaded_setting_value) == "number" then

          -- the fload numbers is some kind of magic in lua
          local decimals_number = widget_content.decimals_number and widget_content.decimals_number or 0
          loaded_setting_value = math.round_with_precision(loaded_setting_value, decimals_number)

          widget_content.current_value_text = loaded_setting_value .. ""
          widget_content.current_value = loaded_setting_value
        else
          -- @TODO: warning:
          widget_content.current_value_text = widget_content.default_value .. ""
          widget_content.current_value = widget_content.default_value
        end

        if widget_content.unit_text then
          widget_content.current_value_text = widget_content.current_value_text .. widget_content.unit_text
        end
      end
    end
  end
end


VMFOptionsView.update_settings_list_widgets_visibility = function (self, mod_name)

  for _, mod_widgets in ipairs(self.settings_list_widgets) do

    if not mod_name or mod_widgets[1].content.mod_name == mod_name then

      for i, widget in ipairs(mod_widgets) do

        if widget.content.parent_widget_number then
          local parent_widget = mod_widgets[widget.content.parent_widget_number]
          local widget_type = parent_widget.content.widget_type

          -- if 'header' or 'checkbox'
          if widget_type == "header" or widget_type == "checkbox" then

            widget.content.is_widget_visible = parent_widget.content.is_checkbox_checked and parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed

          -- if 'dropdown'
          elseif widget_type == "dropdown" then
            if widget.content.show_widget_condition then
              widget.content.is_widget_visible = (widget.content.show_widget_condition[parent_widget.content.current_option_number] or parent_widget.content.current_shown_widgets[i]) and parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed

            -- Usually it had to throw an error by this point, but now it's another part of compatibility
            else
              widget.content.is_widget_visible = parent_widget.content.current_shown_widgets[i] and parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed
              --get_mod(widget.content.mod_name):error("(vmf_options_view): the dropdown widget in the options menu has sub_widgets, but some of its sub_widgets doesn't have 'show_widget_condition' (%s)" , widget.content.setting_id)
            end
          -- if 'group'
          else
            widget.content.is_widget_visible = parent_widget.content.is_widget_visible and not parent_widget.content.is_widget_collapsed
          end
        end
      end
    end
  end
end


VMFOptionsView.readjust_visible_settings_list_widgets_position = function (self)

  local offset_y = 0

  for _, mod_widgets in ipairs(self.settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do
      if widget.content.is_widget_visible then

        widget.offset[2] = -offset_y

        if widget.content.popup_menu_widget then
          widget.content.popup_menu_widget.offset[2] = -offset_y
        end

        offset_y = offset_y + ((widget.content.widget_type == "header") and SETTINGS_LIST_HEADER_WIDGET_SIZE[2] or SETTINGS_LIST_REGULAR_WIDGET_SIZE[2])
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
    self:update_scrollbar_position()
  end
end


-- ####################################################################################################################
-- ##### MISCELLANEOUS: SCROLLING'N'STUFF #############################################################################
-- ####################################################################################################################


VMFOptionsView.calculate_scrollbar_size = function (self)

  local widget_content = self.menu_widgets["scrollbar"].content

  local percentage = self.setting_list_mask_size_y / self.settings_list_size_y

  widget_content.scroll_bar_info.bar_height_percentage = percentage
end


VMFOptionsView.update_mousewheel_scroll_area_input = function (self)
  local widget_content = self.menu_widgets["mousewheel_scroll_area"].content

  local mouse_scroll_value = widget_content.internal_scroll_value

  if mouse_scroll_value ~= 0 then

    local new_offset = self.current_setting_list_offset_y + mouse_scroll_value * _SCROLL_STEP

    self.current_setting_list_offset_y = math.clamp(new_offset, 0, self.max_setting_list_offset_y)

    widget_content.internal_scroll_value = 0

    self:update_scrollbar_position()
  end
end


VMFOptionsView.update_scrollbar_input = function (self)
  local scrollbar_info = self.menu_widgets["scrollbar"].content.scroll_bar_info
  local value = scrollbar_info.value
  local old_value = scrollbar_info.old_value

  if value ~= old_value then
    self.current_setting_list_offset_y = self.max_setting_list_offset_y * value
    scrollbar_info.old_value = value
  end
end


VMFOptionsView.update_scrollbar_position = function (self)

  local widget_content = self.menu_widgets["scrollbar"].content

  local percentage = self.current_setting_list_offset_y / self.max_setting_list_offset_y

  widget_content.scroll_bar_info.value = percentage
  widget_content.scroll_bar_info.old_value = percentage
end

-- ####################################################################################################################
-- ##### SEARCH BAR ###################################################################################################
-- ####################################################################################################################


VMFOptionsView.update_search_bar = function (self)

  local widget_content = self.menu_widgets["search_bar"].content

  if self.search_bar_selected then

    if Mouse.any_pressed() == 0 and not widget_content.hotspot.is_hover or -- Left Mouse Button
       Keyboard.any_pressed() == 27 or -- Esc
       Keyboard.any_released() == 13 then -- Enter

      self:deactivate_search_bar()

      return
    end

    local keystrokes = Keyboard.keystrokes()

    local old_search_text = widget_content.text
    local text_index = string.len(old_search_text) + 1

    local new_search_text = KeystrokeHelper.parse_strokes(old_search_text, text_index, "insert", keystrokes)

    new_search_text = string.gsub(new_search_text, "%%", "")

    if new_search_text ~= old_search_text then
      self:filter_mods_settings_by_name(new_search_text)
    end

    widget_content.text = new_search_text
  end

  if widget_content.hotspot.on_release then

    self:activate_search_bar()
    self:filter_mods_settings_by_name("")
  end
end


VMFOptionsView.activate_search_bar = function (self)

  self.menu_widgets["search_bar"].content.text = ""
  self.menu_widgets["search_bar"].content.is_active = true

  self.search_bar_selected = true

  self.input_manager:device_unblock_all_services("keyboard", 1)
  self.input_manager:block_device_except_service("changing_setting", "keyboard", 1, "keybind")
end


VMFOptionsView.deactivate_search_bar = function (self)

  self.menu_widgets["search_bar"].content.is_active = false

  self.search_bar_selected = false

  self.input_manager:device_unblock_all_services("keyboard", 1)
  self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1, "keybind")
end


VMFOptionsView.filter_mods_settings_by_name = function (self, pattern)

  pattern = string.upper(pattern)

  if pattern == "" then

    for _, mod_widgets in ipairs(self.settings_list_widgets) do

      local content = mod_widgets[1].content

      content.is_widget_visible = true
    end
  else

    for _, mod_widgets in ipairs(self.settings_list_widgets) do

      local content = mod_widgets[1].content

      if string.find(string.upper(content.text), pattern) then
        content.is_widget_visible = true
      else
        content.is_widget_visible = false
      end
    end
  end

  self:update_settings_list_widgets_visibility()
  self:readjust_visible_settings_list_widgets_position()
end


-- ####################################################################################################################
-- ##### UPDATE #######################################################################################################
-- ####################################################################################################################


VMFOptionsView.update = function (self, dt)
  if self.suspended then
    return
  end

  if self.is_scrolling_enabled then
    self:update_scrollbar_input()
    self:update_mousewheel_scroll_area_input()
  end

  self.dt = dt
  self.draw_widgets(self, dt)

  local input_service = self:input_service()
  if input_service.get(input_service, "toggle_menu") then
    self.ingame_ui:handle_transition("exit_menu")
  end

  self:update_search_bar()

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

  self:update_settings_list(self.settings_list_widgets, ui_renderer, ui_scenegraph)


  UIRenderer.end_pass(ui_renderer)
end

-- update settings list widgets position, and draw widget which are inside the visible area
VMFOptionsView.update_settings_list = function (self, settings_list_widgets, ui_renderer, ui_scenegraph)

  local scenegraph = ui_scenegraph[self.settings_list_scenegraph_id]
  scenegraph.offset[2] = self.current_setting_list_offset_y

  local scenegraph_id_start = self.settings_list_scenegraph_id_start
  local list_position = UISceneGraph.get_world_position(ui_scenegraph, scenegraph_id_start)
  local mask_pos = Vector3.deprecated_copy(UISceneGraph.get_world_position(ui_scenegraph, "sg_settings_list_mask"))
  local mask_size = UISceneGraph.get_size(ui_scenegraph, "sg_settings_list_mask")
  local temp_pos_table = {}

  for _, mod_widgets in ipairs(settings_list_widgets) do
    for _, widget in ipairs(mod_widgets) do
      if widget.content.is_widget_visible then
        local style = widget.style
        local size = style.size
        local offset = style.offset

        temp_pos_table[1] = list_position[1] + offset[1]
        temp_pos_table[2] = list_position[2] + offset[2] + widget.offset[2]

        local lower_visible = is_point_inside_2d_box(temp_pos_table, mask_pos, mask_size)
        temp_pos_table[2] = temp_pos_table[2] + size[2]
        local top_visible = is_point_inside_2d_box(temp_pos_table, mask_pos, mask_size)

        local visible = lower_visible or top_visible
        if visible then
          UIRenderer.draw_widget(ui_renderer, widget)
        end
      end
    end
  end
end


-- ####################################################################################################################
-- ##### SOME OTHER STUFF #############################################################################################
-- ####################################################################################################################


VMFOptionsView.on_enter = function (self)

  if ShowCursorStack.stack_depth == 0 then ShowCursorStack.push() end

  local input_manager = self.input_manager
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "keyboard", 1)
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "mouse", 1)
  input_manager.block_device_except_service(input_manager, "vmf_options_menu", "gamepad", 1)

  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_button_open")

  self:sort_settings_list_widgets()
  self:update_picked_option_for_settings_list_widgets()
  self:update_settings_list_widgets_visibility()
  self:readjust_visible_settings_list_widgets_position()
end


VMFOptionsView.on_exit = function (self)
  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_button_close")

  -- in VT1 cursor will be romover automatically
  if not VT1 then ShowCursorStack.pop() end

  vmf.save_unsaved_settings_to_file()
end


-- default event, is used by IngameUI
VMFOptionsView.input_service = function (self)
  return self.input_manager:get_service("vmf_options_menu")
end


-- I'm not really sure if suspend and unsuspend are needed.
--
-- StateInGameRunning.gm_event_end_conditions_met ->
-- IngameUI.suspend_active_view ->
-- XXXXXXX.suspend
VMFOptionsView.suspend = function (self)
  self.suspended = true

  self.input_manager:device_unblock_all_services("keyboard", 1)
  self.input_manager:device_unblock_all_services("mouse", 1)
  self.input_manager:device_unblock_all_services("gamepad", 1)
end
VMFOptionsView.unsuspend = function (self)
  self.suspended = nil

  self.input_manager:block_device_except_service("vmf_options_menu", "keyboard", 1)
  self.input_manager:block_device_except_service("vmf_options_menu", "mouse", 1)
  self.input_manager:block_device_except_service("vmf_options_menu", "gamepad", 1)
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_vmf_options_view_settings = function()
  if vmf:get("vmf_options_scrolling_speed") then
    _SCROLL_STEP = _DEFAULT_SCROLL_STEP / 100 * vmf:get("vmf_options_scrolling_speed")
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_vmf_options_view_settings()


vmf:register_view({
  view_name = "vmf_options_view",
  view_settings = {
    init_view_function = function (ingame_ui_context)
      return VMFOptionsView:new(ingame_ui_context)
    end,
    active = {
      inn = true,
      ingame = true
    }
  },
  view_transitions = {
    vmf_options_view_open = function (self)
      self.current_view = "vmf_options_view"
      self.menu_active = true
    end,
    vmf_options_view_close = function (self)
      require("scripts/ui/views/ingame_ui_settings").transitions.exit_menu(self)
    end
  }
})
