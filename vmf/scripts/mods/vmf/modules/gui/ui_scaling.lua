-- If enabled, scale UI for resolutions greater than 1080p when necessary. Reports to a global when active, so that existing scaling can be disabled.
local vmf = get_mod("VMF")

local _UI_RESOLUTION = UIResolution
local _UI_RESOLUTION_WIDTH_FRAGMENTS = UIResolutionWidthFragments
local _UI_RESOLUTION_HEIGHT_FRAGMENTS = UIResolutionHeightFragments
local _MATH_MIN = math.min

local _UI_SCALING_ENABLED

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("UIResolutionScale", function (func, ...)

  local w, h = _UI_RESOLUTION()

  if (w > _UI_RESOLUTION_WIDTH_FRAGMENTS() and h > _UI_RESOLUTION_HEIGHT_FRAGMENTS() and _UI_SCALING_ENABLED) then

    local max_scaling_factor = 4

    local width_scale = _MATH_MIN(w / _UI_RESOLUTION_WIDTH_FRAGMENTS(), max_scaling_factor) -- Changed to allow scaling up to quadruple the original max scale (1 -> 4)
    local height_scale = _MATH_MIN(h / _UI_RESOLUTION_HEIGHT_FRAGMENTS(), max_scaling_factor) -- Changed to allow scaling up to quadruple the original max scale (1 -> 4)

    return _MATH_MIN(width_scale, height_scale)
  else
    return func(...)
  end
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_ui_scaling_settings = function ()
  _UI_SCALING_ENABLED = vmf:get("ui_scaling")
  if _UI_SCALING_ENABLED then
    RESOLUTION_LOOKUP.ui_scaling = true
  else
    RESOLUTION_LOOKUP.ui_scaling = false
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_ui_scaling_settings()