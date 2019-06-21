local styles = data.raw['gui-style'].default

styles['green_button'] = {
    type = "button_style",
    parent = "button",
    default_graphical_set =
    {
        base = {position = {68, 17}, corner_size = 8},
        shadow = default_dirt
    },
    hovered_graphical_set =
    {
        base = {position = {102, 17}, corner_size = 8},
        shadow = default_dirt,
        glow = default_glow(green_arrow_button_glow_color, 0.5)
    },
    clicked_graphical_set =
    {
        base = {position = {119, 17}, corner_size = 8},
        shadow = default_dirt
    },
    disabled_graphical_set =
    {
        base = {position = {85, 17}, corner_size = 8},
        shadow = default_dirt
    }
}

styles['green_icon_button'] = {
    type = "button_style",
    parent = "green_button",
    padding = 3,
    size = 28
}