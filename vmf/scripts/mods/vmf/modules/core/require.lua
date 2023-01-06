local vmf = get_mod("VMF")

local _io_requires = {}

-- Global store of objects created through require()
local _require_store = Mods.require_store

-- Global backup of the require() function
local _original_require = Mods.original_require

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function add_io_require_path(path)
  _io_requires[path] = true
end


local function remove_io_require_path(path)
  _io_requires[path] = nil
end


local function get_require_store(path)
  return _require_store[path]
end


local function original_require(path, ...)
  return _original_require(path, ...)
end

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

-- Add a file path to be loaded through io instead of require()
function VMFMod:add_require_path(path)
  add_io_require_path(path)
end


-- Remove a file path that was previously loaded through io instead of require()
function VMFMod:remove_require_path(path)
  remove_io_require_path(path)
end


-- Get all instances of a file created through require()
function VMFMod:get_require_store(path)
  return get_require_store(path)
end


-- Get a file through the original, unhooked require() function
function VMFMod:original_require(path, ...)
  return original_require(path, ...)
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- Handles the swap to io for registered files
vmf:hook(_G, "require", function (func, path, ...)
  if _io_requires[path] then
    return vmf:dofile(path)
  else
    return func(path, ...)
  end
end)

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################