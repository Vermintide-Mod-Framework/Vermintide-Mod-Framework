local dmf = get_mod("DMF")

local InputUtils = require("scripts/managers/input/input_utils")

local PRIMARY_BINDABLE_KEYS = {
  ["keyboard"] = {
    [8]   = {"Backspace",           "backspace"},
    [9]   = {"Tab",                 "tab"},
    [13]  = {"Enter",               "enter"},
    [20]  = {"Caps Lock",           "caps lock"},
    [32]  = {"Space",               "space"},
    [33]  = {"Page Up",             "page up"},
    [34]  = {"Page Down",           "page down"},
    [35]  = {"End",                 "end"},
    [36]  = {"Home",                "home"},
    [37]  = {"Left",                "left"},
    [38]  = {"Up",                  "up"},
    [39]  = {"Right",               "right"},
    [40]  = {"Down",                "down"},
    [45]  = {"Insert",              "insert"},
    [46]  = {"Delete",              "delete"},
    [48]  = {"0",                   "0"},
    [49]  = {"1",                   "1"},
    [50]  = {"2",                   "2"},
    [51]  = {"3",                   "3"},
    [52]  = {"4",                   "4"},
    [53]  = {"5",                   "5"},
    [54]  = {"6",                   "6"},
    [55]  = {"7",                   "7"},
    [56]  = {"8",                   "8"},
    [57]  = {"9",                   "9"},
    [65]  = {"A",                   "a"},
    [66]  = {"B",                   "b"},
    [67]  = {"C",                   "c"},
    [68]  = {"D",                   "d"},
    [69]  = {"E",                   "e"},
    [70]  = {"F",                   "f"},
    [71]  = {"G",                   "g"},
    [72]  = {"H",                   "h"},
    [73]  = {"I",                   "i"},
    [74]  = {"J",                   "j"},
    [75]  = {"K",                   "k"},
    [76]  = {"L",                   "l"},
    [77]  = {"M",                   "m"},
    [78]  = {"N",                   "n"},
    [79]  = {"O",                   "o"},
    [80]  = {"P",                   "p"},
    [81]  = {"Q",                   "q"},
    [82]  = {"R",                   "r"},
    [83]  = {"S",                   "s"},
    [84]  = {"T",                   "t"},
    [85]  = {"U",                   "u"},
    [86]  = {"V",                   "v"},
    [87]  = {"W",                   "w"},
    [88]  = {"X",                   "x"},
    [89]  = {"Y",                   "y"},
    [90]  = {"Z",                   "z"},
    [91]  = {"Win",                 "win"},
    [92]  = {"RWin",                "right win"},
    [96]  = {"Num 0",               "numpad 0"},
    [97]  = {"Num 1",               "numpad 1"},
    [98]  = {"Num 2",               "numpad 2"},
    [99]  = {"Num 3",               "numpad 3"},
    [100] = {"Num 4",               "numpad 4"},
    [101] = {"Num 5",               "numpad 5"},
    [102] = {"Num 6",               "numpad 6"},
    [103] = {"Num 7",               "numpad 7"},
    [104] = {"Num 8",               "numpad 8"},
    [105] = {"Num 9",               "numpad 9"},
    [106] = {"Num *",               "numpad *"},
    [107] = {"Num +",               "numpad +"},
    [109] = {"Num -",               "numpad -"},
    [110] = {"Num .",               "numpad ."},
    [111] = {"Num /",               "numpad /"},
    [112] = {"F1",                  "f1"},
    [113] = {"F2",                  "f2"},
    [114] = {"F3",                  "f3"},
    [115] = {"F4",                  "f4"},
    [116] = {"F5",                  "f5"},
    [117] = {"F6",                  "f6"},
    [118] = {"F7",                  "f7"},
    [119] = {"F8",                  "f8"},
    [120] = {"F9",                  "f9"},
    [121] = {"F10",                 "f10"},
    [122] = {"F11",                 "f11"},
    [123] = {"F12",                 "f12"},
    [144] = {"Num Lock",            "num lock"},
    [145] = {"Scroll Lock",         "scroll lock"},
    [166] = {"Browser Back",        "browser back"},
    [167] = {"Browser Forward",     "browser forward"},
    [168] = {"Browser Refresh",     "browser refresh"},
    [169] = {"Browser Stop",        "browser stop"},
    [170] = {"Browser Search",      "browser search"},
    [171] = {"Browser Favorites",   "browser favorites"},
    [172] = {"Browser Home",        "browser home"},
    [173] = {"Volume Mute",         "volume mute"},
    [174] = {"Volume Down",         "volume down"},
    [175] = {"Volume Up",           "volume up"},
    [176] = {"Next Track",          "next track"},
    [177] = {"Previous Track",      "previous track"},
    [178] = {"Stop",                "stop"},
    [179] = {"Play/Pause",          "play pause"},
    [180] = {"Mail",                "mail"},
    [181] = {"Media",               "media"},
    [182] = {"Start Application 1", "start app 1"},
    [183] = {"Start Application 2", "start app 2"},
    [186] = {";",                   ";"},
    [187] = {"=",                   "="},
    [188] = {",",                   ","},
    [189] = {"-",                   "-"},
    [190] = {".",                   "."},
    [191] = {"/",                   "/"},
    [192] = {"`",                   "`"},
    [219] = {"[",                   "["},
    [220] = {"\\",                  "\\"},
    [221] = {"]",                   "]"},
    [222] = {"'",                   "'"},
 --?[226] = {"\",                   "oem_102 (> <)"},
    [256] = {"Num Enter",           "numpad enter"}
  },
  ["mouse"] = {
    [0]  = {"Mouse Left",        "mouse left"},
    [1]  = {"Mouse Right",       "mouse right"},
    [2]  = {"Mouse Middle",      "mouse middle"},
    [3]  = {"Mouse Extra 1",     "mouse extra 1"},
    [4]  = {"Mouse Extra 2",     "mouse extra 2"},
    [10] = {"Mouse Wheel Up",    "mouse wheel up"},
    [11] = {"Mouse Wheel Down",  "mouse wheel down"},
    [12] = {"Mouse Wheel Left",  "mouse wheel left"},
    [13] = {"Mouse Wheel Right", "mouse wheel right"}
  },
  --[[ -- will work on this if it will be needed
  ["gamepad"] = {
    [0]  = {"", "d_up"},
    [1]  = {"", "d_down"},
    [2]  = {"", "d_left"},
    [3]  = {"", "d_right"},
    [4]  = {"", "start"},
    [5]  = {"", "back"},
    [6]  = {"", "left_thumb"},
    [7]  = {"", "right_thumb"},
    [8]  = {"", "left_shoulder"},
    [9]  = {"", "right_shoulder"},
    [10] = {"", "left_trigger"},
    [11] = {"", "right_trigger"},
    [12] = {"", "a"},
    [13] = {"", "b"},
    [14] = {"", "x"},
    [15] = {"", "y"},
  }]]
}

local OTHER_KEYS = {
  -- modifier keys
  ["left shift"]  = {160, "Shift", "keyboard", 161},
  ["right shift"] = {160, "Shift", "keyboard", 161},
  ["shift"]       = {160, "Shift", "keyboard", 161},
  ["left ctrl"]   = {162, "Ctrl",  "keyboard", 163},
  ["right ctrl"]  = {162, "Ctrl",  "keyboard", 163},
  ["ctrl"]        = {162, "Ctrl",  "keyboard", 163},
  ["left alt"]    = {164, "Alt",   "keyboard", 165},
  ["right alt"]   = {164, "Alt",   "keyboard", 165},
  ["alt"]         = {164, "Alt",   "keyboard", 165},
  -- hack for 'dmf.build_keybind_string' function
  ["no_button"] = {-1, ""}
}

local KEYS_INFO = {}

-- Populate KEYS_INFO: Index, readable name, device name
for input_device_name, input_device_keys in pairs(PRIMARY_BINDABLE_KEYS) do
  for key_index, key_info in pairs(input_device_keys) do
    KEYS_INFO[key_info[2]] = {key_index, key_info[1], input_device_name}
  end
end

for key_id, key_data in pairs(OTHER_KEYS) do
    KEYS_INFO[key_id] = key_data
end

-- Can't use 'Device.released' because it will break keybinds if button is released when game window is not active.
local CHECK_INPUT_FUNCTIONS = {
  keyboard = {
    PRESSED  = function(key_id) return Keyboard.pressed(KEYS_INFO[key_id][1]) end,
    RELEASED = function(key_id) return Keyboard.button(KEYS_INFO[key_id][1]) == 0 end
  },
  mouse = {
    PRESSED  = function(key_id) return Mouse.pressed(KEYS_INFO[key_id][1]) end,
    RELEASED = function(key_id) return Mouse.button(KEYS_INFO[key_id][1]) == 0 end
  }
}

local _raw_keybinds_data = {}
local _keybinds = {}
local _pressed_key

local ERRORS = {
  PREFIX = {
    function_call = "[Keybindings] function_call 'mod.%s'"
  },
  REGULAR = {
    function_not_found = "[Keybindings] function_call 'mod.%s': function was not found."
  }
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function is_dmf_input_service_active()
  -- @TODO: Implement check for active DMF input service
  return true
end


-- Executes function for 'function_call' keybinds.
local function call_function(mod, function_name, keybind_is_pressed)
  if type(mod[function_name]) == "function" then
    dmf.safe_call_nr(mod, {ERRORS.PREFIX["function_call"], function_name}, mod[function_name], keybind_is_pressed)
  else
    mod:error(ERRORS.PREFIX["function_not_found"], function_name)
  end
end


-- If check of keybind's conditions is successful, performs keybind's action and returns 'true'.
local function perform_keybind_action(data, is_pressed)
  local can_perform_action = is_dmf_input_service_active() or data.global or data.release_action

  if data.type == "mod_toggle" and can_perform_action and not data.mod:get_internal_data("is_mutator") then
    dmf.mod_state_changed(data.mod:get_name(), not data.mod:is_enabled())
    return true
  elseif data.type == "function_call" and can_perform_action and data.mod:is_enabled() then
    call_function(data.mod, data.function_name, is_pressed)
    return true
  elseif data.type == "view_toggle" and data.mod:is_enabled() then
    dmf.keybind_toggle_view(data.mod, data.view_name, data.transition_data, can_perform_action, is_pressed)
    return true
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Checks for pressed and released keybinds, performs keybind actions.
-- * Checks for both right and left key modifiers (ctrl, alt, shift).
-- * If some keybind is pressed, won't check for other keybinds until this keybind is released.
-- * If several mods bound the same keys, keybind action will be performed for all of them, when keybind is pressed.
-- * Keybind is considered released, when its primary key is released.
function dmf.check_keybinds()
  local ctrl_pressed  = (Keyboard.button(KEYS_INFO["ctrl"][1])  + Keyboard.button(KEYS_INFO["ctrl"][4]))  > 0
  local alt_pressed   = (Keyboard.button(KEYS_INFO["alt"][1])   + Keyboard.button(KEYS_INFO["alt"][4]))   > 0
  local shift_pressed = (Keyboard.button(KEYS_INFO["shift"][1]) + Keyboard.button(KEYS_INFO["shift"][4])) > 0

  if not _pressed_key then
    for primary_key, keybinds_data in pairs(_keybinds) do
      if keybinds_data.check_pressed(primary_key) then
        for _, keybind_data in ipairs(keybinds_data) do

          local all_pressed = true
          for enabler, _ in pairs(keybind_data.enablers) do

            -- Check that every enabler key is pressed
            if OTHER_KEYS[enabler] and
              (
                Keyboard.button(KEYS_INFO[enabler][1]) +
                Keyboard.button(KEYS_INFO[enabler][4])
              ) <= 0
              or not (Keyboard.button(KEYS_INFO[enabler][1]) > 0)
            then
              all_pressed = false
              break
            end
          end

          -- Check that no modifier keys are pressed that shouldn't be
          if all_pressed and
             (not keybind_data.ctrl  and ctrl_pressed)  and
             (not keybind_data.alt   and alt_pressed)   and
             (not keybind_data.shift and shift_pressed)
          then
            all_pressed = false
          end

          -- Peform the keybind action if everything validates
          if all_pressed then
            if perform_keybind_action(keybind_data, true) then
              if keybind_data.trigger == "held" then
                keybind_data.release_action = true
              end
              _pressed_key = primary_key
            end
          end
        end
        if _pressed_key then
          break
        end
      end
    end
  end

  if _pressed_key then
    if _keybinds[_pressed_key].check_released(_pressed_key) then
      for _, keybind_data in ipairs(_keybinds[_pressed_key]) do
        if keybind_data.release_action then
          perform_keybind_action(keybind_data, false)
          keybind_data.release_action = nil
        end
      end
      _pressed_key = nil
    end
  end
end


-- Converts managable (raw) table of keybinds data to the table designed for the function checking for pressed and
-- released keybinds. After initial call requires to be called every time some keybind is added/removed.
function dmf.generate_keybinds()
  _keybinds = {}

  for mod, mod_keybinds in pairs(_raw_keybinds_data) do
    for _, raw_keybind_data in pairs(mod_keybinds) do

      local keys = raw_keybind_data.keys
      local primary_key  = keys[1]
      local modifier_keys = {}
      for i = 2, #keys do
        modifier_keys[keys[i]] = true
      end

      local keybind_data = {
        mod      = mod,
        global   = raw_keybind_data.global,
        trigger  = raw_keybind_data.trigger,
        type     = raw_keybind_data.type,
        enablers = modifier_keys,
        ctrl     = modifier_keys["ctrl"]  or modifier_keys["left ctrl"]  or modifier_keys["right ctrl"],
        alt      = modifier_keys["alt"]   or modifier_keys["left alt"]   or modifier_keys["right alt"],
        shift    = modifier_keys["shift"] or modifier_keys["left shift"] or modifier_keys["right shift"],

        function_name   = raw_keybind_data.function_name,
        view_name       = raw_keybind_data.view_name
      }

      _keybinds[primary_key] = _keybinds[primary_key] or {
        check_pressed  = CHECK_INPUT_FUNCTIONS[KEYS_INFO[primary_key][3]].PRESSED,
        check_released = CHECK_INPUT_FUNCTIONS[KEYS_INFO[primary_key][3]].RELEASED
      }
      table.insert(_keybinds[primary_key], keybind_data)
    end
  end
end


-- Adds/removes keybinds.
function dmf.add_mod_keybind(mod, setting_id, raw_keybind_data)
  if #raw_keybind_data.keys > 0 then
    _raw_keybinds_data[mod] = _raw_keybinds_data[mod] or {}
    _raw_keybinds_data[mod][setting_id] = raw_keybind_data
  elseif _raw_keybinds_data[mod] and _raw_keybinds_data[mod][setting_id] then
    _raw_keybinds_data[mod][setting_id] = nil
  end

  -- Keybind is changed from Mod Options.
  if dmf.all_mods_were_loaded then
    dmf.generate_keybinds()
  end
end


-- Creates DMF input service. It is required to know when non-global keybinds can be triggered.
-- (Called every time a level is loaded, or on mods reload)
function dmf.create_keybinds_input_service()
  -- @TODO: Link this input service to the player's input service and find some way to see if it's blocked
  --[[
  -- To create the DMF input service in Darktide
  local input_manager = Managers.input
  local service_type = "DMF"
  input_manager:add_setting(service_type, aliases, raw_key_table, filter_table, default_devices)
  input_manager:get_input_service(service_type)
  --]]
end


-- Converts key_index to readable key_id, which is used by DMF to identify keys.
-- (Used for capturing keybinds)
function dmf.get_key_id(device, key_index)
  local key_info = PRIMARY_BINDABLE_KEYS[device][key_index]
  return key_info and key_info[2]
end


-- Simply tells if key with key_id can be binded as primary key.
-- (Used for verifying keybind widgets)
function dmf.can_bind_as_primary_key(key_id)
  return KEYS_INFO[key_id] and not OTHER_KEYS[key_id]
end


-- Builds string with readable keys' names to look like "Primary Key + Ctrl + Alt + Shift".
-- (Used in keybind widget)
function dmf.build_keybind_string(keys)
  local readable_key_names = {}
  for _, key_id in ipairs(keys) do
    table.insert(readable_key_names, KEYS_INFO[key_id][2])
  end
  return table.concat(readable_key_names, " + ")
end


-- Translate key watch result to mod options keybind
-- (Used in keybind widget)
function dmf.keybind_result_to_keys(keybind_result)
  local keys = {}

  -- Get the local name of the main key
  if keybind_result.main then

    local global_name = keybind_result.main
    local device_type = InputUtils.key_device_type(global_name)
    local local_name = InputUtils.local_key_name(global_name, device_type)

    -- Check for a missing or unbindable primary key name
    if not local_name or not dmf.can_bind_as_primary_key(local_name) then
      return keys
    end

    keys[1] = local_name
  end

  -- Add the enablers keys as additional keys
  if keybind_result.enablers then
    for _, global_name in ipairs(keybind_result.enablers) do

      local device_type = InputUtils.key_device_type(global_name)
      local local_name = InputUtils.local_key_name(global_name, device_type)

      keys[#keys + 1] = local_name
    end
  end

  return keys
end


-- Translate mod options keybind to key watch result
-- (Used in keybind widget)
function dmf.keys_to_keybind_result(keys)
  local keybind_result = {
    enablers = {},
    disablers = {}
  }

  if not keys or #keys == 0 then
    return nil
  end

  if keys[1] then
    local local_name = keys[1]
    local global_name = KEYS_INFO[local_name] and InputUtils.local_to_global_name(local_name, KEYS_INFO[local_name][3])

    -- End early if our main key doesn't exist, and return an empty result
    if not global_name then
      return nil
    end

    keybind_result.main = global_name
  end

  -- Add all remaining keys to the enablers list
  for i = 2, #keys do
    local local_name = keys[i]
    local global_name = KEYS_INFO[local_name] and InputUtils.local_to_global_name(local_name, KEYS_INFO[local_name][3])

    if global_name then
      keybind_result.enablers[#keybind_result.enablers + 1] = global_name
    end
  end

  return keybind_result
end

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################

-- In case mods reloading was performed right at the moment of entering 'StateInGame'.
dmf.create_keybinds_input_service()
