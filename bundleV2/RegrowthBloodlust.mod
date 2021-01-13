return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`RegrowthBloodlust` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("RegrowthBloodlust", {
			mod_script       = "scripts/mods/RegrowthBloodlust/RegrowthBloodlust",
			mod_data         = "scripts/mods/RegrowthBloodlust/RegrowthBloodlust_data",
			mod_localization = "scripts/mods/RegrowthBloodlust/RegrowthBloodlust_localization",
		})
	end,
	packages = {
		"resource_packages/RegrowthBloodlust/RegrowthBloodlust",
	},
}
