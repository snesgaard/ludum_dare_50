local dl = require "darklord"

local game_over = {}

game_over.font = gfx.newFont(40, "mono")

function game_over.draw(ctx)
    local screen_middle = spatial(
        0,
        dl.constants.field_screen.y * 0.5,
        dl.constants.field_screen.x,
        0
    )
        :expand(0, 80)

    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", screen_middle:unpack())
    gfx.setColor(0.6, 0.2, 0.1)
    dl.render.text(
        "YOU DIED",
        screen_middle.x, screen_middle.y, screen_middle.w, screen_middle.h,
        {align="center", valign="middle", font=game_over.font}
    )

    local help_str = [[
CONTROLS
r  :: restart
q  :: quit
    ]]

    dl.render.button(help_str, dl.constants.control_layout, false, dl.constants.control_text_opt)
end

function game_over.keypressed(ctx, key)
    if key == "r" then
        ctx.world:clear()
        ctx.world:push(dl.scene.core)
    elseif key == "q" then

    end
end

function game_over.draw_gui(ctx)
    dl.render.event_title("Game Over")
end

return game_over
