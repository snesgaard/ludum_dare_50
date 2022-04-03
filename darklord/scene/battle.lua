local dl = require "darklord"
local constants = dl.constants

local battle = {}

battle.MAX_PLAY = 3

function battle.on_push(ctx, player)
    ctx.hand = {
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.slap(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx),
        dl.card.block(ctx)
    }

    ctx.card_hovered = nil

    ctx.enemy = ctx:entity()
        :set(dl.component.health, 10)
        :set(dl.component.card_to_play, {dl.card.slap(ctx)})

    ctx.player = player
        :set(dl.component.hand, ctx.hand)
        :set(dl.component.card_to_play)
end

function battle.card_offset(i, w, selected)
    local dx = (i - 1) * (w - 5)
    local dy = selected and -10 or 0
    return dx, dy
end

battle.enemy_health_font = gfx.newFont(20, "mono")

function battle.draw_enemy(ctx)
    local enemy_frame = get_atlas("art/characters"):get_frame("angry_ooze")
    local w, h = enemy_frame:size()
    local fs = constants.field_scale
    local x, y = gfx.getWidth() / (2 * fs.x), gfx.getHeight() / (3 * fs.y)
    enemy_frame:draw(
        "origin", x, y
    )
    local origin = enemy_frame.slices.origin

    local health_box = spatial(x, y, 0, 0)
        :up(0, 10, 50, 16, "center")


    local health = ctx.enemy:get(dl.component.health) or "NaN"
    gfx.setColor(0, 0, 0)
    dl.render.text(
        health, health_box.x, health_box.y, health_box.w, health_box.h,
        {align="center", valign="middle", font=battle.enemy_health_font}
    )
    gfx.setColor(1, 1, 1)
    local health_icon_box = health_box:left(0, 0, 16, 16)
    local health_icon = get_atlas("art/characters"):get_frame("health_icon")
    health_icon:draw(health_icon_box.x, health_icon_box.y)
end

function battle.draw(ctx)
    battle.draw_enemy(ctx)

    local card_size = dl.render.action_card.card_size()
        :scale(1, -1)
        :sanitize()
        :move(0, gfx.getHeight() / constants.field_scale.y)
        :move(5, -5)

    local hand = ctx.player:get(dl.component.hand)
    local to_play = ctx.player:get(dl.component.card_to_play)

    for i, card in ipairs(hand) do
        local dx, dy = battle.card_offset(i, card_size.w)
        if i ~= ctx.card_hovered then
            dl.render.action_card(
                card_size.x + dx, card_size.y + dy,
                card
            )
        end
    end

    if ctx.card_hovered then
        local card = hand[ctx.card_hovered]
        local dx, dy = battle.card_offset(ctx.card_hovered, card_size.w, true)
        dl.render.action_card(
            card_size.x + dx, card_size.y + dy,
            card
        )
    end

    local play_size = dl.render.action_card.card_size()
        :scale(-1, 1)
        :sanitize()
        :move(gfx.getWidth() / constants.field_scale.x, 0)
        :move(-100, 40)

    for i, card in ipairs(to_play) do
        local dx = battle.card_offset(i, card_size.w)
        dl.render.action_card(
            play_size.x + dx * 0.5, play_size.y,
            card
        )
    end

    local play_size = dl.render.action_card.card_size()
        :move(100, 40)
    local to_play = ctx.enemy:get(dl.component.card_to_play)
    for i, card in ipairs(to_play) do
        local dx = battle.card_offset(i, card_size.w)
        dl.render.action_card(
            play_size.x + dx * 0.5, play_size.y,
            card
        )
    end
end

function battle.keypressed(ctx, key)
    local hand = ctx.player:get(dl.component.hand)
    local to_play = ctx.player:get(dl.component.card_to_play)
    local size = #hand

    if key == "left" and size > 0 then
        if not ctx.card_hovered or ctx.card_hovered == 1 then
            ctx.card_hovered = size
        else
            ctx.card_hovered = ctx.card_hovered - 1
        end
    elseif key == "right" and size > 0 then
        if not ctx.card_hovered or ctx.card_hovered == size then
            ctx.card_hovered = 1
        else
            ctx.card_hovered = ctx.card_hovered + 1
        end
    elseif key == "space" and ctx.card_hovered and #to_play < battle.MAX_PLAY then
        local card = hand[ctx.card_hovered]
        table.remove(hand, ctx.card_hovered)
        table.insert(to_play, card)
        ctx.card_hovered = math.clamp(ctx.card_hovered, 1, #hand)
        if #hand == 0 then ctx.card_hovered = nil end
    elseif key == "backspace" and #to_play > 0 then
        local card = to_play[#to_play]
        table.remove(to_play)
        table.insert(hand, card)
    elseif key == "return" then
        local change = dl.system.battle.resolve(ctx.player, ctx.enemy)


        ctx.enemy:map(dl.component.health, function(h)
            return h - change.enemy.damage
        end)

        print(ctx.player:get(dl.component.health))
        ctx.player:map(dl.component.health, function(hp)
            return hp - change.player.damage
        end)

        print(ctx.player:get(dl.component.health))

        ctx.player:set(dl.component.card_to_play)
        ctx.enemy:set(dl.component.card_to_play)
    end
end

function battle.draw_gui(ctx)
    dl.render.event_title("Battle")
end

return battle
