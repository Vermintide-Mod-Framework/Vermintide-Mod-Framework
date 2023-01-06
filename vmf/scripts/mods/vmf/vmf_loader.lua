local vmf

-- Global variable indicating which version of the game is currently running
VT1 = false

-- Native mod object used by Fatshark mod manager
local vmf_mod_object = {}

-- Global method to load a file through iowith a return
local mod_dofile = Mods.file.dofile

-- #####################################################################################################################
-- ##### Initialization ################################################################################################
-- #####################################################################################################################

function vmf_mod_object:init()
  mod_dofile("dmf/scripts/mods/vmf/modules/vmf_mod_data")
  mod_dofile("dmf/scripts/mods/vmf/modules/vmf_mod_manager")
  --mod_dofile("dmf/scripts/mods/vmf/modules/vmf_dummy")
  mod_dofile("dmf/scripts/mods/vmf/modules/vmf_package_manager")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/safe_calls")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/events")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/settings")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/logging")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/misc")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/persistent_tables")
  mod_dofile("dmf/scripts/mods/vmf/modules/debug/dev_console")
  mod_dofile("dmf/scripts/mods/vmf/modules/debug/table_dump")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/hooks")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/require")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/toggling")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/keybindings")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/chat")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/localization")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/options")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/network")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/commands")
  mod_dofile("dmf/scripts/mods/vmf/modules/gui/custom_textures")
  mod_dofile("dmf/scripts/mods/vmf/modules/gui/custom_views")
  mod_dofile("dmf/scripts/mods/vmf/modules/ui/chat/chat_actions")
  mod_dofile("dmf/scripts/mods/vmf/modules/ui/options/mod_options")
  mod_dofile("dmf/scripts/mods/vmf/modules/vmf_options")
  mod_dofile("dmf/scripts/mods/vmf/modules/core/mutators/mutators_manager")

  vmf = get_mod("VMF")
  vmf.delayed_chat_messages_hook()
  vmf:hook(ModManager, "destroy", function(func, ...)
    vmf.mods_unload_event(true)
    func(...)
  end)
end

-- #####################################################################################################################
-- ##### Events ########################################################################################################
-- #####################################################################################################################

function vmf_mod_object:update(dt)
  vmf.update_package_manager()
  vmf.mods_update_event(dt)
  vmf.check_keybinds()
  vmf.execute_queued_chat_command()

  if not vmf.all_mods_were_loaded and Managers.mod._state == "done" then

    vmf.generate_keybinds()
    vmf.initialize_vmf_options_view()
    vmf.create_network_dictionary()
    vmf.ping_vmf_users()

    vmf.all_mods_loaded_event()

    vmf.all_mods_were_loaded = true
  end
end


function vmf_mod_object:on_unload()
  print("VMF:ON_UNLOAD()")
  vmf.save_chat_history()
  vmf.save_unsaved_settings_to_file()
  vmf.destroy_command_gui()
end


function vmf_mod_object:on_reload()
  print("VMF:ON_RELOAD()")
  vmf.mods_unload_event(false)
  vmf.remove_custom_views()
  vmf.unload_all_resource_packages()
  vmf.hooks_unload()
  vmf.reset_guis()
  vmf.destroy_command_gui()
end


function vmf_mod_object:on_game_state_changed(status, state)
  print("VMF:ON_GAME_STATE_CHANGED(), status: " .. tostring(status) .. ", state: " .. tostring(state))
  vmf.mods_game_state_changed_event(status, state)
  vmf.save_unsaved_settings_to_file()
  vmf.apply_delayed_hooks(status, state)
  vmf.destroy_command_gui()

  if status == "enter" and state == "StateIngame" then
    vmf.create_keybinds_input_service()
  end
end

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return vmf_mod_object
