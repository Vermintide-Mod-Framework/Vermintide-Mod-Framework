local mutator555 = new_mod("mutator555")

mutator555:register_as_mutator({
	incompatible_with_all = true,
	title = "Legendary"
})
mutator555.on_enabled = function() end
mutator555.on_disabled = function() end


local mutator3 = new_mod("mutator3")
mutator3:register_as_mutator({
	incompatible_with = {
		"mutator4"
	},
	title = "Stormvermin Mutation"
})
mutator3.on_enabled = function() end
mutator3.on_disabled = function() end

local mutator2 = new_mod("mutator2")
mutator2:register_as_mutator({
	difficulty_levels = {
		"hardest",
		"survival_hardest"
	},
	title = "Deathwish"
})
mutator2.on_enabled = function() end
mutator2.on_disabled = function() end

local slayer = new_mod("slayer")
slayer:register_as_mutator({
	difficulty_levels = {
		"survival_hard",
		"survival_harder",
		"survival_hardest"
	},
	title = "Slayer's Oath"
})
slayer.on_enabled = function() end
slayer.on_disabled = function() end

local true_solo = new_mod("true_solo")
true_solo:register_as_mutator({
	compatible_with_all = true,
	title = "True Solo"
})
true_solo.on_enabled = function() end
true_solo.on_disabled = function() end

local onslaught = new_mod("onslaught")
onslaught:register_as_mutator({
	title = "Onslaught"
})
onslaught.on_enabled = function() end
onslaught.on_disabled = function() end

local one_hit_one_kill = new_mod("one_hit_one_kill")
one_hit_one_kill:register_as_mutator({
	title = "One Hit One Kill"
})
one_hit_one_kill.on_enabled = function() end
one_hit_one_kill.on_disabled = function() end

local more_rat_weapons = new_mod("more_rat_weapons")
more_rat_weapons:register_as_mutator({
	compatible_with_all = true,
	title = "More Rat Weapons"
})
more_rat_weapons.on_enabled = function() end
more_rat_weapons.on_disabled = function() end

--[[for i=4,17 do
	local mutator = new_mod("mutator" .. i)
	mutator:register_as_mutator({})
	mutator.on_enabled = function() end
	mutator.on_disabled = function() end
end--]]