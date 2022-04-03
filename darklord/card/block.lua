local dl = require "darklord"

return function(ctx)
    return ctx:entity()
        :set(dl.component.attack, 0)
        :set(dl.component.defend, 4)
        :set(dl.component.title, "Block")
end
