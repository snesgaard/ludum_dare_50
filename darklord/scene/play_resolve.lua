local nw = require "nodeworks"
local dl = require "darklord"

local play_resolve = {}

function play_resolve.on_push(ctx, player, enemy)
    ctx.player = player or ctx:entity()
    ctx.enemy = enemy or ctx:entity()
    ctx.change = {}
    ctx.timer = nw.component.timer.create(2)
end

function play_resolve.resolve_play(ctx, user, target)
    local player_to_play = user:ensure(dl.component.card_to_play)

    if #player_to_play > 0 then
        local card = list(player_to_play:head())
        local cards_left = player_to_play:body()
        user:set(dl.component.card_to_play, cards_left)
        ctx.change[user] = dl.system.battle.aggregate_card_effects(
            user, target, card, ctx.change[user]
        )
    end

    return #player_to_play
end

function play_resolve.update(ctx, dt)
    ctx.timer:update(dt)

    if not ctx.timer:done() then return end

    ctx.timer:reset()



    if play_resolve.resolve_play(ctx, ctx.player, ctx.enemy) ~= 0 then
        return
    end

    if play_resolve.resolve_play(ctx, ctx.enemy, ctx.player) ~= 0 then
        return
    end

    dl.system.battle.apply_resolution(
        dl.system.battle.format_change(
            ctx.player, ctx.enemy, ctx.change[ctx.player], ctx.change[ctx.enemy]
        )
    )

    ctx.world:pop()
end

function play_resolve.draw_overlay(ctx)
    local attack_icon = get_atlas("art/characters"):get_frame("attack_icon")
    local defend_icon = get_atlas("art/characters"):get_frame("defend_icon")

    local mid_strip = spatial(
        0, dl.constants.field_screen.y * 0.3, dl.constants.field_screen.x, 20
    )
    local enemy_attack_layout = mid_strip:left(10, 0, -100, nil):sanitize()
    local enemy_attack_icon_layout = enemy_attack_layout:right(-5, 0, -16, nil):sanitize()

    local enemy_defend_layout = enemy_attack_layout:down(0, 10)
    local enemy_defend_icon_layout = enemy_defend_layout:right(-5, 0, -16, nil):sanitize()

    local player_attack_layout = mid_strip:right(10, 0, -100):sanitize()
    local player_attack_icon_layout = player_attack_layout:left(-5, 0, -16, nil):sanitize()

    local player_defend_layout = player_attack_layout:down(0, 10)
    local player_defend_icon_layout = player_defend_layout:left(-5, 0, -16, nil):sanitize()

    local enemy_change = ctx.change[ctx.enemy] or {}
    local player_change = ctx.change[ctx.player] or {}


    dl.render.button(enemy_change.attack or 0, enemy_attack_layout)
    attack_icon:draw("origin", enemy_attack_icon_layout:center():unpack())

    dl.render.button(enemy_change.defend or 0, enemy_defend_layout)
    defend_icon:draw("origin", enemy_defend_icon_layout:center():unpack())

    dl.render.button(player_change.attack or 0, player_attack_layout)
    attack_icon:draw("origin", player_attack_icon_layout:center():unpack())

    dl.render.button(player_change.defend or 0, player_defend_layout)
    defend_icon:draw("origin", player_defend_icon_layout:center():unpack())


    local bottom = spatial(0, dl.constants.field_screen.y, dl.constants.field_screen.x, 0)
        :up(0, 100, nil, 40)

    dl.render.button("Resolving... (space to skip)", bottom)
end

function play_resolve.keypressed(ctx, key)
    if key == "space" then
        if not ctx.skipped then
            ctx.skipped = true
            while play_resolve.resolve_play(ctx, ctx.player, ctx.enemy) > 0 do end
            while play_resolve.resolve_play(ctx, ctx.enemy, ctx.player) > 0 do end
            ctx.timer:reset()
        else
            ctx.timer:finish()
        end
    end
end

function play_resolve.block_event(ctx, event)
    return event == "keypressed" or event == "mousepressed"
end

return play_resolve
