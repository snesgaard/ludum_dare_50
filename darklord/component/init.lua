local rh = {}

local BASE = ...

function rh.__index(t, k)
    return require(BASE .. "." .. k)
end

function rh.hand(hand) return hand or list() end

function rh.draw(draw) return draw or list() end

function rh.discard(discard) return discard or list() end

function rh.threat(t) return t or 0 end

function rh.health(health) return math.max(0, health) end

function rh.money(money) return math.max(0, money) end

function rh.card_to_play(l) return l or list() end

function rh.attack(a) return a or 0 end

function rh.defend(d) return d or 0 end

function rh.temporary_attack(a) return a or 0 end

function rh.temporary_defend(d) return d or 0 end

function rh.title(t) return t or "No Title" end

function rh.text(t) return t or "" end

function rh.deck(deck) return deck or list() end

function rh.ai_card_order(deck, count)
    return List.shuffle(deck):sub(1, count)
end

function rh.effect(func)
    return func or function() end
end

return setmetatable(rh, rh)
