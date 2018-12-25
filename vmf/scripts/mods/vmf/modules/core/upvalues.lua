local vmf = get_mod("VMF")


-- ####################################################################################################################
-- ##### Locals and Variables #####################################################################################{{{1
-- ####################################################################################################################


-- A registry of all upvalue changes.
local _upvalue_registry = setmetatable({}, { __mode = "k" })
--[[ SCHEMA:
      {
        [FUNC] = {
          [UPVALUE_INDEX] = {
            mod = MOD,
            orig = ORIGINAL_VALUE,
            func = FUNC,
            index = UPVALUE_INDEX,
          },
        },
      }
--]]


-- Same data tables, but regrouped by the mod that did the changes.
local _upvalues_by_mod = {}
--[[ SCHEMA:
      {
        [{
          mod = MOD,
          orig = ORIGINAL_VALUE,
          func = FUNC,
          index = UPVALUE_INDEX,
        }] = true,
      }
--]]


-- #####################################################################################################################
-- ##### Local functions ###########################################################################################{{{1
-- #####################################################################################################################

-- Given an argument list, it tries to resolve up to two arguments into a function. The following forms are accepted:
-- Object (table) + Method (string)
-- Global function name (string)
-- Raw function (function)
local function resolve_function(mod, vmf_func_name, obj, method, ...)
  if vmf.check_wrong_argument_type(mod, vmf_func_name, "obj", obj, "function", "string", "table") then
    return nil
  end

  local type_obj = type(obj)

  -- If the first argument is already a function, the argument list is returned as-is.
  if type_obj == "function" then
    return obj, method, ...
  -- If it's a string, we unshift a nil into the arguments and proceed.
  elseif type_obj == "string" then
    obj, method = nil, obj
  -- Otherwise, it's a table and we must ensure that the next argument is a string.
  elseif vmf.check_wrong_argument_type(mod, vmf_func_name, "method", method, "string") then
    return nil
  end

  -- Get the raw function referenced by obj[method], followed by other arguments.
  return vmf.get_orig_function(obj, method), ...
end


-- Retrieve the value and index associated to an upvalue.
local function upvalue_get(func, name)
  local i = 1
  while true do
    local k, v = debug.getupvalue(func, i)
    if not k then
      return
    elseif k == name then
      return v, i
    end
  end
end


local ERRORS = {
  no_such_upvalue = "no such upvalue: '%s'",
  not_upvalue_owner = "upvalue '%s' modified by another mod '%s'",
}

local function show_error(mod, error_prefix_data, error_fmt, ...)
  mod:error("(%s): %s", error_prefix_data, string.format(error_fmt, ...))
end


-- Function intended to be used as the __newindex field. Disallows writes in the table.
local function error_on_write(obj, key)
  return vmf:error("cannot set field '%s' on protected metatable '%s'", key, obj)
end


local function protect_value(value)
  if type(value) == "table" then
    value = setmetatable({}, {
      __metatable = true, -- Protect the metatable
      __newindex = error_on_write, -- Disallow writes.
      __index = value, -- Proxy reads to the original table.
    })
  end

  return value
end


-- #####################################################################################################################
-- ##### VMFMod ####################################################################################################{{{1
-- #####################################################################################################################

--- Retrieve an upvalue by name.
-- @param name The name of the upvalue.
-- @returns The current value of the upvalue.
function VMFMod:upvalue_get(obj, method, upvalue_name)
  local func
  func, upvalue_name = resolve_function(self, "upvalue_get", obj, method, upvalue_name)

  -- Type-check the arguments.
  if not func or
     vmf.check_wrong_argument_type(self, "upvalue_get", "upvalue_name", upvalue_name, "string")
  then
    return
  end

  local value, index = upvalue_get(func, upvalue_name)
  return protect_value(value), index
end


