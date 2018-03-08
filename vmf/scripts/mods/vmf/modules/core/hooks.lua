local vmf = get_mod("VMF")

HOOKED_FUNCTIONS = {} -- global, because 'loadstring' doesn't see local variables

if type(DELAYED_HOOKING_ENABLED) == "boolean" then
  DELAYED_HOOKING_ENABLED = DELAYED_HOOKING_ENABLED
else
  DELAYED_HOOKING_ENABLED = true
end

local _DELAYED_HOOKS = {} -- _DELAYED_HOOKS[hook_name] = {{mod_name, hooked_function},{}}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function check_function_name(mod, hook_function_name, hooked_function_name)
  if type(hooked_function_name) ~= "string" then
    mod:error("(%s): hooked function argument should be the string, not %s", hook_function_name, type(hooked_function_name))
    return false
  end

  return true
end


local function get_function_by_name(function_name)

  local _, value = pcall(loadstring("return " .. function_name))
  -- no need to check status of 'pcall' - if there will be error, it's gonna be string instead of function
  -- also, it can be anything else instead of function, even if 'loadstring' run will be successful, so check it
  if type(value) == "function" then
    return value
  else
    return nil
  end
end


local function create_hooked_function_entry(hooked_function_name)

  local hooked_function = get_function_by_name(hooked_function_name)
  if not hooked_function then
    return nil
  end

  local hooked_function_entry = {}

  hooked_function_entry.name              = hooked_function_name
  hooked_function_entry.original_function = hooked_function
  hooked_function_entry.exec_function     = hooked_function
  hooked_function_entry.hooks             = {}

  table.insert(HOOKED_FUNCTIONS, hooked_function_entry)

  return hooked_function_entry
end


local function create_hook_entry(mod, hooked_function_entry, hook_function)

  local hook_entry = {}

  hook_entry.mod           = mod
  hook_entry.hook_function = hook_function
  hook_entry.exec_function = nil
  hook_entry.is_enabled    = true

  table.insert(hooked_function_entry.hooks, hook_entry)

  --return hook_entry -- @TODO: do I need this return?
end


-- Pick already existing function entry if it's already being hooked by some mod
local function get_hooked_function_entry(hooked_function_name)

  for i, hooked_function_entry in ipairs(HOOKED_FUNCTIONS) do
    if hooked_function_entry.name == hooked_function_name then
      return hooked_function_entry, i
    end
  end

  return nil
end


-- Pick already existing hook entry if there is one
local function get_hook_entry(mod, hooked_function_entry)

  for i, hook_entry in ipairs(hooked_function_entry.hooks) do
    if hook_entry.mod == mod then
      return hook_entry, i
    end
  end

  return nil
end


