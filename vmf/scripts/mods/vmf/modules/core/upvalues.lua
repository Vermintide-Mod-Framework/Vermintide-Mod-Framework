local vmf = get_mod("VMF")


-- #####################################################################################################################
-- ##### Local functions ###########################################################################################{{{1
-- #####################################################################################################################

-- Given a function, a string or a table+string; we resolve it into a function (taking into account hooks).
local function resolve_function(mod, vmf_func_name, obj, method, ...)
  if vmf.check_wrong_argument_type(mod, vmf_func_name, "obj", obj, "function", "string", "table")
  then return nil end

  local type_obj = type(obj)

  -- If it's already a function, we return it as-is followed by the rest of the arguments.
  if type_obj == "function" then
    return obj, method, ...
  end

  -- If it's a string, we unshift the arguments.
  if type_obj == "string" then
    obj, method = nil, obj
  end

  -- At this point, the method argument must always be a string.
  if vmf.check_wrong_argument_type(mod, vmf_func_name, "method", method, "string")
  then return nil end

  return vmf.get_orig_function(obj, method), ...
end


-- Return the next upvalue triplet by index.
local function upvalue_next(func, i)
  i = i and i+1 or 1
  local k, v = debug.getupvalue(func, i)
  if k then
    return i, k, v
  end
end


-- Convenience function for use in `for` loops.
local function upvalue_iterate(func)
  return upvalue_next, func, nil
end


-- #####################################################################################################################
-- ##### VMFMod ####################################################################################################{{{1
-- #####################################################################################################################

--- Analog to `next` for upvalues. Returns the triplet at the next index.
-- @param i Upvalue index
-- @returns The index, key and value of the next upvalue.
function VMFMod:upvalue_next(obj, method, i)
  local func, i = resolve_function(self, "upvalue_next", obj, method, i)

  if not func
  or vmf.check_wrong_argument_type(self, "upvalue_next", "i", i, "nil", "number")
  then return end

  return upvalue_next(func, i)
end


--- Convenience generic upvalue iterator.
-- For use in Lua's `for in` loop structure.
-- @param name The name of the upvalue.
-- @returns The `upvalue_next` function, func and nil.
  function VMFMod:upvalue_iterate(obj, method)
    local func = resolve_function(self, "upvalue_iterate", obj, method)

    return upvalue_next, func, nil
end


--- Build a table with all the upvalues.
-- @returns A table of upvalue key and value pairs.
function VMFMod:upvalue_table(obj, method)
  local func = resolve_function(self, "upvalue_table", obj, method)

  if not func
  then return end

  local t = {}
  for _, k, v in upvalue_iterate(func) do
    t[k] = v
  end
  return t
end


--- Retrieve an upvalue by name.
-- @param name The name of the upvalue.
-- @returns The current value of the upvalue.
function VMFMod:upvalue_get(obj, method, upvalue_name)
  local func, upvalue_name = resolve_function(self, "upvalue_get", obj, method, upvalue_name)

  if not func
  or vmf.check_wrong_argument_type(self, "upvalue_get", "upvalue_name", upvalue_name, "string")
  then return end

  for _, k, v in upvalue_iterate(func) do
    if upvalue_name == k then
      return v
    end
  end
  return nil
end


--- Modify an upvalue by name.
-- @param name The name of the upvalue.
-- @param value The new value.
-- @returns The name of the upvalue if it was changed and nil otherwise.
function VMFMod:upvalue_set(obj, method, upvalue_name, new_value)
  local func, upvalue_name, new_value = resolve_function(self, "upvalue_set", obj, method, upvalue_name, new_value)


  if not func
  or vmf.check_wrong_argument_type(self, "upvalue_set", "func", func, "function")
  or vmf.check_wrong_argument_type(self, "upvalue_set", "upvalue_name", upvalue_name, "string")
  then return end

  for i, k, v in upvalue_iterate(func) do
    if upvalue_name == k then
      return debug.setupvalue(func, i, new_value)
    end
  end
  return nil
end
