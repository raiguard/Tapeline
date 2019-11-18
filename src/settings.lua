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

data:extend{
    -- -- startup settings
    -- {
    --     type = 'int-setting',
    --     name = 'tapeline-capsule-cooldown',
    --     setting_type = 'startup',
    --     default_value = 3,
    --     minimum_value = 1,
    --     order = 'a'
    -- },
    -- map settings
    {
        type = 'bool-setting',
        name = 'draw-tilegrid-on-ground',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'a'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-line-width',
        setting_type = 'runtime-global',
        default_value = 2.0,
        order = 'b'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-clear-delay',
        setting_type = 'runtime-global',
        default_value = 1,
        order = 'c'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-background-color',
        setting_type = 'runtime-global',
        default_value = 'black',
        allowed_values = possible_colors,
        order = 'd'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-global',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'e'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-global',
        default_value = 'lightgrey',
        allowed_values = possible_colors,
        order = 'f'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-global',
        default_value = 'grey',
        allowed_values = possible_colors,
        order = 'g'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-global',
        default_value = 'lightgreen',
        allowed_values = possible_colors,
        order = 'h'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-global',
        default_value = 'lightred',
        allowed_values = possible_colors,
        order = 'i'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-global',
        default_value = 'yellow',
        allowed_values = possible_colors,
        order = 'j'
    },
    -- player settings
    {
        type = 'bool-setting',
        name = 'log-selection-area',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'a'
    }
}