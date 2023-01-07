local dmf = get_mod("DMF")

--[[
English (en)
French (fr)
German (de)
Spanish (es)
Russian (ru)
Portuguese-Brazil (br-pt)
Italian (it)
Polish (pl)
]]

local _language_id = Application.user_setting("language_id")

local _global_localization_database = {}
local _localization_database = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function safe_string_format(mod, str, ...)

  -- the game still crash with unknown error if there is non-standard character after '%'
  local success, message = pcall(string.format, str, ...)

  if success then
    return message
  elseif mod then
    mod:error("(localize) \"%s\": %s", tostring(str), tostring(message))
  else
    dmf:error("(localize) \"%s\": %s", tostring(str), tostring(message))
  end
end


local function get_translated_or_english_message(mod, text_translations, ...)

  if text_translations then

    local message

    if text_translations[_language_id] then

      message = safe_string_format(mod, text_translations[_language_id], ...)
      if message then
        return message
      end
    end

    if text_translations["en"] then

      message = safe_string_format(mod, text_translations["en"], ...)
      if message then
        return message
      end
    end
  end
end

-- ####################################################################################################################
-- ##### DMFMod #######################################################################################################
-- ####################################################################################################################

DMFMod.localize = function (self, text_id, ...)

  local message
  local mod_localization_table = _localization_database[self:get_name()]
  if mod_localization_table then

    local text_translations = mod_localization_table[text_id]
    message = get_translated_or_english_message(self, text_translations, ...)
  else
    self:error("(localize): localization file was not loaded for this mod")
  end

  return message or ("<" .. tostring(text_id) .. ">")
end


DMFMod.add_global_localize_strings = function (self, text_translations)
  for text_id, translations in pairs(text_translations) do
    if not _global_localization_database[text_id] then
      _global_localization_database[text_id] = translations
    end
  end
end

-- ####################################################################################################################
-- ##### DMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- Handles the return of global localize text_ids
dmf:hook(_G, "Localize", function (func, text_id, ...)

  local text_translations = text_id and _global_localization_database[text_id]
  local message = get_translated_or_english_message(nil, text_translations, ...)

  return message or func(text_id, ...)
end)

-- ####################################################################################################################
-- ##### DMF internal functions and variables #########################################################################
-- ####################################################################################################################

dmf.initialize_mod_localization = function (mod, localization_table)

  if type(localization_table) ~= "table" then
    mod:error("(localization): localization file should return table")
    return false
  end

  if _localization_database[mod:get_name()] then
    mod:warning("(localization): overwritting already loaded localization file")
  end

  _localization_database[mod:get_name()] = localization_table

  return true
end

-- Localize without parameters and return nil instead of <text_id> if nothing found
dmf.quick_localize = function (mod, text_id)

  local mod_localization_table = _localization_database[mod:get_name()]

  if mod_localization_table then

    local text_translations = mod_localization_table[text_id]
    
    if text_translations then
      return text_translations[_language_id] or text_translations["en"]
    end
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

local localization_table = dmf:dofile("dmf/localization/dmf")
dmf.initialize_mod_localization(dmf, localization_table)
