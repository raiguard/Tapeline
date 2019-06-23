-- ------------------------------------------------------------
-- SETTINGS MENU

-- create a menu for the player
function create_settings_menu(player, flow)

    local menu_frame = flow.add {
        type = 'frame',
        name = 'tapeline_menu_frame',
        direction = 'vertical'
    }

    -- HEADER
    local header_flow = menu_frame.add {
        type = 'flow',
        name = 'header_flow',
        direction = 'horizontal'
    }

    header_flow.style.horizontally_stretchable = true
    header_flow.style.bottom_margin = 2

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
        name = 'confirm_button',
        style = 'green_icon_button',
        sprite = 'check-mark',
        tooltip = {'gui-button.confirm-tooltip'}
    }
    
    header_flow.add {
        type = 'sprite-button',
        name = 'delete_button',
        style = 'red_icon_button',
        sprite = 'trash-black',
        tooltip = {'gui-button.delete-tooltip'}
    }

    header_flow.visible = false

    -- auto clear
    menu_frame.add {
        type = 'checkbox',
        name = 'autoclear_checkbox',
        state = true,
        caption = {'gui-label.autoclear-caption'},
        tooltip = {'gui-label.autoclear-tooltip', player.mod_settings['tilegrid-clear-delay'].value},
        style = 'caption_checkbox'
    }

    menu_frame.autoclear_checkbox.visible = false

    -- grid type
    local gridtype_flow = menu_frame.add {
        type = 'flow',
        name = 'gridtype_flow',
        direction = 'horizontal'
    }

    gridtype_flow.add {
        type = 'label',
        name = 'gridtype_label',
        caption = {'gui-label.gridtype-caption'},
        style = 'caption_label'
    }

    gridtype_flow.add {
        type = 'flow',
        name = 'gridtype_spacer',
        direction = 'horizontal'
    }

    gridtype_flow.gridtype_spacer.style.horizontally_stretchable = true
    gridtype_flow.style.vertical_align = 'center'

    gridtype_flow.add {
        type = 'drop-down',
        name = 'gridtype_dropdown',
        items = { {'gui-label.gridtype-increment'}, {'gui-label.gridtype-split'} },
        selected_index = 1
    }

    -- increment divisor
    local divisor_label_flow = menu_frame.add {
        type = 'flow',
        name = 'divisor_label_flow',
        direction = 'horizontal'
    }
    
    local divisor_label = divisor_label_flow.add {
        type = 'label',
        name = 'divisor_label',
        caption = 'Number of tiles per subgrid',
        style = 'caption_label'
    }

    divisor_label_flow.style.horizontally_stretchable = true
    divisor_label_flow.style.horizontal_align = 'center'

    local increment_divisor_flow = menu_frame.add {
        type = 'flow',
        name = 'increment_divisor_flow',
        direction = 'horizontal'
    }

    local increment_divisor_slider = increment_divisor_flow.add {
        type = 'slider',
        name = 'increment_divisor_slider',
        style = 'notched_slider',
        minimum_value = 1,
        maximum_value = 10,
        value = 5
    }

    local increment_divisor_textfield = increment_divisor_flow.add {
        type = 'textfield',
        name = 'increment_divisor_textfield',
        text = '5'
    }

    increment_divisor_flow.style.vertical_align = 'center'
    increment_divisor_slider.style.horizontally_stretchable = true
    increment_divisor_textfield.style.width = 50
    increment_divisor_textfield.style.horizontal_align = 'center'

end

function open_settings_menu(player)

    local flow = mod_gui.get_frame_flow(player)
    local menu_frame = flow.tapeline_menu_frame
    if not menu_frame then
        create_settings_menu(player, flow)
    else
        menu_frame.visible = true
    end

end

function close_settings_menu(player)

    local menu_frame = mod_gui.get_frame_flow(player).tapeline_menu_frame
    if menu_frame then
        menu_frame.visible = false
    end

end

-- detect if the player is holding the tapeline capsule, and show/hide the settings menu accordingly
function on_item(e)

    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'tapeline-capsule' then
        -- if holding the tapeline
        if global.player_settings[e.player_index] == nil then
            create_settings(e.player_index)
        end
        open_settings_menu(player) 
    else
        -- hide settings GUI
        close_settings_menu(player)
    end

end

function on_setting_changed(e)
    change_setting(e)
end

function on_slider(e)
    e.element.slider_value = math.floor(e.element.slider_value + 0.5)
    mod_gui.get_frame_flow(game.players[e.player_index]).tapeline_menu_frame.increment_divisor_flow.increment_divisor_textfield.text = e.element.slider_value
    on_setting_changed(e)
end

-- ------------------------------------------------------------
-- DIALOG WINDOW

function create_dialog_menu(center_gui)

    local dialog_frame = center_gui.add {
        type = 'frame',
        name = 'tapeline_dialog_frame',
        direction = 'vertical',
        style = 'dialog_frame',
        caption = {'gui.confirmation'}
    }

    dialog_frame.add {
        type = 'text-box',
        name = 'dialog_text_box',
        style = 'bold_notice_textbox',
        text = 'You are about to permanently delete Tilegrid #32'
    }

    local buttons_flow = dialog_frame.add {
        type = 'flow',
        name = 'dialog_buttons_flow',
        direction = 'horizontal',
        style = 'dialog_buttons_horizontal_flow'
    }

    buttons_flow.add {
        type = 'button',
        name = 'dialog_back_button',
        style = 'back_button',
        caption = {'gui.cancel'}
    }

    buttons_flow.add {
        type = 'flow',
        name = 'dialog_spacer',
        direction = 'horizontal'
    }
    buttons_flow.dialog_spacer.style.horizontally_stretchable = true

    buttons_flow.add {
        type = 'button',
        name = 'dialog_confirm_button',
        style = 'red_confirm_button',
        caption = {'gui.delete'}
    }

end

function on_delete_button(e)

    local player = game.players[e.player_index]
    local center_gui = player.gui.center

    if not center_gui.tapeline_dialog_frame then
        mod_gui.get_frame_flow(player).tapeline_menu_frame.ignored_by_interaction = true
        create_dialog_menu(center_gui)
    end

end

function on_dialog_back_button(e)

    local player = game.players[e.player_index]

    mod_gui.get_frame_flow(player).tapeline_menu_frame.ignored_by_interaction = false
    player.gui.center.tapeline_dialog_frame.destroy()

end

function on_dialog_confirm_button(e)

    local player = game.players[e.player_index]

    mod_gui.get_frame_flow(player).tapeline_menu_frame.ignored_by_interaction = false
    close_settings_menu(player)
    player.gui.center.tapeline_dialog_frame.destroy()
    destroy_tilegrid_data(global.cur_tilegrid_index)

end

stdlib.gui.on_selection_state_changed('grid_type_dropdown', on_setting_changed)
stdlib.gui.on_text_changed('increment_textfield', on_setting_changed)
stdlib.gui.on_text_changed('split_divisor_textfield', on_setting_changed)
stdlib.gui.on_checked_state_changed('autoclear_checkbox', on_setting_changed)
stdlib.gui.on_value_changed('increment_divisor_slider', on_slider)
stdlib.gui.on_click('delete_button', on_delete_button)
stdlib.gui.on_click('dialog_back_button', on_dialog_back_button)
stdlib.gui.on_click('dialog_confirm_button', on_dialog_confirm_button)

stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)