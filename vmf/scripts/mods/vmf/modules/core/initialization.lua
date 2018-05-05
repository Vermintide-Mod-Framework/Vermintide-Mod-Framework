local vmf = get_mod("VMF")

--@TODO: array where I track if data was already initialized (initialize and initialize_data can be called only once)

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.initialize = function (self, script_path)

  local success, error_details = pcall(dofile, script_path)
  if not success then
    if error_details.error then
      self:error("(initialize): %s", error_details.error)
      print("\nTRACEBACK:\n\n" .. error_details.traceback .. "\nLOCALS:\n\n" .. error_details.locals)
    else
      self:error("(initialize): %s", tostring(error_details))
    end
    return
  end

  if self:is_togglable() then
    vmf.initialize_mod_state(self)
  end
end

VMFMod.initialize_data = function (self, mod_data)

  if mod_data.name then
    self._data.readable_name = mod_data.name
  end
  self._data.description  = mod_data.description
  self._data.is_togglable = mod_data.is_togglable or mod_data.is_mutator
  self._data.is_mutator   = mod_data.is_mutator

  if mod_data.is_mutator then
    vmf.register_mod_as_mutator(self, mod_data.mutator_settings)
  end

  if mod_data.options_widgets or (mod_data.is_togglable and not mod_data.is_mutator) then
    vmf.create_options(self, mod_data.options_widgets)
  end
end