local dl = require "darklord"

return function(ctx)
    return ctx:entity()
        :set(dl.component.attack, 4)
        :set(dl.component.defend, 0)
        :set(dl.component.title, "Slap")
        :set(dl.component.text, "With the backhand.")
end
