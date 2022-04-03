local dl = require "darklord"

local card_view = {}

card_view.back_key = "Q"

function card_view.on_push(ctx, cards)
    ctx.cards = List.sort(
        cards,
        function(a, b)
            return a:ensure(dl.component.title) < b:ensure(dl.component.title)
        end
    )
    ctx.card_layout = list()

    local screen = dl.constants.field_screen
    local bound_margin = 80
    local card_margin = 20
    local x_min, x_max = bound_margin, screen.x - bound_margin

    local card_size = dl.render.action_card.card_size():move(x_min, 40)
    local card_row = card_size

    for i, card in ipairs(ctx.cards) do
        ctx.card_layout[i] = card_size
        card_size = card_size:right():move(card_margin, 0)
        if x_max <= card_size.x then
            card_row = card_row:down(0, card_margin)
            card_size = card_row
        end

    end

    ctx.scroll = 0

    ctx.scroll_layout = spatial(0, 0, screen.x, screen.y)
        :left(0, 0, 20)
        :move(screen.x, 0)
        :expand(-10, -80)

    ctx.button_layout = spatial(0, 0, screen.x, screen.y)
        :up(-20, 10, 100, 20)
        :move(0, screen.y)
end

function card_view.draw_overlay(ctx)
    gfx.push()
    gfx.translate(0, ctx.scroll)

    gfx.setColor(1, 1, 1)
    for index, card in ipairs(ctx.cards) do
        local layout = ctx.card_layout[index]
        dl.render.action_card(layout.x, layout.y, card)
    end

    gfx.pop()

    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", ctx.scroll_layout:unpack())

    dl.render.button(
        string.format("go back (%s)", card_view.back_key), ctx.button_layout
    )
end

function card_view.keypressed(ctx, key)
    if key == "up" then
        ctx.scroll = math.max(ctx.scroll - 10, 0)
    elseif key == "down" then
        local lowest_card = ctx.card_layout[#ctx.card_layout]

        if not lowest_card then return end

        local upper_bound = lowest_card.y - 60
        ctx.scroll = math.min(upper_bound, ctx.scroll + 10)
    elseif key == "q" then
        ctx.world:pop()
    end
end

function card_view.mousepressed(ctx, x, y, button, fx, fy)
    if ctx.button_layout:is_point_inside(fx, fy) then
        ctx.world:pop()
    end
end

function card_view.draw_gui(ctx)
    dl.render.event_title("Cards")
end

function card_view.block_event() return true end

return card_view
