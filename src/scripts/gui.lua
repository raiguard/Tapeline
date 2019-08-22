-- ----------------------------------------------------------------------------------------------------
-- GUI CONTROL SCRIPTING
-- Creation and management of the GUI. Also includes GUI listeners.

local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register
local gui = require('__stdlib__/stdlib/event/gui')
local mod_gui = require('__core__/lualib/mod-gui')

local tilegrid = require('tilegrid')
local util = require('util')

local grid_types_by_index = {'increment', 'split'}
local switch_state_to_type = {left=1, right=2}
local min_value_by_type = {increment=1, split=2}

local lib = {}

-- ----------------------------------------------------------------------------------------------------
-- GUI ELEMENT MANAGEMENT

local function create_settings_window(parent, player, tilegrid)
    local settings = tilegrid and global.tilegrids[tilegrid].settings or util.player_table(player).settings
    local window = parent.add{type='frame', name='tapeline_settings_window', style=mod_gui.frame_style, direction='vertical'}
    if tilegrid then
        local header_flow = window.add{type='flow', name='tapeline_settings_header_flow', direction='horizontal'}
        -- default header
        local def_header_flow = header_flow.add{type='flow', name='tapeline_settings_def_header_flow', style='titlebar_flow', direction='horizontal'}
        def_header_flow.add{type='label', name='tapeline_settings_def_header_label', style='heading_1_label', caption={'gui-settings.header-label-caption', tilegrid}}
        def_header_flow.add{type='empty-widget', name='tapeline_settings_def_header_filler', style='invisible_horizontal_filler'}
        def_header_flow.add{type='sprite-button', name='tapeline_settings_def_header_button_confirm', style='green_icon_button', sprite='check_mark'}
        def_header_flow.add{type='sprite-button', name='tapeline_settings_def_header_button_delete', style='red_icon_button', sprite='utility/trash'}
        -- confirmation header
        local confirm_header_flow = header_flow.add{type='flow', name='tapeline_settings_confirm_header_flow', style='titlebar_flow', direction='horizontal'}
        confirm_header_flow.visible = false
        confirm_header_flow.add{type='label', name='tapeline_settings_confirm_header_label', style='bold_red_label', caption={'gui-settings.confirm-delete-label-caption'}}
        confirm_header_flow.add{type='empty-widget', name='tapeline_settings_confirm_header_filler', style='invisible_horizontal_filler'}
        confirm_header_flow.add{type='sprite-button', name='tapeline_settings_confirm_header_button_back', style='tool_button', sprite='utility/reset'}
        confirm_header_flow.add{type='sprite-button', name='tapeline_settings_confirm_header_button_delete', style='red_icon_button', sprite='utility/trash'}
    else
        -- checkboxes
        local toggles_flow = window.add{type='flow', name='tapeline_settings_toggles_flow', style='vertically_centered_flow', direction='horizontal'}
        toggles_flow.add{type='checkbox', name='tapeline_settings_autoclear_checkbox', caption={'gui-settings.autoclear-checkbox-caption'}, tooltip={'gui-settings.autoclear-checkbox-tooltip'}, state=settings.grid_autoclear}
        toggles_flow.add{type='empty-widget', name='tapeline_settings_toggles_filler', style='invisible_horizontal_filler'}
        toggles_flow.add{type='checkbox', name='tapeline_settings_cardinals_checkbox', caption={'gui-settings.cardinals-checkbox-caption'}, tooltip={'gui-settings.cardinals-checkbox-tooltip'}, state=settings.restrict_to_cardinals}
    end
    -- grid type
    local gridtype_flow = window.add{type='flow', name='tapeline_settings_gridtype_flow', style='vertically_centered_flow', direction='horizontal'}
    gridtype_flow.add{type='label', name='tapeline_settings_gridtype_label', caption={'gui-settings.gridtype-label-caption'}}
    gridtype_flow.add{type='empty-widget', name='tapeline_settings_gridtype_filler', style='invisible_horizontal_filler'}
    -- gridtype_flow.add{type='drop-down', name='tapeline_settings_gridtype_dropdown', items={{'gui-settings.gridtype-dropdown-item-increment'}, {'gui-settings.gridtype-dropdown-item-split'}}, selected_index=settings.grid_type}
    gridtype_flow.add{type='switch', name='tapeline_settings_gridtype_switch', left_label_caption={'gui-settings.gridtype-dropdown-item-increment'}, right_label_caption={'gui-settings.gridtype-dropdown-item-split'}, switch_state=(settings.grid_type == 1 and 'left' or 'right')}
    -- grid divisor setting
    local grid_type = grid_types_by_index[settings.grid_type]
    local divisor_label_flow = window.add{type='flow', name='tapeline_settings_divisor_label_flow', direction='horizontal'}
    divisor_label_flow.style.horizontally_stretchable = true
    divisor_label_flow.style.horizontal_align = 'center'
    divisor_label_flow.add{type='label', name='tapeline_settings_divisor_label', style='caption_label', caption={'gui-settings.'..grid_type..'-divisor-label-caption'}}
    local divisor_flow = window.add{type='flow', name='tapeline_settings_divisor_flow', style='vertically_centered_flow', direction='horizontal'}
    divisor_flow.style.horizontal_spacing = 8
    divisor_flow.add{type='slider', name='tapeline_settings_divisor_slider', style='notched_slider', minimum_value=(settings.grid_type == 1 and 1 or 2), maximum_value=(settings.grid_type == 1 and 10 or 12), value=settings[grid_type..'_divisor'], value_step=1, discrete_slider=true, discrete_values=true}.style.horizontally_stretchable = true
    local divisor_textfield = divisor_flow.add{type='textfield', name='tapeline_settings_divisor_textfield', numeric=true, lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, text=tostring(settings[grid_type..'_divisor'])}
    divisor_textfield.style.width = 50
    divisor_textfield.style.horizontal_align = 'center'
    return window
