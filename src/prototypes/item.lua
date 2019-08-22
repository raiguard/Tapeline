data:extend{
    {
        type = 'capsule',
        name = 'tapeline-capsule',
        icon = '__Tapeline__/graphics/icons/item/tapeline-tool.png',
        icon_size = 64,
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
    }
}