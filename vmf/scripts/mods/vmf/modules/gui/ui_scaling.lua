local vmf = get_mod("VMF")

local _ui_scaling_enabled

-- ####################################################################################################################
-- ##### VMF internal functions and variables #########################################################################
-- ####################################################################################################################

vmf.check_if_ui_scaling_was_used_before = function()
  _ui_scaling_enabled = _ui_scaling_enabled or vmf:get("ui_scaling")
  if _ui_scaling_enabled then
    vmf:set("ui_scaling", nil)
    if UIResolutionScale() > 1 then
      vmf:warning("UI SCALING WAS STRIPPED FROM THE VMF AND HAS BEEN RELEASED AS A SEPARATE MOD. " ..
                   "YOU CAN FIND THE DOWNLOAD LINK IN THE VMF WORKSHOP DESCRIPTION. " ..
                   "This message will be shown to you only during this game session.")
    end
  end
end
