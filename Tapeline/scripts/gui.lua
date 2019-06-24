-- ------------------------------------------------------------
-- SETTINGS MENU

-- create a menu for the player
function create_settings_menu(player, mod_gui)

    local menu_frame = mod_gui.add {
        type = 'frame',
        name = 'tapeline_menu_frame',
        direction = 'vertical',
        style = mod_gui.frame_style
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
        caption = {'gui-caption.settings-header-caption', global.player_data[player.index].cur_tilegrid_index},
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
        tooltip = {'gui-tooltip.confirm-tooltip'}
    }
    
    header_flow.add {
        type = 'sprite-button',
        name = 'delete_button',
        style = 'red_icon_button',
        sprite = 'trash-black',
        tooltip = {'gui-tooltip.delete-tooltip'}
    }

    header_flow.visible = false

    -- CHECKBOXES

    local checkboxes_flow = menu_frame.add {
        type = 'flow',
        name = 'checkboxes_flow',
        direction = 'horizontal'
    }

    -- auto clear
    checkboxes_flow.add {
        type = 'checkbox',
        name = 'autoclear_checkbox',
        state = true,
        caption = {'gui-caption.autoclear-caption'},
        tooltip = {'gui-tooltip.autoclear-tooltip', player.mod_settings['tilegrid-clear-delay'].value},
        style = 'caption_checkbox'
    }

    -- spacer
    checkboxes_flow.add {
        type = 'flow',
        name = 'checkboxes_spacer',
        direction = 'horizontal'
    }

    checkboxes_flow.checkboxes_spacer.style.horizontally_stretchable = true

    -- restrict to cardinals
    checkboxes_flow.add {
        type = 'checkbox',
        name = 'restrict_to_cardinals_checkbox',
        state = false,
        caption = {'gui-caption.restrict-to-cardinals-caption'},
        tooltip = {'gui-tooltip.restrict-to-cardinals-tooltip'},
        style = 'caption_checkbox'
    }

    -- REDRAW TILEGRID

    local redraw_button = menu_frame.add {
        type = 'button',
        name = 'redraw_tilegrid_button',
        caption = {'gui-caption.redraw-tilegrid-caption'}
        
    }

    redraw_button.style.horizontally_stretchable = true
    redraw_button.style.horizontal_align = 'center'
    redraw_button.visible = false

    -- GRID TYPE

    local gridtype_flow = menu_frame.add {
        type = 'flow',
        name = 'gridtype_flow',
        direction = 'horizontal'
    }

    gridtype_flow.add {
        type = 'label',
        name = 'gridtype_label',
        caption = {'gui-caption.gridtype-caption'},
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
        items = { {'gui-dropdown.gridtype-increment'}, {'gui-dropdown.gridtype-split'} },
        selected_index = 1
    }

    -- DIVISORS

    local divisor_label_flow = menu_frame.add {
        type = 'flow',
        name = 'divisor_label_flow',
        direction = 'horizontal'
    }
    
    local divisor_label = divisor_label_flow.add {
        type = 'label',
        name = 'divisor_label',
        caption = {'gui-caption.increment-divisor-caption'},
        style = 'caption_label'
    }

    divisor_label_flow.style.horizontally_stretchable = true
    divisor_label_flow.style.horizontal_align = 'center'

    -- increment divisor
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

    -- split divisor
    local split_divisor_flow = menu_frame.add {
        type = 'flow',
        name = 'split_divisor_flow',
        direction = 'horizontal'
    }

    local split_divisor_slider = split_divisor_flow.add {
        type = 'slider',
        name = 'split_divisor_slider',
        style = 'notched_slider',
        minimum_value = 1,
        maximum_value = 10,
        value = 4
    }

    local split_divisor_textfield = split_divisor_flow.add {
        type = 'textfield',
        name = 'split_divisor_textfield',
        text = '4'
    }

    split_divisor_flow.style.vertical_align = 'center'
    split_divisor_slider.style.horizontally_stretchable = true
    split_divisor_textfield.style.width = 50
    split_divisor_textfield.style.horizontal_align = 'center'

    split_divisor_flow.visible = false

end

function open_settings_menu(player)

    local mod_gui = global.player_data[player.index].mod_gui
    local menu_frame = mod_gui.tapeline_menu_frame
    if not menu_frame then
        create_settings_menu(player, mod_gui)
    else
        menu_frame.visible = true
    end

end

function close_settings_menu(player)

    local menu_frame = global.player_data[player.index].mod_gui.tapeline_menu_frame
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
    local textfield = e.element.parent.increment_divisor_textfield or e.element.parent.split_divisor_textfield
    textfield.text = e.element.slider_value
    on_setting_changed(e)

