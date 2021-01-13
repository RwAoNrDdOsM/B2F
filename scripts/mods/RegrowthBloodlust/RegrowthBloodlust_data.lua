local mod = get_mod("RegrowthBloodlust")

return {
	name = "B2F - Regrowth & Bloodlust",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "weapon",
				type          = "dropdown",
				default_value = true,
				options = {
					{text = "ranged",   value = false, show_widgets = {}},
					{text = "melee",   value = true, show_widgets = {}},
				}
			},
			{
				setting_id    = "trait",
				type          = "dropdown",
				default_value = false,
				options = {
					{text = "regrowth_vt1",   value = false, show_widgets = {}},
					{text = "bloodlust_vt1",   value = true, show_widgets = {}},
				}
			},
		}
	}
}
