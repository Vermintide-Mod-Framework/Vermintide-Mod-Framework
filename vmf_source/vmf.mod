print("Vermintide Mod Framework loading")

local ret = {
	run = function()
		return dofile("scripts/mods/vmf/vmf_loader")
	end,
	packages = {
		"resource_packages/vmf"
	},
}
return ret