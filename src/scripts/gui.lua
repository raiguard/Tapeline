-- ----------------------------------------------------------------------------------------------------
-- GUI CONTROL SCRIPTING
-- Creation and management of the GUI. Also includes GUI listeners.

local event = require('__stdlib__/stdlib/event/event')
local on_event = event.register
local gui = require('__stdlib__/stdlib/event/gui')
local util = require('util')

local mod_gui = require('__core__/lualib/mod-gui')

local grid_types = {'increment', 'split'}

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
        confirm_header_flow.add{type='sprite-button', name='tapeline_settings_confirm_header_button_confirm', style='tool_button', sprite='utility/reset'}
        confirm_header_flow.add{type='sprite-button', name='tapeline_settings_confirm_header_button_delete', style='red_icon_button', sprite='utility/trash'}
    end
    -- checkboxes
    local toggles_flow = window.add{type='flow', name='tapeline_settings_toggles_flow', style='vertically_centered_flow', direction='horizontal'}
    toggles_flow.add{type='checkbox', name='tapeline_settings_autoclear_checkbox', caption={'gui-settings.autoclear-checkbox-caption'}, tooltip={'gui-settings.autoclear-checkbox-tooltip'}, state=settings.grid_autoclear}
    toggles_flow.add{type='empty-widget', name='tapeline_settings_toggles_filler', style='invisible_horizontal_filler'}
    toggles_flow.add{type='checkbox', name='tapeline_settings_cardinals_checkbox', caption={'gui-settings.cardinals-checkbox-caption'}, tooltip={'gui-settings.cardinals-checkbox-tooltip'}, state=settings.restrict_to_cardinals}
    -- grid type
    local gridtype_flow = window.add{type='flow', name='tapeline_settings_gridtype_flow', style='vertically_centered_flow', direction='horizontal'}
    gridtype_flow.add{type='label', name='tapeline_settings_gridtype_label', caption={'gui-settings.gridtype-label-caption'}}
    gridtype_flow.add{type='empty-widget', name='tapeline_settings_gridtype_filler', style='invisible_horizontal_filler'}
    -- gridtype_flow.add{type='drop-down', name='tapeline_settings_gridtype_dropdown', items={{'gui-settings.gridtype-dropdown-item-increment'}, {'gui-settings.gridtype-dropdown-item-split'}}, selected_index=settings.grid_type}
    gridtype_flow.add{type='switch', name='tapeline_settings_gridtype_switch', left_label_caption={'gui-settings.gridtype-dropdown-item-increment'}, right_label_caption={'gui-settings.gridtype-dropdown-item-split'}, switch_state=(settings.grid_type == 1 and 'left' or 'right')}
    -- grid divisor setting
    local grid_type = grid_types[settings.grid_type]
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

-- ----------------------------------------------------------------------------------------------------
-- GUI LISTENERS

on_event(defines.events.on_gui_closed, function(e)
    -- local player = util.get_player(e)
    if e.element and e.element.name == 'tapeline_settings_window' then
        e.element.destroy()
    end
end)

-- ----------------------------------------------------------------------------------------------------

return lib