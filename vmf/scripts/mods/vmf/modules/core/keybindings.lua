local vmf = get_mod("VMF")

VMFModsKeyMap = {
  win32 = {
    ["ctrl"]  = {"keyboard", "left ctrl",  "held"},
    ["alt"]   = {"keyboard", "left alt",   "held"},
    ["shift"] = {"keyboard", "left shift", "held"}
  },
  xb1 = {}
  }

-- ["mod_name"]["setting_name"] = {"action_name", {"primary_key", "special_key", "special_key", "special_key"}} (special_key - "ctrl"/"shift"/"alt")
local _RAW_KEYBINDS = {}

-- ["primary_key"] = {{"mod_name", "action_name", ctrl_used(bool), alt_used(bool), shift_used(bool)}, {}, {}, ...}
local _OPTIMIZED_KEYBINDS = {}

local _ACTIVATED_PRESSED_KEY

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function apply_keybinds()

  _OPTIMIZED_KEYBINDS = {}

  for mod_name, mod_keybinds in pairs(_RAW_KEYBINDS) do
    for _, keybind in pairs(mod_keybinds) do
      local action_name = keybind[1]
      local primary_key = keybind[2][1]

      local special_key1 = keybind[2][2]
      local special_key2 = keybind[2][3]
      local special_key3 = keybind[2][4]

      local special_keys = {}

      if special_key1 then
        special_keys[special_key1] = true
      end
      if special_key2 then
        special_keys[special_key2] = true
      end
      if special_key3 then
        special_keys[special_key3] = true
      end

      _OPTIMIZED_KEYBINDS[primary_key] = _OPTIMIZED_KEYBINDS[primary_key] or {}
      table.insert(_OPTIMIZED_KEYBINDS[primary_key], {mod_name, action_name, special_keys["ctrl"], special_keys["alt"], special_keys["shift"]})
    end
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

-- use it directly only for dedugging purposes, otherwise use keybind widget
-- setting_name [string] - keybind identifyer for certain mod
-- action_name  [string] - name of some mod.function which will be called when keybind is pressed
-- keys         [table]  = {"primary_key", "2nd_key" [optional], "3rd_key" [optional], "4th_key" [optional]}
--                       2, 3, 4 keys can contain words "ctrl", "alt", "shift" (lowercase)
VMFMod.keybind = function (self, setting_name, action_name, keys)

  if keys[1] then

    local mod_keybinds = _RAW_KEYBINDS[self:get_name()] or {}

    mod_keybinds[setting_name] = {action_name, keys}

    _RAW_KEYBINDS[self:get_name()] = mod_keybinds
  else

    local mod_keybinds = _RAW_KEYBINDS[self:get_name()]

    if mod_keybinds and mod_keybinds[setting_name] then
      mod_keybinds[setting_name] = nil
    end
  end

  if vmf.keybind_input_service then
    apply_keybinds()
  end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.initialize_keybinds = function()
  Managers.input.create_input_service(Managers.input, "VMFMods", "VMFModsKeyMap")
  Managers.input.map_device_to_service(Managers.input, "VMFMods", "keyboard")
  Managers.input.map_device_to_service(Managers.input, "VMFMods", "mouse")

  vmf.keybind_input_service = Managers.input:get_service("VMFMods")

  apply_keybinds()
end

vmf.check_pressed_keybinds = function()

  local input_service = vmf.keybind_input_service
  if input_service then

    -- don't check for the pressed keybindings until player will release already pressed keybind
    if _ACTIVATED_PRESSED_KEY then
      if input_service:get(_ACTIVATED_PRESSED_KEY) then
        return
      else
        _ACTIVATED_PRESSED_KEY = nil
      end
    end

    local key_has_active_keybind = false

    for key, key_bindings in pairs(_OPTIMIZED_KEYBINDS) do
      if input_service:get(key) then
        for _, binding_info in ipairs(key_bindings) do
          if (not binding_info[3] and not input_service:get("ctrl") or binding_info[3] and input_service:get("ctrl")) and
            (not binding_info[4] and not input_service:get("alt") or binding_info[4] and input_service:get("alt")) and
            (not binding_info[5] and not input_service:get("shift") or binding_info[5] and input_service:get("shift")) then

            local mod = get_mod(binding_info[1])

            if binding_info[2] == "toggle_mod_state" and not mod:is_mutator() then

              vmf.mod_state_changed(mod:get_name(), not mod:is_enabled())

              key_has_active_keybind = true
              _ACTIVATED_PRESSED_KEY = key

            elseif mod:is_enabled() then

              local action_exists, action_function = pcall(function() return mod[binding_info[2]] end)
              if action_exists then
                local success, error_message = pcall(action_function)
                if not success then
                  mod:error("(keybindings)(mod.%s): %s", tostring(binding_info[2]), tostring(error_message))
                end
              else
                mod:error("(keybindings): function '%s' wasn't found.", tostring(binding_info[2]))
              end

              key_has_active_keybind = true
              _ACTIVATED_PRESSED_KEY = key
            end
          end
        end

        -- return here because some other mods can have the same keybind which also need to be executed
        if key_has_active_keybind then
          return
        end
      end
    end
  end
