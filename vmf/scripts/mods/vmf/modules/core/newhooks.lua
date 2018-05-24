local vmf = get_mod("VMF")

-- Private members
local HookMixin = {}

local HOOK_TYPE_BEFORE = 1
local HOOK_TYPE_AFTER  = 2
local HOOK_TYPE_NORMAL = 3
local HOOK_TYPE_RAW = 4
local HOOK_ERR_NAME = { "before-hook", "after-hook", "hook", "rawhook", }

--[[ Planned registry structure:
  _registry[self][hook_type] = {
      active[orig] = true,
      handler[orig] = func,
  }
  _registry.hooks[hook_type]
  _registry.origs
]]

-- This metatable will automatically create a table entry if one doesnt exist.
local auto_table_meta = {__index = function(t, k) t[k] = {} return t[k] end }

-- This lets us easily do _registry[self] without having to worry about nil-checking it.
local _registry = setmetatable({}, auto_table_meta)
-- This table will hold all of the hooks, in the format of _registry.hooks[hook_type]
_registry.hooks = {
    -- Do the same thing with these tables to allow .hooks[hook_type][orig] without a ton of nil-checks.
    setmetatable({}, auto_table_meta), -- before
    setmetatable({}, auto_table_meta), -- after
    setmetatable({}, auto_table_meta), -- normal
    -- Since there can only be one rawhook per function, it doesnt need to generate a table.
    {}, -- raw
}
_registry.origs = {}

-- ####################################################################################################################
-- ##### Util functions ###############################################################################################
-- ####################################################################################################################

local function is_orig_hooked(obj, method)
    if obj and _registry.origs[obj] and _registry.origs[obj][method] then
        return true
    elseif _registry.origs[method] then
        return true
    end
    return false
end

local function is_existing_hook(self, orig, hook_type)
    if _registry[self][hook_type] and
       _registry[self][hook_type].handler and
       _registry[self][hook_type].handler[orig] then
        return true
    end
end

-- ####################################################################################################################
-- ##### Hook Creation ################################################################################################
-- ####################################################################################################################

