local definitions = local_require("scripts/ui/views/map_view_definitions")

definitions.scenegraph_definition.mutators_button = {
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

definitions.scenegraph_definition.banner_mutators_text = {
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

definitions.new_widgets = {
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
	}),
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

return definitions