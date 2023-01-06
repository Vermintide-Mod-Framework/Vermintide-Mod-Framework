local dmf = get_mod("DMF")

-- Global method to load a file through io with a return
local mod_dofile = Mods.file.dofile

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

local function pack_pcall(status, ...)
  return status, {n = select('#', ...), ...}
end


local function print_error_callstack(error_message)
  if type(error_message) == "table" and error_message.error then
    error_message = error_message.error
  end
  print("Error: " .. tostring(error_message) .. "\n" .. Script.callstack())
  return error_message
end


local function show_error(mod, error_prefix_data, error_message)
  local error_prefix
  if type(error_prefix_data) == "table" then
    error_prefix = string.format(error_prefix_data[1], error_prefix_data[2], error_prefix_data[3], error_prefix_data[4])
  else
    error_prefix = error_prefix_data
  end

  mod:error("%s: %s", error_prefix, error_message)
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

function DMFMod:pcall(...)
  return dmf.safe_call(self, "(pcall)", ...)
end


function DMFMod:dofile(file_path)
  local _, return_values = pack_pcall(dmf.safe_call_dofile(self, "(dofile)", file_path))
  return unpack(return_values, 1, return_values.n)
end

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Safe Call
function dmf.safe_call(mod, error_prefix_data, func, ...)
  local success, return_values = pack_pcall(xpcall(func, print_error_callstack, ...))
  if not success then
    show_error(mod, error_prefix_data, return_values[1])
    return success
  end
  return success, unpack(return_values, 1, return_values.n)
end


-- Safe Call [No return values]
function dmf.safe_call_nr(mod, error_prefix_data, func, ...)
  local success, error_message = xpcall(func, print_error_callstack, ...)
  if not success then
    show_error(mod, error_prefix_data, error_message)
  end
  return success
end


-- Safe Call [No return values and error callstack]
function dmf.safe_call_nrc(mod, error_prefix_data, func, ...)
  local success, error_message = pcall(func, ...)
  if not success then
    show_error(mod, error_prefix_data, error_message)
  end
  return success
end


-- Safe Call [dofile]
function dmf.safe_call_dofile(mod, error_prefix_data, file_path)
  if type(file_path) ~= "string" then
    show_error(mod, error_prefix_data, "file path should be a string.")
    return false
  end
  return dmf.safe_call(mod, error_prefix_data, mod_dofile, file_path)
end


-- Format error message and throw error.
function dmf.throw_error(error_message, ...)
  error(string.format(error_message, ...), 0)
end
