local vmf = get_mod("VMF")

local mod_data

----------------------------------------------------------------------------------

local mutator555 = new_mod("mutator555")
mod_data = {}
mod_data.name = "Legendary"
mod_data.description = "Legendary description"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	incompatible_with_all = true,
	compatible_with = {
		--"mutator3"
	}
	--title = "Legendary"
}
mutator555:initialize_data(mod_data)
mutator555.on_enabled = function(init_call) mutator555:echo("Legendary on_enabled(" .. (init_call and "init)" or ")")) end
mutator555.on_disabled = function(init_call) mutator555:echo("Legendary on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mutator555)
----------------------------------------------------------------------------------

local mutator3 = new_mod("mutator3")
mod_data = {}
mod_data.name = "Something"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	incompatible_with = {
		"mutator4"
	},
	--title = "Something"
}
mutator3:initialize_data(mod_data)
mutator3.on_enabled = function(init_call) mutator3:echo("Something on_enabled(" .. (init_call and "init)" or ")")) end
mutator3.on_disabled = function(init_call) mutator3:echo("Something on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mutator3)

----------------------------------------------------------------------------------

local mutator2 = new_mod("mutator2")
mod_data = {}
mod_data.name = "?Deathwish"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {
		"hardest",
		"survival_hardest"
	},
	--title = "?Deathwish",
	title_placement = "after"
}
mutator2:initialize_data(mod_data)
mutator2.on_enabled = function(init_call) mutator3:echo("?Deathwish on_enabled(" .. (init_call and "init)" or ")")) end
mutator2.on_disabled = function(init_call) mutator3:echo("?Deathwish on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(mutator2)

----------------------------------------------------------------------------------

local slayer = new_mod("slayer")
mod_data = {}
mod_data.name = "Slayer's Oath"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	difficulty_levels = {
		"survival_hard",
		"survival_harder",
		"survival_hardest"
	},
	--title = "Slayer's Oath"
}
slayer:initialize_data(mod_data)
slayer.on_enabled = function(init_call) mutator3:echo("Slayer's Oath on_enabled(" .. (init_call and "init)" or ")")) end
slayer.on_disabled = function(init_call) mutator3:echo("Slayer's Oath on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(slayer)

----------------------------------------------------------------------------------

local true_solo = new_mod("true_solo")
mod_data = {}
mod_data.name = "True Solo"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	compatible_with_all = true,
	--title = "True Solo",
	title_placement = "before"
}
true_solo:initialize_data(mod_data)
true_solo.on_enabled = function(init_call) mutator3:echo("True Solo on_enabled(" .. (init_call and "init)" or ")")) end
true_solo.on_disabled = function(init_call) mutator3:echo("True Solo on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(true_solo)

----------------------------------------------------------------------------------

local onslaught = new_mod("onslaught")
mod_data = {}
mod_data.name = "Onslaught"
mod_data.is_mutator = true
--mod_data.mutator_settings = {
--	title = "Onslaught"
--}
onslaught:initialize_data(mod_data)
onslaught.on_enabled = function(init_call) mutator3:echo("Onslaught on_enabled(" .. (init_call and "init)" or ")")) end
onslaught.on_disabled = function(init_call) mutator3:echo("Onslaught on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(onslaught)

----------------------------------------------------------------------------------

local one_hit_one_kill = new_mod("one_hit_one_kill")
mod_data = {}
mod_data.name = "One Hit One Kill"
mod_data.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse tincidunt placerat nulla eget pharetra. Vivamus consequat tristique vestibulum. Nullam vitae feugiat arcu, non porta ante. Phasellus consequat facilisis quam quis dignissim"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	--title = "One Hit One Kill",
	difficulty_levels = {"hardest"},
	enable_after_these = {"more_rat_weapons"}
}
one_hit_one_kill:initialize_data(mod_data)
one_hit_one_kill.on_enabled = function(init_call) mutator3:echo("One Hit One Kill on_enabled(" .. (init_call and "init)" or ")")) end
one_hit_one_kill.on_disabled = function(init_call) mutator3:echo("One Hit One Kill on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(one_hit_one_kill)
----------------------------------------------------------------------------------

local ayyyy = new_mod("ayyyy")
mod_data = {}
mod_data.name = "ayyyy"
mod_data.is_mutator = true
ayyyy:initialize_data(mod_data)
ayyyy.on_enabled = function(init_call) mutator3:echo("ayyyy on_enabled(" .. (init_call and "init)" or ")")) end
ayyyy.on_disabled = function(init_call) mutator3:echo("ayyyy on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(ayyyy)
----------------------------------------------------------------------------------

local lmao = new_mod("lmao")
mod_data = {}
mod_data.name = "lmao"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	--title = "One Hit One Kill",
	difficulty_levels = {"hardest"},
	enable_after_these = {"ayyyy"}
}
lmao:initialize_data(mod_data)
lmao.on_enabled = function(init_call) mutator3:echo("lmao on_enabled(" .. (init_call and "init)" or ")")) end
lmao.on_disabled = function(init_call) mutator3:echo("lmao on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(lmao)

----------------------------------------------------------------------------------

local more_rat_weapons = new_mod("more_rat_weapons")
mod_data = {}
mod_data.name = "More Rat Weapons"
mod_data.is_mutator = true
mod_data.mutator_settings = {
	compatible_with_all = true,
	--title = "More Rat Weapons",
	difficulty_levels = {"hardest"}
}
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)



more_rat_weapons = new_mod("111")
mod_data = {}
mod_data.name = "111"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("222")
mod_data = {}
mod_data.name = "222"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("333")
mod_data = {}
mod_data.name = "333"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("444")
mod_data = {}
mod_data.name = "444"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("555")
mod_data = {}
mod_data.name = "555"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("666")
mod_data = {}
mod_data.name = "666"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("777")
mod_data = {}
mod_data.name = "777"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)


more_rat_weapons = new_mod("888")
mod_data = {}
mod_data.name = "888"
mod_data.is_mutator = true
more_rat_weapons:initialize_data(mod_data)
more_rat_weapons.on_enabled = function(init_call) mutator3:echo("More Rat Weapons on_enabled(" .. (init_call and "init)" or ")")) end
more_rat_weapons.on_disabled = function(init_call) mutator3:echo("More Rat Weapons on_disabled(" .. (init_call and "init)" or ")")) end
vmf.initialize_mod_state(more_rat_weapons)