end

function on_gridtype_dropdown(e)

    local value = e.element.selected_index
    local increment_flow = e.element.parent.parent.increment_divisor_flow
    local split_flow = e.element.parent.parent.split_divisor_flow
    local label = e.element.parent.parent.divisor_label_flow.divisor_label

    if value == 1 then
        label.caption = {'gui-caption.increment-divisor-caption'}
        increment_flow.visible = true
        split_flow.visible = false
    else
        label.caption = {'gui-caption.split-divisor-caption'}
        increment_flow.visible = false
        split_flow.visible = true
    end

    on_setting_changed(e)

end

-- set frame contents to the specified configuration
function set_settings_frame_mode(mode, player)

    if mode then -- editing mode

    else -- drawing mode

    end

end

-- ------------------------------------------------------------
-- DIALOG WINDOW

function create_dialog_menu(player, center_gui)

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
        -- text = {'gui-caption.dialog-warning-caption', global.player_data[player.index].cur_tilegrid_index}
        text = 'You are about to permanently delete Tilegrid #' .. global.player_data[player.index].cur_tilegrid_index
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
    local player_data = global.player_data[e.player_index]

    if not player_data.center_gui.tapeline_dialog_frame then
        player_data.mod_gui.tapeline_menu_frame.ignored_by_interaction = true
        create_dialog_menu(player, player_data.center_gui)
    end

end

function on_dialog_back_button(e)

    local player = game.players[e.player_index]
    local settings_frame = global.player_data[e.player_index].mod_gui.tapeline_menu_frame

    settings_frame.ignored_by_interaction = false
    player.gui.center.tapeline_dialog_frame.destroy()

end

function on_dialog_confirm_button(e)

    local player = game.players[e.player_index]
    local player_data = global.player_data[e.player_index]
    local settings_frame = player_data.mod_gui.tapeline_menu_frame
    
    player_data.center_gui.tapeline_dialog_frame.destroy()
    destroy_tilegrid_data(player_data.cur_tilegrid_index)

    close_settings_menu(player)
    settings_frame.ignored_by_interaction = false
    settings_frame.header_flow.visible = false
    settings_frame.checkboxes_flow.visible = true

    global.player_data[e.player_index] = player_data

end

-- ------------------------------------------------------------
-- TILEGRID SETTINGS BUTTON

-- when a player invokes the 'open-gui' button
function on_leftclick(e)

	local player = game.players[e.player_index]
    local selected = player.selected
    local player_data = global.player_data[e.player_index]

    if selected and selected.name == 'tapeline-settings-button' then
        if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == 'tapeline-capsule' then
            player.surface.create_entity {
                name = 'flying-text',
                position = selected.position,
                text = {'flying-text.capsule-warning'}
            }
        else
            player_data.is_editing = true
            for k,v in pairs(global) do
                if type(v) == 'table' and v.button and v.button == selected then
                    player_data.cur_tilegrid_index = k
                    break
                end
            end

            open_settings_menu(player)

            local settings_frame = player_data.mod_gui.tapeline_menu_frame

            settings_frame.header_flow.visible = true
            settings_frame.header_flow.menu_title.caption={'gui-caption.settings-header-caption', player_data.cur_tilegrid_index}
            settings_frame.checkboxes_flow.visible = false

            global.player_data[e.player_index] = player_data
        end
	end

end

-- settings
stdlib.gui.on_selection_state_changed('gridtype_dropdown', on_gridtype_dropdown)
stdlib.gui.on_text_changed('split_divisor_textfield', on_setting_changed)
stdlib.gui.on_checked_state_changed('autoclear_checkbox', on_setting_changed)
stdlib.gui.on_checked_state_changed('restrict_to_cardinals_checkbox', on_setting_changed)
stdlib.gui.on_value_changed('increment_divisor_slider', on_slider)
stdlib.gui.on_value_changed('split_divisor_slider', on_slider)
stdlib.gui.on_text_changed('increment_divisor_textfield', on_setting_changed)
stdlib.gui.on_text_changed('split_divisor_textfield', on_setting_changed)
-- gui buttons
stdlib.gui.on_click('delete_button', on_delete_button)
stdlib.gui.on_click('dialog_back_button', on_dialog_back_button)
stdlib.gui.on_click('dialog_confirm_button', on_dialog_confirm_button)
-- tilegrid settings button
stdlib.event.register('mouse-leftclick', on_leftclick)
-- held item
stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)