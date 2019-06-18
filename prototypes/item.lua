data:extend({
  {
      type = 'selection-tool',
      name = 'tapeline-tool',
      icon = '__Tapeline__/graphics/icons/item/tapeline-tool.png',
      icon_size = 32,
      flags = {'hidden', 'only-in-cursor'},
      subgroup = 'other',
      order = 'c[automated-construction]-a[blueprint]',
      stack_size = 1,
      stackable = false,
      selection_color = { g = 1 },
      alt_selection_color = { g = 1, b = 1 },
      selection_mode = {'any-tile'},
      alt_selection_mode = {'any-tile'},
      selection_cursor_box_type = 'copy',
      alt_selection_cursor_box_type = 'electricity',
      show_in_library = false
  },
  {
    type = 'capsule',
    name = 'tapeline-capsule',
    icon = '__Tapeline__/graphics/icons/item/tapeline-tool.png',
    icon_size = 32,
    subgroup = 'capsule',
    order = 'zz',
    stack_size = 10000,
    flags = {'hidden'}
    -- When 0.17.51 comes out:
    -- stack_size = 1,
    -- uses_stack = false,
    capsule_action =
    {
      type = 'throw',
      attack_parameters =
      {
        type = 'projectile',
        ammo_category = 'capsule',
        cooldown = 2,
        range = 1000,
        ammo_type =
        {
          category = 'capsule',
          target_type = 'position',
          action =
          {
            type = 'direct',
            action_delivery =
            {
              type = 'instant',
              target_effects =
              {
                type = 'damage',
                damage = { type = 'physical', amount = 0 }
              }
            }
          }
        }
      }
    },
  }
})