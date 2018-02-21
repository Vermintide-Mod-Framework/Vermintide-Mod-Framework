# Mutators
A mutator is a mod that affects other players as well as you by modifying the game rules, enemies, weapon balance etc.  

You can turn your mod into a mutator by calling `mod:register_as_mutator(config)` instead of `mod:init_state()`. This way it will show up on the map screen and have additional features and options to control its behavior.

Note that you can still have additional options for your mutator in the mod options menu:  
``vmf:create_options(options_widgets, false, "Title", "Description")``

## Features  

* Show the toggle for the mutator on the map screen  
* Choose which game modes and difficulty levels the mutator can be played on  
* Add additional dice to the end game roll  
* Control the order in which mutators are enabled/disabled  
* Control compatibility with other mutators  
* Notify players already in the lobby and just joining about enabled mutators  

## Configuration

The config object is optional but obviously you'd want to provide at least a readable title for your mutator. Here are the default values:

```lua
{
	title = "",
	short_title = "",
	description = "No description provided",
	dice = {
		grims = 0,
		tomes = 0,
		bonus = 0
	},
	difficulties = {
		"easy",
		"normal",
		"hard",
		"harder",
		"hardest",

		"survival_hard",
		"survival_harder",
		"survival_hardest"
	},
	load_before_these = {},
	load_after_these = {},
	incompatible_with_all = false,
	compatible_with_all = false,
	incompatible_with = {},
	compatible_with = {}
}
```

``title = ""``  
The full title will show up on the map screen as well as when notifying players of enabled mutators.

``short_title = ""``  
The short title will be used in the lobby browser.

``description = "No description provided"``  
The description will show up in the tooltip of your mutator on the map screen.

``dice = { grims = 0, tomes = 0, bonus = 0 }``  
This determines how many additional dice the players will get for completing maps with your mutator enabled.

```
difficulties = {
	"easy",
	"normal",
	"hard",
	"harder",
	"hardest",

	"survival_hard",
	"survival_harder",
	"survival_hardest"
}
```
This determines which difficulty levels your mutator will be available at. First five are for Adventure and the last three are for Last Stand game mode.


You have a few ways to set compatibility with other mutators. Note that this should be used in the cases where combining mutators somehow breaks the game, not for making your mutator special by prohibiting other to be enabled with it:

``incompatible_with_all = false,``  
Set this to true if you are sure combining other mutators with yours will cause problems. Exceptions can be specified in `compatible_with` on this or other mutators.

``compatible_with_all = false``  
Set this to true if you are sure this mutator won't cause any problems. This overwrites `incompatible_with_all` on other mutators. Exceptions can be specified in `incompatible_with` on this or other mutators.

``compatible_with = {}``  
``incompatible_with = {}``  
You can provide a list of names of mutators you know for sure yours does/doesn't work with respectively. `compatible_with` overwrites `incompatible_with_all` and `incompatible_with` overwrites `compatible_with_all` on other mutators. Use these to provide exceptions to `incompatible_with_all` and `compatible_with_all` on this mutator.

``enable_before_these = {},``  
``enable_after_these = {},``  
You can improve the compatibility of your mutator with other ones by specifiying which mutators should be enabled after or before this one. This can help with mutators that modify the same portions of the game.

# Methods


Mutators have the same methods and event handlers as other mods plus a few additional ones. These are mostly used behind the scenes.  

``mutator:get_config()`` - returns the configuration object without `load_before_these/load_after_these` fields. This shouldn't be modified.

``mutator:can_be_enabled(ignore_map)`` - returns whether the difficulty is right for the mutator and that there are no incompatible mutators enabled. `ignore_map` only takes into account the set difficulty and ignores difficulty selection on the map screen before Play button is pressed.

``mutator:supports_current_difficulty(ignore_map)`` - same as the last one only doesn't check for incompatible mutators

``mutator:get_incompatible_mutators(enabled_only)`` - returns an array of incompatible mutators. `enabled_only` only checks for enabled ones.

