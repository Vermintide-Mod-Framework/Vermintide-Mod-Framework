return {
	init = function(object)

		dofile("scripts/mods/vmf/functions/table")

		dofile("scripts/mods/vmf/modules/dev_console")
		dofile("scripts/mods/vmf/modules/mods")
		dofile("scripts/mods/vmf/modules/debug")
		dofile("scripts/mods/vmf/modules/hooks")
		dofile("scripts/mods/vmf/modules/chat")
		dofile("scripts/mods/vmf/modules/settings")
		dofile("scripts/mods/vmf/modules/keybindings")
		dofile("scripts/mods/vmf/modules/gui")
		dofile("scripts/mods/vmf/modules/vmf_options_view")

		--Application.set_user_setting("mod_developer_mode", true)
		--Application.save_user_settings()

		object.vmf = get_mod("VMF")

		-- temporary solution:
		dofile("scripts/mods/vmf/modules/testing_stuff_here")
	end,

	update = function(object, dt)

		object.vmf.mods_update(dt)
		object.vmf.check_pressed_keybinds()
		object.vmf.check_custom_menus_close_keybinds(dt)

		if not object.vmf.all_mods_were_loaded and Managers.mod._state == "done" then

			object.vmf.initialize_keybinds()

			object.vmf.all_mods_were_loaded = true
		end
	end,

	on_unload = function(object)
		print("VMF:ON_UNLOAD()")
		object.vmf = nil
	end,

	on_reload = function(object)
		print("VMF:ON_RELOAD()")
		object.vmf.close_opened_custom_menus()
		object.vmf.delete_keybinds()
		object.vmf.mods_unload()
		object.vmf.hooks_unload()
		object.vmf.save_unsaved_settings_to_file()
	end,

	on_game_state_changed = function(object, status, state)
		print("VMF:ON_GAME_STATE_CHANGED(), status: " .. tostring(status) .. ", state: " .. tostring(state))
		object.vmf.mods_game_state_changed(status, state)
		object.vmf.save_unsaved_settings_to_file()

		if status == "exit" and state == "StateTitleScreen" then
			object.vmf.hook_chat_manager()
		end

		if status == "enter" and state == "StateIngame" then
			object.vmf.initialize_keybinds()
		end
	end
}
