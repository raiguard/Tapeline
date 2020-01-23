data:extend{
    -- player settings
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
        default_value = 1.5,
        order = 'c'
    },
    {
        type = 'double-setting',
        name = 'tilegrid-clear-delay',
        setting_type = 'runtime-per-user',
        default_value = 1,
        order = 'd'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-background-color',
        setting_type = 'runtime-per-user',
        default_value = '{a=0.8}',
        order = 'ea'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.8, g=0.8, b=0.8}',
        order = 'eb'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.8, g=0.8, b=0.8}',
        order = 'ec'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.5, g=0.5, b=0.5}',
        order = 'ed'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.4, g=0.8, b=0.4}',
        order = 'ee'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.8, g=0.3, b=0.3}',
        order = 'ef'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-per-user',
        default_value = '{r=0.8, g=0.8, b=0.3}',
        order = 'eg'
    }
}