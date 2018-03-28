local mod = new_mod("deathwish")

local RESPAWN_TIME = 60
local breeds_health, breed_actions, rattling_damage, patrol_amount

mod.on_enabled = function()

	mod:enable_all_hooks()

	breeds_health = {}
	for name, breed in pairs(Breeds) do
		breeds_health[name] = breed.max_health[5]
	end

	breed_actions = table.clone(BreedActions)
	rattling_damage = table.clone(AttackDamageValues.ratlinggun_very_hard)
	patrol_amount = DifficultySettings.hardest.amount_storm_vermin_patrol

	Breeds.skaven_clan_rat.max_health[5] = 18

	Breeds.skaven_slave.max_health[5] = 9

	Breeds.skaven_gutter_runner.max_health[5] = 30

	Breeds.skaven_loot_rat.max_health[5] = 200

	Breeds.skaven_pack_master.max_health[5] = 72

	Breeds.skaven_poison_wind_globadier.max_health[5] = 30

	Breeds.skaven_ratling_gunner.max_health[5] = 30

	Breeds.skaven_storm_vermin.max_health[5] = 50

	Breeds.skaven_storm_vermin_commander.max_health[5] = 50

	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.hardest = { 20, 10, 5 }

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.hardest = { 20, 10, 5 }


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.hardest = { 20, 10, 5 }


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.hardest = { 10, 4, 1 }

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_init_damage[5] = { 20, 2, 0 }

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_dot_damage[5] = { 30, 0, 0 }

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_init_damage[5] = { 70, 5, 0 }

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_dot_damage[5] = { 20, 0, 0 }


	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.hardest = { 60, 30, 22.5 }

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.hardest = { 25, 20, 15 }

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.hardest = { 100, 90, 90 }

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.hardest = { 150, 75, 45 }

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.hardest = { 150, 75, 45 }

	--Last Stand
	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.survival_hardest = { 30, 15, 7.5 }

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.survival_hardest = { 30, 15, 7.5 }


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.survival_hardest = { 30, 15, 7.5 }


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.survival_hardest = { 15, 6, 1.5 }

	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.survival_hardest = { 90, 45, 33.75 }

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.survival_hardest = { 37.5, 30, 22.5 }

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.survival_hardest = { 150, 135, 135 }

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.survival_hardest = { 225, 112.5, 67.5 }

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.survival_hardest = { 225, 112.5, 67.5 }
	--LS Krench
	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.survival_hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.survival_hardest = { 225, 112.5, 67.5 }

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.survival_hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.survival_hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.survival_hardest = { 37.5, 30, 22.5 }

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.survival_hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.survival_hardest = { 37.5, 30, 22.5 }

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.survival_hardest = { 37.5, 30, 22.5 }

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.survival_hardest = { 112.5, 67.5, 45 }

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.survival_hardest = { 
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin" }
	--End LS Krench
	--End Last Stand
	--Krench
	Breeds.skaven_storm_vermin_champion.max_health[5] = 1400

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.hardest = { 150, 75, 45 }

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.hardest = { 25, 20, 15 }

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.hardest = { 20, 20, 20 }

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.hardest = { 25, 20, 15 }

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.hardest = { 25, 20, 15 }

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.hardest = { 75, 45, 30 }

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.hardest = { 
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin" 
	}
	--End Krench

	AttackDamageValues.ratlinggun_very_hard = { 16,	2.5, 7.5, 8 }
	BreedActions.skaven_ratling_gunner.shoot_ratling_gun.attack_template_damage_type[4] = "ratlinggun_hard"

	DifficultySettings.hardest.amount_storm_vermin_patrol = 24
end

mod.on_disabled = function(initial)

	mod:disable_all_hooks()

	if initial then return end

	for name, breed in pairs(Breeds) do
		breed.max_health[5] = breeds_health[name]
	end
	BreedActions = breed_actions
	AttackDamageValues.ratlinggun_very_hard = rattling_damage
	DifficultySettings.hardest.amount_storm_vermin_patrol = patrol_amount
end

mod:hook("PlayerUnitHealthExtension._knock_down", function(func, self, unit)
	if Managers.state.game_mode._game_mode_key ~= "inn" then
		PlayerUnitHealthExtension.die(self, unit)
	else
		func(self, unit)
	end
end)

mod:hook("DamageUtils.add_damage_network", function(func, attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, ...)
	local damage_amountfixed = (original_damage_amount / 1.5)
	local damage_amountff = (original_damage_amount * 1.5)
	local breed = Unit.get_data(attacked_unit, "breed")

	if breed ~= nil then
		if breed.name == "skaven_rat_ogre" then
			func(attacked_unit, attacker_unit, damage_amountfixed, hit_zone_name, damage_type, ...)
		else
			func(attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, ...)
		end
	elseif (Unit.get_data(attacker_unit, "breed") == nil and damage_type ~= "damage_over_time") then
		func(attacked_unit, attacker_unit, damage_amountff, hit_zone_name, damage_type, ...)
	else
		func(attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, ...)
	end
end)

mod:hook("RespawnHandler.update", function(func, self, dt, t, player_statuses)
	for _, status in ipairs(player_statuses) do
		if status.health_state == "dead" and not status.ready_for_respawn and not status.respawn_timer then
			local peer_id = status.peer_id
			local local_player_id = status.local_player_id
			local respawn_time = RESPAWN_TIME

			if peer_id or local_player_id then
				local player = Managers.player:player(peer_id, local_player_id)
				local player_unit = player.player_unit

				if Unit.alive(player_unit) then
					local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
					respawn_time = buff_extension.apply_buffs_to_value(buff_extension, respawn_time, StatBuffIndex.FASTER_RESPAWN)
				end
			end

			status.respawn_timer = t + respawn_time
		elseif status.health_state == "dead" and not status.ready_for_respawn and status.respawn_timer < t then
			status.respawn_timer = nil
			status.ready_for_respawn = true
		end
	end

	return 
end)

mod:register_as_mutator({
	title = "Deathwish",
	description = "A serious take on \"what if there was a difficulty after cataclysm?\" " ..
					"to give even the best of the best a serious challenge. If you thought " ..
					"the jump from nightmare to cataclysm was bad, then just you wait.",
	title_placement = "replace",
	dice = {
		grims = 2
	},
	enable_before_these = {
		"mutation"
	},
	difficulty_levels = {
		"hardest",
		"survival_hardest"
	}
})