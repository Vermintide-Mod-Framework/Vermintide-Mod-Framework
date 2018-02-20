local vmf = get_mod("VMF")


-- List of mods that are also mutators in order in which they should be enabled
-- This is populated via VMFMod.register_as_mutator
local mutators = {}
vmf.mutators = mutators

local mutators_config = {}
local default_config = dofile("scripts/mods/vmf/modules/mutators/default_config")

-- This lists mutators and which ones should be enabled after them
-- This is populated via VMFMod.register_as_mutator
local mutators_sequence = {
	--[[
	this_mutator = {
		"will be enabled",
		"before these ones"
	}
	]]--
}

-- So we don't sort after each one is added
local mutators_sorted = false


--[[
	PRIVATE METHODS
]]--

local addDice, removeDice = dofile("scripts/mods/vmf/modules/mutators/dice")
local set_lobby_data = dofile("scripts/mods/vmf/modules/mutators/info")

-- Adds mutator names from enable_these_after to the list of mutators that should be enabled after the mutator_name
local function update_mutators_sequence(mutator_name, enable_these_after)
	if not mutators_sequence[mutator_name] then
		mutators_sequence[mutator_name] = {}
	end
	for _, other_mutator_name in ipairs(enable_these_after) do

		if mutators_sequence[other_mutator_name] and table.has_item(mutators_sequence[other_mutator_name], mutator_name) then
			vmf:error("Mutators '" .. mutator_name .. "' and '" .. other_mutator_name .. "' are both set to load after the other one.")
		elseif not table.has_item(mutators_sequence[mutator_name], other_mutator_name) then
			table.insert(mutators_sequence[mutator_name], other_mutator_name)
		end

	end
	table.combine(mutators_sequence[mutator_name], enable_these_after)
end

-- Sorts mutators in order they should be enabled
local function sort_mutators()

	-- LOG --
	vmf:dump(mutators_sequence, "seq", 5)
	for i, v in ipairs(mutators) do
		print(i, v:get_name())
	end
	print("-----------")
	-- /LOG --

	-- Preventing endless loops (worst case is n*(n+1)/2 I believe)
	local maxIter = #mutators * (#mutators + 1)/2
	local numIter = 0

	-- The idea is that all mutators before the current one are already in the right order
	-- Starting from second mutator
	local i = 2
	while i <= #mutators do
		local mutator = mutators[i]
		local mutator_name = mutator:get_name()
		local enable_these_after = mutators_sequence[mutator_name] or {}

		-- Going back from the previous mutator to the start of the list
		local j = i - 1
		while j > 0 do
			local other_mutator = mutators[j]

			-- Moving it after the current one if it is to be enabled after it
			if table.has_item(enable_these_after, other_mutator:get_name()) then
				table.remove(mutators, j)
				table.insert(mutators, i, other_mutator)

				-- This will shift the current mutator back, so adjust the index
				i = i - 1
			end
			j = j - 1
		end

		i = i + 1

		numIter = numIter + 1
		if numIter > maxIter then
			vmf:error("Mutators: too many iterations. Check for loops in 'enable_before_these'/'enable_after_these'.")
			return
		end
	end
	mutators_sorted = true

	-- LOG --
	for k, v in ipairs(mutators) do
		print(k, v:get_name())
	end
	print("-----------")
	-- /LOG --
end

local function mutator_can_be_enabled(mutator)
	return (not Managers.state or not Managers.state.difficulty:get_difficulty()) or table.has_item(mutator:get_config().difficulties, Managers.state.difficulty:get_difficulty())
end

local function on_enabled(mutator)
	local config = mutator:get_config()
	addDice(config.dice)
	set_lobby_data()
end

local function on_disabled(mutator)
	local config = mutator:get_config()
	removeDice(config.dice)
	set_lobby_data()
end

-- Enables/disables mutator while preserving the sequence in which they were enabled
local function set_mutator_state(mutator, state)

	local i = table.index_of(mutators, mutator)
	if i == nil then
		mutator:error("Mutator isn't in the list")
		return
	end

	if state and not mutator_can_be_enabled(mutator) then
		mutator:error("Can't enable mutator - incorrect difficulty")
		return
	end

	-- Sort mutators if this is the first call
	if not mutators_sorted then
		sort_mutators()
	end

	local disabled_mutators = {}
	local enable_these_after = mutators_sequence[mutator:get_name()]

	-- Disable mutators that were and are required to be enabled after the current one
	-- This will be recursive so that if mutator2 requires mutator3 to be enabled after it, mutator3 will be disabled before mutator2
	-- Yeah this is super confusing
	if enable_these_after and #mutators > i then
		for j = #mutators, i + 1, -1 do
			if mutators[j]:is_enabled() and table.has_item(enable_these_after, mutators[j]:get_name()) then
				print("Disabled ", mutators[j]:get_name())
				mutators[j]:disable()
				table.insert(disabled_mutators, 1, mutators[j])
			end
		end
	end

	-- Enable/disable current mutator
	-- We're calling methods on the class object because we've overwritten them on the current one
	if state then
		print("Enabled ", mutator:get_name(), "!")
		VMFMod.enable(mutator)
		on_enabled(mutator)
	else
		print("Disabled ", mutator:get_name(), "!")
		VMFMod.disable(mutator)
		on_disabled(mutator)
	end

	-- Re-enable disabled mutators
	-- This will be recursive
	if #disabled_mutators > 0 then
		for j = #disabled_mutators, 1, -1 do
			print("Enabled ", disabled_mutators[j]:get_name())
			disabled_mutators[j]:enable()
		end
	end
	print("---------")
end

-- Enables mutator (pcall for now)
local function enable_mutator(self)
	vmf:pcall(function() set_mutator_state(self, true) end)
end

-- Disables mutator (pcall for now)
local function disable_mutator(self)
	vmf:pcall(function() set_mutator_state(self, false) end)
end

local function get_config(self)
	return mutators_config[self:get_name()]
end


--[[
	PUBLIC METHODS
]]--

-- Turns a mod into a mutator
VMFMod.register_as_mutator = function(self, config)
	if not config then config = {} end

	local mod_name = self:get_name()

	if table.has_item(mutators, self) then
		self:error("Mod is already registered as mutator")
		return
	end

	table.insert(mutators, self)

	-- Save config
	mutators_config[mod_name] = table.clone(default_config)
	local _config = mutators_config[mod_name]
	for k, _ in pairs(_config) do
		if config[k] then
			_config[k] = config[k]
		end
	end
	if _config.short_title == "" then _config.short_title = nil end

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

	self.get_config = get_config

	mutators_sorted = false

	-- Always init in the off state
	self:init_state(false)
end

--[[
	HOOKS
]]--
vmf:hook("DifficultyManager.set_difficulty", function(func, self, difficulty)
	for _, mutator in ipairs(mutators) do
		if mutator:is_enabled() and not mutator_can_be_enabled(mutator:get_config()) then
			mutator:disable()
		end
	end
	return func(self, difficulty)
end)


















--[[
	Testing
--]]
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
	enable_before_these = {
		"mutator555",
		"mutator3",
		"mutation"
	},
	difficulties = {
		"hardest"
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
