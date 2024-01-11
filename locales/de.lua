local Translations = {
    tips = {
        move = "Bewegen",
        updown = "Hock/Runter",
        rotate = "Drehen",
        place = "Platzieren",
        resettoground = "Auf Boden zurücksetzen",
        speed = "Schneller",
        cancel = "Abbrechen"
    },
    message = {
        itempickup = "Du hast das Item aufgehoben!",
        notplaceable = "Dieses Item kann nicht platziert werden!"
    },
    target = {
        pickup = "Aufheben"
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})