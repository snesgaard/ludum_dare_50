local text = {}
text.__index = {}

local function compute_vertical_offset(valign, font, h)
    if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
    else
        return (h - font:getHeight()) / 2
	end
end

function text:__call(text, x, y, w, h, opt, sx, sy)
    local opt = opt or {}
    if opt.font then gfx.setFont(opt.font) end

    local dy = compute_vertical_offset(opt.valign, gfx.getFont(), h)

    gfx.printf(text, x, y + dy, w, opt.align or "left")
end

return setmetatable({}, text)
