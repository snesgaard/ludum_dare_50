local dl = require "darklord"

local mystery = {}

function mystery.next_option_box(prev_box)
    return prev_box
        :down(0, 10, nil, 20)
        --:expand(-10, 0, "left")
end

function mystery.bg_box_from_text_box(box)
    return box
        :expand(6, 6)
        :expand(20, 0, "right")
end

local fs = dl.constants.field_scale

mystery.round = 5

mystery.text_box = spatial(0, 0, gfx.getWidth() / fs.x, gfx.getHeight() / fs.y)
    :scale(0.5, 0.5)
    :move(0, 30)
    :expand(-10, -10)
    :floor()

mystery.bg_box = mystery.bg_box_from_text_box(mystery.text_box)

mystery.font = gfx.newFont(8, "mono")

function mystery.on_push(ctx)
    ctx.options = {
        "cry",
        "do a little dance",
        "ZOOOM!"
    }
    ctx.options_text_box = {}

    local prev_option = mystery.text_box
    for i, _ in ipairs(ctx.options) do
        prev_option = mystery.next_option_box(prev_option)
        table.insert(ctx.options_text_box, prev_option)
    end
end

function mystery.draw(ctx)
    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", mystery.bg_box:unpack(mystery.round))

    for i, box in ipairs(ctx.options_text_box) do
        local bg_box = mystery.bg_box_from_text_box(box)
        if i == ctx.hovered_option then
            bg_box = bg_box:expand(20, 0, "left")
        end
        gfx.rectangle("fill", bg_box:unpack(mystery.round))
    end

    gfx.setColor(1, 1, 1)
    dl.render.text(
        [[
I need your strongest potion, potion maker.

You can't handle my potions adventurer.

:(
        ]],
        mystery.text_box.x, mystery.text_box.y,
        mystery.text_box.w, mystery.text_box.h,
        {align = "left", valign = "top", font=mystery.font}
    )

    for i, option in ipairs(ctx.options) do
        local prev_option = ctx.options_text_box[i]
        dl.render.text(
            option,
            prev_option.x, prev_option.y, prev_option.w, prev_option.h,
            {align="left", font=mystery.font}
        )
    end
end

function mystery.mousemoved(ctx, x, y, dx, dy, fx, fy)
    ctx.hovered_option = nil

    for i, box in ipairs(ctx.options_text_box) do
        local bg_box = mystery.bg_box_from_text_box(box)
        if bg_box:is_point_inside(fx, fy) then
            ctx.hovered_option = i
        end
    end
end

function mystery.keypressed(ctx, key)
    local size = #ctx.options

    if key == "up" then
        if ctx.hovered_option == nil or ctx.hovered_option == 1 then
            ctx.hovered_option = size
        else
            ctx.hovered_option = ctx.hovered_option - 1
        end
    elseif key == "down" then
        if ctx.hovered_option == nil or ctx.hovered_option == size then
            ctx.hovered_option = 1
        else
            ctx.hovered_option = ctx.hovered_option + 1
        end
    end
end

function mystery.draw_gui(ctx)
    dl.render.event_title("Shopkeeper on the loose")
end

return mystery
