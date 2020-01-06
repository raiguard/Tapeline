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
        default_value = '{a=0.6}',
        order = 'da'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-border-color',
        setting_type = 'runtime-global',
        default_value = '{r=0.8, g=0.8, b=0.8}',
        order = 'db'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-label-color',
        setting_type = 'runtime-global',
        default_value = '{r=0.8, g=0.8, b=0.8}',
        order = 'dc'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-1',
        setting_type = 'runtime-global',
        default_value = '{r=0.5, g=0.5, b=0.5}',
        order = 'dd'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-2',
        setting_type = 'runtime-global',
        default_value = '{r=0.4, g=0.8, b=0.4}',
        order = 'de'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-3',
        setting_type = 'runtime-global',
        default_value = '{r=0.8, g=0.3, b=0.3}',
        order = 'df'
    },
    {
        type = 'string-setting',
        name = 'tilegrid-color-4',
        setting_type = 'runtime-global',
        default_value = '{r=0.8, g=0.8, b=0.3}',
        order = 'dg'
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