return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`B2F` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("B2F", {
			mod_script       = "scripts/mods/B2F/B2F",
			mod_data         = "scripts/mods/B2F/B2F_data",
			mod_localization = "scripts/mods/B2F/B2F_localization",
		})
	end,
	packages = {
		"resource_packages/B2F/B2F",
	},
}
