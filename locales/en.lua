local Translations = {
    tips = {
        move = "Move",
        updown = "Up/Down",
        rotate = "Rotate",
        place = "Place",
        resettoground = "Reset to ground",
        speed = "Speed Up",
        cancel = "Cancel"
    },
    message = {
        itempickup = "You picked up the item!",
        notplaceable = "This item is not placeable!"
    },
    target = {
        pickup = "Pickup"
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})