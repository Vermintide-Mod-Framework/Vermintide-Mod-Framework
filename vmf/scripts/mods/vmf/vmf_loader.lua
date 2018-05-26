VT1 = (type(script_data["eac-untrusted"]) == "nil")
--move vmf to local var
return {
	init = function(object)

		Managers.vmf = Managers.vmf or {}

		dofile("scripts/mods/vmf/modules/mods")
		dofile("scripts/mods/vmf/modules/core/events")
		dofile("scripts/mods/vmf/modules/core/settings")
		dofile("scripts/mods/vmf/modules/core/core_functions")
		dofile("scripts/mods/vmf/modules/core/initialization")
		dofile("scripts/mods/vmf/modules/core/persistent_tables")
		dofile("scripts/mods/vmf/modules/debug/dev_console")
		dofile("scripts/mods/vmf/modules/debug/table_dump")
		dofile("scripts/mods/vmf/modules/core/hooks")
		dofile("scripts/mods/vmf/modules/core/toggling")
		dofile("scripts/mods/vmf/modules/core/keybindings")
		dofile("scripts/mods/vmf/modules/core/delayed_chat_messages")
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



		object.vmf = get_mod("VMF")

		object.vmf:hook("ModManager.destroy", function(func, self)

			object.vmf.mods_unload_event(true)
			func(self)
		end)

		-- @TODO: temporary V2 fix for not working event
		--if not VT1 then Boot._machine._notify_mod_manager = true end

		-- temporary solution:
		local mod = new_mod("test_mod")
		mod:initialize("scripts/mods/vmf/modules/testing_stuff_here")
	end,

	update = function(object, dt)

		object.vmf.mods_update_event(dt)
		object.vmf.check_pressed_keybinds()
		object.vmf.check_custom_menus_close_keybinds(dt)
		object.vmf.execute_queued_chat_command()
		if VT1 then object.vmf.check_mutators_state() end

		if not object.vmf.all_mods_were_loaded and Managers.mod._state == "done" then

			object.vmf.initialize_keybinds()
			object.vmf.initialize_vmf_options_view()
			object.vmf.create_network_dictionary()
			object.vmf.ping_vmf_users()

			if VT1 then object.vmf.modify_map_view() end
			if VT1 then object.vmf.mutators_delete_raw_config() end

			object.vmf.all_mods_loaded_event()

			object.vmf.all_mods_were_loaded = true
		end
	end,

	on_unload = function(object)
		print("VMF:ON_UNLOAD()")
		object.vmf.reset_guis()
		object.vmf.save_chat_history()
		object.vmf.save_unsaved_settings_to_file()
		object.vmf = nil
	end,

	on_reload = function(object)
		print("VMF:ON_RELOAD()")
		object.vmf.disable_mods_options_button()
		object.vmf.close_opened_custom_menus()
		if VT1 then object.vmf.reset_map_view() end
		object.vmf.delete_keybinds()
		object.vmf.mods_unload_event()
		object.vmf.hooks_unload()
	end,

	on_game_state_changed = function(object, status, state)
		print("VMF:ON_GAME_STATE_CHANGED(), status: " .. tostring(status) .. ", state: " .. tostring(state))
		object.vmf.mods_game_state_changed_event(status, state)
		object.vmf.save_unsaved_settings_to_file()
		object.vmf.apply_delayed_hooks()

		--if status == "exit" and state == "StateTitleScreen" then
		--	object.vmf.hook_chat_manager()
		--end

		if status == "enter" and state == "StateIngame" then
			object.vmf.initialize_keybinds()
		end
	end
}
