data:extend({
    {
        type = 'shortcut',
        name = 'tapeline-shortcut',
        order = 'a[alt-mode]-b[copy]',
        action = 'create-blueprint-item',
        item_to_create = 'tapeline-capsule',
        localised_name = {'shortcut.tapeline'},
        icon =
        {
            filename = '__Tapeline__/graphics/icons/shortcut-bar/' .. 'tapeline-x32.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'}
        },
        disabled_icon =
        {
            filename = '__Tapeline__/graphics/icons/shortcut-bar/' .. 'tapeline-x32-white.png',
            priority = 'extra-high-no-scale',
            size = 32,
            scale = 1,
            flags = {'icon'}
        },
        small_icon =
        {
            filename = '__Tapeline__/graphics/icons/shortcut-bar/' .. 'tapeline-x24.png',
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 1,
            flags = {'icon'}
        },
        disabled_small_icon =
        {
            filename = '__Tapeline__/graphics/icons/shortcut-bar/' .. 'tapeline-x24-white.png',
            priority = 'extra-high-no-scale',
            size = 24,
            scale = 1,
            flags = {'icon'}
        }
    },
})