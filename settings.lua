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
    {
        type = 'bool-setting',
        name = 'log-selection-area',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'a'
    },
    {
        type = 'bool-setting',
        name = 'draw-tilegrid-on-ground',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'b'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-line-width',
        setting_type = 'runtime-per-user',
        default_value = 2.0,
        order = 'd'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-clear-delay',
        setting_type = 'runtime-per-user',
        default_value = 5,
        order = 'e'
    },
    {
        type = 'int-setting',
        name = 'tilegrid-group-divisor',
        setting_type = 'runtime-per-user',
        default_value = 5,
        order = 'f'
    },
    {
        type = 'int-setting',
        name = 'tilegrid-split-divisor',
        setting_type = 'runtime-per-user',
        default_value = 4,
        order = 'g'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-background-color',
        setting_type = 'runtime-per-user',
        default_value = 'black',
        allowed_values = possible_colors,
        order = 'h'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-per-user',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'i'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-per-user',
        default_value = 'lightgrey',
        allowed_values = possible_colors,
        order = 'j'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-per-user',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'k'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-per-user',
        default_value = 'lightgreen',
        allowed_values = possible_colors,
        order = 'l'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-per-user',
        default_value = 'lightred',
        allowed_values = possible_colors,
        order = 'm'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-per-user',
        default_value = 'yellow',
        allowed_values = possible_colors,
        order = 'n'
    }
})