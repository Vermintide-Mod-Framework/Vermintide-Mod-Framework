local dmf = get_mod("DMF")

local function create_test_mutator(mod_name, mod_data)
  return new_mod(mod_name, {
    mod_data = mod_data,
    mod_script = function()
      local mod = get_mod(mod_name)
      local readable_name = mod_data.name or mod_name
      function mod.on_enabled(init_call)
        mod:echo("%s on_enabled(%s)", readable_name, init_call and "init" or "")
      end
      function mod.on_disabled(init_call)
        mod:echo("%s on_disabled(%s)", readable_name, init_call and "init" or "")
      end
    end
  })
end

----------------------------------------------------------------------------------

create_test_mutator("test_legendary", {
  name = "Legendary",
  description = "Legendary description",
  is_mutator = true,
  mutator_settings = {
    incompatible_with_all = true,
    compatible_with = {
      "test_something"
    },
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_something", {
  name = "Something",
  is_mutator = true,
  mutator_settings = {
    incompatible_with = {
      "test_true_solo",
      "test_slayer",
    },
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_deathwish", {
  name = "?Deathwish",
  is_mutator = true,
  mutator_settings = {
    difficulty_levels = {
      "highest",
    },
    title_placement = "after",
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_slayer", {
  name = "Slayer's Oath",
  is_mutator = true,
  mutator_settings = {
    difficulty_levels = {
      "medium",
      "high",
      "highest",
    },
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_true_solo", {
  name = "True Solo",
  is_mutator = true,
  mutator_settings = {
    compatible_with_all = true,
    title_placement = "before",
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_onslaught", {
  name = "Onslaught",
  is_mutator = true,
})

----------------------------------------------------------------------------------

create_test_mutator("test_one_hit_one_kill", {
  name = "One Hit One Kill",
  description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse tincidunt placerat" ..
                         " nulla eget pharetra. Vivamus consequat tristique vestibulum. Nullam vitae feugiat arcu," ..
                         " non porta ante. Phasellus consequat facilisis quam quis dignissim",
  is_mutator = true,
  mutator_settings = {
    difficulty_levels = {"highest"},
    enable_after_these = {"test_more_rats_weapons"},
  },
})

----------------------------------------------------------------------------------

create_test_mutator("ayyyy", {
  name = "ayyyy",
  is_mutator = true,
})

----------------------------------------------------------------------------------

create_test_mutator("lmao", {
  name = "lmao",
  is_mutator = true,
  mutator_settings = {
    difficulty_levels = {"highest"},
    enable_after_these = {"ayyyy"},
    reward = {
      plasteel = 2,
    },
  },
})

----------------------------------------------------------------------------------

create_test_mutator("test_more_rats_weapons", {
  name = "More Rat Weapons",
  is_mutator = true,
  mutator_settings = {
    compatible_with_all = true,
    difficulty_levels = {"highest"},
  },
})

--[[ -- scrollbar test
for i=1, 8 do
  create_test_mutator("test_more_rats_weapons", {
    name = i .. i .. i,
    is_mutator = true,
  })
end
--]]
