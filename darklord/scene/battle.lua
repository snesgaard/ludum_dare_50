local dl = require "darklord"
local constants = dl.constants

local battle = {}

local rng = love.math.random

battle.MAX_PLAY = dl.constants.MAX_PLAY
battle.MAX_HAND = dl.constants.MAX_HAND
battle.FADE_TIME = 1.0

function battle.enemy_end_animation(ctx, dt)
    ctx.enemy_fade = ctx.enemy_fade or 0
    ctx.enemy_fade = ctx.enemy_fade + dt
    return battle.FADE_TIME <= ctx.enemy_fade
end

function battle.on_push(ctx, player, enemy)
    ctx.card_hovered = nil

    local enemy_deck = {}
    for _, card in ipairs(enemy.card_pool) do
        table.insert(enemy_deck, card(ctx))
    end

    ctx.enemy_template = enemy
    local threat = player:ensure(dl.component.threat)
    local stat_threat = math.floor(threat / 3)

    ctx.enemy = ctx:entity()
        :set(dl.component.health, (enemy.health or 10) + threat)
        :set(dl.component.deck, enemy_deck)
        :set(dl.component.ai_card_order, enemy_deck, #enemy_deck, enemy.fixed_order)
        :set(dl.component.card_to_play)


    for _, card in ipairs(enemy_deck) do
        dl.system.battle.change_attack(card, stat_threat)
        dl.system.battle.change_defend(card, stat_threat)
    end

    ctx.player = player
        :set(dl.component.hand, list((player % dl.component.deck):unpack()))
        :set(dl.component.card_to_play)

    battle.prepare_enemy_move(ctx.enemy)
end

function battle.is_dead(entity)
    return entity:ensure(dl.component.health) <= 0
end

function battle.on_pop(ctx)
    ctx.enemy:destroy()

    for _, card in ipairs(ctx.player:ensure(dl.component.deck)) do
        dl.system.battle.reset_card(card)
    end
end

function battle.on_reveal(ctx, confirmed)
    if confirmed then
        --battle.exceture_turn(ctx)
        ctx.world:push(dl.scene.play_resolve, ctx.player, ctx.enemy)
    elseif confirmed == nil then
        battle.prepare_enemy_move(ctx.enemy)
        if battle.is_dead(ctx.enemy) then
            ctx.battle_is_over = true
            ctx.battle_end_animation = battle.enemy_end_animation
        elseif battle.is_dead(ctx.player) then
            ctx.battle_is_over = true
        elseif #ctx.player:ensure(dl.component.hand) == 0 then
            ctx.battle_is_over = true
        end
    end
end

function battle.update(ctx, dt)
    if not ctx.battle_is_over then return end

    if ctx.battle_end_animation ~= nil and not ctx.battle_end_animation(ctx, dt) then
        return
    end

    if battle.is_dead(ctx.player) or #ctx.player:ensure(dl.component.hand) == 0 then
        ctx.world:move(dl.scene.game_over)
    elseif battle.is_dead(ctx.enemy) then
        local reward_pool = (ctx.enemy_template.card_pool + ctx.enemy_template.reward_pool):shuffle()
        local reward_instances = list()

        for i = 1, math.min(3, #reward_pool) do
            local card_type = reward_pool[i]
            table.insert(reward_instances, card_type(ctx))
        end

        ctx.world:move(
            dl.scene.card_reward, ctx.player, reward_instances

        )
    end


end

function battle.prepare_enemy_move(enemy)
    local card_order = enemy % dl.component.ai_card_order
    local card_to_play = enemy:ensure(dl.component.card_to_play)

    if #card_order == 0 then return end

    local card = card_order[#card_order]
    table.remove(card_order)
    table.insert(card_order, 1, card)

    table.insert(card_to_play, card)
end

function battle.card_offset(i, w, selected)
    local dx = (i - 1) * (w - 5)
    local dy = selected and -10 or 0
    return dx, dy
end

battle.enemy_health_font = gfx.newFont(20, "mono")

function battle.draw_enemy(ctx)
    local enemy_frame = get_atlas(ctx.enemy_template.atlas):get_frame(ctx.enemy_template.image)
    local w, h = enemy_frame:size()
    local fs = constants.field_scale
    local x, y = gfx.getWidth() / (2 * fs.x), gfx.getHeight() / (3 * fs.y)
    local dx = ctx.enemy_fade and math.sin(ctx.enemy_fade * 30) * 10 or 0
    local alpha = ctx.enemy_fade and 1 - ctx.enemy_fade / battle.FADE_TIME or 1
    gfx.setColor(1, 1, 1, alpha)
    enemy_frame:draw(
        "origin", x + dx, y
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
        :move(-200, 60)

    for i, card in ipairs(to_play) do
        local dx = battle.card_offset(i, card_size.w)
        dl.render.action_card(
            play_size.x + dx * 0.5, play_size.y,
            card
        )
    end

    local play_size = dl.render.action_card.card_size()
        :move(100, 60)
    local enemy_to_play = ctx.enemy:get(dl.component.card_to_play)
    for i, card in ipairs(enemy_to_play) do
        local dx = battle.card_offset(i, card_size.w)
        dl.render.action_card(
            play_size.x + dx * 0.5, play_size.y,
            card
        )
    end

    local control_str = [[
CONTROLS
<- ->       :: select card
space       :: add card to play
enter        :: play cards
backspace :: undo added card
    ]]

    local control_opt = {
        align="left", valign="top", font=dl.render.button.text_opt.font
    }
    local button_layout = spatial(constants.field_screen.x, 150, 150, 65)
        :left()
        :move(10, 25)
    dl.render.button(control_str, button_layout, false, control_opt)

    dl.render.button("Enemy play", spatial(-10, 30, 100, 20))

    local play_string = string.format("Cards left: %i", 3 - #to_play)
    local play_layout = spatial(constants.field_screen.x + 10 - 100, 30, 100, 20)

    dl.render.button(play_string, play_layout)

end

function battle.exceture_turn(ctx)
    if ctx.battle_is_over then return end

    local change = dl.system.battle.resolve(ctx.player, ctx.enemy)

    dl.system.battle.apply_resolution(change)

    ctx.player:set(dl.component.card_to_play)
    ctx.enemy:set(dl.component.card_to_play)

    battle.prepare_enemy_move(ctx.enemy)

    if battle.is_dead(ctx.enemy) then
        ctx.battle_is_over = true
        ctx.battle_end_animation = battle.enemy_end_animation
    elseif battle.is_dead(ctx.player) then
        ctx.battle_is_over = true
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
    elseif key == "space" and ctx.card_hovered and #to_play < battle.MAX_PLAY and not ctx.battle_is_over then
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
        --battle.exceture_turn(ctx)
        ctx.world:push(dl.scene.confirm, "Activate played cards?")
        --ctx.world:push(dl.scene.play_resolve, ctx.player, ctx.enemy)
    end
end

function battle.draw_gui(ctx)
    local title = ctx.enemy_template.name or "Unknown"
    dl.render.event_title(title)
end

return battle
