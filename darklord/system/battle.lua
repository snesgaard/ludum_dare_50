local dl = require "darklord"
local nw = require "nodeworks"

local battle = nw.ecs.system()

function battle.change_attack(entity, ca)
    local a = entity:ensure(dl.component.attack)
    if a == 0 then return end
    local ta = entity:ensure(dl.component.temporary_attack)
    local next_ta = math.max(-a, ta + ca)
    entity:set(dl.component.temporary_attack, next_ta)
end

function battle.change_defend(entity, cd)
    local d = entity:ensure(dl.component.defend)
    if d == 0 then return end
    local td = entity:ensure(dl.component.temporary_defend)
    local next_td = math.max(-d, td + cd)
    entity:set(dl.component.temporary_defend, next_td)
end

function battle.read_defend(card)
    local d = card:ensure(dl.component.defend) + card:ensure(dl.component.temporary_defend)
    return math.max(0, d)
end

function battle.read_attack(card)
    local a = card:ensure(dl.component.attack) + card:ensure(dl.component.temporary_attack)
    return math.max(0, a)
end

function battle.reset_card(card)
    card:set(dl.component.temporary_attack):set(dl.component.temporary_defend)
end

function battle.aggregate_card_effects(user, target, cards)
    local card_stack = list(unpack(cards)):reverse()
    local effect = {attack = 0, defend = 0}

    while #card_stack > 0 do
        local card = card_stack[#card_stack]
        table.remove(card_stack)
        effect.attack = effect.attack + battle.read_attack(card)
        effect.defend = effect.defend + battle.read_defend(card)
        --if card.effect then card.effect(effect, user, target, card_stack) end
        local card_effect = card:ensure(dl.component.effect)
        card_effect(effect, user, target, card_stack)
    end

    return effect
end

function battle.resolve(player, enemy)
    local player_card = player:get(dl.component.card_to_play)
    local enemy_card = enemy:get(dl.component.card_to_play)

    local player_effect = battle.aggregate_card_effects(
        player, enemy, player_card
    )
    local enemy_effect = battle.aggregate_card_effects(
        enemy, player, enemy_card
    )

    local player_change = {
        damage = math.max(0, enemy_effect.attack - player_effect.defend),
    }
    local enemy_change = {
        damage = math.max(0, player_effect.attack - enemy_effect.defend)
    }

    local change = {}

    change[player] = player_change
    change[enemy] = enemy_change

    return change
end

function battle.apply_resolution(all_changes)
    for entity, change in pairs(all_changes) do
        entity:map(dl.component.health, function(hp)
            return hp - change.damage
        end)
    end
end

return battle
