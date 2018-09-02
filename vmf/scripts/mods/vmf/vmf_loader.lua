local vmf

-- Global variable indicating which version of the game is currently running
VT1 = not pcall(require, "PlayFab.json")

-- Native mod object used by Fatshark mod manager
local vmf_mod_object = {}

-- #####################################################################################################################
-- ##### Initialization ################################################################################################
-- #####################################################################################################################

function vmf_mod_object:init()
	dofile("scripts/mods/vmf/modules/vmf_mod_data")
	dofile("scripts/mods/vmf/modules/vmf_mod_manager")
	dofile("scripts/mods/vmf/modules/core/safe_calls")
	dofile("scripts/mods/vmf/modules/core/events")
	dofile("scripts/mods/vmf/modules/core/settings")
	dofile("scripts/mods/vmf/modules/core/logging")
	dofile("scripts/mods/vmf/modules/core/misc")
	dofile("scripts/mods/vmf/modules/core/persistent_tables")
	dofile("scripts/mods/vmf/modules/debug/dev_console")
	dofile("scripts/mods/vmf/modules/debug/table_dump")
	dofile("scripts/mods/vmf/modules/core/hooks")
	dofile("scripts/mods/vmf/modules/core/toggling")
	dofile("scripts/mods/vmf/modules/core/keybindings")
	dofile("scripts/mods/vmf/modules/core/chat")
	dofile("scripts/mods/vmf/modules/core/localization")
	dofile("scripts/mods/vmf/modules/core/network")
	dofile("scripts/mods/vmf/modules/core/commands")
	dofile("scripts/mods/vmf/modules/gui/custom_textures")
	dofile("scripts/mods/vmf/modules/gui/custom_menus")
	dofile("scripts/mods/vmf/modules/gui/ui_scaling")
	dofile("scripts/mods/vmf/modules/ui/chat/chat_actions")
	dofile("scripts/mods/vmf/modules/ui/options/vmf_options_view")
	dofile("scripts/mods/vmf/modules/vmf_options")

	if VT1 then
		dofile("scripts/mods/vmf/modules/core/mutators/mutators_manager")
		dofile("scripts/mods/vmf/modules/ui/mutators/mutators_gui")
	end

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
	vmf.mods_update_event(dt)
	vmf.check_pressed_keybinds()
	vmf.check_custom_menus_close_keybinds(dt)
	vmf.execute_queued_chat_command()
	if VT1 then vmf.check_mutators_state() end

	if not vmf.all_mods_were_loaded and Managers.mod._state == "done" then

		vmf.initialize_keybinds()
		vmf.initialize_vmf_options_view()
		vmf.create_network_dictionary()
		vmf.ping_vmf_users()

		if VT1 then vmf.modify_map_view() end
		if VT1 then vmf.mutators_delete_raw_config() end

		vmf.all_mods_loaded_event()

		vmf.all_mods_were_loaded = true
	end
end


function vmf_mod_object:on_unload()
	print("VMF:ON_UNLOAD()")
	vmf.save_chat_history()
	vmf.save_unsaved_settings_to_file()
end


function vmf_mod_object:on_reload()
	print("VMF:ON_RELOAD()")
	vmf.disable_mods_options_button()
	vmf.close_opened_custom_menus()
	if VT1 then vmf.reset_map_view() end
	vmf.delete_keybinds()
	vmf.mods_unload_event(false)
	vmf.hooks_unload()
	vmf.reset_guis()
end


function vmf_mod_object:on_game_state_changed(status, state)
	print("VMF:ON_GAME_STATE_CHANGED(), status: " .. tostring(status) .. ", state: " .. tostring(state))
	vmf.mods_game_state_changed_event(status, state)
	vmf.save_unsaved_settings_to_file()
	vmf.apply_delayed_hooks(status, state)

	if status == "enter" and state == "StateIngame" then
		vmf.initialize_keybinds()
	end
end

-- #####################################################################################################################
-- ##### Return ########################################################################################################
-- #####################################################################################################################

return vmf_mod_object