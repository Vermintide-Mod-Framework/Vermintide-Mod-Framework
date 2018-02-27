local vmf = get_mod("VMF")

local _RPC_CALLBACKS = {}

local _LOCAL_MODS_MAP = {}
local _LOCAL_RPCS_MAP = {}

local _SHARED_MODS_MAP = {}
local _SHARED_RPCS_MAP = {}

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

vmf.create_network_dictionary = function()

  local i = 0
  for mod_name, mod_rpcs in pairs(_RPC_CALLBACKS) do

    i = i + 1

    _SHARED_MODS_MAP[mod_name] = i
    _LOCAL_MODS_MAP[i] = mod_name

    _SHARED_RPCS_MAP[mod_name] = {}
    _LOCAL_RPCS_MAP[i] = {}

    local j = 0
    for rpc_name, _ in pairs(mod_rpcs) do

      j = j + 1

      _SHARED_RPCS_MAP[mod_name][rpc_name] = j
      _LOCAL_RPCS_MAP[i][j] = rpc_name
    end
  end

  _SHARED_MODS_MAP = cjson.encode(_SHARED_MODS_MAP)
  _SHARED_RPCS_MAP = cjson.encode(_SHARED_RPCS_MAP)
end
