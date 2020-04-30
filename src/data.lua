local function icon(name, size, mipmap_count)
  return {
    filename = "__Tapeline__/graphics/"..name,
    priority = "extra-high-no-scale",
    size = size,
    scale = 1,
    mipmap_count = mipmap_count,
    flags = {"icon"}
  }
end

local function shortcut_icon(suffix, size)
  return icon("shortcut-bar/tapeline-"..suffix, size, 2)
end

local function capsule(name, icon, cooldown)
  return {
    type = "capsule",
    name = name,
    icons = {
      {icon="__Tapeline__/graphics/item/black.png", icon_size=1, scale=64},
      {icon=icon, icon_size=32, mipmap_count=2}
    },
    subgroup = "capsule",
    order = "zz",
    flags = {"hidden", "only-in-cursor", "not-stackable"},
    radius_color = {a=0},
    stack_size = 1,
    capsule_action = {
      type = "throw",
      uses_stack = false,
      attack_parameters = {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = cooldown,
        range = 1000,
        ammo_type = {
          category = "capsule",
          target_type = "position",
          action = {
            type = "direct",
            action_delivery = {
              type = "instant",
              target_effects = {
                type = "damage",
                damage = {type="physical", amount=0}
              }
            }
          }
        }
      }
    }
  }
end

data:extend{
  -- capsules
  capsule("tl-adjust-capsule", "__Tapeline__/graphics/item/adjust.png", 1),
  capsule("tl-draw-capsule", "__Tapeline__/graphics/shortcut-bar/tapeline-x32-white.png", 3),
  capsule("tl-edit-capsule", "__Tapeline__/graphics/item/edit.png", 10),
  -- custom inputs
  {
    type = "custom-input",
    name = "tl-get-draw-capsule",
    key_sequence = "ALT + M",
    action = "create-blueprint-item",
    item_to_create = "tl-draw-capsule"
  },
  {
    type = "custom-input",
    name = "tl-get-edit-capsule",
    key_sequence = "",
    action = "create-blueprint-item",
    item_to_create = "tl-edit-capsule"
  },
  {
    type = "custom-input",
    name = "tl-cycle-forwards",
    key_sequence = "",
    linked_game_control = "cycle-blueprint-forwards"
  },
  {
    type = "custom-input",
    name = "tl-cycle-backwards",
    key_sequence = "",
    linked_game_control = "cycle-blueprint-backwards"
  },
  -- shortcut
  {
    type = "shortcut",
    name = "tl-get-draw-capsule",
    order = "a[alt-mode]-b[copy]",
    associated_control_input = "tl-get-draw-capsule",
    action = "create-blueprint-item",
    item_to_create = "tl-draw-capsule",
    icon = shortcut_icon("x32.png", 32),
    small_icon = shortcut_icon("x24.png", 24),
    disabled_icon = shortcut_icon("x32-white.png", 32),
    disabled_small_icon = shortcut_icon("x24-white.png", 24)
  },
  -- other
  {
    type = "highlight-box",
    name = "tl-highlight-box"
  }
}

-- GUI STYLES

local styles = data.raw["gui-style"].default

styles.tl_slider_textfield = {
  type = "textbox_style",
  parent = "short_number_textfield",
  width = 50,
  horizontal_align = "center",
  left_margin = 8
}

styles.tl_invalid_slider_textfield = {
  type = "textbox_style",
  parent = "tl_slider_textfield",
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

styles.tl_stretchable_button = {
  type = "button_style",
  horizontally_stretchable = "on"
}