local dl = require "darklord"

local navigation = {}

navigation.event_types = {"battle", "resource", "rest", "event"}

function navigation.on_push(ctx)
    local rng = love.math.random
    local size = #navigation.event_types

    local card_size = spatial(0, 0, dl.render.event_card.card_size())
    local screen_size = vec2(
        gfx.getWidth() / dl.constants.field_scale.x,
        gfx.getHeight() / dl.constants.field_scale.y
    )

    ctx.event_options = {
        navigation.event_types[rng(size)],
        navigation.event_types[rng(size)],
        navigation.event_types[rng(size)],
    }

    local y = math.floor((screen_size.y - card_size.h) / 2)
    local margin = 60
    local min_x = margin
    local max_x = screen_size.x - margin - card_size.w

    ctx.click_boxes = {}

    for index, _ in ipairs(ctx.event_options) do
        local s = (index - 1) / (#ctx.event_options - 1)
        ctx.click_boxes[index] = card_size:move(min_x * (1 - s) + max_x * s, y)
    end
end

function navigation.draw(ctx)
    for i, card_type in ipairs(ctx.event_options) do
        local cb = ctx.click_boxes[i]
        dl.render.event_card(card_type, cb.x, cb.y)
    end
end

function navigation.draw_gui(ctx)
    dl.render.event_title("Pick an event")
end

function navigation.mousepressed(ctx, x, y, button, fx, fy)
    for index, box in ipairs(ctx.click_boxes) do
        if box:is_point_inside(fx, fy) then
            print("You clicked a ", ctx.event_options[index])
            ctx.world:pop("fafa")
            return
        end
    end
end

return navigation
