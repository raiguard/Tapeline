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
        default_value = false
    },
    {
        type = 'bool-setting',
        name = 'draw-tilegrid-on-ground',
        setting_type = 'runtime-per-user',
        default_value = true
    },
    {
        type = 'double-setting',
        name = 'tilegrid-line-width',
        setting_type = 'runtime-per-user',
        default_value = 2.0,
        minimum_value = 1.0,
        maximum_value = 5.0
    },
    {
        type = 'double-setting',
        name = 'tilegrid-clear-delay',
        setting_type = 'runtime-per-user',
        default_value = 5
    },
    {
        type = 'int-setting',
        name = 'tilegrid-group-divisor',
        setting_type = 'runtime-per-user',
        default_value = 5
    },
    {
        type = 'int-setting',
        name = 'tilegrid-split-divisor',
        setting_type = 'runtime-per-user',
        default_value = 4
    },
    {
        type = 'string-setting',
        name = 'tilegrid-background-color',
        setting_type = 'runtime-per-user',
        default_value = 'black',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-per-user',
        default_value = 'grey',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-per-user',
        default_value = 'lightgrey',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-per-user',
        default_value = 'grey',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-per-user',
        default_value = 'lightgreen',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-per-user',
        default_value = 'lightred',
        allowed_values = possible_colors
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-per-user',
        default_value = 'yellow',
        allowed_values = possible_colors
    }
})