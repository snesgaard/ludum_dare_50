local render = require "darklord.render"

local action_card = {}
action_card.__index = action_card

action_card.title_font = gfx.newFont(10, "mono")
action_card.text_font = gfx.newFont(8, "mono")

function action_card:__call(x, y, title, text, attack, defend)
    local frame = get_atlas("art/characters"):get_frame("card_action_generic")

    local title_slice = frame.slices.title
    local text_slice = frame.slices.text
    local attack_slice = frame.slices.attack
    local defend_slice = frame.slices.defend

    gfx.push()
    gfx.translate(x, y)
    frame:draw(0, 0)

    gfx.setColor(1, 1, 1)
    render.text(
        title, title_slice.x, title_slice.y, title_slice.w, title_slice.h,
        {align="center", valign="top", font=action_card.title_font}
    )
    render.text(
        attack,
        attack_slice.x, attack_slice.y, attack_slice.w, attack_slice.h,
        {align="center", font=action_card.text_font, valign="top"}
    )
    render.text(
        defend,
        defend_slice.x, defend_slice.y, defend_slice.w, defend_slice.h,
        {align="center", font=action_card.text_font, valign="top"}
    )

    gfx.setColor(0, 0, 0)
    render.text(
        text,
        text_slice.x, text_slice.y, text_slice.w, text_slice.h,
        {align="left", valign="top", font=action_card.text_font}
    )



    gfx.pop()
end

return setmetatable({}, action_card)
