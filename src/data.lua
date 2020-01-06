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

data:extend{
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
  capsule('tapeline-adjust', '__Tapeline__/graphics/item/adjust.png', 1),
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

-- DEBUGGING TOOL
if mods['debugadapter'] then
  data:extend{
    {
    type = 'custom-input',
    name = 'DEBUG-INSPECT-GLOBAL',
    key_sequence = 'CONTROL + SHIFT + ENTER'
    }
  }
end

-- GUI STYLES

local styles = data.raw['gui-style'].default

styles.tl_green_button = {
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

styles.tl_green_icon_button = {
  type = 'button_style',
  parent = 'tl_green_button',
  padding = 2,
  size = 28
}

styles.tl_horizontal_pusher = {
  type = 'empty_widget_style',
  horizontally_stretchable = 'on'
}

styles.tl_vertical_pusher = {
  type = 'empty_widget_style',
  vertically_stretchable = 'on'
}

styles.tl_slider_textfield = {
  type = 'textbox_style',
  parent = 'short_number_textfield',
  width = 50,
  horizontal_align = 'center',
  left_margin = 8
}

styles.tl_invalid_slider_textfield = {
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

styles.tl_invalid_bold_label = {
  type = "label_style",
  parent = "bold_label",
  font_color = warning_red_color
}

styles.tl_vertically_centered_flow = {
  type='horizontal_flow_style',
  vertical_align = 'center',
  vertically_stretchable = 'on'
}

styles.tl_horizontally_centered_flow = {
  type = 'vertical_flow_style',
  horizontal_align = 'center',
  horizontally_stretchable = 'on'
}

styles.tl_stretchable_button = {
  type = 'button_style',
  horizontally_stretchable = 'on'
}