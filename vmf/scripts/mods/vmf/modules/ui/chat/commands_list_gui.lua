local vmf = get_mod("VMF") --@TODO: remove it?

local _gui

if VT1 then
  -- @TODO: I don't think I need the 2nd texture
  _gui = World.create_screen_gui(Managers.world:world("top_ingame_view"), "immediate",
                                  "material", "materials/fonts/gw_fonts",
                                  "material", "materials/ui/ui_1080p_ingame_common")
else
  _gui = World.create_screen_gui(Managers.world:world("top_ingame_view"),
                                 "material", "materials/fonts/gw_fonts", "immediate")
end

--	DebugScreen.gui = World.create_screen_gui(world, "material", "materials/fonts/gw_fonts",
--                                                   "material", "materials/menu/debug_screen", "immediate")


local _FONT_TYPE = "hell_shark_arial"
local _FONT_SIZE = 22

local _MULTISTRING_INDICATOR_TEXT = "[...]"

local _MAX_COMMANDS_VISIBLE = 5

local _STRING_HEIGHT = 25
local _STRING_Y_OFFSET = 7
local _STRING_X_MARGIN = 10

local _OFFSET_X = 0
local _OFFSET_Y = 200
local _OFFSET_Z = 880
local _WIDTH = 550

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function get_text_width(text, font_material, font_size)
	local text_extent_min, text_extent_max = Gui.text_extents(_gui, text, font_material, font_size)
	local text_height = text_extent_max[1] - text_extent_min[1]
	return text_height
end

local function word_wrap(text, font_material, font_size, max_width)
	local whitespace = " "
	local soft_dividers = "-+&/*"
	local return_dividers = "\n"
	local reuse_global_table = true
  local scale = RESOLUTION_LOOKUP.scale

  return Gui.word_wrap(_gui, text, font_material, font_size, max_width * scale, whitespace,
                             soft_dividers, return_dividers, reuse_global_table)
end

local function draw(commands_list, selected_command_index)
  --vmf:pcall(function()

    local selected_command_new_index = 0

    -- pick displayed commands
    local last_displayed_command = math.max(math.min(_MAX_COMMANDS_VISIBLE, #commands_list), selected_command_index)
    local first_displayed_command = math.max(1, last_displayed_command - (_MAX_COMMANDS_VISIBLE - 1))
    local displayed_commands = {}
    for i = first_displayed_command, last_displayed_command do
      local new_entry = {}
      new_entry.name        = "/" .. commands_list[i].name
      new_entry.description = commands_list[i].description
      new_entry.full_text   = new_entry.name .. " " .. new_entry.description
      if i == selected_command_index then
        new_entry.selected = true
        selected_command_new_index = #displayed_commands + 1
      end
      table.insert(displayed_commands, new_entry)
    end

    local scale = RESOLUTION_LOOKUP.scale

    local selected_strings_number = 1

    local font, font_size = UIFontByResolution({font_type = _FONT_TYPE, font_size = _FONT_SIZE})
    local font_material = font[1]
    local font_name     = font[3]

    for i, command in ipairs(displayed_commands) do

      -- draw "/command_name" text
      local scaled_offet_x = (_OFFSET_X + _STRING_X_MARGIN) * scale

      local selected_string_height = _STRING_HEIGHT * (i + selected_strings_number - 1) + _STRING_Y_OFFSET
      local scaled_offset_y = (_OFFSET_Y - selected_string_height) * scale

      local string_position = Vector3(scaled_offet_x, scaled_offset_y, _OFFSET_Z + 2)
      Gui.text(_gui, command.name, font_material, font_size, font_name, string_position, Color(255, 100, 255, 100))

      local command_text_strings = word_wrap(command.full_text, font_material, font_size, _WIDTH - _STRING_X_MARGIN * 2)
      local multistring = #command_text_strings > 1
      local first_description_string
      if multistring then
        if command.selected then
          selected_strings_number = #command_text_strings
        else
          local multistring_indicator_width = get_text_width(_MULTISTRING_INDICATOR_TEXT, font_material, font_size)
          local command_text_width = _WIDTH - _STRING_X_MARGIN * 2 - (multistring_indicator_width / scale)
          command_text_strings = word_wrap(command.full_text, font_material, font_size, command_text_width)

          -- draw that [...] thing
          local multistring_offset_x = (_OFFSET_X + _WIDTH) * scale - multistring_indicator_width
          local multistring_indicator_position = Vector3(multistring_offset_x, string_position.y, string_position.z)
          Gui.text(_gui, _MULTISTRING_INDICATOR_TEXT, font_material, font_size, font_name,
                          multistring_indicator_position, Color(255, 100, 100, 100))
        end
        first_description_string = string.sub(command_text_strings[1], #command.name + 2)
      else
        first_description_string = command.description
      end

      -- draw command description text (1st string)
      local first_description_string_width = get_text_width(command.name, font_material, font_size)

      local first_description_pos_x = string_position.x + first_description_string_width
      local first_description_string_position = Vector3(first_description_pos_x, string_position.y, string_position.z)
      Gui.text(_gui, first_description_string, font_material, font_size, font_name,
                     first_description_string_position, Color(255, 255, 255, 255))

      -- draw command description text (2+ strings)
      if command.selected and multistring then
        for j = 2, selected_strings_number do
          string_position.y = string_position.y - _STRING_HEIGHT * scale
          Gui.text(_gui, command_text_strings[j], font_material, font_size, font_name,
                         string_position, Color(255, 255, 255, 255))
        end
      end
    end

    -- background rectangle
    local bg_height = _STRING_HEIGHT * (#displayed_commands + selected_strings_number - 1)
    local bg_pos_y  = _OFFSET_Y - bg_height

    local bg_position = Vector3(_OFFSET_X * scale, bg_pos_y * scale, _OFFSET_Z)
    local bg_size     = Vector2(_WIDTH * scale, bg_height * scale)
    local bg_color    = Color(200, 10, 10, 10)
    Gui.rect(_gui, bg_position, bg_size, bg_color)

    -- selection rectangle
    if selected_command_new_index > 0 then
      local selection_height = _STRING_HEIGHT * selected_strings_number
      local selection_pos_y  = _OFFSET_Y - selection_height - _STRING_HEIGHT * (selected_command_new_index - 1)

      local selection_position = Vector3(_OFFSET_X * scale, selection_pos_y * scale, _OFFSET_Z + 1)
      local selection_size     = Vector2(_WIDTH * scale, selection_height * scale)
      local selection_color    = Color(100, 120, 120, 120)
      Gui.rect(_gui, selection_position, selection_size, selection_color)
    end

    -- "selected command number / total commands number" indicator
    if not ((#commands_list == 1) and (selected_command_index > 0)) then
      local total_number_indicator = tostring(#commands_list)
      if selected_command_index > 0 then
        total_number_indicator = selected_command_index .. "/" .. total_number_indicator
      end
      local total_number_indicator_width = get_text_width(total_number_indicator, font_material, font_size)
      local total_number_indicator_x = (_WIDTH) * scale - total_number_indicator_width
      local total_number_indicator_y = (_OFFSET_Y + _STRING_Y_OFFSET) * scale
      local total_number_indicator_position = Vector3(total_number_indicator_x, total_number_indicator_y, _OFFSET_Z + 2)
      Gui.text(_gui, total_number_indicator, font_material, font_size, font_name,
                     total_number_indicator_position, Color(255, 100, 100, 100))
    end
  --end)
end

return draw