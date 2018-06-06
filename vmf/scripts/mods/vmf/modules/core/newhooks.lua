local vmf = get_mod("VMF")

-- ####################################################################################################################
-- ##### Locals and Variables #########################################################################################
-- ####################################################################################################################

-- Constants for hook_type
local HOOK_TYPES = {
    hook = 1,
    before = 1,
    after = 2,
    rawhook = 3,
}

-- Upvalued constants to ease on table lookups when not needed
local HOOK_TYPE_NORMAL = HOOK_TYPES.hook
local HOOK_TYPE_BEFORE = HOOK_TYPES.before
local HOOK_TYPE_AFTER  = HOOK_TYPES.after
local HOOK_TYPE_RAW = HOOK_TYPES.rawhook

--[[ Planned registry structure:
  _registry[self][orig] = { active = true}
  _registry.hooks[hook_type]
  _registry.origs
]]

local _delayed = {} -- dont need to attach this to registry.

-- This metatable will automatically create a table entry if one doesnt exist.
local auto_table_meta = {__index = function(t, k) t[k] = {} return t[k] end }

-- This lets us easily do _registry[self] without having to worry about nil-checking it.
local _registry = setmetatable({}, auto_table_meta)
-- This table will hold all of the hooks, in the format of _registry.hooks[hook_type]
_registry.hooks = {
    -- Do the same thing with these tables to allow .hooks[hook_type][orig] without a ton of nil-checks.
    setmetatable({}, auto_table_meta), -- normal
    setmetatable({}, auto_table_meta), -- after
    -- Since there can only be one rawhook per function, it doesnt need to generate a table.
    {}, -- raw
}
_registry.origs = {}

-- ####################################################################################################################
-- ##### Util functions ###############################################################################################
-- ####################################################################################################################

local function is_orig_hooked(obj, method)
    local orig_registry = _registry.origs
    if obj and orig_registry[obj] and orig_registry[obj][method] then
        return true
    elseif orig_registry[method] then
        return true
    end
    return false
end

-- Since we replace the original function, we need to keep its reference around.
-- This will grab the cached reference if we hooked it before, otherwise return the function.
local function get_orig_function(self, obj, method)
    if obj then
        if is_orig_hooked(obj, method) then
            return _registry.origs[obj][method]
        else
            return obj[method]
        end
    else
        if is_orig_hooked(obj, method) then
            return _registry.origs[method]
        else
            return rawget(_G, method)
        end
    end
end

-- Return an object from the global table. Second return value is if it was sucessful.
local function get_object_from_string(obj)
    if type(obj) == "table" then
        return obj, true
    elseif type(obj) == "string" then
        local obj_table = rawget(_G, obj)
        if obj_table then
            return obj_table, true
        end
    end
    return obj, false
end

-- VT1 hooked everything using a "Obj.Method" string
-- Add backward compatibility for that format.
local function split_function_string(str)
    local find_position = string.find(str, "%.")
    local method, obj
    if find_position then
        method = string.sub(str, find_position + 1)
        obj = string.sub(str, 1, find_position - 1)
    else
        method = str
    end
    return method, obj
end

-- ####################################################################################################################
-- ##### Hook Creation ################################################################################################
-- ####################################################################################################################

