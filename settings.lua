data:extend({
    {
        type = "bool-setting",
        name = "log-selection-area",
        setting_type = "runtime-per-user",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "draw-tilegrid-on-ground",
        setting_type = "runtime-per-user",
        default_value = true
    },
    {
        type = "double-setting",
        name = "tilegrid-line-width",
        setting_type = "runtime-per-user",
        default_value = 2.0,
        minimum_value = 1.0,
        maximum_value = 5.0
    },
    {
        type = "double-setting",
        name = "tilegrid-clear-delay",
        setting_type = "runtime-per-user",
        default_value = 5
    },
    {
        type = "int-setting",
        name = "tilegrid-group-divisor",
        setting_type = "runtime-per-user",
        default_value  = 5
    },
    {
        type = "int-setting",
        name = "tilegrid-split-divisor",
        setting_type = "runtime-per-user",
        default_value  = 4
    }
})