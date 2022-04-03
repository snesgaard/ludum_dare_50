local dl = require "darklord"

local confirm = {}

function confirm.on_push(ctx, message)
    local screen = spatial(gfx.getWidth() * 0.5, gfx.getHeight() * 0.5, 0, 0)
    ctx.message = message or "Confirm?"
    ctx.bg_layout = screen:expand(800, 200)
    ctx.text_layout = ctx.bg_layout:expand(-20, -20)
    ctx.font = gfx.newFont(40, "mono")
    ctx.yes_layout = ctx.bg_layout:down(0, 0, 400, 60)
    ctx.no_layout = ctx.bg_layout:down(0, 0, 400, 60, "right")

    ctx.select = true
end

function confirm.draw_gui(ctx)
    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", ctx.bg_layout:unpack(20))
    gfx.setColor(1, 1, 1)
    dl.render.text(
        ctx.message,
        ctx.text_layout.x, ctx.text_layout.y,
        ctx.text_layout.w, ctx.text_layout.h,
        {align="center", valign="middle", font=ctx.font}
    )

    dl.render.button(
        "yes", ctx.yes_layout, ctx.select ~= true,
        {align="center", valign="middle", font=ctx.font}
    )

    dl.render.button(
        "no", ctx.no_layout, ctx.select ~= false,
        {align="center", valign="middle", font=ctx.font}
    )
end

function confirm.keypressed(ctx, key)
    if key == "left" then
        if ctx.select == nil then
            ctx.select = false
        else
            ctx.select = not ctx.select
        end
    elseif key == "right" then
        if ctx.select == nil then
            ctx.select = true
        else
            ctx.select = not ctx.select
        end
    elseif key == "backspace" then
        ctx.world:pop(false)
    elseif key == "space" and ctx.select ~= nil then
        ctx.world:pop(ctx.select)
    end
end

function confirm.block_event(ctx, event)
    return event == "keypressed" or event == "mousepressed"
end


return confirm
