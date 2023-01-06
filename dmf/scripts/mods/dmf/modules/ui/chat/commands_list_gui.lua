local dmf = get_mod("DMF")

local MULTISTRING_INDICATOR_TEXT = "[...]"

local DEFAULT_HUD_SCALE = 100

local FONT_TYPE = "arial"
local FONT_MATERIAL = "content/ui/fonts/arial"
local FONT_SIZE = 22

local MAX_COMMANDS_VISIBLE = 5

local STRING_HEIGHT   = 25
local STRING_Y_OFFSET = 7
local STRING_X_MARGIN = 10

local OFFSET_X = 10
local OFFSET_Y = 300
local OFFSET_Z = 880
local WIDTH    = 550

local BASE_COMMAND_TEXT_WIDTH = WIDTH - STRING_X_MARGIN * 2

local _gui

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function create_gui()
  if not _gui then
    local world_manager = Managers.world
    if world_manager and world_manager:has_world("level_world") then
      _gui = World.create_screen_gui(world_manager:world("level_world"), "immediate")
    end
  end
end


local function destroy_gui()
  if _gui then
    local world_manager = Managers.world
    if world_manager and world_manager:has_world("level_world") then
      World.destroy_gui(world_manager:world("level_world"), _gui)
    end
    _gui = nil
  end
end


local function get_hud_scale()
  local save_data = Managers.save:account_data()
  local interface_settings = save_data.interface_settings
  local hud_scale = interface_settings.hud_scale or DEFAULT_HUD_SCALE

  return hud_scale
end


local function get_text_size(text, font_type, font_size)
  local font_data = Managers.font:data_by_type(font_type)
  local font = font_data.path
  local additional_settings = {
    flags = font_data.render_flags or 0
  }

  local min, max, caret = Gui2.slug_text_extents(_gui, text, font, font_size, additional_settings)
  local min_x, min_y = Vector3.to_elements(min)
  local max_x, max_y = Vector3.to_elements(max)
  local width = max_x - min_x
  local height = max_y - min_y

  return width, height, min, caret
end


local function get_text_width(text, font, font_size)
  local text_extent_min, text_extent_max = Gui.slug_text_extents(_gui, text, font, font_size)
  local text_height = text_extent_max[1] - text_extent_min[1]
  return text_height
end


local function get_scaled_font_size_by_width(text, font_type, font_size, max_width)
  local scale = RESOLUTION_LOOKUP.scale
  local min_font_size = 1
  local scaled_font_size = math.max(font_size * scale, 1)
  local text_width = get_text_size(text, font_type, scaled_font_size)

  if max_width < text_width then
    repeat
      if font_size <= min_font_size then
        break
      end

      font_size = math.max(font_size - 1, min_font_size)
      scaled_font_size = math.max(font_size * scale, 1)
      text_width = math.floor(get_text_size(text, font_type, scaled_font_size))
    until text_width <= max_width
  end

  return font_size
end


local function word_wrap(text, font, font_size, max_width)
  local soft_dividers = "-+&/*"
  local return_dividers = "\n"
  local reuse_global_table = true
  local scale = RESOLUTION_LOOKUP.scale

  return Gui.slug_word_wrap(_gui, text, font, font_size, max_width * scale, return_dividers,
                             soft_dividers, reuse_global_table, 0)
end


