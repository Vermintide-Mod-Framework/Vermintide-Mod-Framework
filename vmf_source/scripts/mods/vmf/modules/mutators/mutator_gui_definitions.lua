local definitions = local_require("scripts/ui/views/map_view_definitions")
local scenegraph_definition = definitions.scenegraph_definition

-- Mutators to show per page
definitions.PER_PAGE = 6

-- Button to toggle mutators view
scenegraph_definition.mutators_button = {
	vertical_alignment = "bottom",
	parent = "banner_party",
	horizontal_alignment = "center",
	size = {
		64,
		64
	},
	position = {
		-150,
		90,
		1
	}
}

-- This will replace the Mission text
scenegraph_definition.banner_mutators_text = {
	vertical_alignment = "center",
	parent = "banner_level",
	horizontal_alignment = "center",
	size = {
		300,
		40
	},
	position = {
		0,
		0,
		1
	}
}


local new_widgets = {

	-- This will replace the banner behind the Mission text
	banner_mutators_widget = UIWidgets.create_texture_with_text_and_tooltip("title_bar", "Mutators", "Enable and disable mutators", "banner_level", "banner_mutators_text", {
			vertical_alignment = "center",
			scenegraph_id = "banner_mutators_text",
			localize = false,
			font_size = 28,
			horizontal_alignment = "center",
			font_type = "hell_shark",
			text_color = Colors.get_color_table_with_alpha("cheeseburger", 255)
		},
		{
			font_size = 24,
			max_width = 500,
			localize = false,
			horizontal_alignment = "left",
			vertical_alignment = "top",
			font_type = "hell_shark",
			text_color = Colors.get_color_table_with_alpha("white", 255),
			line_colors = {},
			offset = {
				0,
				0,
				50
			}
		}
	),

	-- Button to toggle mutators view
	mutators_button_widget = {
		element = UIElements.ToggleIconButton,
		content = {
			click_texture = "octagon_button_clicked",
			toggle_hover_texture = "octagon_button_toggled_hover",
			toggle_texture = "octagon_button_toggled",
			hover_texture = "octagon_button_hover",
			normal_texture = "octagon_button_normal",
			icon_texture = "map_icon_browser_01",
			icon_hover_texture = "map_icon_browser_01",
			tooltip_text = "Mutators",
			toggled_tooltip_text = "Mutators",
			button_hotspot = {}
		},
		style = {
			normal_texture = {
				color = {
					255,
					255,
					255,
					255
				}
			},
			hover_texture = {
				color = {
					255,
					255,
					255,
					255
				}
			},
			click_texture = {
				color = {
					255,
					255,
					255,
					255
				}
			},
			toggle_texture = {
				color = {
					255,
					255,
					255,
					255
				}
			},
			toggle_hover_texture = {
				color = {
					255,
					255,
					255,
					255
				}
			},
			icon_texture = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					0,
					0,
					1
				}
			},
			icon_hover_texture = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					0,
					0,
					1
				}
			},
			icon_click_texture = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					0,
					-1,
					1
				}
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
				offset = {
					0,
					0,
					20
				}
			}
		},
		scenegraph_id = "mutators_button"
	}
}

-- Checkboxes
for i = 1, definitions.PER_PAGE do
	new_widgets["mutator_checkbox_" .. i] = {
		scenegraph_id = "mutator_checkbox_" .. i,
		element = {
			passes = {
				{
					pass_type = "hotspot",
					content_id = "button_hotspot"
				},
				{
					style_id = "tooltip_text",
					pass_type = "tooltip_text",
					text_id = "tooltip_text",
					content_check_function = function (ui_content)
						return ui_content.button_hotspot.is_hover
					end
				},
				{
					style_id = "setting_text",
					pass_type = "text",
					text_id = "setting_text",
					content_check_function = function (content)
						return not content.button_hotspot.is_hover
					end
				},
				{
					style_id = "setting_text_hover",
					pass_type = "text",
					text_id = "setting_text",
					content_check_function = function (content)
						return content.button_hotspot.is_hover
					end
				},
				{
					pass_type = "texture",
					style_id = "checkbox_style",
					texture_id = "checkbox_unchecked_texture",
					content_check_function = function (content)
						return not content.selected
					end
				},
				{
					pass_type = "texture",
					style_id = "checkbox_style",
					texture_id = "checkbox_checked_texture",
					content_check_function = function (content)
						return content.selected
					end
				}
			}
		},
		content = {
			tooltip_text = "Mutator ajksad " .. i,
			checkbox_unchecked_texture = "checkbox_unchecked",
			checkbox_checked_texture = "checkbox_checked",
			selected = false,
			setting_text = "Mutator asdasasda " .. i * 3,
			button_hotspot = {}
		},
		style = {
			checkbox_style = {
				size = {
					20,
					20
				},
				offset = {
					0,
					6,
					1
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			setting_text = {
				vertical_alignment = "center",
				font_size = 22,
				localize = false,
				horizontal_alignment = "left",
				word_wrap = true,
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("cheeseburger", 255),
				offset = {
					24,
					2,
					4
				}
			},
			setting_text_hover = {
				vertical_alignment = "center",
				font_size = 22,
				localize = false,
				horizontal_alignment = "left",
				word_wrap = true,
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("white", 255),
				offset = {
					24,
					2,
					4
				}
			},
			tooltip_text = {
				font_size = 18,
				max_width = 500,
				localize = false,
				cursor_side = "right",
				horizontal_alignment = "left",
				vertical_alignment = "top",
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("white", 255),
				line_colors = {},
				offset = {
					0,
					0,
					50
				},
				cursor_offset = {
					-10,
					-27
				}
			}
		}
	}
	scenegraph_definition["mutator_checkbox_" .. i] = {
		vertical_alignment = "center",
		parent = "banner_party",
		horizontal_alignment = "left",
		size = {
			310,
			30
		},
		position = {
			30,
			520 - 40 * (i - 1),
			1
		}
	}
end

definitions.new_widgets = new_widgets

return definitions