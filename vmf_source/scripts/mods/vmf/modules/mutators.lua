local vmf = get_mod("VMF")

local mutators = {}
local mutators_sequence = {}
local mutators_sorted = false

local function update_mutators_sequence(mutator_name, load_these_after)
	if not mutators_sequence[mutator_name] then
		mutators_sequence[mutator_name] = {}
	end
	for _, other_mutator_name in ipairs(load_these_after) do

		if mutators_sequence[other_mutator_name] and table.has_item(mutators_sequence[other_mutator_name], mutator_name) then
			vmf:error("Mutators '" .. mutator_name .. "' and '" .. other_mutator_name .. "' are both set to load after the other one.")
		elseif not table.has_item(mutators_sequence[mutator_name], other_mutator_name) then
			table.insert(mutators_sequence[mutator_name], other_mutator_name)
		end

	end
	table.combine(mutators_sequence[mutator_name], load_these_after)
end

local function error_endless_loop()
	vmf:error("Mutators: too many iterations. Check for loops in 'enable_before_these'/'enable_after_these'.")
end

local function sort_mutators()

	vmf:dump(mutators_sequence, "seq", 5)
	for i, v in ipairs(mutators) do
		print(i, v:get_name())
	end
	print("-----------")

	local maxIter = #mutators * #mutators * #mutators
	local numIter = 0

	local i = 2
	while i <= #mutators do
		local mutator = mutators[i]
		local mutator_name = mutator:get_name()
		local load_these_after = mutators_sequence[mutator_name] or {}

		local j = i - 1
		while j > 0 do
			local other_mutator = mutators[j]
			if table.has_item(load_these_after, other_mutator:get_name()) then
				table.remove(mutators, j)
				table.insert(mutators, i, other_mutator)
				i = i - 1
			end
			j = j - 1

			numIter = numIter + 1
			if numIter > maxIter then return error_endless_loop() end
		end

		i = i + 1

		numIter = numIter + 1
		if numIter > maxIter then return error_endless_loop() end
	end
	mutators_sorted = true

	for i, v in ipairs(mutators) do
		print(i, v:get_name())
	end
	print("-----------")
end

local function set_mutator_state(self, state)
	local i = table.index_of(mutators, self)
	if i == nil then
		self:error("Mutator isn't in the list")
		return
	end

	if not mutators_sorted then
		sort_mutators()
	end

	local disabled_mutators = {}
	local load_these_after = mutators_sequence[self:get_name()]

	if load_these_after and #mutators > i then
		for j = #mutators, i + 1, -1 do
			if mutators[j]:is_enabled() and table.has_item(load_these_after, mutators[j]:get_name()) then
				print("Disabled ", mutators[j]:get_name())
				mutators[j]:disable()
				table.insert(disabled_mutators, 1, mutators[j])
			end
		end
	end

	if state then
		print("Enabled ", self:get_name(), "!")
		VMFMod.enable(self)
	else
		print("Disabled ", self:get_name(), "!")
		VMFMod.disable(self)
	end

	if #disabled_mutators > 0 then
		for j = #disabled_mutators, 1, -1 do
			print("Enabled ", disabled_mutators[j]:get_name())
			disabled_mutators[j]:enable()
		end
	end
	print("---------")
end

local function enable_mutator(self)
	vmf:pcall(function() set_mutator_state(self, true) end)
end

local function disable_mutator(self)
	vmf:pcall(function() set_mutator_state(self, false) end)
end

VMFMod.register_as_mutator = function(self, config)
	if not config then config = {} end

	local mod_name = self:get_name()

	if table.has_item(mutators, self) then
		self:error("Mod is already registered as mutator")
		return
	end

	table.insert(mutators, self)

	if config.enable_before_these then
		update_mutators_sequence(mod_name, config.enable_before_these)
	end

	if config.enable_after_these then
		for _, other_mod_name in ipairs(config.enable_after_these) do
			update_mutators_sequence(other_mod_name, {mod_name})
		end
	end

	self.enable = enable_mutator
	self.disable = disable_mutator

	mutators_sorted = false

	-- Always init in the off state
	self:init_state(false)
end

-- Testing
local mutation = new_mod("mutation")
local deathwish = new_mod("deathwish")
local mutator3 = new_mod("mutator3")
local mutator555 = new_mod("mutator555")
local mutator_whatever = new_mod("mutator_whatever")

mutator555:register_as_mutator({
	enable_after_these = {
		"mutation"
	}
})
mutator555:create_options({}, true, "mutator555", "mutator555 description")
mutator555.on_enabled = function() end
mutator555.on_disabled = function() end


deathwish:register_as_mutator({
	enable_after_these = {
		"mutation"
	},
	enable_before_these = {
		"mutator555",
		"mutator3",
		"mutation"
	}
})
deathwish:create_options({}, true, "deathwish", "deathwish description")
deathwish.on_enabled = function() 
	print(tostring(Breeds.skaven_gutter_runner == Breeds.skaven_pack_master))
end
deathwish.on_disabled = function() end


-------------------------------
local breeds
mutation:register_as_mutator({
	enable_after_these = {
		"deathwish"
	}
})
mutation:create_options({}, true, "mutation", "mutation description")
mutation.on_enabled = function()
	breeds = table.clone(Breeds)
	Breeds.skaven_slave = Breeds.skaven_clan_rat
	Breeds.skaven_clan_rat = Breeds.skaven_storm_vermin_commander

	Breeds.skaven_gutter_runner = Breeds.skaven_rat_ogre
	Breeds.skaven_pack_master = Breeds.skaven_rat_ogre
	Breeds.skaven_poison_wind_globadier = Breeds.skaven_rat_ogre
	Breeds.skaven_ratling_gunner = Breeds.skaven_rat_ogre
end
mutation.on_disabled = function(initial)
	if not initial then Breeds = breeds end
end
-------------------------------

mutator3:register_as_mutator({
	enable_before_these = {
		"mutator555"
	}
})
mutator3:create_options({}, true, "mutator3", "mutator3 description")
mutator3.on_enabled = function() end
mutator3.on_disabled = function() end

mutator_whatever:register_as_mutator()
mutator_whatever:create_options({}, true, "mutator_whatever", "mutator_whatever description")
mutator_whatever.on_enabled = function() end
mutator_whatever.on_disabled = function() end
