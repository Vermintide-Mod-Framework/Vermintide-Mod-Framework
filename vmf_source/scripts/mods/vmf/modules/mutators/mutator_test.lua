local mutator2 = new_mod("mutator2")
local mutator3 = new_mod("mutator3")
local mutator555 = new_mod("mutator555")

mutator555:register_as_mutator({
	incompatible_with_all = true
})
mutator555:create_options({}, true, "mutator555", "mutator555 description")
mutator555.on_enabled = function() end
mutator555.on_disabled = function() end


mutator3:register_as_mutator({
	incompatible_with = {
		"mutator4"
	}
})
mutator3.on_enabled = function() end
mutator3.on_disabled = function() end

mutator2:register_as_mutator({
	compatible_with_all = true,
	difficulty_levels = {
		"hardest"
	}
})
mutator2.on_enabled = function() end
mutator2.on_disabled = function() end

--[[for i=4,17 do
	local mutator = new_mod("mutator" .. i)
	mutator:register_as_mutator({})
	mutator.on_enabled = function() end
	mutator.on_disabled = function() end
end--]]