end

vmf.delete_keybinds = function()
  VMFModsKeyMap = {}
end

local keyboard_buton_name = Keyboard.button_name
local mouse_buton_name    = Mouse.button_name

vmf.keys = {
  keyboard = {
    [8]   = {"Backspace",           "backspace",         keyboard_buton_name(8)},
    [9]   = {"Tab",                 "tab",               keyboard_buton_name(9)},
    [13]  = {"Enter",               "enter",             keyboard_buton_name(13)},
    [20]  = {"Caps Lock",           "caps lock",         keyboard_buton_name(20)},
    [32]  = {"Space",               "space",             keyboard_buton_name(32)},
    [33]  = {"Page Up",             "page up",           keyboard_buton_name(33)},
    [34]  = {"Page Down",           "page down",         keyboard_buton_name(34)},
    [35]  = {"End",                 "end",               keyboard_buton_name(35)},
    [36]  = {"Home",                "home",              keyboard_buton_name(36)},
    [37]  = {"Left",                "left",              keyboard_buton_name(37)},
    [38]  = {"Up",                  "up",                keyboard_buton_name(38)},
    [39]  = {"Right",               "right",             keyboard_buton_name(39)},
    [40]  = {"Down",                "down",              keyboard_buton_name(40)},
    [45]  = {"Insert",              "insert",            keyboard_buton_name(45)},
    [46]  = {"Delete",              "delete",            keyboard_buton_name(46)},
    [48]  = {"0",                   "0",                 keyboard_buton_name(48)},
    [49]  = {"1",                   "1",                 keyboard_buton_name(49)},
    [50]  = {"2",                   "2",                 keyboard_buton_name(50)},
    [51]  = {"3",                   "3",                 keyboard_buton_name(51)},
    [52]  = {"4",                   "4",                 keyboard_buton_name(52)},
    [53]  = {"5",                   "5",                 keyboard_buton_name(53)},
    [54]  = {"6",                   "6",                 keyboard_buton_name(54)},
    [55]  = {"7",                   "7",                 keyboard_buton_name(55)},
    [56]  = {"8",                   "8",                 keyboard_buton_name(56)},
    [57]  = {"9",                   "9",                 keyboard_buton_name(57)},
    [65]  = {"A",                   "a",                 keyboard_buton_name(65)},
    [66]  = {"B",                   "b",                 keyboard_buton_name(66)},
    [67]  = {"C",                   "c",                 keyboard_buton_name(67)},
    [68]  = {"D",                   "d",                 keyboard_buton_name(68)},
    [69]  = {"E",                   "e",                 keyboard_buton_name(69)},
    [70]  = {"F",                   "f",                 keyboard_buton_name(70)},
    [71]  = {"G",                   "g",                 keyboard_buton_name(71)},
    [72]  = {"H",                   "h",                 keyboard_buton_name(72)},
    [73]  = {"I",                   "i",                 keyboard_buton_name(73)},
    [74]  = {"J",                   "j",                 keyboard_buton_name(74)},
    [75]  = {"K",                   "k",                 keyboard_buton_name(75)},
    [76]  = {"L",                   "l",                 keyboard_buton_name(76)},
    [77]  = {"M",                   "m",                 keyboard_buton_name(77)},
    [78]  = {"N",                   "n",                 keyboard_buton_name(78)},
    [79]  = {"O",                   "o",                 keyboard_buton_name(79)},
    [80]  = {"P",                   "p",                 keyboard_buton_name(80)},
    [81]  = {"Q",                   "q",                 keyboard_buton_name(81)},
    [82]  = {"R",                   "r",                 keyboard_buton_name(82)},
    [83]  = {"S",                   "s",                 keyboard_buton_name(83)},
    [84]  = {"T",                   "t",                 keyboard_buton_name(84)},
    [85]  = {"U",                   "u",                 keyboard_buton_name(85)},
    [86]  = {"V",                   "v",                 keyboard_buton_name(86)},
    [87]  = {"W",                   "w",                 keyboard_buton_name(87)},
    [88]  = {"X",                   "x",                 keyboard_buton_name(88)},
    [89]  = {"Y",                   "y",                 keyboard_buton_name(89)},
    [90]  = {"Z",                   "z",                 keyboard_buton_name(90)},
    [91]  = {"Win",                 "win",               keyboard_buton_name(91)},
    [92]  = {"RWin",                "right win",         keyboard_buton_name(92)},
    [96]  = {"Num 0",               "numpad 0",          keyboard_buton_name(96)},
    [97]  = {"Num 1",               "numpad 1",          keyboard_buton_name(97)},
    [98]  = {"Num 2",               "numpad 2",          keyboard_buton_name(98)},
    [99]  = {"Num 3",               "numpad 3",          keyboard_buton_name(99)},
    [100] = {"Num 4",               "numpad 4",          keyboard_buton_name(100)},
    [101] = {"Num 5",               "numpad 5",          keyboard_buton_name(101)},
    [102] = {"Num 6",               "numpad 6",          keyboard_buton_name(102)},
    [103] = {"Num 7",               "numpad 7",          keyboard_buton_name(103)},
    [104] = {"Num 8",               "numpad 8",          keyboard_buton_name(104)},
    [105] = {"Num 9",               "numpad 9",          keyboard_buton_name(105)},
    [106] = {"Num *",               "numpad *",          keyboard_buton_name(106)},
    [107] = {"Num +",               "numpad +",          keyboard_buton_name(107)},
    [109] = {"Num -",               "numpad -",          keyboard_buton_name(109)},
    [110] = {"Num .",               "numpad .",          keyboard_buton_name(110)},
    [111] = {"Num /",               "numpad /",          keyboard_buton_name(111)},
    [112] = {"F1",                  "f1",                keyboard_buton_name(112)},
    [113] = {"F2",                  "f2",                keyboard_buton_name(113)},
    [114] = {"F3",                  "f3",                keyboard_buton_name(114)},
    [115] = {"F4",                  "f4",                keyboard_buton_name(115)},
    [116] = {"F5",                  "f5",                keyboard_buton_name(116)},
    [117] = {"F6",                  "f6",                keyboard_buton_name(117)},
    [118] = {"F7",                  "f7",                keyboard_buton_name(118)},
    [119] = {"F8",                  "f8",                keyboard_buton_name(119)},
    [120] = {"F9",                  "f9",                keyboard_buton_name(120)},
    [121] = {"F10",                 "f10",               keyboard_buton_name(121)},
    [122] = {"F11",                 "f11",               keyboard_buton_name(122)},
    [123] = {"F12",                 "f12",               keyboard_buton_name(123)},
    [144] = {"Num Lock",            "num lock",          keyboard_buton_name(144)},
    [145] = {"Scroll Lock",         "scroll lock",       keyboard_buton_name(145)},
    [166] = {"Browser Back",        "browser back",      keyboard_buton_name(166)},
    [167] = {"Browser Forward",     "browser forward",   keyboard_buton_name(167)},
    [168] = {"Browser Refresh",     "browser refresh",   keyboard_buton_name(168)},
    [169] = {"Browser Stop",        "browser stop",      keyboard_buton_name(169)},
    [170] = {"Browser Search",      "browser search",    keyboard_buton_name(170)},
    [171] = {"Browser Favorites",   "browser favorites", keyboard_buton_name(171)},
    [172] = {"Browser Home",        "browser home",      keyboard_buton_name(172)},
    [173] = {"Volume Mute",         "volume mute",       keyboard_buton_name(173)},
    [174] = {"Volume Down",         "volume down",       keyboard_buton_name(174)},
    [175] = {"Volume Up",           "volume up",         keyboard_buton_name(175)},
    [176] = {"Next Track",          "next track",        keyboard_buton_name(176)},
    [177] = {"Previous Track",      "previous track",    keyboard_buton_name(177)},
    [178] = {"Stop",                "stop",              keyboard_buton_name(178)},
    [179] = {"Play/Pause",          "play pause",        keyboard_buton_name(179)},
    [180] = {"Mail",                "mail",              keyboard_buton_name(180)},
    [181] = {"Media",               "media",             keyboard_buton_name(181)},
    [182] = {"Start Application 1", "start app 1",       keyboard_buton_name(182)},
    [183] = {"Start Application 2", "start app 2",       keyboard_buton_name(183)},
    [186] = {";",                   ";",                 keyboard_buton_name(186)},
    [187] = {"=",                   "=",                 keyboard_buton_name(187)},
    [188] = {",",                   ",",                 keyboard_buton_name(188)},
    [189] = {"-",                   "-",                 keyboard_buton_name(189)},
    [190] = {".",                   ".",                 keyboard_buton_name(190)},
    [191] = {"/",                   "/",                 keyboard_buton_name(191)},
    [192] = {"`",                   "`",                 keyboard_buton_name(192)},
    [219] = {"[",                   "[",                 keyboard_buton_name(219)},
    [220] = {"\\",                  "\\",                keyboard_buton_name(220)},
    [221] = {"]",                   "]",                 keyboard_buton_name(221)},
    [222] = {"'",                   "'",                 keyboard_buton_name(222)},
    --?[226] = {"\", "oem_102 (> <)", keyboard_buton_name(226)},
    [256] = {"Num Enter",           "numpad enter",      keyboard_buton_name(256)}
  },
  mouse = {
    [0]  = {"Mouse Left",        "mouse left",        mouse_buton_name(0)},
    [1]  = {"Mouse Right",       "mouse right",       mouse_buton_name(1)},
    [2]  = {"Mouse Middle",      "mouse middle",      mouse_buton_name(2)},
    [3]  = {"Mouse Extra 1",     "mouse extra 1",     mouse_buton_name(3)},
    [4]  = {"Mouse Extra 2",     "mouse extra 2",     mouse_buton_name(4)},
    [10] = {"Mouse Wheel Up",    "mouse wheel up",    mouse_buton_name(10)},
    [11] = {"Mouse Wheel Down",  "mouse wheel down",  mouse_buton_name(11)},
    [12] = {"Mouse Wheel Left",  "mouse wheel left",  mouse_buton_name(12)},
    [13] = {"Mouse Wheel Right", "mouse wheel right", mouse_buton_name(13)}
  },--[[ -- will work on this if it will be needed
  gamepad = {
    [0] = {"", "d_up", gamepad_buton_name(0)},
    [1] = {"", "d_down", gamepad_buton_name(1)},
    [2] = {"", "d_left", gamepad_buton_name(2)},
    [3] = {"", "d_right", gamepad_buton_name(3)},
    [4] = {"", "start", gamepad_buton_name(4)},
    [5] = {"", "back", gamepad_buton_name(5)},
    [6] = {"", "left_thumb", gamepad_buton_name(6)},
    [7] = {"", "right_thumb", gamepad_buton_name(7)},
    [8] = {"", "left_shoulder", gamepad_buton_name(8)},
    [9] = {"", "right_shoulder", gamepad_buton_name(9)},
    [10] = {"", "left_trigger", gamepad_buton_name(10)},
    [11] = {"", "right_trigger", gamepad_buton_name(11)},
    [12] = {"", "a", gamepad_buton_name(12)},
    [13] = {"", "b", gamepad_buton_name(13)},
    [14] = {"", "x", gamepad_buton_name(14)},
    [15] = {"", "y", gamepad_buton_name(15)},
  }]]
}

vmf.readable_key_names = {}

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

for _, controller_keys in pairs(vmf.keys) do
  for _, key_info in pairs(controller_keys) do
    vmf.readable_key_names[key_info[2]] = key_info[1]
  end
end

vmf.readable_key_names["ctrl"]  = "Ctrl"
vmf.readable_key_names["alt"]   = "Alt"
vmf.readable_key_names["shift"] = "Shift"

for _, key_info in pairs(vmf.keys.keyboard) do
  VMFModsKeyMap.win32[key_info[2]] = {"keyboard", key_info[3], "held"}
end

for i = 0, 4 do
  local key_info = vmf.keys.mouse[i]
  VMFModsKeyMap.win32[key_info[2]] = {"mouse", key_info[3], "held"}
end

for i = 10, 13 do
  local key_info = vmf.keys.mouse[i]
  VMFModsKeyMap.win32[key_info[2]] = {"mouse", key_info[3], "pressed"}
end