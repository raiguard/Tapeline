-- ----------------------------------------------------------------------------------------------------
-- EDIT GUI
-- Edit settings on a current tilegrid

local event = require('lualib/event')
local mod_gui = require('mod-gui')
local util = require('lualib/util')

local tilegrid = require('scripts/tilegrid')

local edit_gui = {}

-- --------------------------------------------------
-- LOCAL UTILITIES

type_to_switch_state = {'left', 'right'}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {'increment', 'split'}
type_to_clamps = {{4,13}, {2,11}}

origin_localized_items = {
	{'tl-gui-edit.origin-left_top'},
	{'tl-gui-edit.origin-right_top'},
	{'tl-gui-edit.origin-left_bottom'},
	{'tl-gui-edit.origin-right_bottom'}
}
corner_to_index = {
	left_top = 1,
	right_top = 2,
	left_bottom = 3,
	right_bottom = 4
}
index_to_corner = {'left_top', 'right_top', 'left_bottom', 'right_bottom'}

local function get_settings_table(player_index)
	return global.tilegrids.registry[global.players[player_index].flags.editing].settings
end

-- --------------------------------------------------
-- EVENT HANDLERS

local function save_changes_button_clicked(e)
	local player_table = global.players[e.player_index]
	player_table.flags.editing = false
	edit_gui.destroy(player_table.gui.edit.elems.window, e.player_index)
	player_table.gui.edit.highlight_box.destroy()
	player_table.gui.edit = nil
end

local function delete_button_clicked(e)
	e.element.parent.visible = false
	e.element.parent.parent.children[2].visible = true
end

local function confirm_yes_button_clicked(e)
	local player_table = global.players[e.player_index]
	tilegrid.destroy(player_table.flags.editing)
	player_table.flags.editing = false
	local gui_data = player_table.gui.edit
	edit_gui.destroy(gui_data.elems.window, e.player_index)
	gui_data.highlight_box.destroy()
	player_table.gui.edit = nil
	-- clean player cursor
	local player = game.get_player(e.player_index)
	local stack = player.cursor_stack
	if stack and stack.valid_for_read and stack.name == 'tapeline-adjust' then
		player.clean_cursor()
	end
end

local function confirm_no_button_clicked(e)
	e.element.parent.visible = false
	e.element.parent.parent.children[1].visible = true
end

local function origin_dropdown_state_changed(e)
	local player_table = global.players[e.player_index]
	local registry = global.tilegrids.registry[player_table.flags.editing]
	registry.hot_corner = util.area.opposite_corner(index_to_corner[e.element.selected_index])
	tilegrid.refresh(player_table.flags.editing)
end

local function type_switch_state_changed(e)
	local settings_table = get_settings_table(e.player_index)
	settings_table.grid_type = switch_state_to_type_index[e.element.switch_state]
	edit_gui.update(e.player_index)
	tilegrid.refresh(global.players[e.player_index].flags.editing)
end

local function divisor_slider_value_changed(e)
	local player_table = global.players[e.player_index]
	local settings_table = get_settings_table(e.player_index)
	local textfield = player_table.gui.edit.elems.divisor_textfield
	local divisor_name = type_index_to_name[settings_table.grid_type]..'_divisor'
	settings_table[divisor_name] = e.element.slider_value
	textfield.text = e.element.slider_value
	tilegrid.refresh(player_table.flags.editing)
end

local function divisor_textfield_text_changed(e)
	local player_table = global.players[e.player_index]
	local settings_table = get_settings_table(e.player_index)
	local gui_data = player_table.gui.edit
	local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[settings_table.grid_type], gui_data.last_divisor_value)
	if new_value ~= gui_data.last_divisor_value then
		gui_data.last_divisor_value = new_value
		gui_data.elems.divisor_slider.slider_value = new_value
		tilegrid.refresh(player_table.flags.editing)
	end
end

local function divisor_textfield_confirmed(e)
	local player_table = global.players[e.player_index]
	local settings_table = get_settings_table(e.player_index)
	local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.edit.last_divisor_value)
	settings_table[type_index_to_name[settings_table.grid_type]..'_divisor'] = tonumber(final_text)
	tilegrid.refresh(player_table.flags.editing)
end

local function move_button_clicked(e)
	local player = game.get_player(e.player_index)
	player.clean_cursor()
	player.cursor_stack.set_stack{name='tapeline-adjust'}
end

local function redraw_button_clicked(e)
	game.print('redraw tilegrid')
end

