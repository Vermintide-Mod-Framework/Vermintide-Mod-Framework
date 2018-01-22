Mods={}
--[[
  Mods Hook v2:
    New version with better control
--]]

-- Hook structure
if not MODS_HOOKS then
  MODS_HOOKS = {}
end

local item_template = {
  name = "",
  func = EMPTY_FUNC,
  hooks = {},
}

local item_hook_template = {
  name = "",
  func = EMPTY_FUNC,
  enable = false,
  exec = EMPTY_FUNC,
}

Mods.hook = {
  --
  -- Set hook
  --
  set = function(mod_name, func_name, hook_func)
    local item = Mods.hook._get_item(func_name)
    local item_hook = Mods.hook._get_item_hook(item, mod_name)

    item_hook.enable = true
    item_hook.func = hook_func

    Mods.hook._patch()
  end,

  --
  -- Enable/Disable hook
  --
  enable = function(value, mod_name, func_name)
    for _, item in ipairs(MODS_HOOKS) do
      if item.name == func_name or func_name == nil then
        for _, hook in ipairs(item.hooks) do
          if hook.name == mod_name then
            hook.enable = value
            Mods.hook._patch()
          end
        end
      end
    end

    return
  end,

  ["remove"] = function(func_name, mod_name)
    for i, item in ipairs(MODS_HOOKS) do
      if item.name == func_name then
        if mod_name ~= nil then
          for j, hook in ipairs(item.hooks) do
            if hook.name == mod_name then
              table.remove(item.hooks, j)

              Mods.hook._patch()
            end
          end
        else
          local item_name = "MODS_HOOKS[" .. tostring(i) .. "]"

          -- Restore orginal function
          assert(loadstring(item.name .. " = " .. item_name .. ".func"))()

          -- Remove hook function
          table.remove(MODS_HOOKS, i)

          return
        end
      end
    end

    return
  end,

  front = function(mod_name, func_name)
    for _, item in ipairs(MODS_HOOKS) do
      if item.name == func_name or func_name == nil then
        for i, hook in ipairs(item.hooks) do
          if hook.name == mod_name then
            local saved_hook = table.clone(hook)
            table.remove(item.hooks, i)
            table.insert(item.hooks, saved_hook)

            Mods.hook._patch()
          end
        end
      end
    end

    return
  end,

  back = function(mod_name, func_name)
    for _, item in ipairs(MODS_HOOKS) do
      if item.name == func_name or func_name == nil then
        local saved_hook = nil
        local saved_index = nil
        for i, hook in ipairs(item.hooks) do
          if hook.name == mod_name then
            saved_hook = table.clone(hook)
            saved_index = i
            break
          end
        end
        if saved_hook then
          table.remove(item.hooks, saved_index)
          table.insert(item.hooks, 1, saved_hook)
          Mods.hook._patch()
        end
      end
    end

    return
  end,

  --
  -- Get function by function name
  --
  _get_func = function(func_name)
    return assert(loadstring("return " .. func_name))()
  end,

  --
  -- Get item by function name
  --
  _get_item = function(func_name)
    -- Find existing item
    for _, item in ipairs(MODS_HOOKS) do
      if item.name == func_name then
        return item
      end
    end

    -- Create new item
    local item = table.clone(item_template)
    item.name = func_name
    item.func = Mods.hook._get_func(func_name)

    -- Save
    table.insert(MODS_HOOKS, item)

    return item
  end,

  --
  -- Get item hook by mod name
  --
  _get_item_hook = function(item, mod_name)
    -- Find existing item
    for _, hook in ipairs(item.hooks) do
      if hook.name == mod_name then
        return hook
      end
    end

    -- Create new item
    local item_hook = table.clone(item_hook_template)
    item_hook.name = mod_name

    -- Save
    table.insert(item.hooks, 1, item_hook) -- @MINE: why he's inserting it at the beginning?

    return item_hook
  end,

  --
  -- If settings are changed the hook itself needs to be updated
  --
  _patch = function(mods_hook_item)
    for i, item in ipairs(MODS_HOOKS) do
      local item_name = "MODS_HOOKS[" .. i .. "]"

      local last_j = 1
      for j, hook in ipairs(item.hooks) do
        local hook_name = item_name .. ".hooks[" .. j .. "]"
        local before_hook_name = item_name .. ".hooks[" .. (j - 1) .. "]"

        if j == 1 then
          if hook.enable then
            assert(
              loadstring(
                hook_name .. ".exec = function(...)" ..
                " return " .. hook_name .. ".func(" .. item_name .. ".func, ...)" ..
                "end"
              )
            )()
          else
            assert(
              loadstring(
                hook_name .. ".exec = function(...)" ..
                " return " .. item_name .. ".func(...)" ..
                "end"
              )
            )()
          end
        else
          if hook.enable then
            assert(
              loadstring(
                hook_name .. ".exec = function(...)" ..
                " return " .. hook_name .. ".func(" .. before_hook_name .. ".exec, ...)" ..
                "end"
              )
            )()
          else
            assert(
              loadstring(
                hook_name .. ".exec = function(...)" ..
                " return " .. before_hook_name .. ".exec(...)" ..
                "end"
              )
            )()
          end
        end

        last_j = j
      end

      -- Patch orginal function call
      assert(loadstring(item.name .. " = " .. item_name .. ".hooks[" .. last_j .. "].exec"))()
    end
  end,
}

-- ####################################################################################################################
-- ##### CONSOLE ######################################################################################################
-- ####################################################################################################################

if not CONSOLE_ENABLED then
  CONSOLE_ENABLED = false
end

local console_is_active = true
Mods.hook.set("DevConsole", "print", function(func, ...)
  if console_is_active then
    CommandWindow.print(...)
    func(...)
  else
    func(...)
  end
end)

if CONSOLE_ENABLED == false then
  CommandWindow.open("Development command window")
  CONSOLE_ENABLED = true
end