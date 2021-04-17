local mod = get_mod("Dofile")

-- Traits
local PROXY = "ring_potion_spread"
local PARRY = "melee_timed_block_cost"
local SHRAPNEL = "trinket_grenade_damage_taken"
local GRENADIER = "trinket_not_consume_grenade"
local HAND_OF_SHALLYA = "necklace_heal_self_on_heal_other"
local OPPORTUNIST = "melee_counter_push_power"

-- Props
local REVIVE_SPEED = "revive_speed"
local STAMINA_REGEN = "fatigue_regen"
local BCR = "block_cost"
local CRIT_CHANCE = "crit_chance"
local ATTACK_SPEED = "attack_speed"
local BOON_OF_SHALLYA = "necklace_increased_healing_received"
local THERMAL_EQUALIZER = "ranged_reduced_overcharge" -- TODO: Port Earthing Rune
local STAMINA = "stamina"

-- Talents
local HEAL_SHARE = "btf_heal_share"
local SCAVENGER = "btf_scavenger"

--[[
   _____             __ _
  / ____|           / _(_)
 | |     ___  _ __ | |_ _  __ _ _   _ _ __ ___
 | |    / _ \| '_ \|  _| |/ _` | | | | '__/ _ \
 | |___| (_) | | | | | | | (_| | |_| | | |  __/
  \_____\___/|_| |_|_| |_|\__, |\__,_|_|  \___|
     | |                   __/ |
     | |__   ___ _ __ ___ |___/
     | '_ \ / _ \ '__/ _ \
     | | | |  __/ | |  __/
     |_| |_|\___|_|  \___| [] [] []
]]--

local BOSS_DAMAGE_PERCENT = 125
local DODGE_STAMINA_REGEN_DELAY = 0.4 -- between 0 and 1
local PROC_CHANCE = {
    scavenger_get_ammo_on_kill = 0.07,

    heal_permanent_proc_on_hit_melee = 0.07,
    heal_permanent_proc_on_hit_ranged = 0.07,

    heal_permanent_proc_on_kill = 0.1
}
local SCAVENGER_REFUND_PERCENT = 0.05

local HEAL_SHARE_MULTIPLIER = 0.2

local HEAL_SHARE_RANGE = 10

local HANDMAIDEN_STAM_REGEN_MULITPLIER = 1

-- Traits and Properties Configuration (Multipliers are percentages where 0 = 0% and 1 = 100%)

local PROXY_SHARE_DISTANCE = 10

local PARRY_MULTIPLIER = -1

local SHRAPNEL_MULTIPLIER = 0.2

local SHRAPNEL_DURATION = 10

local SHRAPNEL_MAX_STACKS = 1

local GRENADIER_PROC_CHANCE = 0.25

local HAND_OF_SHALLYA_MULTIPLIER = 0.5

local OPPORTUNIST_MULTIPLIER = 0.5


local REVIVE_SPEED_MULTIPLIER = -0.3

local STAMINA_REGEN_MULTIPLIER = 0.3

local BLOCK_COST_MULTIPLIER = -0.3

local CRIT_CHANCE_MULTIPLIER = 0.05

local ATTACK_SPEED_MULTIPLIER = 0.05

local BOON_OF_SHALLYA_MULTIPLIER = 0.3

local STAMINA_SHIELDS_BONUS = 2

--[[
 __     __                _           _ _     _
 \ \   / /               | |         (_) |   | |
  \ \_/ /__  _   _ _ __  | |__  _   _ _| | __| |
   \   / _ \| | | | '__| | '_ \| | | | | |/ _` |
    | | (_) | |_| | |    | |_) | |_| | | | (_| |
    |_|\___/ \__,_|_|    |_.__/ \__,_|_|_|\__,_| [] [] []
]]--

local MELEE_HP_TRAIT = "bloodlust" -- or "regrowth"

local RANGED_HP_TRAIT = "regrowth" -- or "bloodlust"

local PARTY_TRAIT = HEAL_SHARE -- One of PROXY, HEAL_SHARE, HAND_OF_SHALLYA, GRENADIER, SHRAPNEL, REVIVE_SPEED

local PERSONAL_TRAIT_1 = PARRY -- One of STAMINA_REGEN, BCR, CRIT_CHANCE, ATTACK_SPEED, PARRY

local PERSONAL_TRAIT_2 = SCAVENGER -- One of BOON_OF_SHALLYA, SCAVENGER, THERMAL_EQUALIZER, STAMINA, OPPORTUNIST

--[[
   _____          _
  / ____|        | |
 | |     ___   __| | ___
 | |    / _ \ / _` |/ _ \
 | |___| (_) | (_| |  __/
  \_____\___/ \__,_|\___| [] [] []
]]--

local TRAITS = {PARTY_TRAIT, PERSONAL_TRAIT_1, PERSONAL_TRAIT_2}

-- Proc Functions for Buffs
ProcFunctions.heal_permanent_proc_on_hit_melee = function(player, buff, params)
    local player_unit = player.player_unit

    local hit_unit = params[1]
    local buff_type = params[6]
    local breed = AiUtils.unit_breed(hit_unit)

    if Unit.alive(player_unit) and Managers.player.is_server and breed and
        (buff_type == "MELEE_1H" or buff_type == "MELEE_2H") then
        local heal_amount = buff.bonus

        DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
        if player.local_player then
            mod:echo("Melee Regrowth awarded you 5 health!")
        end
    end
end

ProcFunctions.heal_permanent_proc_on_hit_ranged = function(player, buff, params)
    local player_unit = player.player_unit

    local hit_unit = params[1]
    local hit_zone_name = params[3]
    local buff_type = params[6]
    local target_number = params[7]
    local breed = AiUtils.unit_breed(hit_unit)

    if Unit.alive(player_unit) and Managers.player.is_server and breed and
        (buff_type == "RANGED" or buff_type == "RANGED_ABILITY") and hit_zone_name ~= "full" and target_number ~= nil then
        local heal_amount = buff.bonus

        DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
        if player.local_player then
            mod:dump(params, "params", 4)
            mod:echo("Ranged Regrowth awarded you 5 health!")
        end
    end
end

ProcFunctions.heal_permanent_proc_on_kill = function(player, buff, params)
    local player_unit = player.player_unit

    local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
    local wielded_slot = inventory_extension:get_wielded_slot_name()

    local should_proc = false
    if wielded_slot == "slot_ranged" and RANGED_HP_TRAIT == "bloodlust" then
        should_proc = true
    elseif wielded_slot == "slot_melee" and MELEE_HP_TRAIT == "bloodlust" then
        should_proc = true
    end

    if Unit.alive(player_unit) and Managers.player.is_server and should_proc then
        local heal_amount = buff.bonus
        DamageUtils.heal_network(player_unit, player_unit, heal_amount, "career_passive")
        if player.local_player then
            mod:echo("%s Bloodlust awarded you 10 health!", wielded_slot)
        end
    end
end

ProcFunctions.scavenger_get_ammo_on_kill = function(player, buff, params)
    local player_unit = player.player_unit

    local killing_blow = params[1]
    local weapon = killing_blow[7]
    local weapon_template = ItemMasterList[weapon]
    if not weapon_template then
        return
    end
    local is_ranged = weapon_template.slot_type == "ranged"

    if Unit.alive(player_unit) and Managers.player.is_server and is_ranged then
        local buff_template = buff.template
        local weapon_slot = "slot_ranged"
        local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
        local slot_data = inventory_extension:get_slot_data(weapon_slot)
        local right_unit_1p = slot_data.right_unit_1p
        local left_unit_1p = slot_data.left_unit_1p
        local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
        local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
        local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
        if ammo_extension then
            local ammo_bonus_fraction = SCAVENGER_REFUND_PERCENT or buff_template.ammo_bonus_fraction
            local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)
            ammo_extension:add_ammo_to_reserve(ammo_amount)
            if player.local_player then
                mod:echo("Scavenger awarded you " .. tostring(ammo_amount) .. " ammunition!")
            end
        end
    end
end

-- Buffs

BuffTemplates.kerillian_maidenguard_passive_stamina_regen_buff.buffs[1].multiplier = HANDMAIDEN_STAM_REGEN_MULITPLIER

-- Regrowth/Bloodlust
BuffTemplates.regrowth_vt1_melee = {
    name = "regrowth_vt1_melee",
    buffs = {{
        proc_chance = PROC_CHANCE.heal_permanent_proc_on_hit_melee,
        event_buff = true,
        event = "on_damage_dealt",
        buff_func = "heal_permanent_proc_on_hit_melee",
        bonus = 5
    }}
}
BuffTemplates.regrowth_vt1_ranged = {
    name = "regrowth_vt1_ranged",
    buffs = {{
        proc_chance = PROC_CHANCE.heal_permanent_proc_on_hit_ranged,
        event_buff = true,
        event = "on_damage_dealt",
        buff_func = "heal_permanent_proc_on_hit_ranged",
        bonus = 5
    }}
}
BuffTemplates.bloodlust_vt1 = {
    name = "bloodlust_vt1",
    buffs = {{
        proc_chance = PROC_CHANCE.heal_permanent_proc_on_kill,
        event_buff = true,
        event = "on_kill",
        buff_func = "heal_permanent_proc_on_kill",
        bonus = 10
    }}
}

-- Scavenger
BuffTemplates.scavenger_vt1 = {
    name = "scavenger_vt1",
    buffs = {{
        proc_chance = PROC_CHANCE.scavenger_get_ammo_on_kill,
        event_buff = true,
        event = "on_kill",
        buff_func = "scavenger_get_ammo_on_kill",
        ammo_bonus_fraction = SCAVENGER_REFUND_PERCENT
    }}
}

--Traits/Properties
TrinketSpreadDistance = PROXY_SHARE_DISTANCE
local parry_buff = BuffTemplates.traits_melee_timed_block_cost.buffs[1]
parry_buff.multiplier = PARRY_MULTIPLIER
local shrapnel_buff = BuffTemplates.trait_trinket_grenade_damage_taken_buff.buffs[1]
shrapnel_buff.max_stacks = SHRAPNEL_MAX_STACKS
shrapnel_buff.multiplier = SHRAPNEL_MULTIPLIER
shrapnel_buff.duration = SHRAPNEL_DURATION
local grenadier_buff = BuffTemplates.trait_trinket_not_consume_grenade.buffs[1]
grenadier_buff.proc_chance = GRENADIER_PROC_CHANCE
local hos_buff = BuffTemplates.trait_necklace_heal_self_on_heal_other.buffs[1]
hos_buff.multiplier = HAND_OF_SHALLYA_MULTIPLIER
local opportunist_buff = BuffTemplates.traits_melee_counter_push_power.buffs[1]
opportunist_buff.multiplier = OPPORTUNIST_MULTIPLIER
opportunist_buff.stat_buff = "push_power" -- Removes attacking requirement

local revive_speed_buff = BuffTemplates.properties_revive_speed.buffs[1]
revive_speed_buff.variable_multiplier = nil
revive_speed_buff.multiplier = REVIVE_SPEED_MULTIPLIER
local stam_regen_buff = BuffTemplates.properties_fatigue_regen.buffs[1]
stam_regen_buff.variable_multiplier = nil
stam_regen_buff.multiplier = STAMINA_REGEN_MULTIPLIER
local block_cost_buff = BuffTemplates.properties_block_cost.buffs[1]
block_cost_buff.variable_multiplier = nil
block_cost_buff.multiplier = BLOCK_COST_MULTIPLIER
local crit_chance_buff = BuffTemplates.properties_crit_chance.buffs[1]
crit_chance_buff.variable_multiplier = nil
crit_chance_buff.multiplier = CRIT_CHANCE_MULTIPLIER
local attack_speed_buff = BuffTemplates.properties_attack_speed.buffs[1]
attack_speed_buff.variable_multiplier = nil
attack_speed_buff.multiplier = ATTACK_SPEED_MULTIPLIER
local bos_buff = BuffTemplates.trait_necklace_increased_healing_received.buffs[1]
bos_buff.multiplier = BOON_OF_SHALLYA_MULTIPLIER
local stamina_buff = BuffTemplates.properties_stamina.buffs[1]
stamina_buff.variable_bonus = nil
stamina_buff.bonus = STAMINA_SHIELDS_BONUS

local heal_share_buff = BuffTemplates.conqueror.buffs[1]
heal_share_buff.multiplier = HEAL_SHARE_MULTIPLIER
heal_share_buff.range = HEAL_SHARE_RANGE



-- debug proc chances
mod:hook(BuffExtension, "has_procced", function(func, self, proc_chance, buff)
    local chance = PROC_CHANCE[buff.buff_func] or proc_chance
    return func(self, chance, buff)
end)

-- Adding buffs through talent
mod:hook(TalentExtension, "apply_buffs_from_talents", function(func, self, talent_ids)
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

    if MELEE_HP_TRAIT == "bloodlust" or RANGED_HP_TRAIT == "bloodlust" then
        local id = buff_extension:add_buff("bloodlust_vt1")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if MELEE_HP_TRAIT == "regrowth" then
        local id = buff_extension:add_buff("regrowth_vt1_melee")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if RANGED_HP_TRAIT == "regrowth" then
        local id = buff_extension:add_buff("regrowth_vt1_ranged")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if table.contains(TRAITS, "btf_scavenger") then
        local id = buff_extension:add_buff("scavenger_vt1")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if table.contains(TRAITS, "btf_heal_share") then
        local id = buff_extension:add_buff("conqueror")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end

    local career_name = self._career_name
    if career_name == "we_waywatcher" then
        local id = buff_extension:add_buff("kerillian_waywatcher_activated_ability_restore_ammo_on_career_skill_special_kill")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if career_name == "we_shade" then
        local id = buff_extension:add_buff("kerillian_shade_activated_ability_quick_cooldown")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
    if career_name == "dr_slayer" then
        local id = buff_extension:add_buff("bardin_slayer_passive_cooldown_reduction_on_max_stacks")
        talent_buff_ids[#talent_buff_ids + 1] = id
    end
end)

-- Removing traits and properties
mod:hook(GearUtils, "get_property_and_trait_buffs",
    function(func, backend_items, backend_id, buffs_table, only_no_wield_required)

        for i, trait_key in ipairs(TRAITS) do

            local trait_data = WeaponTraits.traits[trait_key] or WeaponProperties.properties[trait_key]
            if trait_data then
                local buff_name = trait_data.buff_name
                local buffer = trait_data.buffer or "client"
                local no_wield_required = WeaponTraits.traits.no_wield_required

                if BuffTemplates[buff_name] then
                    if only_no_wield_required and no_wield_required then
                        buffs_table[buffer][buff_name] = {
                            variable_value = 1
                        }
                    elseif not only_no_wield_required and not no_wield_required then
                        buffs_table[buffer][buff_name] = {
                            variable_value = 1
                        }
                    end
                end
            end
        end

        return buffs_table
end)

-- dodge stam regen delay
mod:hook_safe(GenericStatusExtension, "add_fatigue_points", function(self, type)
    if type == "action_dodge" then
        local t = Managers.time:time("game")
        self.last_fatigue_gain_time = t - DODGE_STAMINA_REGEN_DELAY
    end
end)

-- boss/lord damage multiplier
mod:hook(DamageUtils, "calculate_damage",
    function(func, damage_output, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve,
        boost_damage_multiplier, is_critical_strike, damage_profile, target_index, backstab_multiplier, damage_source)
        local dmg = func(damage_output, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve,
                        boost_damage_multiplier, is_critical_strike, damage_profile, target_index, backstab_multiplier,
                        damage_source)

        if target_unit then
            local breed = Unit.get_data(target_unit, "breed")
            if breed and breed.boss then
                dmg = dmg * BOSS_DAMAGE_PERCENT / 100
                return dmg
            end
        end

        return dmg
    end)

-- no invisibility
mod:hook(GenericStatusExtension, "set_invisible", function(func, self, invisible, force_third_person)
    return
end)

-- -- Host on complete msg
-- mod:hook_safe(VoteTemplates.game_settings_vote, "on_complete", function(result)
--     local print_traits = ""
--     for i, key in ipairs(TRAITS) do
--         if i > 1 then
--             print_traits = print_traits .. ", "
--         end
--         local trait_data = WeaponTraits.traits[key] or WeaponProperties.properties[key]
--         if trait_data then
--             print_traits = print_traits .. Localize(trait_data.display_name)
--         end

--         if key == "btf_scavenger" then
--             print_traits = print_traits .. "Scavenger"
--         end

--         if key == "btf_heal_share" then
--             print_traits = print_traits .. "Heal Share"
--         end
--     end

--     if result == 1 then
--         local local_player = Managers.player:local_player()
--         Managers.chat:send_chat_message(1, local_player:local_player_id(), print_traits, false, nil, false)
--     end
-- end)

-- -- Clients on complete msg
-- mod:hook_safe(VoteManager "rpc_client_complete_vote", function (self, channel_id, vote_result)
--     local print_traits = ""
--     for i, key in ipairs(TRAITS) do
--         if i > 1 then
--             print_traits = print_traits .. ", "
--         end
--         local trait_data = WeaponTraits.traits[key] or WeaponProperties.properties[key]
--         if trait_data then
--             print_traits = print_traits .. Localize(trait_data.display_name)
--         end

--         if key == "btf_scavenger" then
--             print_traits = print_traits .. "Scavenger"
--         end

--         if key == "btf_heal_share" then
--             print_traits = print_traits .. "Heal Share"
--         end
--     end

--     if vote_result == 1 then
--         local local_player = Managers.player:local_player()
--         Managers.chat:send_chat_message(1, local_player:local_player_id(), print_traits, false, nil, false)
--     end
-- end)

local local_player = Managers.player:local_player()
local player_unit = local_player.player_unit
local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
talent_extension:apply_buffs_from_talents()

local print_traits = ""
for i, key in ipairs(TRAITS) do
    if i > 1 then
        print_traits = print_traits .. ", "
    end
    local trait_data = WeaponTraits.traits[key] or WeaponProperties.properties[key]
    if trait_data then
        print_traits = print_traits .. Localize(trait_data.display_name)
    end

    if key == "btf_scavenger" then
        print_traits = print_traits .. "Scavenger"
    end

    if key == "btf_heal_share" then
        print_traits = print_traits .. "Heal Share"
    end
end

mod:echo("B2F loaded")

Managers.chat:send_chat_message(1, local_player:local_player_id(), print_traits, false, nil, false)
