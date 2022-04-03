local dl = require "darklord"

local event_title = {}
event_title.__index = event_title

event_title.box = spatial(0, 0, gfx.getWidth(), 75)
event_title.font = gfx.newFont(35, "mono")

function event_title:__call(text)
    gfx.setColor(0, 0, 0)
    gfx.rectangle("fill", event_title.box:unpack())
    gfx.setColor(1, 1, 1)
    dl.render.text(
        text,
        event_title.box.x, event_title.box.y,
        event_title.box.w, event_title.box.h,
        {align="center", valign="middle", font=event_title.font}
    )
end

return setmetatable({}, event_title)
