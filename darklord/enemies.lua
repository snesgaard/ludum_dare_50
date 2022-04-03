local dl = require "darklord"

local common_pool = list(
    dl.card.finale,
    dl.card.overcommit,
    dl.card.lucky,
    dl.card.better_block,
    dl.card.happy_jazz,
    dl.card.jazz_frenzy
)

local enemies = {}

enemies.slime = {
    atlas = "art/characters",
    image = "angry_ooze",
    name = "Angry Ooze",
    card_pool = list(
        dl.card.slime_buffer, dl.card.slime_slap, dl.card.overcommit
    ),
    reward_pool = common_pool + list(
        dl.card.slime_buffer, dl.card.slime_slap
    )
}

return enemies
