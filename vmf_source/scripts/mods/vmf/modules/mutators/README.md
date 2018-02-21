# Mutators
You can turn your mod into a mutator by calling `mod:register_as_mutator(config)` instead of `mod:init_state()`. This way it will show up on the map screen and have additional features and options to control its behavior.

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