-- For any given original function, return the newest entry of the hook_chain.
-- Since all hooks of the chain contains the call to the previous one, we don't need to do any manual loops.
-- This continues until the end of the chain, where the original function is called.
local function get_hook_chain(orig)
    local hooks = _registry.hooks[HOOK_TYPE_NORMAL][orig]
    if hooks and #hooks > 0 then
        return hooks[#hooks]
    end
    -- We can't simply return orig here, or it would cause rawhooks to depend on load order.
    return function(...)
        if _registry.hooks[HOOK_TYPE_RAW][orig] then
            return _registry.hooks[HOOK_TYPE_RAW][orig](...)
        else
            return orig(...)
        end
    end
end

-- Returns a function closure with all the information needed for a given hook to be handled correctly.
local function create_specialized_hook(self, orig, handler, hook_type)
    local func
    local active = _registry[self][hook_type].active
    if hook_type == HOOK_TYPE_NORMAL then
        -- Determine the previous function in the hook stack
        local previous_hook = get_hook_chain(orig)
        -- Note: If a previous hook is removed from the table, this function wouldnt be updated
        -- This would break the chain, solution would be not to remove the hook, but make it inactive
        -- Make sure inactive hooks just seamlessly call the next function on the list without disruption.
        func = function(...)
            if active[orig] then
                return handler(previous_hook, ...)
            else
                return previous_hook(...)
            end
        end
    -- Need to make sure a disabled Rawhook will correctly call the original.
    elseif hook_type == HOOK_TYPE_RAW then
        func = function(...)
            if active[orig] then
                return handler(...)
            else
                return orig(...)
            end
        end
    else
        func = function(...)
            if active[orig] then
                return handler(...)
            end
        end
    end
    return func
end

-- TODO: Check to see if before-hooks are slower with or without 1 rawhook.
-- The hook system makes internal functions that replace the original function and handles all the hooks.
local function create_internal_hook(orig, obj, method)
    local fn = function(...)
        local before_hooks = _registry.hooks[HOOK_TYPE_BEFORE][orig]
        local after_hooks = _registry.hooks[HOOK_TYPE_AFTER][orig]
        if before_hooks and #before_hooks > 0 then
            for i = 1, #before_hooks do before_hooks[i](...) end
        end
        -- Execute the hook chain. Note that we need to keep the return values
        -- in case another function depends on them.
        local hook_chain = get_hook_chain(orig)
        -- We need to keep return values in case another function depends on them
        local values = { hook_chain(...) }
        if after_hooks and #after_hooks > 0 then
            for i = 1, #after_hooks do after_hooks[i](...) end
        end
        --print(#values)
        return unpack(values)
    end

    if obj then
        -- object cannot be a string at this point, so we don't need to check for that.
        if not _registry.origs[obj] then _registry.origs[obj] = {} end
        _registry.origs[obj][method] = orig
        obj[method] = fn
    else
        _registry.origs[method] = orig
        _G[method] = fn
    end
end

local function create_hook(self, orig, obj, method, handler, hook_type)
    local err_name = HOOK_ERR_NAME[hook_type]
    if type(handler) ~= "function" then
        self:error("(%s): 'handler' - function expected, got %s", err_name, type(handler))
        return
    end

    if type(obj) == "string" then
        if not _G[obj] then
            return
        end
        obj = _G[obj]
    end

    if not is_orig_hooked(obj, method) then
        create_internal_hook(orig, obj, method)
    end

    -- Check to make sure it wasn't hooked before
    if not is_existing_hook(self, orig, hook_type) then
        -- Also set up related info accessible to the hook object under self.
        if not _registry[self][hook_type] then

            _registry[self][hook_type] = {
                active = {},
                handler = {},
            }
        end
        _registry[self][hook_type].active[orig] = true
        _registry[self][hook_type].handler[orig] = handler
        -- Add to the hook to registry. Raw hooks are unique, so we check for that too.
        if hook_type == HOOK_TYPE_RAW then
            if _registry.hooks[hook_type][orig] then
                self:error("(%s): Attempting to rawhook already hooked function %s", err_name, method)
            else
                _registry.hooks[hook_type][orig] = create_specialized_hook(self, orig, handler, hook_type)
            end
        else
            table.insert(_registry.hooks[hook_type][orig], create_specialized_hook(self, orig, handler, hook_type))
        end
    else
        self:error("(%s): Attempting to rehook already active %s %s.", err_name, err_name, method)
    end

end

-- Since we replace the original function, we need to keep its reference around.
-- This will grab the cached reference if we hooked it before, otherwise return the function.
local function get_orig_function(self, obj, method)
    -- Validate types
    if obj and not (type(obj) == "table" or type(obj) == "string")  then
        self:error("(hook): 'object' - table or string expected, got %s", type(obj))
        return
    end
    if type(method) ~= "string" then
        self:error("(hook): 'method' - string expected, got %s", type(method))
        return
    end

    if obj then
        -- obj can be a string. We'll need to grab the actual object first.
        -- if we can't find object, we don't need to go any further.
        if type(obj) == "string" then
            if not _G[obj] then return end
            obj = _G[obj]
        end
        if is_orig_hooked(obj, method) then
            return _registry.origs[obj][method]
        else
            return obj[method]
        end
    else
        if is_orig_hooked(obj, method) then
            return _registry.origs[method]
        else
            return _G[method]
        end
    end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

-- NEW API
-- Based on discord discussion, this is a refined version of the api functions,
-- with better definitions for their roles. These functions will also return an object
-- for the modders to control the hooks that they define, should they decide to do it.

-- :before() provides a callback before a function is called. You have no control over the execution of the
--           original function, nor can you change its return values.
-- This type of hook is typically used if you need to know a function was called, but dont want to modify it.
-- These will always be executed before the hook chain.
-- Due to discussion, handler may not receive any arguments, but will see what the use cases are with them first.
function HookMixin:new_before(obj, method, handler)
    if type(method) == "function" then
        method, handler, obj = obj, method, nil
    end

    local orig = get_orig_function(self, obj, method)
    create_hook(self, orig, obj, method, handler, HOOK_TYPE_BEFORE)
end

-- :after() provides callback after a function is called. You have no control over the execution of the
--          original function, nor can you change its return values.
-- These will always be executed after the hook chain.
-- This is similar to :front() functionality in V1 modding.
function HookMixin:new_after(obj, method, handler)
    if type(method) == "function" then
        method, handler, obj = obj, method, nil
    end

    local orig = get_orig_function(self, obj, method)
    create_hook(self, orig, obj, method, handler, HOOK_TYPE_AFTER)
end

-- :hook() will allow you to hook a function, allowing your handler to replace the function in the stack,
--         and control it's execution. All hooks on the same function will be part of a chain, with the
--         original function at the end. Your handler has to call the next function in the chain manually.
-- The chain of event is determined by mod load order.
function HookMixin:new_hook(obj, method, handler)
    if type(method) == "function" then
        method, handler, obj = obj, method, nil
    end

    local orig = get_orig_function(self, obj, method)
    create_hook(self, orig, obj, method, handler, HOOK_TYPE_NORMAL)
end

-- :rawhook() allows you to directly hook a function, replacing it. The original function will bever be called.
--            This hook will not be part of the hook chain proper, instead taking the place of the original function.
-- This is similar to :back functionality that was sparsely used in old V1 mods.
-- This there is a limit of a single rawhook for any given function.
-- This should only be used as a last resort due to its limitation and its potential to break the game if not careful.
function HookMixin:new_rawhook(obj, method, handler)
    if type(method) == "function" then
        method, handler, obj = obj, method, nil
    end

    local orig = get_orig_function(self, obj, method)
    create_hook(self, orig, obj, method, handler, HOOK_TYPE_RAW)
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- -- removes all hooks when VMF is about to be reloaded
-- vmf.hooks_unload = function()
-- end

-- put the hook mixin inside VMFMod
do
    for k, v in pairs(HookMixin) do
        VMFMod[k] = v
    end
end