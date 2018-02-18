local vmf = get_mod("VMF")

-- If enabled, scale UI for resolutions greater than 1080p when necessary. Reports to a global when active, so that existing scaling can be disabled.
local ui_resolution = UIResolution
local ui_resolution_width_fragments = UIResolutionWidthFragments
local ui_resolution_height_fragments = UIResolutionHeightFragments
local math_min = math.min
local raw_set = rawset

vmf:hook("UIResolutionScale", function (func, ...)

  local w, h = ui_resolution()

  if (w > ui_resolution_width_fragments() and h > ui_resolution_height_fragments() and vmf:get("ui_scaling")) then

    local max_scaling_factor = 4

    local width_scale = math_min(w / ui_resolution_width_fragments(), max_scaling_factor) -- Changed to allow scaling up to quadruple the original max scale (1 -> 4)
    local height_scale = math_min(h / ui_resolution_height_fragments(), max_scaling_factor) -- Changed to allow scaling up to quadruple the original max scale (1 -> 4)

    raw_set(_G, "vmf_hd_ui_scaling_enabled", true)
    return math_min(width_scale, height_scale)
  else

    raw_set(_G, "vmf_hd_ui_scaling_enabled", false)
    return func(...)
  end
end)