-- For any given original function, return the newest entry of the hook_chain.
-- Since all hooks of the chain contains the call to the previous one, we don't need to do any manual loops.
-- This continues until the end of the chain, where the original function is called.
local function get_hook_chain(orig)
    local hook_registry = _registry.hooks
    local hooks = hook_registry[HOOK_TYPE_NORMAL][orig]
    if hooks and #hooks > 0 then
        return hooks[#hooks]
    end
    -- We can't simply return orig here, or it would cause rawhooks to depend on load order.
    return function(...)
        if hook_registry[HOOK_TYPE_RAW][orig] then
            return hook_registry[HOOK_TYPE_RAW][orig](...)
        else
            return orig(...)
        end
    end
end

-- Returns a function closure with all the information needed for a given hook to be handled correctly.
local function create_specialized_hook(self, orig, handler, hook_type)
    local func
    local hook_data = _registry[self][orig]

    -- Determine the previous function in the hook stack
    -- Note: If a previous hook is removed from the table, these functions wouldnt be updated
    -- This would break the chain, solution is to not remove the hooks, simply make them inactive
    -- Make sure inactive hooks that rely on the chain still call the next function seamlessly.
    local previous_hook = get_hook_chain(orig)
   
    if hook_type == HOOK_TYPE_NORMAL then
        func = function(...)
            if hook_data.active then
                return handler(previous_hook, ...)
            else
                return previous_hook(...)
            end
        end
    -- Rawhooks need to directly call the original function is inactive.
    elseif hook_type == HOOK_TYPE_RAW then
        func = function(...)
            if hook_data.active then
                return handler(...)
            else
                return orig(...)
            end
        end
    elseif hook_type == HOOK_TYPE_AFTER then
        func = function(...)
            if hook_data.active then
                return handler(...)
            end
        end
    else
        self:error("(create_specialized_hook): Invalid hook_type given. You should never this see.")
    end
    return func
end

-- TODO: Check to see if before-hooks are slower with or without 1 rawhook.
-- The hook system makes internal functions that replace the original function and handles all the hooks.
local function create_internal_hook(orig, obj, method)
    local fn = function(...)
        -- Execute the hook chain. Note that we need to keep the return values
        -- in case another function depends on them.
        local hook_chain = get_hook_chain(orig)
        -- We need to keep return values in case another function depends on them
        local values = { hook_chain(...) }
        local after_hooks = _registry.hooks[HOOK_TYPE_AFTER][orig]
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

local function create_hook(self, orig, obj, method, handler, func_name, hook_type)

    if not is_orig_hooked(obj, method) then
        create_internal_hook(orig, obj, method)
    end

    -- Check to make sure it wasn't hooked before
    if not _registry[self][orig] then
        _registry[self][orig] = { active = true }

        local hook_registry = _registry.hooks[hook_type]
        -- Add to the hook to registry. Raw hooks are unique, so we check for that too.
        if hook_type == HOOK_TYPE_RAW then
            if hook_registry[orig] then
                self:error("(%s): Attempting to rawhook already hooked function %s", func_name, method)
            else
                hook_registry[orig] = create_specialized_hook(self, orig, handler, hook_type)
            end
        else
            table.insert(hook_registry[orig], create_specialized_hook(self, orig, handler, hook_type))
        end
    else
        local hook_type_name = func_name
        if hook_type == HOOK_TYPE_BEFORE or hook_type == HOOK_TYPE_AFTER then
            hook_type_name = func_name.."-hook"
        end
        self:error("(%s): Attempting to rehook already active %s.", func_name, hook_type_name, method)
    end

end

-- ####################################################################################################################
-- ##### GENERIC API ##################################################################################################
-- ####################################################################################################################
-- Singular functions that works on a generic basis so the VMFMod API can be tailored for user simplicity.

-- Valid styles:

-- Giving a string pointing to a global object table and method string and hook function
--     self, string (obj), string (method), function (handler), hook_type(number)
-- Giving an object table and a method string and hook function
--     self, table (obj), string (method), function (handler), hook_type(number)
-- Giving a method string or a Obj.Method string (VT1 Style) and a hook function
--     self, string (method), function (handler), nil, hook_type(number)

local function generic_hook(self, obj, method, handler, func_name)
    if vmf.check_wrong_argument_type(self, func_name, "obj", obj, "string", "table") or
    vmf.check_wrong_argument_type(self, func_name, "method", method, "string", "function") or
    vmf.check_wrong_argument_type(self, func_name, "handler", handler, "function", "nil") then
        return
    end

    -- Adjust the arguments.
    if type(method) == "function" then
        handler = method
        method, obj = split_function_string(obj)
    end

    -- Get hook_type based on name
    local hook_type = HOOK_TYPES[func_name]

    -- Check if hook should be delayed.
    local obj, sucess = get_object_from_string(obj) --luacheck: ignore
    if not sucess then
        -- Call this func at a later time, using upvalues.
        vmf:info("(%s): [%s.%s] needs to be delayed.", func_name, obj, method)
        table.insert(_delayed, function()
            generic_hook(self, obj, method, handler, hook_type)
        end)
        return
    end

    -- obj can't be a string for these now.
    local orig = get_orig_function(self, obj, method)
    return create_hook(self, orig, obj, method, handler, func_name, hook_type)
end

local function generic_hook_toggle(self, obj, method, enabled_state)
    local func_name = (enabled_state) and "hook_enable" or "hook_disable"

    if vmf.check_wrong_argument_type(self, func_name, "obj", obj, "string", "table") or
    vmf.check_wrong_argument_type(self, func_name, "method", method, "string", "nil") then
        return
    end

    -- Adjust the arguments.
    if not method then
        method, obj = split_function_string(obj)
    end

    local obj, sucess = get_object_from_string(obj) --luacheck: ignore
    if not sucess then
        self:error("(%s): object doesn't exist.", func_name)
        return
    end

    local orig = get_orig_function(self, obj, method)

    if _registry[self][orig] then
        _registry[self][orig].active = enabled_state
    else
        self:warning("(%s): trying to toggle hook that doesn't exist: %s", func_name, method)
        return
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
function VMFMod:before(obj, method, handler)
    return generic_hook(self, obj, method, handler, "before")
end

-- :after() provides callback after a function is called. You have no control over the execution of the
--          original function, nor can you change its return values.
-- These will always be executed after the hook chain.
-- This is similar to :front() functionality in V1 modding.
function VMFMod:after(obj, method, handler)
    return generic_hook(self, obj, method, handler, "after")
end

-- :hook() will allow you to hook a function, allowing your handler to replace the function in the stack,
--         and control it's execution. All hooks on the same function will be part of a chain, with the
--         original function at the end. Your handler has to call the next function in the chain manually.
-- The chain of event is determined by mod load order.
function VMFMod:hook(obj, method, handler)
    return generic_hook(self, obj, method, handler, "hook")
end

-- :rawhook() allows you to directly hook a function, replacing it. The original function will bever be called.
--            This hook will not be part of the hook chain proper, instead taking the place of the original function.
-- This is similar to :back functionality that was sparsely used in old V1 mods.
-- This there is a limit of a single rawhook for any given function.
-- This should only be used as a last resort due to its limitation and its potential to break the game if not careful.
function VMFMod:rawhook(obj, method, handler)
    return generic_hook(self, obj, method, handler, "rawhook")
end
    
-- Enable/disable functions for all hook types:
function VMFMod:hook_enable(obj, method)  generic_hook_toggle(self, obj, method, true) end
function VMFMod:hook_disable(obj, method) generic_hook_toggle(self, obj, method, false) end

function VMFMod:enable_all_hooks()
    -- Using pairs because the self table may contain nils, and order isnt important.
    for _, hook in pairs(_registry[self]) do
        hook.active = true
    end
end

function VMFMod:disable_all_hooks()
    -- Using pairs because the self table may contain nils, and order isnt important.
    for _, hook in pairs(_registry[self]) do
        hook.active = false
    end
end

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

-- -- removes all hooks when VMF is about to be reloaded
vmf.hooks_unload = function()
    for key, value in pairs(_registry.origs) do
        -- origs[method] = orig
        if type(value) == "function" then
            _G[key] = value
        -- origs[obj][method] = orig
        elseif type(value) == "table" then
            for method, orig in pairs(value) do
                key[method] = orig
            end
        end
    end
end

vmf.apply_delayed_hooks = function()
    if #_delayed > 0 then
        -- Go through the table in reverse so we don't get any issues removing entries inside the loop
        for i = #_delayed, 1, -1 do
            _delayed[i]()
            table.remove(_delayed, i)
        end
    end
end