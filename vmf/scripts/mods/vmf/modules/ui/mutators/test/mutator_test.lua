local vmf = get_mod("VMF")

local mod
local mod_data

----------------------------------------------------------------------------------

mod = new_mod("test_legendary")
mod_data = {}
mod_data.name = "Legendary"
mod_data.description = "Legendary description"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	incompatible_with_all = true,
	compatible_with = {
		"test_something"
	}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("Legendary on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("Legendary on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)
----------------------------------------------------------------------------------

mod = new_mod("test_something")
mod_data = {}
mod_data.name = "Something"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	incompatible_with = {
		"test_true_solo",
		"test_slayer"
	}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("Something on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("Something on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_deathwish")
mod_data = {}
mod_data.name = "?Deathwish"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {
		"hardest",
		"survival_hardest"
	},
	title_placement = "after"
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("?Deathwish on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("?Deathwish on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_slayer")
mod_data = {}
mod_data.name = "Slayer's Oath"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {
		"survival_hard",
		"survival_harder",
		"survival_hardest"
	}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("Slayer's Oath on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("Slayer's Oath on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_true_solo")
mod_data = {}
mod_data.name = "True Solo"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	compatible_with_all = true,
	title_placement = "before"
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("True Solo on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("True Solo on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_onslaught")
mod_data = {}
mod_data.name = "Onslaught"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("Onslaught on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("Onslaught on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_one_hit_one_kill")
mod_data = {}
mod_data.name = "One Hit One Kill"
mod_data.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse tincidunt placerat" ..
											 " nulla eget pharetra. Vivamus consequat tristique vestibulum. Nullam vitae feugiat arcu," ..
											 " non porta ante. Phasellus consequat facilisis quam quis dignissim"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {"hardest"},
	enable_after_these = {"test_more_rats_weapons"}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("One Hit One Kill on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("One Hit One Kill on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)
----------------------------------------------------------------------------------

mod = new_mod("ayyyy")
mod_data = {}
mod_data.name = "ayyyy"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("ayyyy on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("ayyyy on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)
----------------------------------------------------------------------------------

mod = new_mod("lmao")
mod_data = {}
mod_data.name = "lmao"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {"hardest"},
	enable_after_these = {"ayyyy"},
	dice = {
		bonus = 2
	}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("lmao on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("lmao on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

----------------------------------------------------------------------------------

mod = new_mod("test_more_rats_weapons")
mod_data = {}
mod_data.name = "More Rat Weapons"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	compatible_with_all = true,
	difficulty_levels = {"hardest"}
}
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)

--[[ -- scrollbar test
mod = new_mod("111")
mod_data = {}
mod_data.name = "111"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("111 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("111 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("222")
mod_data = {}
mod_data.name = "222"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("222 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("222 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("333")
mod_data = {}
mod_data.name = "333"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("333 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("333 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("444")
mod_data = {}
mod_data.name = "444"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("444 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("444 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("555")
mod_data = {}
mod_data.name = "555"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("555 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("555 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("666")
mod_data = {}
mod_data.name = "666"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("666 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("666 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("777")
mod_data = {}
mod_data.name = "777"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("777 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("777 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)


mod = new_mod("888")
mod_data = {}
mod_data.name = "888"
mod_data.is_mutator = true
mod:initialize_data(mod_data)
mod.on_enabled = function(init_call) mod:echo("888 on_enabled(" .. (init_call and "init)" or ")")) end
mod.on_disabled = function(init_call) mod:echo("888 on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mod)
]]