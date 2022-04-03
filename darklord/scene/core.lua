local dl = require "darklord"

local core = {}

core.deck_view_key = "tab"

function core.on_push(ctx)
    local init_deck = list(
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx)
    )

    ctx.player = ctx:entity()
        :set(dl.component.health, 20)
        :set(dl.component.money, 0)
        :set(dl.component.threat, 0)
        :set(dl.component.deck, init_deck)

    ctx.world:push(dl.scene.navigation, ctx.player)
    --ctx.world:push(dl.scene.card_view, ctx.player % dl.component.deck)
    --ctx.world:push(
    --    dl.scene.card_reward, ctx.player,
    --    list(dl.card.megaslap(ctx), dl.card.megaslap(ctx))
    --)
    --ctx.world:push(dl.scene.game_over)

    local screen = dl.constants.field_screen
    ctx.deck_view_layout = spatial(0, 0, 0, 0)
        :down(-10, screen.y * 0.5, 100, 20)
end

function core.on_reveal(ctx, ...)
    --ctx.world:push(dl.scene.navigation)
    if not dl.scene.battle.is_dead(ctx.player) then
        ctx.player:map(dl.component.threat, function(m) return m + 3 end)
        ctx.world:push(dl.scene.navigation, ctx.player)
    end
end

function core.draw(ctx)
    --dl.render.button(string.format("view deck (%s)", core.deck_view_key), ctx.deck_view_layout)
end

function core.draw_gui(ctx)
    dl.render.stat_ui(
        ctx.player:get(dl.component.health),
        ctx.player:get(dl.component.threat)
    )
end

function core.mousepressed(ctx, x, y, button, fx, fy)
    if ctx.deck_view_layout:is_point_inside(fx, fy) then
        ctx.world:push(dl.scene.card_view, ctx.player % dl.component.deck)
    end
end

function core.keypressed(ctx, key)
    if key == core.deck_view_key then
        ctx.world:push(dl.scene.card_view, ctx.player % dl.component.deck)
    end
end

return core
