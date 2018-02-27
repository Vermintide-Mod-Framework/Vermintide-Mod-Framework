local vmf = get_mod("VMF")

local _RPC_CALLBACKS = {}

VMFMod.rpc_register = function (self, rpc_name, rpc_function)

  if type(rpc_name) ~= "string" then
    self:error("(rpc_register): rpc_name should be the string, not %s", type(rpc_name))
    return
  end

  if type(rpc_function) ~= "function" then
    self:error("(rpc_register): rpc_function should be the function, not %s", type(rpc_name))
    return
  end

  _RPC_CALLBACKS[self:get_name()] = _RPC_CALLBACKS[self:get_name()] or {}

  _RPC_CALLBACKS[self:get_name()][rpc_name] = rpc_function
end