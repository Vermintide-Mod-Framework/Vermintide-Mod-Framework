local vmf = get_mod("VMF")

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

-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

function VMFMod:pcall(...)
  return vmf.xpcall(self, "(pcall)", ...)
end


function VMFMod:dofile(file_path)
  local _, return_values = pack_pcall(vmf.xpcall_dofile(self, "(dofile)", file_path))
	return unpack(return_values, 1, return_values.n)
end

-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

function vmf.xpcall(mod, error_prefix, func, ...)
  local success, return_values = pack_pcall(xpcall(func, print_error_callstack, ...))
  if not success then
		mod:error("%s: %s", error_prefix, return_values[1])
		return success
  end
  return success, unpack(return_values, 1, return_values.n)
end


function vmf.xpcall_no_return_values(mod, error_prefix, func, ...)
  local success, error_message = xpcall(func, print_error_callstack, ...)
  if not success then
    mod:error("%s: %s", error_prefix, error_message)
  end
  return success
end


function vmf.xpcall_dofile(mod, error_prefix, file_path)
	if type(file_path) ~= "string" then
		mod:error("%s: file path should be a string.", error_prefix)
		return false
	end
  return vmf.xpcall(mod, error_prefix, dofile, file_path)
end