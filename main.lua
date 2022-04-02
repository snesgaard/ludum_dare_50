local nw = require "nodeworks"
local dl = require "darklord"

local systems = {}

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(1, 1, 1)

    world = nw.ecs.world(systems)
    world:push(dl.scene.core)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end

    world("keypressed", key)
end

function love.mousepressed(x, y, button, isTouch)
    local s = dl.constants.field_scale
    world("mousepressed", x, y, button, x / s.x, y / s.y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    local s = dl.constants.field_scale
    world("mousemoved", x, y, dx, dy, x / s.x, y / s.y)
end

function love.update(dt)
    world("update", dt)
end

function love.draw()
    gfx.scale(dl.constants.field_scale:unpack())
    gfx.setColor(1, 1, 1)

--    for i, card_type in ipairs{"battle", "event", "resource", "rest"} do
--        dl.render.event_card(card_type, 10 + 80 * (i - 1), 40)
--    end

--    dl.render.action_card(
--        100, 100, "yo mom", "buy me more jewlery!", 10, 20
--    )

    world("draw")
    gfx.origin()
--    dl.render.stat_ui(love.math.random(0, 9999), 20)
    world("draw_gui")
end
