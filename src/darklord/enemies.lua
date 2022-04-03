local dl = require "darklord"

local common_pool = list(
    dl.card.overcommit,
    dl.card.better_block,
    dl.card.megaslap,
    dl.card.barricade
)

local enemies = {}

enemies.slime = {
    atlas = "art/characters",
    image = "angry_ooze",
    name = "Angry Ooze",
    health = 20,
    card_pool = list(
        dl.card.slime_buffer, dl.card.slime_slap
    ),
    reward_pool = common_pool
}

enemies.deer = {
    health = 10,
    atlas = "art/characters",
    image = "demonic_deer",
    name = "Demonic Deer",
    card_pool = list(
         dl.card.finale, dl.card.lucky
    ),
    fixed_order = true,
    reward_pool = common_pool
}

enemies.sax = {
    health = 10,
    atlas = "art/characters",
    image = "sassy_saxophone",
    name = "Seductive Saxophone",
    card_pool = list(
        dl.card.block, dl.card.jazz_frenzy, dl.card.happy_jazz,
        dl.card.slap
    ),
    reward_pool = common_pool
}

enemies.warpig = {
    health = 10,
    atlas = "art/characters",
    image = "warpig",
    name = "War Pig",
    card_pool = list(dl.card.overcommit, dl.card.slap),
    fixed_order = true,
    reward_pool = common_pool
}

enemies.tomato = {
    health = 7,
    atlas = "art/characters",
    image = "toasty_tomato",
    name = "Toasty Tomato",
    card_pool = list(dl.card.barricade, dl.card.fiery_roar, dl.card.tomato_breath)
}

return enemies
