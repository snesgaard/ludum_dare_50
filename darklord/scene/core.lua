local dl = require "darklord"

local core = {}

function core.on_push(ctx)
    ctx.player = ctx:entity()
        :set(dl.component.health, 20)
        :set(dl.component.money, 69)

    ctx.world:push(dl.scene.battle, ctx.player)
end

function core.on_reveal(ctx, ...)
    ctx.world:push(dl.scene.navigation)
end

function core.draw_gui(ctx)
    dl.render.stat_ui(
        ctx.player:get(dl.component.health),
        ctx.player:get(dl.component.money)
    )
end

return core
