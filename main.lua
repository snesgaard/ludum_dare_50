local nw = require "nodeworks"
local dl = require "darklord"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(1, 1, 1)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
end

function love.draw()
    gfx.scale(3, 3)
    gfx.setColor(1, 1, 1)

    for i, card_type in ipairs{"battle", "event", "resource", "rest"} do
        dl.render.event_card(card_type, 10 + 80 * (i - 1), 40)
    end

    dl.render.action_card(
        100, 100, "yo mom", "buy me more jewlery!", 10, 20
    )

    gfx.origin()
    dl.render.stat_ui(love.math.random(0, 9999), 20)
end
