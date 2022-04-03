local dl = require "darklord"
local battle = dl.system.battle
local rng = love.math.random

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

function rh.happy_jazz(ctx)
    local heal = 3
    return ctx:entity()
        :set(dl.component.defend, 5)
        :set(dl.component.title, "Happy Jazz")
        :set(dl.component.heal, 3)
        :set(dl.component.text, string.format("Heal yourself for %i", heal))
end

function rh.jazz_frenzy(ctx)
    local attack = 3

    local function effect(immediate_effect, user)
        local deck = user:ensure(dl.component.deck)
        for _, card in ipairs(deck) do
            battle.change_attack(card, attack)
        end
    end

    return ctx:entity()
        :set(dl.component.defend, 5)
        :set(dl.component.title, "Jazz Frenzy")
        :set(dl.component.text, string.format("Increase attack by %i", attack))
        :set(dl.component.effect, effect)
end

function rh.lucky(ctx)
    local function effect(immediate_effect, user)
        local deck = user:get(dl.component.hand) or user:ensure(dl.component.deck)

        local deck = list(unpack(deck)):shuffle()

        for _, card in ipairs(deck) do
            local attack = battle.read_attack(card)

            if attack > 0 then
                battle.change_attack(card, attack)
                return
            end
        end
    end

    return ctx:entity()
        :set(dl.component.title, "Lucky")
        :set(dl.component.text, "Doubles attack of a random card in hand.")
        :set(dl.component.effect, effect)
end

function rh.better_block(ctx)
    return ctx:entity()
        :set(dl.component.title, "Better Block")
        :set(dl.component.defend, 10)
        :set(dl.component.text, "Just better.")
end

function rh.fiery_roar(ctx)
    local defense_reduce = 3

    local function effect(immediate, user, target)
        local deck = target:ensure(dl.component.deck)

        for _, card in ipairs(deck) do
            battle.change_defend(card, -defense_reduce)
        end
    end

    return ctx:entity()
        :set(dl.component.title, "Fiery Roar")
        :set(dl.component.attack, 2)
        :set(dl.component.defend, 5)
        :set(dl.component.text, string.format("Reduce enemy defense by %i", defense_reduce))
        :set(dl.component.effect, effect)
end

function rh.tomato_breath(ctx)
    local attack_reduce = 3

    local function effect(immediate, user, target)
        local deck = target:ensure(dl.component.deck)

        for _, card in ipairs(deck) do
            battle.change_attack(card, -attack_reduce)
        end
    end

    return ctx:entity()
        :set(dl.component.title, "Fire Breath")
        :set(dl.component.attack, 8)
        :set(dl.component.defend, 2)
        :set(dl.component.text, string.format("Reduce enemy attack by %i", attack_reduce))
        :set(dl.component.effect, effect)
end

function rh.barricade(ctx)
    local defense_increase = 5

    local function effect(immediate, user, target)
        local deck = user:ensure(dl.component.deck)

        for _, card in ipairs(deck) do
            battle.change_defend(card, defense_increase)
        end
    end

    return ctx:entity()
        :set(dl.component.title, "Barricade")
        :set(dl.component.defend, 2)
        :set(dl.component.text, string.format("Increase defend by %i", defense_increase))
        :set(dl.component.effect, effect)
end

function rh.panic(ctx)
    local function effect(immediate, user)
        local deck = user:ensure(dl.component.deck)

        for _, card in ipairs(deck) do
            local d = battle.read_defend(card)
            battle.change_defend(card, -d)
        end
    end

    return ctx:entity()
        :set(dl.component.title, "Panic!")
        :set(dl.component.defend, 99)
        :set(dl.component.text, "Reduce all card defend to 0.")
        :set(dl.component.effect, effect)
end

return setmetatable(rh, rh)
