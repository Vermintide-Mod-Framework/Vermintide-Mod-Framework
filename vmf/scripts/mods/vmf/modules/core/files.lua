local vmf = get_mod("VMF")

local _cloud_enabled = Cloud.enabled()
local _loading_tokens = {}


local function get_save_system(cloud)
  if cloud and _cloud_enabled then
    return Cloud
  else
    return SaveSystem
  end
end


-- #####################################################################################################################
-- ##### VMFMod ########################################################################################################
-- #####################################################################################################################

--[[
  Saves data to a file on the local system.
  * filename [string]  : file name
  * data     [any]     : data to save
  * cloud    [boolean] : (optional) synchronize file to Steam cloud
  * callback [function]: (optional) function to execute when the operation finished
--]]
function VMFMod:save_file(filename, data, cloud, callback)
  if vmf.check_wrong_argument_type(self, "load_package", "filename", filename, "string") or
     vmf.check_wrong_argument_type(
       self, "load_package", "data", data, "number", "boolean", "string", "table", "userdata"
     ) or
     vmf.check_wrong_argument_type(self, "load_package", "cloud", cloud, "boolean", "nil") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil")
  then
    return
  end

  if cloud and not _cloud_enabled then
    self:warning("Cloud storage is disabled. Treating '%s' as local file instead", filename)
  end

  table.insert(_loading_tokens, {
    callback = callback,
    cloud = cloud,
    token = get_save_system(cloud).auto_save(filename, data),
  })
end


--[[
  Loads data from a saved file.
  * filename [string]  : file name
  * cloud    [boolean] : (optional) synchronize file to Steam cloud
  * callback [function]: (optional) function to execute when the operation finished
--]]
function VMFMod:load_file(filename, cloud, callback)
  if vmf.check_wrong_argument_type(self, "load_package", "filename", filename, "string") or
     vmf.check_wrong_argument_type(self, "load_package", "cloud", cloud, "boolean", "nil") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function")
  then
    return
  end

  if cloud and not _cloud_enabled then
    self:warning("Cloud storage is disabled. Treating '%s' as local file instead", filename)
  end

  table.insert(_loading_tokens, {
    callback = callback,
    cloud = cloud,
    token = get_save_system(cloud).auto_load(filename),
  })
end


--[[
  Deletes a file. This should be used when a user explicitely requested to delete a file.

  This operation only works for files saved to Steam cloud.
  * filename [string]  : file name
  * callback [function]: (optional) function to execute when the operation finished
--]]
function VMFMod:delete_file(filename, callback)
  if vmf.check_wrong_argument_type(self, "load_package", "filename", filename, "string") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil")
  then
    return
  end

  if not _cloud_enabled then
    self:error("Cloud storage is disabled. Can't delete local files", filename)
    return
  end

  table.insert(_loading_tokens, {
    callback = callback,
    cloud = true,
    token = Cloud.delete(filename),
  })
end


--[[
  Mark for a file for deletion. The file will be deleted when the game exits.
  This should be used when a file is to be deleted through an automatic process.

  This operation only works for files saved to Steam cloud.
  * filename [string]  : file name
  * callback [function]: (optional) function to execute when the operation finished
--]]
function VMFMod:forget_file(filename, callback)
  if vmf.check_wrong_argument_type(self, "load_package", "filename", filename, "string") or
     vmf.check_wrong_argument_type(self, "load_package", "callback", callback, "function", "nil")
  then
    return
  end

  if not _cloud_enabled then
    self:error("Cloud storage is disabled. Can't delete local files", filename)
    return
  end

  table.insert(_loading_tokens, {
    callback = callback,
    cloud = true,
    token = Cloud.forget(filename),
  })
end


-- #####################################################################################################################
-- ##### VMF internal functions and variables ##########################################################################
-- #####################################################################################################################

-- Checks the list of laoading file tokens and calls their callbacks on success or error
function vmf.update_file_manager()
  for index, loading_token in pairs(_loading_tokens) do
    local save_system = get_save_system(loading_token.cloud)
    --[[
      `progress` can be:

      ```
      {
        done: boolean,
        error: string | nil,
        data: any,
      }
      ```

      Possible error codes:
      - "non_existing_file"
      - "delete_failed"
    --]]
    local progress = save_system.progress(loading_token.token)

    if progress.done then
      if loading_token.callback then
        if progress.error then
          loading_token.callback(progress.error)
        else
          loading_token.callback(nil, progress.data)
        end
      end

      save_system.close(loading_token.token)
      _loading_tokens[index] = nil
    end
  end
end