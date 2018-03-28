local mod = new_mod("mutation")

local breeds 

mod.on_enabled = function()
	breeds = {
		skaven_slave = Breeds.skaven_slave,
		skaven_clan_rat = Breeds.skaven_clan_rat,
		skaven_gutter_runner = Breeds.skaven_gutter_runner,
		skaven_pack_master = Breeds.skaven_pack_master,
		skaven_poison_wind_globadier = Breeds.skaven_poison_wind_globadier,
		skaven_ratling_gunner = Breeds.skaven_ratling_gunner,
	}

	Breeds.skaven_slave = Breeds.skaven_clan_rat
	Breeds.skaven_clan_rat = Breeds.skaven_storm_vermin_commander

	Breeds.skaven_gutter_runner = Breeds.skaven_rat_ogre
	Breeds.skaven_pack_master = Breeds.skaven_rat_ogre
	Breeds.skaven_poison_wind_globadier = Breeds.skaven_rat_ogre
	Breeds.skaven_ratling_gunner = Breeds.skaven_rat_ogre
end

mod.on_disabled = function(initial)
	if not initial then
		Breeds.skaven_slave = breeds.skaven_slave
		Breeds.skaven_clan_rat = breeds.skaven_clan_rat
		Breeds.skaven_gutter_runner = breeds.skaven_gutter_runner
		Breeds.skaven_pack_master = breeds.skaven_pack_master
		Breeds.skaven_poison_wind_globadier = breeds.skaven_poison_wind_globadier
		Breeds.skaven_ratling_gunner = breeds.skaven_ratling_gunner
	end
end

mod:register_as_mutator({
	title = "Stormvermin Mutation",
	short_title = "Mutation",
	description = "All slave rats are replaced by clan rats. All original clan rats are " ..
					"replaced with stormvermins. All specials are replaced with ogres. " ..
					"Chaos ensues. Playable on any difficulty, although the recommended " ..
					"difficulty is hard for full, serious group play, and easy or normal " ..
					"for play with bots or with an inexperienced team. Psychopaths may " ..
					"also attempt nightmare and cataclysm. Funeral costs are not covered.",
	dice = {
		bonus = 5
	},
	enable_after_these = {
		"deathwish"
	}
})
