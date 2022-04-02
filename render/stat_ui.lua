local text_render = require "render.text"

local stat_ui = {}
stat_ui.__index = stat_ui

stat_ui.font = gfx.newFont(40, "mono")
stat_ui.font:setFilter("nearest", "nearest")

function stat_ui:__call(health, money, sx, sy)
    local atlas = get_atlas("art/characters")
    local stat_frame = atlas:get_frame("stat_frame")
    local health_icon = atlas:get_frame("health_icon")
    local money_icon = atlas:get_frame("money_icon")

    local sx = sx or 3
    local sy = sy or 3
    local w = gfx.getWidth()
    local h = gfx.getHeight()

    stat_frame:draw(0, 0, 0, sx, sy)
    stat_frame:draw(w, 0, 0, -sx, sy)

    local health_number_slice = stat_frame.slices.number:scale(sx, sy)
    local money_number_slice = stat_frame.slices.number:scale(-sx, sy):sanitize()

    gfx.setColor(0, 0, 0)
    text_render(
        health, health_number_slice.x, health_number_slice.y, health_number_slice.w, health_number_slice.h,
        {align="right", font = stat_ui.font}
    )
    text_render(
        money, w + money_number_slice.x, money_number_slice.y, money_number_slice.w, money_number_slice.h,
        {align="left", font = stat_ui.font}
    )

    gfx.setColor(1, 1, 1)

    local health_icon_slice = stat_frame.slices.icon:scale(sx, sy)
    local money_icon_slice = stat_frame.slices.icon:scale(-sx, sy):sanitize()

    health_icon:draw(
        health_icon_slice.x, health_icon_slice.y, 0,
        sx + love.math.random(), sy
    )
    money_icon:draw(
        money_icon_slice.x + w, money_icon_slice.y, 0,
        sx, sy
    )

end

return setmetatable({}, stat_ui)
