local possible_colors = {
    'white',
    'black',
    'darkgrey',
    'grey',
    'lightgrey',
    'darkred',
    'red',
    'lightred',
    'darkgreen',
    'green',
    'lightgreen',
    'darkblue',
    'blue',
    'lightblue',
    'orange',
    'yellow',
    'pink',
    'purple',
    'brown'
}

data:extend({
    -- per player
    {
        type = 'bool-setting',
        name = 'log-selection-area',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'a'
    },
    -- map settings
    {
        type = 'bool-setting',
        name = 'draw-tilegrid-on-ground',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'b'
    },
    {
        type = 'bool-setting',
        name = 'draw-diagonal',
        setting_type = 'runtime-global',
        default_value = false,
        order = 'ba'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-line-width',
        setting_type = 'runtime-global',
        default_value = 2.0,
        order = 'c'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-clear-delay',
        setting_type = 'runtime-global',
        default_value = 1,
        order = 'd'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-background-color',
        setting_type = 'runtime-global',
        default_value = 'black',
        allowed_values = possible_colors,
        order = 'e'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-global',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'f'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-global',
        default_value = 'lightgrey',
        allowed_values = possible_colors,
        order = 'g'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-global',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'h'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-global',
        default_value = 'lightgreen',
        allowed_values = possible_colors,
        order = 'i'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-global',
        default_value = 'lightred',
        allowed_values = possible_colors,
        order = 'j'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-global',
        default_value = 'yellow',
        allowed_values = possible_colors,
        order = 'k'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-diagonal-color',
        setting_type = 'runtime-global',
        default_value = 'white',
        allowed_values = possible_colors,
        order = 'l'
    }
})