local handlers = {
	edit_save_changes_button_clicked = save_changes_button_clicked,
	edit_delete_button_clicked = delete_button_clicked,
	edit_confirm_yes_button_clicked = confirm_yes_button_clicked,
	edit_confirm_no_button_clicked = confirm_no_button_clicked,
	edit_type_switch_state_changed = type_switch_state_changed,
	edit_divisor_slider_value_changed = divisor_slider_value_changed,
	edit_divisor_textfield_text_changed = divisor_textfield_text_changed,
	edit_divisor_textfield_confirmed = divisor_textfield_confirmed,
	edit_origin_dropdown_state_changed = origin_dropdown_state_changed,
	edit_move_button_clicked = move_button_clicked,
	edit_redraw_button_clicked = redraw_button_clicked
}

event.on_load(function()
	event.load_conditional_handlers(handlers)
end)

-- --------------------------------------------------
-- LIBRARY

function edit_gui.create(parent, player_index, settings, hot_corner)
	local window = parent.add{type='frame', name='tl_edit_window', style=mod_gui.frame_style, direction='vertical'}
	window.style.width = gui_window_width
	local titlebar_flow = window.add{type='flow', name='tl_edit_titlebar_flow', style='tl_vertically_centered_flow', direction='horizontal'}
	-- default titlebar
	local def_titlebar_flow = titlebar_flow.add{type='flow', name='tl_edit_def_titlebar_flow', style='tl_vertically_centered_flow', direction='horizontal'}
	def_titlebar_flow.add{type='label', name='tl_edit_def_titlebar_label', style='heading_1_label', caption={'tl-gui-edit.titlebar-label-caption'}}
	def_titlebar_flow.add{type='empty-widget', name='tl_edit_def_titlebar_pusher', style='tl_horizontal_pusher'}
	event.on_gui_click(save_changes_button_clicked, {name='edit_save_changes_button_clicked', player_index=player_index, gui_filters=
		def_titlebar_flow.add{type='sprite-button', name='tl_edit_def_titlebar_button_confirm', style='tl_green_icon_button', sprite='utility/confirm_slot',
			tooltip={'tl-gui-edit.titlebar-confirm-button-tooltip'}}
	})
	event.on_gui_click(delete_button_clicked, {name='edit_delete_button_clicked', player_index=player_index, gui_filters=
		def_titlebar_flow.add{type='sprite-button', name='tl_edit_def_titlebar_button_delete', style='red_icon_button', sprite='utility/trash',
			tooltip={'tl-gui-edit.titlebar-delete-button-tooltip'}}
	})
	-- confirmation titlebar
	local confirm_titlebar_flow = titlebar_flow.add{type='flow', name='tl_edit_confirm_titlebar_flow', style='tl_vertically_centered_flow', direction='horizontal'}
	confirm_titlebar_flow.visible = false
	confirm_titlebar_flow.add{type='label', name='tl_edit_confirm_titlebar_label', style='tl_invalid_bold_label',
		caption={'tl-gui-edit.confirm-delete-label-caption'}}
	confirm_titlebar_flow.add{type='empty-widget', name='tl_edit_confirm_titlebar_pusher', style='tl_horizontal_pusher'}
	event.on_gui_click(confirm_no_button_clicked, {name='edit_confirm_no_button_clicked', player_index=player_index, gui_filters=
		confirm_titlebar_flow.add{type='sprite-button', name='tl_edit_confirm_titlebar_button_back', style='tool_button', sprite='utility/reset',
			tooltip={'tl-gui-edit.confirm-button-no-tooltip'}}
	})
	event.on_gui_click(confirm_yes_button_clicked, {name='edit_confirm_yes_button_clicked', player_index=player_index, gui_filters=
		confirm_titlebar_flow.add{type='sprite-button', name='tl_edit_confirm_titlebar_button_delete', style='red_icon_button', sprite='utility/trash',
			tooltip={'tl-gui-edit.confirm-button-yes-tooltip'}}
	})
	local origin_flow = window.add{type='flow', name='tl_edit_origin_flow', style='tl_vertically_centered_flow', direction='horizontal'}
	origin_flow.add{type='label', name='tl_edit_origin_label', caption={'', {'tl-gui-edit.origin-label-caption'}, ' [img=info]'},
		tooltip={'tl-gui-edit.origin-label-tooltip'}}
	origin_flow.add{type='empty-widget', name='tl_edit_origin_pusher', style='tl_horizontal_pusher'}
	event.on_gui_selection_state_changed(origin_dropdown_state_changed, {name='edit_origin_dropdown_state_changed', player_index=player_index, gui_filters=
		origin_flow.add{type='drop-down', name='tl_edit_origin_dropdown', items=origin_localized_items,
			selected_index=corner_to_index[util.area.opposite_corner(hot_corner)]}
	})
	local switch_flow = window.add{type='flow', name='tl_edit_switch_flow', direction='horizontal'}
    switch_flow.add{type='label', name='tl_edit_switch_label', caption={'tl-gui-edit.type-switch-label'}}
	switch_flow.add{type='empty-widget', name='tl_edit_switch_pusher', style='tl_horizontal_pusher'}
	local grid_type = settings.grid_type
  local type_switch = switch_flow.add{type='switch', name='tl_edit_switch', left_label_caption={'tl-gui-edit.type-switch-increment-caption'},
    right_label_caption={'tl-gui-edit.type-switch-split-caption'}, switch_state=type_to_switch_state[grid_type]}
	event.on_gui_switch_state_changed(type_switch_state_changed, {name='edit_type_switch_state_changed', player_index=player_index, gui_filters=type_switch})
	local divisor_label_flow = window.add{type='flow', name='tl_edit_divisor_label_flow', style='tl_horizontally_centered_flow', direction='vertical'}
  local divisor_label = divisor_label_flow.add{type='label', name='tl_edit_divisor_label', style='caption_label',
		caption={'tl-gui-edit.'..type_index_to_name[grid_type]..'-divisor-label-caption'}}
	local divisor_slider_flow = window.add{type='flow', name='tl_edit_divisor_slider_flow', style='tl_vertically_centered_flow', direction='horizontal'}
	local divisor_slider = divisor_slider_flow.add{type='slider', name='tl_edit_divisor_slider', style='notched_slider',
		minimum_value=type_to_clamps[grid_type][1], maximum_value=type_to_clamps[grid_type][2], value_step=1, discrete_slider=true, discrete_values=true,
		value=settings[type_index_to_name[grid_type]..'_divisor']}
	divisor_slider.style.horizontally_stretchable = true
	event.on_gui_value_changed(divisor_slider_value_changed, {name='edit_divisor_slider_value_changed', player_index=player_index, gui_filters=divisor_slider})
	local divisor_textfield = divisor_slider_flow.add{type='textfield', name='tl_edit_divisor_textfield', style='tl_slider_textfield', numeric=true,
		lose_focus_on_confirm=true, clear_and_focus_on_right_click=true, text=settings[type_index_to_name[grid_type]..'_divisor']}
	event.on_gui_text_changed(divisor_textfield_text_changed, {name='edit_divisor_textfield_text_changed', player_index=player_index,
		gui_filters=divisor_textfield})
	event.on_gui_confirmed(divisor_textfield_confirmed, {name='edit_divisor_textfield_confirmed', player_index=player_index, gui_filters=divisor_textfield})
	local buttons_flow = window.add{type='flow', name='tl_edit_buttons_flow', direction='horizontal'}
	buttons_flow.style.top_margin = 4
	buttons_flow.style.horizontally_stretchable = true
	event.on_gui_click(move_button_clicked, {name='edit_move_button_clicked', player_index=player_index, gui_filters=
		buttons_flow.add{type='button', name='tl_edit_move_button', style='tl_stretchable_button', caption={'tl-gui-edit.move-button-caption'}}
	})
	return {window=window, type_switch=type_switch, divisor_label=divisor_label, divisor_slider=divisor_slider, divisor_textfield=divisor_textfield},
		   		settings[type_index_to_name[grid_type]..'_divisor']
end

function edit_gui.update(player_index)
	local player_table = global.players[player_index]
	local settings = player_table.settings
	local elems = player_table.gui.edit.elems
	-- update values and names of divisor elements
	local grid_type = settings.grid_type
	elems.divisor_label.caption = {'tl-gui-edit.'..type_index_to_name[grid_type]..'-divisor-label-caption'}
	elems.divisor_slider.set_slider_minimum_maximum(type_to_clamps[grid_type][1], type_to_clamps[grid_type][2])
	elems.divisor_slider.slider_value = settings[type_index_to_name[grid_type]..'_divisor']
	elems.divisor_textfield.text = settings[type_index_to_name[grid_type]..'_divisor']
end

function edit_gui.destroy(window, player_index)
  -- deregister all GUI events if needed
	for cn,h in pairs(handlers) do
		event.deregister_conditional(h, {name=cn, player_index=player_index})
	end
	window.destroy()
end

return edit_gui