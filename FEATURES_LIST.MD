Goals
=====
The old Vermintide Mod Framework is a good tool, but it has a lot of legacy code, some of its components' code is hardly readable, and after the new workshop update it's more like a bunch of functions than a framework. So I decided to rewrite the whole thing from the scratch. My goals were:

1. Write VMF using self-documenting code. So it would be easy to read and maintain.  
2. Move all the managing code from the mods to VMF if possible. So the modders will spend less time on writing managing code.  
3. Make public VMF functions names short and clear. This and #2 will make mods' code shorter and clearer.  
4. Make it easy for the mods to communicate with each other.  
5. Make it work with bundled mods (new mod format).

In short, make VMF the real framework, which will provide a very user-friendly API and will do all the managing for the modders.

New Approach
============
From now on, I'll refer to old VMF as "Old-VMF" and to new VMF as "VMF".
Also, when comparing functions, (*) means same functionality and (+) means new functionality.

Mods Handling
-------------

The modders who's working with Old-VMF are used to the string `local mod, mod_name, oi = Mods.new_mod("ModName")`. That was an unnecessary step. The created "mod" was just a table which could be accessed from anywhere with `Mods.get_mod("ModName")` function, and all the interactions with VMF were made via public functions. So a lot of modders just skipped this step since they didn't need it.

But, from now on, the mod instance is not a table anymore, it's the object of the class `VMFMod` and it is the core element of any mod. It is the bridge between the mod and VMF. From this moment, there are only 2 public functions in VMF:

* `new_mod(mod_name)` - creates the new instance of `VMFMod` class object and returns it
* `get_mod(mod_name)` - returns already created mod instance or `nil` if it doesn't exist

All the other VMF functionality can be accessed only through the created `VMFMod` objects.

To understand what I'm talking about, just look at this little example:
```lua
local mod = new_mod("totally_useless_mod")

mod:hook("MatchmakingManager.update", function(func, ...)
  func(...)
  mod:echo("Some annoying message you'll see a lot of times no matter what")
end)
```
This approach allows to simplify a lot of things for the modder and makes it much easier for VMF to handle things on its own.

Basic functions and events
--------------------------

Now let's get to some basic functions.

Before:  
`EchoConsole(message [string])`  
After:  
`mod:echo(message [string], show_mod_name [bool])`  
(*) Shows the message in the chat.  
(+) If `show_mod_name` is `true` the message will be prefixed with `[mod_name] `.  
(+) The message will also appear in the log as `[ECHO][mod_name] message`

Before:  
`Safe_pcall(...)`  
After:  
`mod:pcall(...)`  
(*) Lets safely execute function, shows the error message in the chat  
(+) Shows which mod failed to execute the code.  
(+) Log it.

Also, there is the new thing in VMF: events. It's working like this:

1. The modder defines `mod.some_event_name = some_function`  
2. Certain conditions for some_event are met  
3. If the mod has `mod.some_event_name` defined, VMF calls it and passes specific event arguments  

Here are some basic events:

`mod.unload()` - is called when the mod is about to be reloaded  
`mod.update(dt)` - is called every tick

Now, the example from above, but using `update` event this time:  
```lua
local mod = new_mod("totally_useless_mod")

mod.update = function(dt)
  mod:echo("Some annoying message you'll see a lot of times no matter what")
end
```

Hooking system
--------------
Imagine that you're debugging your code and experimenting with different hooks, but some time later you notice, that some hook you deleted from the code 20 mins ago is still working. You do the /reload, but it doesn't help, so you have to restart the game to stop it. Sounds familiar? Well, that's not the case anymore. Now VMF removes all the hooks when it's about to be reloaded.

Before:  
`Mods.hook.set(mod_name, "Object.Function", new_function)`  
After:  
`mod:hook("Object.Function", new_function)`  
(*) Hooks the function  
(+) It won't crash anymore if there's misprint in `"Object.Function"` or it doesn't exist. The error message with the mod name will be shown in the chat instead. Actually, there are many small changes like that, which will make debugging easier. There is no point to describe them all so I just skip them from now on.

Before:  
`Mods.hook.enable(false, mod_name, "Object.Function")`  
After:  
`mod:hook_disable("Object.Function")`  
(*) Disables hook (but not removes)

Before:  
`Mods.hook.enable(true, mod_name, "Object.Function")`  
After:  
`mod:hook_enable("Object.Function")`  
(*) Enables disabled hook

Before:  
`Mods.hook.remove("Object.Function", mod_name)`  
After:  
`mod:hook_remove("Object.Function")`  
(*) Removes hook

Also, new functions:  
`mod:disable_all_hooks()`  
`mod:enable_all_hooks()`  
`mod:remove_all_hooks()`  
(*) Disables/enables/removes all hooks for certain mod


Settings manager
-------------------------
This is the new thing. In the Old-VMF mods interacted with user settings via 'Application' directly. Now VMF is using settings manager. What's the difference?

* Settings manager operates settings within the mod namespace, so now you can define settings with the same name for different mods. Forget about `cb_bot_improvements_keep_tomes`. `keep_tomes` will do it.
* In Old-VMF, in order to actually save changed settings, some mods had to save settings to file right after changing it. That wasn't good for HDD. Now, setting manager takes care of it. It will automatically save changed settings to file when changing map / reloading VMF / closing options menu.

FUNCTIONS:

`mod:get(setting_name)` - returns setting value or `nil`

`mod:set(setting_name, setting_value, call_setting_changed_event)` - changes setting value. If `call_setting_changed_event` is `true`, the `setting_changed` event will be called for the mod.

EVENT:

`mod.setting_changed(setting_name)` - is called whenever something changes mods setting with `call_setting_changed_event` set to `true`.

With this event you won't need to repeatedly check if some option is changed. By default, after mod initilizing, the only thing that will call `mod:set` is the the VMF options menu. And it will always call `setting_changed` event.



Gui (WIP)  
Options menu (WIP)  
Keybindings (Will do)  
Network (Will do)  
Actions  
Localization  
Game modes  
Debug modules