local function update_function_hook_chain(hooked_function_name)

  local hooked_function_entry, hooked_function_entry_index = get_hooked_function_entry(hooked_function_name)

  for i, hook_entry in ipairs(hooked_function_entry.hooks) do
    if i == 1 then
      if hook_entry.is_enabled then
        hook_entry.exec_function = function(...)
          return hook_entry.hook_function(hooked_function_entry.original_function, ...)
        end
      else
        hook_entry.exec_function = hooked_function_entry.original_function
      end
    else
      if hook_entry.is_enabled then
        hook_entry.exec_function = function(...)
          return hook_entry.hook_function(hooked_function_entry.hooks[i - 1].exec_function, ...)
        end
      else
        hook_entry.exec_function = hooked_function_entry.hooks[i - 1].exec_function
      end
    end
  end

  if #hooked_function_entry.hooks > 0 then
    hooked_function_entry.exec_function = hooked_function_entry.hooks[#hooked_function_entry.hooks].exec_function
  else
    hooked_function_entry.exec_function = hooked_function_entry.original_function
  end

  assert(loadstring(hooked_function_name .. " = HOOKED_FUNCTIONS[" .. hooked_function_entry_index .. "].exec_function"))()
end


local function modify_hook(mod, hooked_function_name, action)

  if not get_function_by_name(hooked_function_name) then
    mod:error("(hook_%s): function [%s] doesn't exist", action, hooked_function_name)
    return
  end

  local hooked_function_entry, hooked_function_entry_index = get_hooked_function_entry(hooked_function_name)
  if not hooked_function_entry then
    return
  end

  local hook_entry, hook_entry_index = get_hook_entry(mod, hooked_function_entry)

  if hook_entry then
    if action == "remove" then
      table.remove(hooked_function_entry.hooks, hook_entry_index)
    elseif action == "enable" then
      hook_entry.is_enabled = true
    elseif action == "disable" then
      hook_entry.is_enabled = false
    end

    update_function_hook_chain(hooked_function_name)
  end

  if #hooked_function_entry.hooks == 0 then
    table.remove(HOOKED_FUNCTIONS, hooked_function_entry_index)
  end

end


local function modify_all_hooks(mod, action)

  local no_hooks_functions_indexes = {}

  for i, hooked_function_entry in ipairs(HOOKED_FUNCTIONS) do
    for j, hook_entry in ipairs(hooked_function_entry.hooks) do
      if hook_entry.mod == mod then

        if action == "remove" then
          table.remove(hooked_function_entry.hooks, j)
        elseif action == "enable" then
          hook_entry.is_enabled = true
        elseif action == "disable" then
          hook_entry.is_enabled = false
        end

        update_function_hook_chain(hooked_function_entry.name)
        break

      end
    end

    -- can't delete functions entries right away
    -- because next function entry will be skiped by 'for'
    -- so it have to be done later
    if #hooked_function_entry.hooks == 0 then
      table.insert(no_hooks_functions_indexes, 1, i)
    end
  end

  for _, no_hooks_function_index in ipairs(no_hooks_functions_indexes) do
    table.remove(HOOKED_FUNCTIONS, no_hooks_function_index)
  end
end


-- DELAYED HOOKING


local function add_delayed_hook(mod, hooked_function_name, hook_function)

  if _DELAYED_HOOKS[hooked_function_name] then

    for _, hook_info in ipairs(_DELAYED_HOOKS[hooked_function_name]) do

      if hook_info[1] == mod then
        hook_info[2] = hook_function
        return
      end
    end
  else

    _DELAYED_HOOKS[hooked_function_name] = _DELAYED_HOOKS[hooked_function_name] or {}
  end

  table.insert(_DELAYED_HOOKS[hooked_function_name], {mod, hook_function})
end


local function delayed_hook(hooked_function_name)

  local hooked_function_entry = create_hooked_function_entry(hooked_function_name)
  if not hooked_function_entry then
    return
  end

  for _, hook_info in ipairs(_DELAYED_HOOKS[hooked_function_name]) do

    create_hook_entry(hook_info[1], hooked_function_entry, hook_info[2])
  end

  update_function_hook_chain(hooked_function_name)

  _DELAYED_HOOKS[hooked_function_name] = nil
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.hook = function (self, hooked_function_name, hook_function)

  if not check_function_name(self, "hook", hooked_function_name) then
    return
  end

  local hooked_function_entry = get_hooked_function_entry(hooked_function_name) or create_hooked_function_entry(hooked_function_name)
  if not hooked_function_entry then

    if DELAYED_HOOKING_ENABLED then
      add_delayed_hook(self, hooked_function_name, hook_function)
    else
      self:error("(hook): function [%s] doesn't exist", hooked_function_name)
    end

    return
  end

  if DELAYED_HOOKING_ENABLED and _DELAYED_HOOKS[hooked_function_name] then
    add_delayed_hook(self, hooked_function_name, hook_function)
    delayed_hook(hooked_function_name)
    return
  end

  local hook_entry = get_hook_entry(self, hooked_function_entry)

  -- overwrite existing hook
  if hook_entry then
    hook_entry.hook_function = hook_function
    hook_entry.is_enabled    = true
  -- create the new one
  else
    create_hook_entry(self, hooked_function_entry, hook_function)
  end

  update_function_hook_chain(hooked_function_name)
end


VMFMod.hook_remove = function (self, hooked_function_name)

  if not check_function_name(self, "hook_remove", hooked_function_name) then
    return
  end

  modify_hook(self, hooked_function_name, "remove")
end


VMFMod.hook_disable = function (self, hooked_function_name)

  if not check_function_name(self, "hook_disable", hooked_function_name) then
    return
  end

  modify_hook(self, hooked_function_name, "disable")
end


VMFMod.hook_enable = function (self, hooked_function_name)

  if not check_function_name(self, "hook_enable", hooked_function_name) then
    return
  end

  modify_hook(self, hooked_function_name, "enable")
end


VMFMod.remove_all_hooks = function (self)
  modify_all_hooks(self, "remove")
end


VMFMod.disable_all_hooks = function (self)
  modify_all_hooks(self, "disable")
end


VMFMod.enable_all_hooks = function (self)
  modify_all_hooks(self, "enable")
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- removes all hooks when VMF is about to be reloaded
vmf.hooks_unload = function()
  for _, hooked_function_entry in ipairs(HOOKED_FUNCTIONS) do
    hooked_function_entry.hooks = {}
    update_function_hook_chain(hooked_function_entry.name)
  end

  HOOKED_FUNCTIONS = {}
end

vmf.apply_delayed_hooks = function()

  if DELAYED_HOOKING_ENABLED then

    -- if chat is initialized, the game is fully loaded
    if Managers.chat and Managers.chat:has_channel(1) then

      DELAYED_HOOKING_ENABLED = false
      for hooked_function_name, hooks in pairs(_DELAYED_HOOKS) do
        for _, hook_info in ipairs(hooks) do
          hook_info[1]:hook(hooked_function_name, hook_info[2]) -- mod:hook(hooked_function_name, hook_function)
        end
        _DELAYED_HOOKS[hooked_function_name] = nil
      end

    else

      for hooked_function_name, _ in pairs(_DELAYED_HOOKS) do
        delayed_hook(hooked_function_name)
      end

    end
  end
end