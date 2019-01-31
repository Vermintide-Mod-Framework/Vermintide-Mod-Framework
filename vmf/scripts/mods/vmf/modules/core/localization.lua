local vmf = get_mod("VMF")

local _language_id = Application.user_setting("language_id")
local _localization_database = {}

local ERRORS = {
  REGULAR = {
    duplicate_localization = "[Localization] (initialize_mod_localization) The fully qualified text id '%s' was " ..
                              "already defined by another mod. Set 'force_override' to true to override it.",
  },
}

local WARNINGS = {
  quick_localize_deprecated = "(quick_localize) this method is deprecated, please update the mod. "..
                               "You're seeing this message because you have developer_mode enabled",
}


-- ####################################################################################################################
-- ##### VMFMod ###################################################################################################{{{1
-- ####################################################################################################################

--- Returns a localized version of a string, with optional formatting.
function VMFMod:localize(text_id, ...)
  local fully_qualified_text_id = self:qualify_text_id(text_id)
  local message_format = self:localize_raw(fully_qualified_text_id)
  if message_format then
    local _, message = vmf.safe_call(self, "(localize)", string.format, message_format, ...)
    if message then
      return message
    end
  end

  -- At this point either the localization was not found or there was an error when formatting.
  return ("<" .. tostring(text_id) .. ">") -- Return a placeholder string.
end


--- Does not format the message; returns nil if the localization is not found.
function VMFMod:localize_raw(text_id)
  return _localization_database[text_id]
end


-- Returns a fully qualified text_id that can be used in GUIs.
function VMFMod:qualify_text_id(text_id)
  if vmf.check_wrong_argument_type(self, "qualify_text_id", "text_id", text_id, "string") then
    return
  end

  return self:get_name() .. "." .. text_id
end


-- ####################################################################################################################
-- ##### VMF internal functions ###################################################################################{{{1
-- ####################################################################################################################

function vmf.initialize_mod_localization(mod, localization_table)
  -- Add all localizations to the unified database.
  for text_id, text_settings in pairs(localization_table) do
    local fully_qualified_text_id = text_id

    if not text_settings.no_prefix then
      fully_qualified_text_id = mod:qualify_text_id(text_id)
    end

    if _localization_database[fully_qualified_text_id] and not text_settings.force_override then
      mod:error(ERRORS.REGULAR.duplicate_localization, fully_qualified_text_id)
    else
      _localization_database[fully_qualified_text_id] = text_settings[_language_id] or text_settings.en
    end
  end

  return true
end


-- Kept here for compatibility purposes. Hopefully can be deleted soon.
function vmf.quick_localize(mod, text_id)
  if vmf:get("developer_mode") then
    mod:warning(WARNINGS.quick_localize_deprecated)
  end
  return VMFMod.localize_raw(mod, text_id)
end


-- ####################################################################################################################
-- ##### Script ###################################################################################################{{{1
-- ####################################################################################################################

local localization_table = vmf:dofile("localization/vmf")
vmf.initialize_mod_localization(vmf, localization_table)


-- ####################################################################################################################
-- ##### Hooks ####################################################################################################{{{1
-- ####################################################################################################################

vmf:hook(LocalizationManager, "_base_lookup", function(func, self, text_id)
  return _localization_database[text_id] or func(self, text_id)
end)
