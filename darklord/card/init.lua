local dl = require "darklord"
local battle = dl.system.battle

local rh = {}

local BASE = ...

function rh.__index(t, k)
    return require(BASE .. "." .. k)
end

local slime_buffer = {}
slime_buffer.__index = slime_buffer
slime_buffer.defense_increase = 2

function slime_buffer.effect(immediate, user)
    local hand = user:ensure(dl.component.deck)

    for _, card in ipairs(hand) do
        battle.change_defend(card, slime_buffer.defense_increase)
    end
end

function slime_buffer:__call(ctx)
    return ctx:entity()
        :set(dl.component.defend, 2)
        :set(dl.component.title, "Slime Buffer")
        :set(
            dl.component.text,
            string.format(
                "Increase defense by %i", slime_buffer.defense_increase
            )
        )
        :set(dl.component.effect, slime_buffer.effect)
end

rh.slime_buffer = setmetatable({}, slime_buffer)

function rh.slime_slap(ctx)
    return ctx:entity()
        :set(dl.component.attack, 5)
        :set(dl.component.defend, 5)
        :set(dl.component.title, "Slime Slap")
        :set(dl.component.text, "Ew...")
end

local overcommit = {}
overcommit.__index = overcommit

overcommit.attack_decrease = 3

function overcommit.effect(immediate_effect, user)
    local hand = user:ensure(dl.component.deck)

    for _, card in ipairs(hand) do
        battle.change_attack(card, -overcommit.attack_decrease)
    end
end

function overcommit:__call(ctx)
    return ctx:entity()
        :set(dl.component.attack, 15)
        :set(dl.component.defend, 0)
        :set(dl.component.title, "Overcommit")
        :set(
            dl.component.text,
            string.format("Decrease attack of your cards by %i", overcommit.attack_decrease)
        )
        :set(dl.component.effect, overcommit.effect)
end

rh.overcommit = setmetatable({}, overcommit)

local finale = {}
finale.__index = finale

finale.decrease = 10

function finale.effect(immediate_effect, user)
    local hand = user:ensure(dl.component.deck)

    for _, card in ipairs(hand) do
        battle.change_attack(card, -finale.decrease)
        battle.change_defend(card, -finale.decrease)
    end
end

function finale:__call(ctx)
    local text = string.format("Decrease attack and defend of your cards by %i.", finale.decrease)
    return ctx:entity()
        :set(dl.component.attack, 15)
        :set(dl.component.defend, 15)
        :set(dl.component.title, "Finale")
        :set(dl.component.text, text)
        :set(dl.component.effect, finale.effect)
end

rh.finale = setmetatable({}, finale)




return setmetatable(rh, rh)
