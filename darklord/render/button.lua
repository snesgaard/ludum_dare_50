local dl = require "darklord"

local button = {}
button.__index = button

button.text_opt = {
    align="center", valign="middle", font=gfx.newFont(8, "mono")
}
button.margin = 8
button.round = 4

function button:__call(text, shape, invert, text_opt)
    opt = opt or {}
    text_box = shape:expand(-button.margin, -button.margin)
    if invert then
        gfx.setColor(1, 1, 1)
    else
        gfx.setColor(0, 0, 0)
    end
    gfx.rectangle("fill", shape:unpack(button.round))
    if invert then
        gfx.setColor(0, 0, 0)
    else
        gfx.setColor(1, 1, 1)
    end
    dl.render.text(text, text_box.x, text_box.y, text_box.w, text_box.h, text_opt or button.text_opt)
end

return setmetatable({}, button)
