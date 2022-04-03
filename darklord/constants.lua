local constants = {}

constants.field_scale = vec2(3, 3)
constants.field_screen = vec2(
    gfx.getWidth() / constants.field_scale.x,
    gfx.getHeight() / constants.field_scale.y
)

return constants
