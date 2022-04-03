local dl = require "darklord"

return function(ctx)
    return ctx:entity()
        :set(dl.component.attack, 14)
        :set(dl.component.defend, 0)
        :set(dl.component.title, "Mega Slap")
        :set(dl.component.text, "Running backhand!")
end