local function draw(commands_list, selected_command_index)

  create_gui()
  if not _gui then
    return
  end
  
  -- Apply additional HUD scaling
  local hud_scale = get_hud_scale()
  local should_scale = hud_scale ~= DEFAULT_HUD_SCALE
  if should_scale then
    UPDATE_RESOLUTION_LOOKUP(true, hud_scale * 0.01)
  end

  local selected_command_new_index = 0

  -- pick displayed commands
  local last_displayed_command = math.max(math.min(MAX_COMMANDS_VISIBLE, #commands_list), selected_command_index)
  local first_displayed_command = math.max(1, last_displayed_command - (MAX_COMMANDS_VISIBLE - 1))
  local displayed_commands = {}
  for i = first_displayed_command, last_displayed_command do
    local new_entry = {}
    new_entry.name        = "/" .. commands_list[i].name
    new_entry.description = " " .. commands_list[i].description
    new_entry.full_text   = new_entry.name .. " " .. new_entry.description
    if i == selected_command_index then
      new_entry.selected = true
      selected_command_new_index = #displayed_commands + 1
    end
    table.insert(displayed_commands, new_entry)
  end

  local scale = RESOLUTION_LOOKUP.scale
  local selected_strings_number = 1

  local font_size = FONT_SIZE

  for i, command in ipairs(displayed_commands) do
    font_size = get_scaled_font_size_by_width(command.name, FONT_TYPE, FONT_SIZE, BASE_COMMAND_TEXT_WIDTH)

    -- draw "/command_name" text
    local scaled_offet_x = (OFFSET_X + STRING_X_MARGIN) * scale
    local scaled_offset_y = (OFFSET_Y - STRING_HEIGHT * (i + selected_strings_number - 1) + STRING_Y_OFFSET) * scale

    local string_position = Vector3(scaled_offet_x, scaled_offset_y, OFFSET_Z + 2)
    Gui.slug_text(_gui, command.name, FONT_MATERIAL, font_size, string_position, nil, Color(255, 100, 255, 100))

    local command_text_strings = word_wrap(command.full_text, FONT_MATERIAL, font_size, BASE_COMMAND_TEXT_WIDTH)
    local multistring = #command_text_strings > 1
    local first_description_string
    if multistring then
      if command.selected then
        selected_strings_number = #command_text_strings
      else
        local multistring_indicator_width = get_text_width(MULTISTRING_INDICATOR_TEXT, FONT_MATERIAL, font_size)
        local command_text_width = BASE_COMMAND_TEXT_WIDTH - (multistring_indicator_width / scale)
        command_text_strings = word_wrap(command.full_text, FONT_MATERIAL, font_size, command_text_width)

        -- draw that [...] thing
        local multistring_offset_x = (OFFSET_X + WIDTH) * scale - multistring_indicator_width
        local multistring_indicator_position = Vector3(multistring_offset_x, string_position.y, string_position.z)
        Gui.slug_text(_gui, MULTISTRING_INDICATOR_TEXT, FONT_MATERIAL, font_size,
                        multistring_indicator_position, nil, Color(255, 100, 100, 100))
      end
      first_description_string = string.sub(command_text_strings[1], #command.name + 2)
    else
      first_description_string = command.description
    end

    -- draw command description text (1st string)
    local first_description_string_width = get_text_width(command.name, FONT_MATERIAL, font_size)

    local first_description_pos_x = string_position.x + first_description_string_width
    local first_description_string_position = Vector3(first_description_pos_x, string_position.y, string_position.z)
    Gui.slug_text(_gui, first_description_string, FONT_MATERIAL, font_size,
                    first_description_string_position, nil, Color(255, 255, 255, 255))

    -- draw command description text (2+ strings)
    if command.selected and multistring then
      for j = 2, selected_strings_number do
        string_position.y = string_position.y - STRING_HEIGHT * scale
        Gui.slug_text(_gui, command_text_strings[j], FONT_MATERIAL, font_size,
                        string_position, nil, Color(255, 255, 255, 255))
      end
    end
  end

  -- background rectangle
  local bg_height = STRING_HEIGHT * (#displayed_commands + selected_strings_number - 1)
  local bg_pos_y  = OFFSET_Y - bg_height

  local bg_position = Vector3(OFFSET_X * scale, bg_pos_y * scale, OFFSET_Z)
  local bg_size     = Vector2(WIDTH * scale, bg_height * scale)
  local bg_color    = Color(200, 10, 10, 10)
  Gui.rect(_gui, bg_position, bg_size, bg_color)

  -- selection rectangle
  if selected_command_new_index > 0 then
    local selection_height = STRING_HEIGHT * selected_strings_number
    local selection_pos_y  = OFFSET_Y - selection_height - STRING_HEIGHT * (selected_command_new_index - 1)

    local selection_position = Vector3(OFFSET_X * scale, selection_pos_y * scale, OFFSET_Z + 1)
    local selection_size     = Vector2(WIDTH * scale, selection_height * scale)
    local selection_color    = Color(100, 120, 120, 120)
    Gui.rect(_gui, selection_position, selection_size, selection_color)
  end

  -- "selected command number / total commands number" indicator
  if not ((#commands_list == 1) and (selected_command_index > 0)) then
    local total_number_indicator = tostring(#commands_list)
    if selected_command_index > 0 then
      total_number_indicator = selected_command_index .. "/" .. total_number_indicator
    end
    local total_number_indicator_width = get_text_width(total_number_indicator, FONT_MATERIAL, font_size)
    local total_number_indicator_x = (WIDTH) * scale - total_number_indicator_width
    local total_number_indicator_y = (OFFSET_Y + STRING_Y_OFFSET) * scale
    local total_number_indicator_position = Vector3(total_number_indicator_x, total_number_indicator_y, OFFSET_Z + 2)
    Gui.slug_text(_gui, total_number_indicator, FONT_MATERIAL, font_size,
                    total_number_indicator_position, nil, Color(255, 100, 100, 100))
  end

  if should_scale then
    UPDATE_RESOLUTION_LOOKUP(true)
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions ########################################################################################
-- #####################################################################################################################

-- A way for modders to change definitions. No safety checks. No guarantees definitions won't change. At least until
-- global refactoring.
function dmf.update_commands_list_gui_definitions(new_definitions)
  MULTISTRING_INDICATOR_TEXT = new_definitions.MULTISTRING_INDICATOR_TEXT or MULTISTRING_INDICATOR_TEXT
  FONT_TYPE                  = new_definitions.FONT_TYPE                  or FONT_TYPE
  FONT_SIZE                  = new_definitions.FONT_SIZE                  or FONT_SIZE
  MAX_COMMANDS_VISIBLE       = new_definitions.MAX_COMMANDS_VISIBLE       or MAX_COMMANDS_VISIBLE
  STRING_HEIGHT              = new_definitions.STRING_HEIGHT              or STRING_HEIGHT
  STRING_Y_OFFSET            = new_definitions.STRING_Y_OFFSET            or STRING_Y_OFFSET
  STRING_X_MARGIN            = new_definitions.STRING_X_MARGIN            or STRING_X_MARGIN
  OFFSET_X                   = new_definitions.OFFSET_X                   or OFFSET_X
  OFFSET_Y                   = new_definitions.OFFSET_Y                   or OFFSET_Y
  OFFSET_Z                   = new_definitions.OFFSET_Z                   or OFFSET_Z
  WIDTH                      = new_definitions.WIDTH                      or WIDTH
end

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return { draw = draw, destroy = destroy_gui }
