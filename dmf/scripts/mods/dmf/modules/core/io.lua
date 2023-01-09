local dmf = get_mod("DMF")

-- Local backup of the io library
local _io = dmf:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then
  _io = dmf.deepcopy(Mods.lua.io)
end

local _mod_directory = "./../mods"

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- Build a file path out of the mod directory and the given parameters
local get_file_path = function(local_path, file_name, file_extension)
  local file_path = _mod_directory

  if local_path and local_path ~= "" then
    file_path = file_path .. "/" .. local_path
  end

  if file_name and file_name ~= "" then
    file_path = file_path .. "/" .. file_name
  end

  if file_extension and file_extension ~= "" then
    file_path = file_path .. "." .. file_extension
  else
    file_path = file_path .. ".lua"
  end

  if string.find(file_path, "\\") then
    file_path = string.gsub(file_path, "\\", "/")
  end

  return file_path
end


-- Handle an IO operation with respect to safety, execution, and the results returned
local function handle_io(mod, local_path, file_name, file_extension, args, safe_call, execute, return_result)
  local file_path = get_file_path(local_path, file_name, file_extension)
  mod:debug("Loading " .. file_path)

  -- Check for the existence of the path
  local ff, err_io = _io.open(file_path, "r")
  if ff ~= nil then
    ff:close()

    -- Initialize variables
    local status, result

    -- If this is a safe call, wrap it in a pcall
    if safe_call then
      status, result = pcall(function ()
        local f = _io.open(file_path, "r")
        local data = f:read("*all")

        -- Either execute the data or return it unmodified
        local pcall_result
        if execute then
          local func = loadstring(data)
          pcall_result = func(args)
        else
          pcall_result = data
        end

        f:close()
        if return_result then
          return pcall_result
        else
          return true
        end
      end)

      -- If status is failed, notify the user and return false
      if not status then
        mod:error("Error processing '" .. file_path .. "': " .. tostring(result))
        return false
      end

    -- If this isn't a safe call, load without a pcall
    else
      local f = _io.open(file_path, "r")
      local data = f:read("*all")

      -- Either execute the data or return it unmodified
      if execute then
        local func = loadstring(data)
        result = func(args)
      else
        result = data
      end

      f:close()
    end

    -- Return data if configured
    if return_result then
      return result

    -- Otherwise return success
    else
      return true
    end

  -- If the initial open failed, report failure
  else
    mod:error("Error opening '" .. file_path .. "': " .. tostring(err_io))
    return false
  end
end


-- Return whether the file exists at the given path
local function file_exists(local_path, file_name, file_extension)
  local file_path = get_file_path(local_path, file_name, file_extension)
  local f = io.open(file_path,"r")

  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- #####################################################################################################################
-- ##### DMFMod ########################################################################################################
-- #####################################################################################################################

-- Use the io library to execute the given file safely, without return
function DMFMod:io_exec(local_path, file_name, file_extension, args)
  return handle_io(self, local_path, file_name, file_extension, args, true, true, false)
end


-- Use the io library to execute the given file without return
function DMFMod:io_exec_unsafe(local_path, file_name, file_extension, args)
  return handle_io(self, local_path, file_name, file_extension, args, false, true, false)
end


-- Use the io library to execute the given file and return the result
function DMFMod:io_exec_with_return(local_path, file_name, file_extension, args)
  return handle_io(self, local_path, file_name, file_extension, args, true, true, true)
end


-- Use the io library to execute the given file unsafely and return the result
function DMFMod:io_exec_unsafe_with_return(local_path, file_name, file_extension, args)
  return handle_io(self, local_path, file_name, file_extension, args, false, true, true)
end


-- Use the io library to execute the given file and return the result,
-- but treat the first parameter as the entire path to the file, and assume .lua.
-- IO version of the dofile method.
function DMFMod:io_dofile(file_path)
  return handle_io(self, file_path, nil, nil, nil, true, true, true)
end


-- Use the io library to execute the given file unsafely and return the result,
-- but treat the first parameter as the entire path to the file, and assume .lua.
-- IO version of the dofile method.
function DMFMod:io_dofile_unsafe(file_path)
  return handle_io(self, file_path, nil, nil, nil, false, true, true)
end


-- Use the io library to return the contents of the given file without execution
function DMFMod:io_read_content(file_path, file_extension)
  return handle_io(self, file_path, nil, file_extension, nil, true, false, true)
end

-- #####################################################################################################################
-- ##### Hooks #########################################################################################################
-- #####################################################################################################################

-- #####################################################################################################################
-- ##### DMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- #####################################################################################################################
-- ##### Script ########################################################################################################
-- #####################################################################################################################