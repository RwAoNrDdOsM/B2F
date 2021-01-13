local mod = get_mod("B2F")

--Proc Functions for Buffs
ProcFunctions.heal_permanent_proc_on_hit_melee = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") then
		local heal_amount = buff.bonus

		DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
		if player.local_player then
			mod:echo("Melee Regrowth awarded you 5 health!")
		end
	end
end
ProcFunctions.heal_permanent_proc_on_kill_melee = function (player, buff, params)
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
		if player.local_player then
			mod:echo("Melee Bloodlust awarded you 10 health!")
		end
	end
end
ProcFunctions.heal_permanent_proc_on_hit_ranged = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "RANGED" or buff_type == "RANGED_ABILITY") then
		local heal_amount = buff.bonus

		DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
		if player.local_player then
			mod:echo("Ranged Regrowth awarded you 5 health!")
		end
	end
end
ProcFunctions.heal_permanent_proc_on_kill_ranged = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local damage_dealt = params[8] and params[8].damage_amount or 0
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	local target_health_extension = ScriptUnit.extension(hit_unit, "health_system")
	local killing_blow = target_health_extension:current_health() < damage_dealt

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "RANGED" or buff_type == "RANGED_ABILITY") and killing_blow then
		local heal_amount = buff.bonus

		DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
		if player.local_player then
			mod:echo("Ranged Bloodlust awarded you 10 health!")
		end
	end
end

ProcFunctions.scavenger_get_ammo_on_kill = function (player, buff, params)
	local player_unit = player.player_unit

	local hit_unit = params[1]
	local damage_dealt = params[8] and params[8].damage_amount or 0
	local buff_type = params[6]
	local breed = AiUtils.unit_breed(hit_unit)

	local target_health_extension = ScriptUnit.extension(hit_unit, "health_system")
	local killing_blow = target_health_extension:current_health() < damage_dealt

	if Unit.alive(player_unit) and Managers.player.is_server and breed and (buff_type == "RANGED" or buff_type == "RANGED_ABILITY") and killing_blow then	
			local buff_template = buff.template
			local weapon_slot = "slot_ranged"
			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local slot_data = inventory_extension:get_slot_data(weapon_slot)
			local right_unit_1p = slot_data.right_unit_1p
			local left_unit_1p = slot_data.left_unit_1p
			local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
			local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
			local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
			local ammo_bonus_fraction = mod:get("scavenger_ammo_regen") --buff_template.ammo_bonus_fraction
			local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)
			if ammo_extension then
				ammo_extension:add_ammo_to_reserve(ammo_amount)
				if player.local_player then
					mod:echo("Scavenger awarded you " .. tostring(ammo_amount) .. " ammunition!")
				end
			end
	end
end

--Buffs

--Regrowth/Bloodlust
BuffTemplates.regrowth_vt1_melee = {
	name = "regrowth_vt1_melee",
	buffs = {
		{
			proc_chance = 0.07,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_hit_melee",
			bonus = 5
		}
	}
}
BuffTemplates.bloodlust_vt1_melee = {
	name = "bloodlust_vt1_melee",
	buffs = {
		{
			proc_chance = 0.1,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_kill_melee",
			bonus = 10
		}
	}
}
BuffTemplates.regrowth_vt1_ranged = {
	name = "regrowth_vt1_ranged",
	buffs = {
		{
			proc_chance = 0.07,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_hit_ranged",
			bonus = 5
		}
	}
}
BuffTemplates.bloodlust_vt1_ranged = {
	name = "bloodlust_vt1_ranged",
	buffs = {
		{
			proc_chance = 0.1,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "heal_permanent_proc_on_kill_ranged",
			bonus = 10
		}
	}
}
--Scavenger
BuffTemplates.scavenger_vt1 = {
	name = "scavenger_vt1",
	buffs = {
		{
			proc_chance = mod:get("scavenger_proc_chance") or 0.07,
			event_buff = true,
			event = "on_damage_dealt",
			buff_func = "scavenger_get_ammo_on_kill",
			ammo_bonus_fraction = 0.05
		},
	}
}
-- Adding buffs through talent
mod:hook_origin(TalentExtension, "apply_buffs_from_talents", function (self, talent_ids)
	local hero_name = self._hero_name
	local buff_extension = self.buff_extension
	local player = self.player

	self:_clear_buffs_from_talents()

	local talent_buff_ids = self._talent_buff_ids
	local is_server_bot = self.is_server and player.bot_player
	local talents = Talents[hero_name]

	if not talents then
		return
	end
	
	if mod:get("weapon") then
		if mod:get("trait") then
			local buff_template = "bloodlust_vt1_melee"
			local id = buff_extension:add_buff(buff_template)
			talent_buff_ids[#talent_buff_ids + 1] = id 
		else
			local buff_template = "regrowth_vt1_melee"
			local id = buff_extension:add_buff(buff_template)
			talent_buff_ids[#talent_buff_ids + 1] = id
		end
	else
		if mod:get("trait") then
			local buff_template = "bloodlust_vt1_ranged"
			local id = buff_extension:add_buff(buff_template)
			talent_buff_ids[#talent_buff_ids + 1] = id
		else
			local buff_template = "regrowth_vt1_ranged"
			local id = buff_extension:add_buff(buff_template)
			talent_buff_ids[#talent_buff_ids + 1] = id
		end
	end

	if mod:get("scavenger") then
		local buff_template = "scavenger_vt1"
		local id = buff_extension:add_buff(buff_template)
		talent_buff_ids[#talent_buff_ids + 1] = id
	end
end)

--Removing traits and properties
mod:hook(GearUtils, "get_property_and_trait_buffs", function (func, backend_items, backend_id, buffs_table, only_no_wield_required)
    return buffs_table
end)