--- Modify an upvalue by name.
-- @param upvalue_name The name of the upvalue.
-- @param new_value The new value.
-- @returns The name of the upvalue if it was changed and nil otherwise.
function VMFMod:upvalue_set(obj, method, upvalue_name, new_value)
  local func
  func, upvalue_name, new_value = resolve_function(self, "upvalue_set", obj, method, upvalue_name, new_value)

  -- Type-check the arguments.
  if not func or
     vmf.check_wrong_argument_type(self, "upvalue_set", "upvalue_name", upvalue_name, "string")
  then
    return
  end

  -- Get the index of the upvalue. Fail if it doesn't exist.
  local current_value, index = upvalue_get(func, upvalue_name)
  if not index then
    return show_error(mod, "upvalue_set", ERRORS.no_such_upvalue, upvalue_name)
  end

  -- Lookup the function in the upvalue registry. Register it if wasn't found.
  if not _upvalue_registry[func] then
    _upvalue_registry[func] = {}
  end
  local func_upvalues = _upvalue_registry[func]

  -- If we have no data registered for this upvalue, we register it.
  if not func_upvalues[index] then
    local upvalue_data = {
      mod = mod,
      orig = current_value,
      func = func,
      index = index,
    }
    func_upvalues[index] = upvalue_data
    _upvalues_by_mod[mod][upvalue_data] = true

  -- Otherwise, we make sure that it wasn't modified by another mod.
  elseif func_upvalues[index].mod ~= mod then
    local other_mod_name = upvalue_data.mod:get_name()
    return show_error(mod, "upvalue_set", ERRORS.not_upvalue_owner, upvalue_name, other_mod_name)
  end

  -- All good, we modify the upvalue.
  debug.setupvalue(func, index, new_value)
end


--- Reset an upvalue to its original value and relinquish ownership of it.
-- @param upvalue_name The name of the upvalue.
-- @returns The name of the upvalue if it was reset and nil otherwise.
function VMFMod:upvalue_unset(obj, method, upvalue_name)
  local func
  func, upvalue_name, new_value = resolve_function(self, "upvalue_unset", obj, method, upvalue_name, new_value)

  -- Type-check the arguments.
  if not func or
     vmf.check_wrong_argument_type(self, "upvalue_unset", "upvalue_name", upvalue_name, "string")
  then
    return
  end

  -- Get the index of the upvalue. Fail if it doesn't exist.
  local current_value, index = upvalue_get(func, upvalue_name)
  if not index then
    return show_error(mod, "upvalue_unset", ERRORS.no_such_upvalue, upvalue_name)
  end

  -- Lookup the function in the upvalue registry. Nothing to do if there are no changes.
  local func_upvalues = _upvalue_registry[func]
  if not func_upvalues then
    return
  end

  -- If we have no data registed for this upvalue, we do nothing and return.
  local upvalue_data = func_upvalues[index]
  if not upvalue_data then
    return -- Nothing to do

  -- Otherwise, we make sure that it wasn't modified by another mod.
  elseif func_upvalues[index].mod ~= mod then
    local other_mod_name = upvalue_data.mod:get_name()
    return show_error(mod, "upvalue_unset", ERRORS.not_upvalue_owner, upvalue_name, other_mod_name)
  end

  -- Restore the upvalue.
  debug.setupvalue(func, index, upvalue_data.orig)

  -- Clean our records.
  upvalue_data[index] = nil
  _upvalues_by_mod[mod][upvalue_data] = nil

  return
end

function VMFMod:upvalue_unset_all()
  local mod_upvalues = _upvalues_by_mod[mod]
  if not mod_upvalues then
    return
  end

  for upvalue_data in pairs(mod_upvalues) do
    debug.setupvalue(upvalue_data.func, upvalue_data.index, upvalue_data.orig)
  end
end


-- ####################################################################################################################
-- ##### VMF internal functions and variables #####################################################################{{{1
-- ####################################################################################################################

-- Restore all upvalues when VMF is about to be reloaded.
function vmf.upvalues_unload()
  for func, upvalue_data in pairs(_upvalue_registry) do
    for index, upvalue_data in pairs(upvalue_data) do
      debug.setupvalue(func, index, upvalue_data.orig)
    end
  end
end