end

function lib.open(player, tilegrid)
    local frame_flow = mod_gui.get_frame_flow(player)
    if not frame_flow.tapeline_settings_window then
        local window = create_settings_window(frame_flow, player, tilegrid)
        if tilegrid then
            player.opened = window
        end
    end
end

function lib.close(player)
    local frame_flow = mod_gui.get_frame_flow(player)
    if frame_flow.tapeline_settings_window then
        frame_flow.tapeline_settings_window.destroy()
    end
end

function lib.refresh(player, tilegrid)
    lib.close(player)
    lib.open(player, tilegrid)
end

-- ----------------------------------------------------------------------------------------------------
-- GUI LISTENERS

local function get_table_and_settings(player_index)
    local player_table = util.player_table(player_index)
    local settings = player_table.cur_editing > 0 and global.tilegrids[player_table.cur_editing].settings or player_table.settings
    return player_table, settings, grid_types_by_index[settings.grid_type], player_table.cur_editing
end

on_event(defines.events.on_gui_closed, function(e)
    if e.element and e.element.name == 'tapeline_settings_window' then
        e.element.destroy()
        local player_table = util.player_table(e.player_index)
        if player_table.cur_editing > 0 then
            local highlight_box = global.tilegrids[player_table.cur_editing].highlight_box
            if highlight_box and highlight_box.valid then highlight_box.destroy() end
        end
    end
end)

gui.on_click('tapeline_settings_def_header_button_confirm', function(e)
    util.player_table(e.player_index).cur_editing = false
    event.dispatch{name=defines.events.on_gui_closed, player_index=e.player_index, gui_type=defines.gui_type.custom, element=e.element.parent.parent.parent}
end)

gui.on_click('tapeline_settings_def_header_button_delete', function(e)
    e.element.parent.visible = false
    e.element.parent.parent.children[2].visible = true
end)

gui.on_click('tapeline_settings_confirm_header_button_back', function(e)
    e.element.parent.visible = false
    e.element.parent.parent.children[1].visible = true
end)

gui.on_click('tapeline_settings_confirm_header_button_delete', function(e)
    local player_table = util.player_table(e.player_index)
    event.dispatch{name=defines.events.on_gui_closed, player_index=e.player_index, gui_type=defines.gui_type.custom, element=e.element.parent.parent.parent}
    tilegrid.destroy(player_table.cur_editing)
    player_table.cur_editing = 0
end)

gui.on_checked_state_changed('tapeline_settings_autoclear_checkbox', function(e)
    local player_table, settings, grid_type_name, cur_editing = get_table_and_settings(e.player_index)
    settings.grid_autoclear = e.element.state
end)

gui.on_checked_state_changed('tapeline_settings_cardinals_checkbox', function(e)
    local player_table, settings, cur_editing = get_table_and_settings(e.player_index)
    settings.restrict_to_cardinals = e.element.state
end)

-- STDLIB does not yet have a switch state changed event, so we must use the vanilla one
on_event(defines.events.on_gui_switch_state_changed, function(e)
    if e.element.name ~= 'tapeline_settings_gridtype_switch' then return end
    local player_table, settings, grid_type_name, cur_editing = get_table_and_settings(e.player_index)
    settings.grid_type = switch_state_to_type[e.element.switch_state]
    if cur_editing > 0 then
        tilegrid.update_settings(cur_editing)
    end
    lib.refresh(util.get_player(e), cur_editing > 0 and cur_editing or nil)
end)

gui.on_value_changed('tapeline_settings_divisor_slider', function(e)
    local player_table, settings, grid_type_name, cur_editing = get_table_and_settings(e.player_index)
    local textfield = e.element.parent[string.gsub(e.element.name, 'slider', 'textfield')]
    if textfield then
        textfield.text = tostring(e.element.slider_value)
    end
    if player_table.last_valid_textfield_value ~= e.element.slider_value then
        settings[grid_type_name..'_divisor'] = e.element.slider_value
    end
    if cur_editing > 0 then
        tilegrid.update_settings(cur_editing)
    end
    player_table.last_valid_textfield_value = e.element.slider_value
end)

gui.on_text_changed('tapeline_settings_divisor_textfield', function(e)
    local player_table, settings, grid_type_name, cur_editing = get_table_and_settings(e.player_index)
    local text = e.element.text
    if text == '' or tonumber(text) < min_value_by_type[grid_type_name] then
        e.element.style = 'invalid_short_number_textfield'
        if player_table.last_valid_textfield_value == nil then
            player_table.last_valid_textfield_value = settings[grid_type_name..'_divisor']
        end
        return nil
    else
        e.element.style = 'textbox'
    end
    settings[grid_type_name..'_divisor'] = tonumber(text)
    player_table.last_valid_textfield_value = text
    local slider = e.element.parent[string.gsub(e.element.name, 'textfield', 'slider')]
    if slider then slider.slider_value = text end
end)

gui.on_confirmed('tapeline_settings_divisor_textfield', function(e)
    local player_table, settings, grid_type_name, cur_editing = get_table_and_settings(e.player_index)
    local text = e.element.text
    if text ~= player_table.last_valid_textfield_value then
        e.element.text = player_table.last_valid_textfield_value
        e.element.style = 'textbox'
    end
    if cur_editing > 0 then
        tilegrid.update_settings(cur_editing)
    end
    settings[grid_type_name..'_divisor'] = tonumber(text)
    if cur_editing > 0 then
        tilegrid.update_settings(cur_editing)
    end
    player_table.last_valid_textfield_value = nil
end)

-- ----------------------------------------------------------------------------------------------------

return lib