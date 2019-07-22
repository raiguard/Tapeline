data:extend{
    {
        type = 'simple-entity',
        name = 'tapeline-settings-button',
        render_layer = 'collision-selection-box',
        selection_box = {
            {-0.3,-0.3},
            {0.3,0.3}
        },
        collision_mask = {},
        picture = {
            filename = '__Tapeline__/graphics/icons/entity/settings_button.png',
            width = 28,
            height = 26,
            scale = 0.5
        },
        flags = {'placeable-off-grid', 'not-on-map', 'not-blueprintable', 'not-deconstructable', 'not-upgradable', 'no-copy-paste'},
        selection_priority = 100
    }
}