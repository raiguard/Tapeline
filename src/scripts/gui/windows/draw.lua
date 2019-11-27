-- ----------------------------------------------------------------------------------------------------
-- DRAW GUI
-- Edit settings related to drawing tilegrids

local event = require('scripts/lib/event-handler')
local mod_gui = require('mod-gui')
local util = require('scripts/lib/util')

local draw_gui = {}

-- --------------------------------------------------
-- LOCAL UTILITIES

type_to_switch_state = {'left', 'right'}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {'increment', 'split'}
type_to_clamps = {{4,13}, {2,11}}

-- --------------------------------------------------
-- EVENT HANDLERS

local function autoclear_checkbox_clicked(e)
	local player_table = util.player_table(e.player_index)
	player_table.settings.auto_clear = e.element.state
end

local function cardinals_checkbox_clicked(e)
	local player_table = util.player_table(e.player_index)
	player_table.settings.cardinals_only = e.element.state
end

local function type_switch_state_changed(e)
	local player_table = util.player_table(e.player_index)
	player_table.settings.grid_type = switch_state_to_type_index[e.element.switch_state]
	draw_gui.update(e.player_index)
end

local function divisor_slider_value_changed(e)
	local player_table = util.player_table(e.player_index)
	local textfield = player_table.gui.draw.elems.divisor_textfield
	local divisor_name = type_index_to_name[player_table.settings.grid_type]..'_divisor'
	player_table.settings[divisor_name] = e.element.slider_value
	textfield.text = e.element.slider_value
end

local function divisor_textfield_text_changed(e)
	local player_table = util.player_table(e.player_index)
	local gui_data = player_table.gui.draw
	local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[player_table.settings.grid_type], gui_data.last_divisor_value)
	if new_value ~= gui_data.last_divisor_value then
		gui_data.last_divisor_value = new_value
		gui_data.elems.divisor_slider.slider_value = new_value
	end
end

local function divisor_textfield_confirmed(e)
	local player_table = util.player_table(e.player_index)
	local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.draw.last_divisor_value)
    player_table.settings[type_index_to_name[player_table.settings.grid_type]..'_divisor'] = tonumber(final_text)
end

local handlers = {
	draw_autoclear_checkbox_clicked = autoclear_checkbox_clicked,
	draw_cardinals_checkbox_clicked = cardinals_checkbox_clicked,
	draw_type_switch_state_changed = type_switch_state_changed,
	draw_divisor_slider_value_changed = divisor_slider_value_changed,
	draw_divisor_textfield_text_changed = divisor_textfield_text_changed,
	draw_divisor_textfield_confirmed = divisor_textfield_confirmed
}

event.on_load(function()
	event.load_conditional_handlers(handlers)
end)

-- --------------------------------------------------
-- LIBRARY

