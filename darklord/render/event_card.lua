local nw = require "nodeworks"

local atlas = "art/characters"

local frames = {
    generic = "card_back_generic",
    battle = "card_back_battle",
    event = "card_back_event",
    resource = "card_back_resource",
    rest = "card_back_rest"
}

local function get_frame(type)
    local frame_name = frames[type]
    if not frame_name then return end

    return get_atlas(atlas):get_frame(frame_name)
end

local event_card = {}
event_card.__index = event_card

function event_card:card_size()
    local x, y, w, h = get_frame("generic").quad:getViewport()
    return w, h
end

function event_card:__call(type, x, y)
    get_frame("generic"):draw(x, y)

    local top_frame = get_frame(type)

    if not top_frame then return end
    top_frame:draw(x, y)
end

return setmetatable({}, event_card)
