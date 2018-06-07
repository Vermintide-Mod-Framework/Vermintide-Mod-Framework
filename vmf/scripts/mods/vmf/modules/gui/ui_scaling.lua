-- If enabled, scale UI for resolutions greater than 1080p when necessary.
-- Reports to a global when active, so that existing scaling can be disabled.
local vmf = get_mod("VMF")

local _ui_scaling_enabled

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("UIResolutionScale", function (func, ...)

  local width, height = UIResolution()

  if (width > UIResolutionWidthFragments() and height > UIResolutionHeightFragments() and _ui_scaling_enabled) then

    local max_scaling_factor = 4

    -- Changed to allow scaling up to quadruple the original max scale (1 -> 4)
    local width_scale = math.min(width / UIResolutionWidthFragments(), max_scaling_factor)
    local height_scale = math.min(height / UIResolutionHeightFragments(), max_scaling_factor)

    return math.min(width_scale, height_scale)
  else
    return func(...)
  end
end)

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.load_ui_scaling_settings = function ()
  _ui_scaling_enabled = vmf:get("ui_scaling")
  if _ui_scaling_enabled then
    RESOLUTION_LOOKUP.ui_scaling = true
  else
    RESOLUTION_LOOKUP.ui_scaling = false
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf.load_ui_scaling_settings()