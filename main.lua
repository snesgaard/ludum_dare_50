local nw = require "nodeworks"
local event_card = require "render.event_card"
local stat_ui = require "render.stat_ui"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(1, 1, 1)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
end

function love.draw()
    gfx.scale(4, 4)
    gfx.setColor(1, 1, 1)

    for i, card_type in ipairs{"battle", "event", "resource", "rest"} do
        event_card(card_type, 10 + 80 * (i - 1), 40)
    end

    gfx.origin()
    stat_ui(love.math.random(0, 9999), 20)
end
