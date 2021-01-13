local mod = get_mod("RegrowthBloodlust")

--Proc Functions for Buffs
ProcFunctions.heal_permanent_proc_on_hit = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") then
		local heal_amount = buff.bonus

		DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
	end
end

ProcFunctions.heal_permanent_proc_on_kill = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local damage_dealt = params[8] and params[8].damage_amount or 0
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	local target_health_extension = ScriptUnit.extension(hit_unit, "health_system")
	local killing_blow = target_health_extension:current_health() < damage_dealt

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") and killing_blow then
		local heal_amount = buff.bonus

		DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
	end
end

--Buffs & Traits
WeaponTraits.buff_templates.regrowth_vt1 = {
	name = "regrowth_vt1",
	buffs = {
		{
			proc_chance = 0.07,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_hit",
			bonus = 5
		}
	}
}

WeaponTraits.buff_templates.bloodlust_vt1 = {
	name = "bloodlust_vt1",
	buffs = {
		{
			proc_chance = 0.1,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_kill",
			bonus = 10
		}
	}
}

WeaponTraits.traits.regrowth_vt1 = {
	name = "regrowth_vt1",
	display_name = "regrowth_vt1",
	advanced_description = "regrowth_vt1_desc",
	icon = "melee_attack_speed_on_crit",
	buff_name = "regrowth_vt1",
}

WeaponTraits.traits.bloodlust_vt1 = {
	name = "bloodlust_vt1",
	display_name = "bloodlust_vt1",
	advanced_description = "bloodlust_vt1_desc",
	icon = "melee_attack_speed_on_crit",
	buff_name = "bloodlust_vt1",
}

table.merge_recursive(BuffTemplates, WeaponTraits.buff_templates)

mod:hook_origin(GearUtils, "get_property_and_trait_buffs", function (backend_items, backend_id, buffs_table, only_no_wield_required)
	local backend_items = Managers.backend:get_interface("items")
	local item = backend_items:get_item_from_id(backend_id)
	if item then
		local item_data = item.data
		local slot_type = item_data.slot_type

		if mod:get("weapon") and slot_type == "melee" then
			if mod:get("trait") then
				buffs_table.client.bloodlust_vt1 = {
					variable_value = 1
				}
				--mod:echo("it worky")
			else
				buffs_table.client.regrowth_vt1 = {
					variable_value = 1
				}
				--mod:echo("it worked")
			end
		elseif not mod:get("weapon") and slot_type == "ranged" then
			if mod:get("trait") then
				buffs_table.client.bloodlust_vt1 = {
					variable_value = 1
				}
				--mod:echo("it worken")
			else
				buffs_table.client.regrowth_vt1 = {
					variable_value = 1
				}
				--mod:echo("it working")
			end
		end
	end

    return buffs_table
end)