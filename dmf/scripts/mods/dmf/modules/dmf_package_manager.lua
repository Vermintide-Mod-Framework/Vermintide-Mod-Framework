local dmf = get_mod("DMF")

local _packages = {}
local _queued_packages = {}

local PUBLIC_STATUSES = {
  queued            = "loading", -- Package is in the loading queue waiting to be loaded.
  loading           = "loading", -- Package is loading.
  loaded            = "loaded",  -- Package is loaded
  loading_cancelled = nil        -- Package is loading, but will be unloaded once done loading.
}

local ERRORS = {
  REGULAR = {
    -- DMFMod:load_package:
    package_already_loaded = "[DMF Package Manager] (load_package): package '%s' has already been loaded.",
    package_not_found = "[DMF Package Manager] (load_package): could not find package '%s'.",
    package_already_queued = "[DMF Package Manager] (load_package): package '%s' is already queued for loading.",
    -- DMFMod:unload_package:
    package_not_loaded = "[DMF Package Manager] (unload_package): package '%s' has not been loaded.",
    cant_unload_loading_package = "[DMF Package Manager] (unload_package): package '%s' can't be unloaded because " ..
                                   "it's currently loading."

  },
  PREFIX = {
    package_loaded_callback = "[DMF Package Manager] '%s' package loaded callback execution"
  }
}

local WARNINGS = {
  force_unloading_package = "[DMF Package Manager] Force-unloading package '%s'. Please make sure to properly " ..
                             "release packages when the mod is unloaded",
  still_loading_package = "[DMF Package Manager] Still loading package '%s'. Memory leaks may occur when unloading " ..
                           "while a package is loading."
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Brings resources of the loaded package in game and executes callback. Or unloads package's resources, if loading was
-- cancelled.
local function flush_package(package_name)
  local package_data = _packages[package_name]

  if package_data.status == "loading_cancelled" then
    Application.release_resource_package(package_data.resource_package)
    _packages[package_name] = nil
  else
    package_data.resource_package:flush()
    package_data.status = "loaded"
    local callback = package_data.callback
    if callback then
      dmf.safe_call_nr(package_data.mod, {ERRORS.PREFIX.package_loaded_callback, package_name}, callback, package_name)
    end
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
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Loads a mod package.
  * package_name [string]  : package name. needs to be the full path to the `.package` file without the extension
  * callback     [function]: (optional) callback for when loading is done
  * sync         [boolean] : (optional) load the packages synchronously, freezing the game until it is loaded
--]]
function DMFMod:load_package(package_name, callback, sync)
  if dmf.check_wrong_argument_type(self, "load_package", "package_name", package_name, "string") or
     dmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil") or
     dmf.check_wrong_argument_type(self, "load_package", "sync", sync, "boolean", "nil")
  then
    return
  end

  if _packages[package_name] and _packages[package_name].status == "loaded" then
    self:error(ERRORS.REGULAR.package_already_loaded, package_name)
    return
  end

  local resource_package = Application.resource_package(package_name)
  if not resource_package then
    self:error(ERRORS.REGULAR.package_not_found, package_name)
    return
  end

  -- (is_package_already_queued == true) => Package was already loaded asynchronously before, but not fully loaded yet.
  -- (is_package_loading_cancelled == true) => Package is in the process of loading, but once it's loaded it's going
  --                                           to be unloaded.
  -- If package is not already queued create new entry for it. If it's already queued, but has "loading_cancelled"
  -- status, update its callback.
  local is_package_already_queued = (_packages[package_name] ~= nil)
  local is_package_loading_cancelled = _packages[package_name] and _packages[package_name].status == "loading_cancelled"
  if not is_package_already_queued or is_package_loading_cancelled then
    _packages[package_name] = {
      status            = is_package_loading_cancelled and "loading" or "queued",
      resource_package  = is_package_loading_cancelled and _packages[package_name].resource_package or resource_package,
      callback          = callback,
      mod               = self
    }
  end

  if sync then
    -- Load resource package if it's not already loading.
    if _packages[package_name].status == "queued" then
      resource_package:load()
    end
    if is_package_already_queued then
      remove_package_from_queue(package_name)
    end
    flush_package(package_name)
  else
    -- If package loading was cancelled before, don't add it to loading queue, because it's still in loading queue.
    if not is_package_loading_cancelled then
      if is_package_already_queued then
        self:error(ERRORS.REGULAR.package_already_queued, package_name)
      else
        table.insert(_queued_packages, package_name)
      end
    end
  end
end


--[[
  Unloads a loaded mod package.
  * package_name [string]: package name. needs to be the full path to the `.package` file without the extension
--]]
function DMFMod:unload_package(package_name)
  if dmf.check_wrong_argument_type(self, "unload_package", "package_name", package_name, "string")
  then
    return
  end

  local package_status = _packages[package_name] and _packages[package_name].status
  if not package_status then
    self:error(ERRORS.REGULAR.package_not_loaded, package_name)
    return
  end

  if package_status == "queued" then
    remove_package_from_queue(package_name)
    _packages[package_name] = nil
  elseif package_status == "loading" then
    _packages[package_name].status = "loading_cancelled"
  elseif package_status == "loaded" then
    Application.release_resource_package(_packages[package_name].resource_package)
    _packages[package_name] = nil
  end
end


--[[
  Returns package status string.
  * package_name [string]: package name. needs to be the full path to the `.package` file without the extension
--]]
function DMFMod:package_status(package_name)
  if dmf.check_wrong_argument_type(self, "package_status", "package_name", package_name, "string")
  then
    return
  end

  local package_data = _packages[package_name]
  if package_data then
    return PUBLIC_STATUSES[package_data.status]
  end
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Loads queued packages one at a time.
function dmf.update_package_manager()
  local queued_package_name = _queued_packages[1]
  if queued_package_name then
    local package_data = _packages[queued_package_name]
    if (package_data.status == "loading" or package_data.status == "loading_cancelled") and
        package_data.resource_package:has_loaded()
    then
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
function dmf.unload_all_resource_packages()
  for package_name, package_data in pairs(_packages) do
    local package_status = package_data.status

    if package_status == "loaded" then
      package_data.mod:warning(WARNINGS.force_unloading_package, package_name)
      package_data.mod:unload_package(package_name)
    end

    if package_status == "loading" or package_status == "loading_cancelled" then
      package_data.mod:warning(WARNINGS.still_loading_package, package_name)
    end
  end
end
