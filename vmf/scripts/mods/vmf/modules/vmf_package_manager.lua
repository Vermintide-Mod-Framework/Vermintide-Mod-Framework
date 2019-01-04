local vmf = get_mod("VMF")

local _packages = {}
local _queued_packages = {}

local ERRORS = {
  REGULAR = {
    -- check_vt1:
    cant_use_vmf_package_manager_in_vt1 = "[VMF Package Manager] (%s): you can't use VMF package manager in VT1 " ..
                                           "because VT1 mods don't support more than 1 resource package.",
    -- VMFMod:load_package:
    package_already_loaded = "[VMF Package Manager] (load_package): package '%s' has already been loaded.",
    package_not_found = "[VMF Package Manager] (load_package): could not find package '%s'.",
    package_already_queued = "[VMF Package Manager] (load_package): package '%s' is already queued for loading.",
    -- VMFMod:unload_package:
    package_not_loaded = "[VMF Package Manager] (unload_package): package '%s' has not been loaded.",
    cant_unload_loading_package = "[VMF Package Manager] (unload_package): package '%s' can't be unloaded because " ..
                                   "it's currently loading."

  },
  PREFIX = {
    package_loaded_callback = "[VMF Package Manager] '%s' package loaded callback execution"
  }
}

local WARNINGS = {
  force_unloading_package = "[VMF Package Manager] Force-unloading package '%s'. Please make sure to properly " ..
                             "release packages when the mod is unloaded",
  still_loading_package = "[VMF Package Manager] Still loading package '%s'. Memory leaks may occur when unloading " ..
                           "while a package is loading."
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function check_vt1(mod, function_name)
  if VT1 then
    mod:error(ERRORS.REGULAR.cant_use_vmf_package_manager_in_vt1, function_name)
    return true
  end
end


-- Brings resources of the loaded package in game and executes callback.
local function flush_package(package_name)
  local package_data = _packages[package_name]
  package_data.resource_package:flush()
  package_data.status = "loaded"

  local callback = package_data.callback
  if callback then
    vmf.safe_call_nr(package_data.mod, {ERRORS.PREFIX.package_loaded_callback, package_name}, callback, package_name)
  end
end


local function remove_package_from_queue(package_name)
  for i, queued_package_name in ipairs(_queued_packages) do
    if package_name == queued_package_name then
      table.remove(_queued_packages, i)
      return
    end
  end
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Loads a mod package.
  * package_name [string]  : package name. needs to be the full path to the `.package` file without the extension
  * callback     [function]: (optional) callback for when loading is done
  * sync         [boolean] : (optional) load the packages synchronously, freezing the game until it is loaded
--]]
function VMFMod:load_package(package_name, callback, sync)
  if check_vt1(self, "load_package") or
     vmf.check_wrong_argument_type(self, "load_package", "package_name", package_name, "string") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil") or
     vmf.check_wrong_argument_type(self, "load_package", "sync", sync, "boolean", "nil")
  then
    return
  end

  if self:package_status(package_name) == "loaded" then
    self:error(ERRORS.REGULAR.package_already_loaded, package_name)
    return
  end

  local resource_package = Mod.resource_package(self:get_internal_data("mod_handle"), package_name)
  if not resource_package then
    self:error(ERRORS.REGULAR.package_not_found, package_name)
    return
  end

  -- If package is_already_queued it means it was already loaded asynchroniously before, but not fully loaded yet.
  -- It can have "queued" or "loading" status. Don't redefine data for this package.
  local is_already_queued = _packages[package_name] ~= nil
  if not is_already_queued then
    _packages[package_name] = {
      status           = "queued",
      resource_package = resource_package,
      callback         = callback,
      mod              = self
    }
  end

  if sync then
    -- Load resource package if it's not already loading.
    if _packages[package_name].status == "queued" then
      resource_package:load()
    end
    if is_already_queued then
      remove_package_from_queue(package_name)
    end
    flush_package(package_name)
  else
    if is_already_queued then
      self:error(ERRORS.REGULAR.package_already_queued, package_name)
    else
      table.insert(_queued_packages, package_name)
    end
  end
end


--[[
  Unloads a loaded mod package.
  * package_name [string]: package name. needs to be the full path to the `.package` file without the extension
--]]
function VMFMod:unload_package(package_name)
  if check_vt1(self, "unload_package") or
     vmf.check_wrong_argument_type(self, "unload_package", "package_name", package_name, "string")
  then
    return
  end

  local package_status = self:package_status(package_name)
  if not package_status then
    self:error(ERRORS.REGULAR.package_not_loaded, package_name)
    return
  end

  if package_status == "queued" then
    remove_package_from_queue(package_name)
  elseif package_status == "loading" then
    self:error(ERRORS.REGULAR.cant_unload_loading_package, package_name)
    return
  elseif package_status == "loaded" then
    Mod.release_resource_package(_packages[package_name].resource_package)
  end

  _packages[package_name] = nil
end


--[[
  Returns package status string.
  * package_name [string]: package name. needs to be the full path to the `.package` file without the extension
--]]
function VMFMod:package_status(package_name)
  if check_vt1(self, "package_status") or
     vmf.check_wrong_argument_type(self, "package_status", "package_name", package_name, "string")
  then
    return
  end

  local package_data = _packages[package_name]
  return package_data and package_data.status
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Loads queued packages one at a time.
function vmf.update_package_manager()
  local queued_package_name = _queued_packages[1]
  if queued_package_name then
    local package_data = _packages[queued_package_name]
    if package_data.status == "loading" and package_data.resource_package:has_loaded() then
      flush_package(queued_package_name)
      table.remove(_queued_packages, 1)
    end

    if package_data.status == "queued" then
      package_data.resource_package:load()
      package_data.status = "loading"
    end
  end
end


-- Forcefully unloads all not unloaded packages.
function vmf.unload_all_resource_packages()
  for package_name, package_data in pairs(_packages) do
    local package_status = package_data.status

    if package_status == "loaded" then
      package_data.mod:warning(WARNINGS.force_unloading_package, package_name)
      package_data.mod:unload_package(package_name)
    end

    if package_status == "loading" then
      package_data.mod:warning(WARNINGS.still_loading_package, package_name)
    end
  end
end
