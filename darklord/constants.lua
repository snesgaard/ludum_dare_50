local constants = {}

constants.field_scale = vec2(3, 3)
constants.field_screen = vec2(
    gfx.getWidth() / constants.field_scale.x,
    gfx.getHeight() / constants.field_scale.y
)

constants.MAX_PLAY = 3
constants.MAX_HAND = 10
constants.INIT_HAND = 5

constants.control_layout = spatial(constants.field_screen.x, 150, 150, 85)
    :left()
    :move(10, 0)

constants.control_text_opt = {
    align="left", valign="top", font=gfx.newFont(8, "mono")
}

return constants
