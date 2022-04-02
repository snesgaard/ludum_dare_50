local dl = require "darklord"

local core = {}

function core.on_push(ctx)
    ctx.world:push(dl.scene.mystery)
end

function core.on_reveal(ctx, ...)
    ctx.world:push(dl.scene.navigation)
end

function core.draw_gui(ctx)
    dl.render.stat_ui(love.math.random(0, 9999), 20)
end

return core
