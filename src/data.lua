local function icon(name, size, mipmap_count)
    return {
        filename = '__Tapeline__/graphics/'..name,
        priority = 'extra-high-no-scale',
        size = size,
        scale = 1,
        mipmap_count = mipmap_count,
        flags = {'icon'}
    }
end

local function shortcut_icon(suffix, size)
    return icon('shortcut-bar/tapeline-'..suffix, size, 2)
end

local function capsule(name, icon, cooldown)
    return {
        type = 'capsule',
        name = name,
        icons = {
            {icon='__Tapeline__/graphics/item/black.png', icon_size=1, scale=64},
            {icon=icon, icon_size=32, mipmap_count=2}
        },
        subgroup = 'capsule',
        order = 'zz',
        flags = {'hidden', 'only-in-cursor'},
        -- 0.18: remove range visualization
        -- range_color = {a=0},
        stack_size = 1,
        stackable = false,
        capsule_action = {
            type = 'throw',
            uses_stack = false,
            attack_parameters = {
                type = 'projectile',
                ammo_category = 'capsule',
                cooldown = cooldown,
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
    }
end

-- local function capsule(name, icon)
--     return {
--         type = 'item-with-label',
--         name = name,
--         icons = {
--             {icon='__Tapeline__/graphics/item/black.png', icon_size=1, scale=64},
--             {icon=icon, icon_size=32, mipmap_count=2}
--         },
--         draw_label_for_cursor_render = true,
--         stack_size = 1,
--         stackable = false
--     }
-- end

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
    -- shortcut
    {
        type = 'shortcut',
        name = 'tapeline-shortcut',
        order = 'a[alt-mode]-b[copy]',
        associated_control_input = 'get-tapeline-tool',
        action = 'create-blueprint-item',
        item_to_create = 'tapeline-draw',
        icon = shortcut_icon('x32.png', 32),
        small_icon = shortcut_icon('x24.png', 24),
        disabled_icon = shortcut_icon('x32-white.png', 32),
        disabled_small_icon = shortcut_icon('x24-white.png', 24)
    },
    -- capsules
    capsule('tapeline-draw', '__Tapeline__/graphics/shortcut-bar/tapeline-x32-white.png', 3),
    capsule('tapeline-adjust', '__Tapeline__/graphics/item/adjust.png', 3),
    capsule('tapeline-edit', '__Tapeline__/graphics/item/edit.png', 10),
    -- custom inputs
    {
        type = 'custom-input',
        name = 'get-tapeline-tool',
        key_sequence = 'ALT + M',
        action = 'create-blueprint-item',
        item_to_create = 'tapeline-draw'
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
    },
    {
        type = 'custom-input',
        name = 'tapeline-cycle-forwards',
        key_sequence = '',
        linked_game_control = 'cycle-blueprint-forwards'
    },
    {
        type = 'custom-input',
        name = 'tapeline-cycle-backwards',
        key_sequence = '',
        linked_game_control = 'cycle-blueprint-backwards'
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

styles['titlebar_flow'] = {
    type = 'horizontal_flow_style',
    direction = 'horizontal',
    horizontally_stretchable = 'on',
    vertical_align = 'center'
}

styles['invisible_horizontal_pusher'] = {
    type = 'empty_widget_style',
    horizontally_stretchable = 'on'
}

styles['invisible_vertical_pusher'] = {
    type = 'empty_widget_style',
    vertically_stretchable = 'on'
}

styles['tl_slider_textfield'] = {
    type = 'textbox_style',
    parent = 'short_number_textfield',
    width = 50,
    horizontal_align = 'center',
    left_margin = 8
}

styles['tl_invalid_slider_textfield'] = {
    type = 'textbox_style',
    parent = 'tl_slider_textfield',
    default_background = {
        base = {position = {248,0}, corner_size=8, tint=warning_red_color},
        shadow = textbox_dirt
    },
    active_background = {
        base = {position={265,0}, corner_size=8, tint=warning_red_color},
        shadow = textbox_dirt
    },
    disabled_background = {
        base = {position = {282,0}, corner_size=8, tint=warning_red_color},
        shadow = textbox_dirt
    }
}

styles['invalid_bold_label'] = {
    type = "label_style",
    parent = "bold_label",
    font_color = warning_red_color
}

styles['vertically_centered_flow'] = {
    type='horizontal_flow_style',
    vertical_align = 'center',
    vertically_stretchable = 'on'
}

styles['horizontally_centered_flow'] = {
    type = 'vertical_flow_style',
    horizontal_align = 'center',
    horizontally_stretchable = 'on'
}

styles['tl_confirm_button_small'] = {
    type = 'button_style',
    parent = 'confirm_button',
    height = 26
}

styles['tl_back_button_small'] = {
    type = 'button_style',
    parent = 'back_button',
    height = 26
}