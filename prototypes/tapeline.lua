data:extend({
   {
      type = "shortcut",
      name = "tapeline-shortcut",
      order = "a[alt-mode]-b[copy]",
      action = "create-blueprint-item",
      item_to_create = "tapeline-dummy",
      localised_name = {"shortcut.tapeline"},
      icon =
      {
        filename = "__Tapeline__/graphics/icons/shortcut-bar/" .. "tapeline-x32.png",
        priority = "extra-high-no-scale",
        size = 32,
        scale = 1,
        flags = {"icon"}
      },
      small_icon =
      {
        filename = "__Tapeline__/graphics/icons/shortcut-bar/" .. "tapeline-x24.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      },
      disabled_small_icon =
      {
        filename = "__Tapeline__/graphics/icons/shortcut-bar/" .. "tapeline-x24-white.png",
        priority = "extra-high-no-scale",
        size = 24,
        scale = 1,
        flags = {"icon"}
      }
  },
  {
      type = "selection-tool",
      name = "tapeline-tool",
      icon = "__Tapeline__/graphics/icons/item/tapeline-tool.png",
      icon_size = 32,
      flags = {"hidden", "only-in-cursor"},
      subgroup = "other",
      order = "c[automated-construction]-a[blueprint]",
      stack_size = 1,
      stackable = false,
      selection_color = { g = 1 },
      alt_selection_color = { g = 1, b = 1 },
      selection_mode = {"any-tile"},
      alt_selection_mode = {"any-tile"},
      selection_cursor_box_type = "copy",
      alt_selection_cursor_box_type = "electricity",
      show_in_library = false
  },
  {
    type = "simple-entity",
    name = "tapeline-dummy",
    render_layer = "object",
    icon = "__Tapeline__/graphics/icons/item/tapeline-tool.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    order = "s-e-w-f",
    picture =
    {
      filename = "__Tapeline__/graphics/icons/item/tapeline-tool.png",
      priority = "extra-high",
      width = 32,
      height = 32
    }
  },
  {
    type = "item",
    name = "tapeline-dummy",
    icon = "__Tapeline__/graphics/icons/item/tapeline-tool.png",
    icon_size = 32,
    flags = {"hidden"},
    subgroup = "other",
    order = "s[simple-entity-with-force]-f[simple-entity-with-force]",
    place_result = "tapeline-dummy",
    stack_size = 50
  },
  {
    type = "capsule",
    name = "tapeline-capsule",
    icon = "__Tapeline__/graphics/icons/item/tapeline-tool.png",
    icon_size = 32,
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 5,
        range = 0,
        ammo_type =
        {
          category = "capsule",
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "create-entity",
                entity_name = "tapeline-dummy",
                trigger_created_entity = true
              }
            }
          }
        }
      }
    },
    subgroup = "capsule",
    order = "zz",
    stack_size = 1
  }
})