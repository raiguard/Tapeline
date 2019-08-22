local function shortcut_icon(suffix, size)
    return {
        filename = '__Tapeline__/graphics/shortcut-bar/tapeline-'..suffix,
        priority = 'extra-high-no-scale',
        size = size,
        scale = 1,
        flags = {'icon'}
    }
end

data:extend{
    -- on-ground settings button entity
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
            filename = '__Tapeline__/graphics/entity/settings_button.png',
            width = 28,
            height = 26,
            scale = 0.5
        },
        flags = {'placeable-off-grid', 'not-on-map', 'not-blueprintable', 'not-deconstructable', 'not-upgradable', 'no-copy-paste'},
        selection_priority = 100
    },
    -- capsule
    {
        type = 'capsule',
        name = 'tapeline-capsule',
        icons = {
            {icon='__Tapeline__/graphics/item/black.png', icon_size=64},
            {icon='__Tapeline__/graphics/shortcut-bar/tapeline-x32-white.png', icon_size=32, scale=0.5}
        },
        subgroup = 'capsule',
        order = 'zz',
        flags = {'hidden', 'only-in-cursor'},
        stack_size = 1,
        stackable = false,
        capsule_action = {
            type = 'throw',
            uses_stack = false,
            attack_parameters = {
                type = 'projectile',
                ammo_category = 'capsule',
                cooldown = 2,
                range = 1000,
                ammo_type = {
                    category = 'capsule',
                    target_type = 'position',
                    action = {
                        type = 'direct',
                        action_delivery = {
                            type = 'instant',
                            target_effects = {
                                type = 'damage',
                                damage = {type='physical', amount=0}
                            }
                        }
                    }
                }
            }
        }
    },
    -- shortcut
    {
        type = 'shortcut',
        name = 'tapeline-shortcut',
        order = 'a[alt-mode]-b[copy]',
        associated_control_input = 'get-tapeline-tool',
        action = 'create-blueprint-item',
        item_to_create = 'tapeline-capsule',
        icon = shortcut_icon('x32.png', 32),
        small_icon = shortcut_icon('x24.png', 24),
        disabled_icon = shortcut_icon('x32-white.png', 32),
        disabled_small_icon = shortcut_icon('x24-white.png', 24)
    },
    -- custom inputs
    {
        type = 'custom-input',
        name = 'get-tapeline-tool',
        key_sequence = 'ALT + M',
        action = 'create-blueprint-item',
        item_to_create = 'tapeline-capsule'
    },
    {
        type = 'custom-input',
        name = 'tapeline-open-gui',
        key_sequence = '',
        linked_game_control = 'open-gui'
    },
    -- sprites
    {
        type = 'sprite',
        name = 'check_mark',
        filename = '__Tapeline__/graphics/gui/check-mark.png',
        size = 32,
        flags = {'icon'}
    }
}

-- GUI STYLES

local styles = data.raw['gui-style'].default

styles['green_button'] = {
    type = 'button_style',
    parent = 'button',
    default_graphical_set = {
        base = {position = {68, 17}, corner_size = 8},
        shadow = default_dirt
    },
    hovered_graphical_set = {
        base = {position = {102, 17}, corner_size = 8},
        shadow = default_dirt,
        glow = default_glow(green_arrow_button_glow_color, 0.5)
    },
    clicked_graphical_set = {
        base = {position = {119, 17}, corner_size = 8},
        shadow = default_dirt
    },
    disabled_graphical_set = {
        base = {position = {85, 17}, corner_size = 8},
        shadow = default_dirt
    }
}

styles['green_icon_button'] = {
    type = 'button_style',
    parent = 'green_button',
    padding = 3,
    size = 28
}

styles['dialog_info'] = {
    type = 'label_style',
    font = 'default-bold',
    single_line = false,
    maximal_width = 400
}

styles['draggable_space_filler'] = {
    type = 'frame_style',
    height = 32,
    graphical_set = styles['draggable_space'].graphical_set,
    use_header_filler = false,
    horizontally_stretchable = 'on',
    left_margin = styles['draggable_space'].left_margin,
    right_margin = styles['draggable_space'].right_margin,
}