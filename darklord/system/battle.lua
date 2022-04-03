local dl = require "darklord"
local nw = require "nodeworks"

local battle = nw.ecs.system()

function battle.aggregate_card_effects(user, target, cards)
    local card_stack = {unpack(cards)}
    local effect = {attack = 0, defend = 0}

    while #card_stack > 0 do
        local card = card_stack[#card_stack]
        table.remove(card_stack)
        effect.attack = effect.attack + card.attack
        effect.defend = effect.defend + card.defend
        if card.effect then card.effect(effect, user, target, card_stack) end
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

    return {player = player_change, enemy = enemy_change}
end

return battle
