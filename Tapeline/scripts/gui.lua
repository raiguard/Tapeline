-- create a menu for the player
function create_menu(player, flow)

    flow.add {
        type = 'frame',
        name = 'tapeline_menu_frame',
        direction = 'vertical'
    }

    -- HEADER
    local header_flow = flow.tapeline_menu_frame.add {
        type = 'flow',
        name = 'header_flow',
        direction = 'horizontal'
    }

    header_flow.style.horizontally_stretchable = true

    header_flow.add {
        type = 'label',
        name = 'menu_title',
        caption = 'Editing Tilegrid #32',
        style = 'heading_1_label'
    }

    header_flow.add {
        type = 'flow',
        name = 'header_spacer',
        direction = 'horizontal'
    }

    header_flow.header_spacer.style.horizontally_stretchable = true

    header_flow.add {
        type = 'sprite-button',
        name = 'confirm',
        style = 'green_icon_button',
        sprite = 'check-mark',
        tooltip = {'gui-button.confirm-tooltip'}
    }
    
    header_flow.add {
        type = 'sprite-button',
        name = 'delete',
        style = 'red_icon_button',
        sprite = 'trash-black',
        tooltip = {'gui-button.delete-tooltip'}
    }

    -- SETTINGS
    flow.tapeline_menu_frame.add {
        type = 'table',
        name = 'settings_table',
        column_count = 2
    }

    local settings_table = flow.tapeline_menu_frame.settings_table

    -- auto clear
    settings_table.add {
        type = 'label',
        name = 'autoclear_label',
        caption = {'gui-label.autoclear-caption'},
        tooltip = {'gui-label.autoclear-tooltip', player.mod_settings['tilegrid-clear-delay'].value},
        style = 'bold_label'
    }
    settings_table.add {
        type = 'checkbox',
        name = 'autoclear_checkbox',
        state = true
    }

    -- grid type
    settings_table.add {
        type = 'label',
        name = 'grid_type_label',
        caption = {'gui-label.gridtype-caption'},
        style = 'bold_label'
    }

    settings_table.add {
        type = 'drop-down',
        name = 'grid_type_dropdown',
        items = { {'gui-label.gridtype-increment'}, {'gui-label.gridtype-split'} },
        selected_index = 1
    }

    -- increment divisor
    settings_table.add {
        type = 'label',
        name = 'increment_divisor_label',
        caption = {'gui-label.increment-divisor-caption'},
        tooltip = {'gui-label.increment-divisor-tooltip'},
        style = 'bold_label'
    }
    settings_table.add {
        type = 'textfield',
        name = 'increment_divisor_textfield',
        text = '5'
    }
    settings_table.increment_divisor_textfield.style.width = 40
    settings_table.increment_divisor_textfield.style.horizontal_align = 'center'

    -- split divisor
    settings_table.add {
        type = 'label',
        name = 'split_divisor_label',
        caption = {'gui-label.split-divisor-caption'},
        tooltip = {'gui-label.split-divisor-tooltip'},
        style = 'bold_label'
    }
    settings_table.add {
        type = 'textfield',
        name = 'split_divisor_textfield',
        text = '4'
    }
    settings_table.split_divisor_textfield.style.width = 40
    settings_table.split_divisor_textfield.style.horizontal_align = 'center'

    flow.tapeline_menu_frame.add {
        type = 'slider',
        name = 'increment_divisor_slider',
        minimum_value = 1,
        maximum_value = 10,
        value = 5
    }

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
        if global.player_settings[e.player_index] == nil then
            create_settings(e.player_index)
        end
        show_menu(player)
    else
        hide_menu(player)
    end

end

function on_setting_changed(e)
    change_setting(e)
end

function on_slider(e)
    mod_gui.get_frame_flow(game.players[e.player_index]).tapeline_menu_frame.settings_table.increment_divisor_textfield.text = e.element.slider_value
    on_setting_changed(e)
end

stdlib.gui.on_selection_state_changed('grid_type_dropdown', on_setting_changed)
stdlib.gui.on_text_changed('increment_divisor_textfield', on_setting_changed)
stdlib.gui.on_text_changed('split_divisor_textfield', on_setting_changed)
stdlib.gui.on_checked_state_changed('autoclear_checkbox', on_setting_changed)
stdlib.gui.on_value_changed('increment_divisor_slider', on_slider)

stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)