local dl = require "darklord"

local card_reward = {}

function card_reward.on_push(ctx, player, cards_to_pick)
    ctx.player = player
    ctx.cards_to_pick = cards_to_pick

    local screen = dl.constants.field_screen
    ctx.field_to_draw = spatial(0, 0, screen.x, screen.y)
        :expand(0, -40, "left", "bottom")
        :expand(0, -20, "left", "top")

    ctx.middle_line = spatial(
        0, ctx.field_to_draw.y + ctx.field_to_draw.h * 0.5,
        ctx.field_to_draw.w, 1
    )

    ctx.middle_box = spatial(
        30, ctx.field_to_draw.y + ctx.field_to_draw.h * 0.5, 0, 0
    )
        :expand(40, 20)

    local card_size = dl.render.action_card.card_size()
    ctx.init_hand_layout = ctx.field_to_draw
        :down(20, 0, card_size.w, -card_size.h)
        :sanitize()

    ctx.init_reward_layout = ctx.field_to_draw
        :up(20, 0, card_size.w, -card_size.h)
        :sanitize()

    ctx.confirm_button_layout = ctx.middle_line
        :right(0, 0, 0, 0)
        :move(-60, 0)
        :expand(70, 20, "left")

    ctx.cursor_on_hand = true
    ctx.cursor_index = 1

    ctx.deck = ctx.player:ensure(dl.component.deck)
end

function card_reward.draw(ctx)
    local deck = ctx.player:ensure(dl.component.deck)

    gfx.setColor(0, 0, 0)
    --gfx.rectangle("line", ctx.init_reward_layout:unpack())

    gfx.rectangle("fill", ctx.middle_line:unpack())

    local counter_str = string.format("%i / %i", #deck, dl.constants.MAX_HAND)
    dl.render.button(
        counter_str, ctx.middle_box, true
    )

    gfx.setColor(1, 1, 1)


    local layout = ctx.init_hand_layout
    for i, card in ipairs(deck) do
        local hovered = ctx.cursor_on_hand and ctx.cursor_index == i
        local dy = hovered and -4 or 0
        dl.render.action_card(layout.x, layout.y + dy, card)
        layout = layout:right(-4)
    end

    local layout = ctx.init_reward_layout
    for i, card in ipairs(ctx.cards_to_pick) do
        local hovered = not ctx.cursor_on_hand and ctx.cursor_index == i
        local dy = hovered and -4 or 0
        dl.render.action_card(layout.x, layout.y + dy, card)
        layout = layout:right(-4)
    end

    dl.render.button(
        "Confirm", ctx.confirm_button_layout
    )

    local help_str = [[
CONTROLS
up / down  :: change row
left / right :: change card
space   :: move card to other row
enter    :: finish
    ]]

    dl.render.button(help_str, dl.constants.control_layout, false, dl.constants.control_text_opt)

    local deck_button = ctx.middle_line
        :down(0, 10, 100, 20)
        :move(-10, 0)
    dl.render.button("Your cards", deck_button)

    local remove_button = ctx.middle_line
        :up(0, 10, 100, 20)
        :move(-10, 0)
    dl.render.button("To be removed", remove_button)
end

function card_reward.draw_gui(ctx)
    dl.render.event_title("Pick cards")
end

function card_reward.keypressed(ctx, key)
    if key == "up" or key == "down" then
        ctx.cursor_on_hand = not ctx.cursor_on_hand
        local cards = ctx.cursor_on_hand and ctx.deck or ctx.cards_to_pick
        if ctx.cursor_index then
            ctx.cursor_index = math.clamp(ctx.cursor_index, 1, #cards)
        end
    elseif key == "left" then
        local cards = ctx.cursor_on_hand and ctx.deck or ctx.cards_to_pick
        if ctx.cursor_index == nil or ctx.cursor_index <= 1 then
            ctx.cursor_index = #cards
        else
            ctx.cursor_index = ctx.cursor_index - 1
        end
    elseif key == "right" then
        local cards = ctx.cursor_on_hand and ctx.deck or ctx.cards_to_pick
        if ctx.cursor_index == nil or #cards <= ctx.cursor_index then
            ctx.cursor_index = 1
        else
            ctx.cursor_index = ctx.cursor_index + 1
        end
    elseif key == "space" then
        local index = ctx.cursor_index
        if not ctx.cursor_index then return end

        local src = ctx.cursor_on_hand and ctx.deck or ctx.cards_to_pick
        local dst = not ctx.cursor_on_hand and ctx.deck or ctx.cards_to_pick

        if dl.constants.MAX_HAND <= #dst then return end

        local card = src[index]
        table.remove(src, index)
        table.insert(dst, card)

        ctx.cursor_index = math.clamp(ctx.cursor_index, 1, #src)
    elseif key == "return" then
        ctx.world:push(dl.scene.confirm, "Move on to next event?")
    end
end

function card_reward.on_reveal(ctx, confirm)
    if confirm then ctx.world:pop() end
end

function card_reward.mousepressed(ctx, x, y, button, fx, fy)
    if ctx.confirm_button_layout:is_point_inside(fx, fy) then
        ctx.world:pop()
    end
end

return card_reward
