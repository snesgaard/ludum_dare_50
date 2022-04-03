local dl = require "darklord"
local rng = love.math.random

local navigation = {}

navigation.event_types = {"battle", "resource", "rest", "event"}

function navigation.generate_events()
    local pool = list()
    local enemies = dl.enemies

    for _, enemy in pairs(enemies) do
        table.insert(pool, enemy)
    end

    local enemies = pool:shuffle():sub(1, 3)
    local events = {}

    for _, enemy in ipairs(enemies) do
        table.insert(events, {type="battle", enemy=enemy})
    end

    return events
end

function navigation.push_event(ctx, event)
    if event.type == "battle" then
        ctx.world:move(dl.scene.battle, ctx.player, event.enemy)
    end
end

function navigation.draw_event_card(event, x, y)
    if event.type ~= "battle" then
        dl.render.event_card(event.type, x, y)
    else
        local enemy = event.enemy
        local frame = get_atlas(enemy.atlas):get_frame(enemy.image)
        dl.render.event_card(frame, x, y)
    end
end

function navigation.on_push(ctx, player)
    local size = #navigation.event_types

    local card_size = spatial(0, 0, dl.render.event_card.card_size())
    local screen_size = vec2(
        gfx.getWidth() / dl.constants.field_scale.x,
        gfx.getHeight() / dl.constants.field_scale.y
    )

    ctx.event_options = navigation.generate_events()

    ctx.player = player
    local y = math.floor((screen_size.y - card_size.h) / 2)
    local margin = 60
    local min_x = margin
    local max_x = screen_size.x - margin - card_size.w

    ctx.click_boxes = {}

    for index, _ in ipairs(ctx.event_options) do
        local s = (index - 1) / (#ctx.event_options - 1)
        ctx.click_boxes[index] = card_size:move(min_x * (1 - s) + max_x * s, y)
    end

    ctx.card_hovered = nil
end

function navigation.keypressed(ctx, key)
    local options = #ctx.event_options
    local h = ctx.card_hovered
    if key == "left" then
        if not h or h <= 1 then
            h = options
        else
            h = h - 1
        end
    elseif key == "right" then
        if not h or options <= h then
            h = 1
        else
            h = h + 1
        end
    elseif key == "space" and h then
        local event = ctx.event_options[h]
        if event then
            navigation.push_event(ctx, event)
        end
    end

    ctx.card_hovered = h
end

function navigation.draw(ctx)
    for i, event in ipairs(ctx.event_options) do
        local cb = ctx.click_boxes[i]
        local dy = ctx.card_hovered == i and -8 or 0
        navigation.draw_event_card(event, cb.x, cb.y + dy)
    end
end

function navigation.draw_gui(ctx)
    dl.render.event_title("Pick an event")
end

function navigation.mousepressed(ctx, x, y, button, fx, fy)
    for index, box in ipairs(ctx.click_boxes) do
        if box:is_point_inside(fx, fy) then
            --ctx.world:pop("fafa")
            --return
        end
    end
end

return navigation
