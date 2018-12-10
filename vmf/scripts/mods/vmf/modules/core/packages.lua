local vmf = get_mod("VMF")

local _queued_packages = {}
local _loading_package = nil
local _loaded_packages = {}

function VMFMod:load_package(package_name, callback)
  if vmf.check_wrong_argument_type(self, "load_package", "package_name", package_name, "string") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil")
  then
    return
  end

  if self:has_package_loaded(package_name) then
    self:error("Package '%s' has already been loaded", package_name)
    return
  end

  local mod_handle = self:get_internal_data("mod_handle")

  if not mod_handle then
    self:error("Failed to get mod handle. Package management is not available.")
    return
  end

  if not _loaded_packages[self] then
    _loaded_packages[self] = {}
  end

  local resource_package = Mod.resource_package(mod_handle, package_name)

  if not resource_package then
    self:error("Could not find package '%s'.", package_name)
    return
  end

  local is_loading = self:is_package_loading(package_name)

  if not callback then
    if not is_loading then
      resource_package:load()
    end

    resource_package:flush()

    _loaded_packages[self][package_name] = resource_package
  else
    if is_loading then
      self:error("Package '%s' is currently loading", package_name)
      return
    end

    table.insert(_queued_packages, {
      mod = self,
      package_name = package_name,
      resource_package = resource_package,
      callback = callback,
    })
  end
end

function VMFMod:unload_package(package_name)
  if vmf.check_wrong_argument_type(self, "unload_package", "package_name", package_name, "string") then
    return
  end

  if not self:has_package_loaded(package_name) then
    self:error("Package '%s' has not been loaded", package_name)
    return
  end

  local resource_package = _loaded_packages[self][package_name]

  resource_package:unload()
  Mod.release_resource_package(resource_package)
  _loaded_packages[self][package_name] = nil
end

function VMFMod:is_package_loading(package_name)
  if vmf.check_wrong_argument_type(self, "is_package_loading", "package_name", package_name, "string") then
    return
  end

  if _loading_package and _loading_package.mod == self and _loading_package.package_name == package_name then
    return true
  end

  for _, queued_package in ipairs(_queued_packages) do
    if queued_package.mod == self and queued_package.package_name == package_name then
      return true
    end
  end

  return false
end

function VMFMod:has_package_loaded(package_name)
  if vmf.check_wrong_argument_type(self, "has_package_loaded", "package_name", package_name, "string") then
    return
  end

  local loaded_packages = _loaded_packages[self]
  return loaded_packages and loaded_packages[package_name] ~= nil
end

function vmf.update_package_manager()
  local loading_package = _loading_package

  if loading_package then
    if loading_package.resource_package:has_loaded() then
      _loaded_packages[loading_package.mod][loading_package.package_name] = loading_package.resource_package
      _loading_package = nil

      -- The callback has to be called last, so that any calls to `has_package_loaded` or `is_package_loading` return the correct value
      loading_package.callback()
    end

    return
  end

  local queued_package = _queued_packages[1]

  if queued_package then
    _loading_package = queued_package
    table.remove(_queued_packages, 1)

    _loading_package.resource_package:load()
  end
end