function draw_gui.create(parent, player_index, default_settings)
    local window = parent.add{type='frame', name='tl_draw_window', style=mod_gui.frame_style, direction='vertical'}
    local checkboxes_flow = window.add{type='flow', name='tl_draw_checkboxes_flow', direction='horizontal'}
	local autoclear_checkbox = checkboxes_flow.add{type='checkbox', name='tl_draw_autoclear_checkbox', tooltip={'gui-draw.autoclear-checkbox-tooltip'},
												   caption={'', {'gui-draw.autoclear-checkbox-caption'}, ' [img=info]'}, state=default_settings.auto_clear}
	event.gui.on_click(autoclear_checkbox, autoclear_checkbox_clicked, 'draw_autoclear_checkbox_clicked', player_index)
    checkboxes_flow.add{type='empty-widget', name='tl_draw_checkboxes_pusher', style='invisible_horizontal_pusher'}
    local cardinals_checkbox = checkboxes_flow.add{type='checkbox', name='tl_draw_cardinals_checkbox', tooltip={'gui-draw.cardinals-checkbox-tooltip'},
												   caption={'', {'gui-draw.cardinals-checkbox-caption'}, ' [img=info]'}, state=default_settings.cardinals_only}
	event.gui.on_click(cardinals_checkbox, cardinals_checkbox_clicked, 'draw_cardinals_checkbox_clicked', player_index)
    local switch_flow = window.add{type='flow', name='tl_draw_switch_flow', direction='horizontal'}
    switch_flow.add{type='label', name='tl_draw_switch_label', caption={'gui-draw.type-switch-label'}}
	switch_flow.add{type='empty-widget', name='tl_draw_switch_pusher', style='invisible_horizontal_pusher'}
	local grid_type = default_settings.grid_type
    local type_switch = switch_flow.add{type='switch', name='tl_draw_switch', left_label_caption={'gui-draw.type-switch-increment-caption'},
                                        right_label_caption={'gui-draw.type-switch-split-caption'},
										switch_state=type_to_switch_state[grid_type]}
	event.gui.on_switch_state_changed(type_switch, type_switch_state_changed, 'draw_type_switch_state_changed', player_index)
	local divisor_label_flow = window.add{type='flow', name='tl_draw_divisor_label_flow', style='horizontally_centered_flow', direction='vertical'}
    local divisor_label = divisor_label_flow.add{type='label', name='tl_draw_divisor_label', style='caption_label',
									 caption={'gui-draw.'..type_index_to_name[grid_type]..'-divisor-label-caption'}}
	local divisor_slider_flow = window.add{type='flow', name='tl_draw_divisor_slider_flow', style='vertically_centered_flow', direction='horizontal'}
	local divisor_slider = divisor_slider_flow.add{type='slider', name='tl_draw_divisor_slider', style='notched_slider',
												   minimum_value=type_to_clamps[grid_type][1], maximum_value=type_to_clamps[grid_type][2], value_step=1,
												   discrete_slider=true, discrete_values=true,
												   value=default_settings[type_index_to_name[grid_type]..'_divisor']}
	event.gui.on_value_changed(divisor_slider, divisor_slider_value_changed, 'draw_divisor_slider_value_changed', player_index)
	local divisor_textfield = divisor_slider_flow.add{type='textfield', name='tl_draw_divisor_textfield', style='tl_slider_textfield', numeric=true,
													  lose_focus_on_confirm=true, clear_and_focus_on_right_click=true,
													  text=default_settings[type_index_to_name[grid_type]..'_divisor']}
	event.gui.on_text_changed(divisor_textfield, divisor_textfield_text_changed, 'draw_divisor_textfield_text_changed', player_index)
	event.gui.on_confirmed(divisor_textfield, divisor_textfield_confirmed, 'draw_divisor_textfield_confirmed', player_index)
	return {window=window, autoclear_checkbox=autoclear_checkbox, cardinals_checkbox=cardinals_checkbox, type_switch=type_switch, divisor_label=divisor_label,
			divisor_slider=divisor_slider, divisor_textfield=divisor_textfield},
		   default_settings[type_index_to_name[grid_type]..'_divisor']
end

function draw_gui.update(player_index)
	local player_table = util.player_table(player_index)
	local settings = player_table.settings
	local elems = player_table.gui.draw.elems
	-- update values and names of divisor elements
	local grid_type = settings.grid_type
	elems.divisor_label.caption = {'gui-draw.'..type_index_to_name[grid_type]..'-divisor-label-caption'}
	elems.divisor_slider.set_slider_minimum_maximum(type_to_clamps[grid_type][1], type_to_clamps[grid_type][2])
	elems.divisor_slider.slider_value = settings[type_index_to_name[grid_type]..'_divisor']
	elems.divisor_textfield.text = settings[type_index_to_name[grid_type]..'_divisor']
end

function draw_gui.destroy(window, player_index)
    -- deregister all GUI events if needed
    local con_registry = global.conditional_event_registry
    for cn,h in pairs(handlers) do
        event.gui.deregister(con_registry[cn].id, h, cn, player_index)
    end
	window.destroy()
end

return draw_gui