-- create a menu for the player
function create_menu(player, flow)

    flow.add {
        type = 'frame',
        name = 'tapeline_menu_frame',
        direction = 'vertical'
    }

    flow.tapeline_menu_frame.add {
        type = 'table',
        name = 'settings_table',
        column_count = 2
    }

    local settings_table = flow.tapeline_menu_frame.settings_table

    -- -- AUTO CLEAR
    -- settings_table.add {
    --     type = 'label',
    --     name = 'autoclear_label',
    --     caption = 'Auto clear',
    --     style = 'bold_label'
    -- }
    -- settings_table.add {
    --     type = 'checkbox',
    --     name = 'autoclear_checkbox',
    --     state = true
    -- }

    -- GRID TYPE
    settings_table.add {
        type = 'label',
        name = 'grid_type_label',
        caption = 'Grid type',
        style = 'bold_label'
    }

    settings_table.add {
        type = 'drop-down',
        name = 'grid_type_dropdown',
        items = { 'increment', 'split' },
        selected_index = 1
    }

    -- INCREMENT DIVISOR
    settings_table.add {
        type = 'label',
        name = 'increment_divisor_label',
        caption = 'Increment Divisor',
        style = 'bold_label'
    }
    settings_table.add {
        type = 'textfield',
        name = 'increment_divisor_textfield',
        text = '5'
    }
    settings_table.increment_divisor_textfield.style.width = 40

    -- SPLIT DIVISOR
    settings_table.add {
        type = 'label',
        name = 'split_divisor_label',
        caption = 'Split Divisor',
        style = 'bold_label'
    }
    settings_table.add {
        type = 'textfield',
        name = 'split_divisor_textfield',
        text = '4'
    }
    settings_table.split_divisor_textfield.style.width = 40

end

-- show or create the menu for the player
function show_menu(player)

    local flow = mod_gui.get_frame_flow(player)
    local menu_frame = flow.tapeline_menu_frame
    if not menu_frame then
       create_menu(player, flow)
    else
        menu_frame.visible = true
    end

end

-- hide the menu for the player
function hide_menu(player)

    local menu_frame = mod_gui.get_frame_flow(player).tapeline_menu_frame
    if menu_frame then
        menu_frame.visible = false
    end

end

-- detect if the player is holding the tapeline capsule
function on_item(e)

    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'tapeline-capsule' then
        show_menu(player)
    else
        hide_menu(player)
    end

end

function on_dropdown_changed(e)
    stdlib.logger.log(e)
    game.print('Player ' .. game.players[e.player_index].name .. 'changed dropdown to ' .. e.element.items[e.element.selected_index])
end

stdlib.gui.on_selection_state_changed('grid_type_dropdown', on_dropdown_changed)

stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)