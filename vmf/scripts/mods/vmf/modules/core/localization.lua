local vmf = get_mod("VMF")

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
local _localization_database = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function safe_string_format(mod, str, ...)

  -- the game still crash with unknown error if there is non-standard character after '%'
  local success, message = pcall(string.format, str, ...)

  if success then
    return message
  else
    mod:error("(localize) \"%s\": %s", tostring(str), tostring(message))
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.localize = function (self, text_id, ...)

  local mod_localization_table = _localization_database[self:get_name()]
  if mod_localization_table then

    local text_translations = mod_localization_table[text_id]
    if text_translations then

      local message

      if text_translations[_language_id] then

        message = safe_string_format(self, text_translations[_language_id], ...)
        if message then
          return message
        end
      end

      if text_translations["en"] then

        message = safe_string_format(self, text_translations["en"], ...)
        if message then
          return message
        end
      end
    end
  else
    self:error("(localize): localization file was not loaded for this mod")
  end

  return "<" .. tostring(text_id) .. ">"
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_mod_localization = function (mod, localization_table)

  if type(localization_table) ~= "table" then
    mod:error("(localization): localization file should return table")
    return
  end

  if _localization_database[mod:get_name()] then
    mod:warning("(localization): overwritting already loaded localization file")
  end

  _localization_database[mod:get_name()] = localization_table
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

local localization_table = vmf:dofile("localization/vmf")
vmf.load_mod_localization(vmf, localization_table)