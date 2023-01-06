local vmf = get_mod("VMF")

-- Add vmf functions with a value of dummy_func if they need to be defined while a module is disabled.
local dummy_func = function() return end