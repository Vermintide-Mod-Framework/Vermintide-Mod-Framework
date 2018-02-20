return {
	init = function(object)

		dofile("scripts/mods/vmf/functions/table")

		dofile("scripts/mods/vmf/modules/mods")
		dofile("scripts/mods/vmf/modules/core/events")
		dofile("scripts/mods/vmf/modules/core/settings")
		dofile("scripts/mods/vmf/modules/core/core_functions")
		dofile("scripts/mods/vmf/modules/debug/dev_console")
		dofile("scripts/mods/vmf/modules/debug/table_dump")
		dofile("scripts/mods/vmf/modules/core/hooks")
		dofile("scripts/mods/vmf/modules/core/toggling")
		dofile("scripts/mods/vmf/modules/core/keybindings")
		dofile("scripts/mods/vmf/modules/core/delayed_chat_messages")
		dofile("scripts/mods/vmf/modules/core/chat")
		dofile("scripts/mods/vmf/modules/core/localization")
		dofile("scripts/mods/vmf/modules/gui/custom_textures")
		dofile("scripts/mods/vmf/modules/gui/custom_menus")
		dofile("scripts/mods/vmf/modules/gui/ui_scaling")
		dofile("scripts/mods/vmf/modules/options_menu/vmf_options_view")
		dofile("scripts/mods/vmf/modules/vmf_options")

		dofile("scripts/mods/vmf/modules/mod_gui/basic_gui")
		dofile("scripts/mods/vmf/modules/mod_gui/gui")

		dofile("scripts/mods/vmf/modules/mutators/mutators")

		object.vmf = get_mod("VMF")

		-- temporary solution:
		dofile("scripts/mods/vmf/modules/testing_stuff_here")
	end,

	update = function(object, dt)

		object.vmf.mods_update_event(dt)
		object.vmf.check_pressed_keybinds()
		object.vmf.check_custom_menus_close_keybinds(dt)

		if not object.vmf.all_mods_were_loaded and Managers.mod._state == "done" then

			object.vmf.initialize_keybinds()
			object.vmf.initialize_vmf_options_view()

			object.vmf.all_mods_were_loaded = true
		end
	end,

	on_unload = function(object)
		print("VMF:ON_UNLOAD()")
		object.vmf = nil
	end,

	on_reload = function(object)
		print("VMF:ON_RELOAD()")
		object.vmf.disable_mods_options_button()
		object.vmf.close_opened_custom_menus()
		object.vmf.delete_keybinds()
		object.vmf.mods_unload_event()
		object.vmf.hooks_unload()
		object.vmf.save_unsaved_settings_to_file()
	end,

	on_game_state_changed = function(object, status, state)
		print("VMF:ON_GAME_STATE_CHANGED(), status: " .. tostring(status) .. ", state: " .. tostring(state))
		object.vmf.mods_game_state_changed_event(status, state)
		object.vmf.save_unsaved_settings_to_file()

		if status == "exit" and state == "StateTitleScreen" then
			object.vmf.hook_chat_manager()
		end

		if status == "enter" and state == "StateIngame" then
			object.vmf.initialize_keybinds()
		end
	end
}
