-- ----------------------------------------------------------------------------------------------------
-- DRAW GUI
-- Edit settings related to drawing tilegrids

local event = require('lualib.event')
local gui = require('lualib.gui')
local mod_gui = require('mod-gui')
local util = require('lualib.util')

local self = {}

-- --------------------------------------------------
-- LOCAL UTILITIES

type_to_switch_state = {'left', 'right'}
switch_state_to_type_index = {left=1, right=2}
type_index_to_name = {'increment', 'split'}
type_to_clamps = {{4,13}, {2,11}}

-- --------------------------------------------------
-- GUI DATA

gui.add_templates(util.gui_templates)
gui.add_handlers('draw', {
	auto_clear_checkbox = {
		on_checked_state_changed = function(e)
			local player_table = global.players[e.player_index]
			player_table.settings.auto_clear = e.element.state
		end
	},
	cardinals_checkbox = {
		on_checked_state_changed = function(e)
			local player_table = global.players[e.player_index]
			player_table.settings.cardinals_only = e.element.state
		end
	},
	grid_type_switch = {
		on_switch_state_changed = function(e)
			local player_table = global.players[e.player_index]
			player_table.settings.grid_type = switch_state_to_type_index[e.element.switch_state]
			self.update(e.player_index)
		end
	},
	divisor_slider = {
		on_value_changed = function(e)
			local player_table = global.players[e.player_index]
			local textfield = player_table.gui.draw.elems.divisor_textfield
			local divisor_name = type_index_to_name[player_table.settings.grid_type]..'_divisor'
			player_table.settings[divisor_name] = e.element.slider_value
			textfield.text = e.element.slider_value
		end
	},
	divisor_textfield = {
		on_text_changed = function(e)
			local player_table = global.players[e.player_index]
			local gui_data = player_table.gui.draw
			local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[player_table.settings.grid_type], gui_data.last_divisor_value)
			if new_value ~= gui_data.last_divisor_value then
				gui_data.last_divisor_value = new_value
				gui_data.elems.divisor_slider.slider_value = new_value
			end
		end,
		on_confirmed = function(e)
			local player_table = global.players[e.player_index]
			local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.draw.last_divisor_value)
			player_table.settings[type_index_to_name[player_table.settings.grid_type]..'_divisor'] = tonumber(final_text)
		end
	}
})

-- --------------------------------------------------
-- LIBRARY

function self.create(parent, player_index, default_settings)
	local grid_type = default_settings.grid_type
	local data = gui.create(parent, 'edit', player_index,
		{template='window', name='tl_draw_window', children={
			-- checkboxes
			{type='flow', direction='horizontal', children={
				{type='checkbox', caption={'', {'tl-gui-draw.autoclear-checkbox-caption'}, ' [img=info]'},
					tooltip={'tl-gui-draw.autoclear-checkbox-tooltip'}, state=default_settings.auto_clear, handlers='auto_clear_checkbox', save_as=true},
				{template='pushers.horizontal'},
				{type='checkbox', caption={'', {'tl-gui-draw.cardinals-checkbox-caption'}, ' [img=info]'},
					tooltip={'tl-gui-draw.cardinals-checkbox-tooltip'}, state=default_settings.cardinals_only, handlers='cardinals_checkbox', save_as=true}
			}},
			-- grid type switch
			{type='flow', style={vertical_align='center'}, direction='horizontal', children={
				{type='label', caption={'tl-gui-draw.type-switch-label'}},
				{template='pushers.horizontal'},
				{type='switch', left_label_caption={'tl-gui-draw.type-switch-increment-caption'}, right_label_caption={'tl-gui-draw.type-switch-split-caption'},
					switch_state=type_to_switch_state[grid_type], handlers='grid_type_switch', save_as=true}
			}},
			-- divisor label
			{type='flow', style={horizontal_align='center', horizontally_stretchable=true}, children={
				{type='label', style='caption_label', caption={'tl-gui-draw.'..type_index_to_name[grid_type]..'-divisor-label-caption'}, save_as='divisor_label'},
			}},
			-- divisor slider and textfield
			{type='flow', style={horizontal_spacing=8, vertical_align='center'}, direction='horizontal', children={
				{type='slider', style={name='notched_slider', horizontally_stretchable=true}, minimum_value=type_to_clamps[grid_type][1],
					maximum_value=type_to_clamps[grid_type][2], value_step=1, value=default_settings[type_index_to_name[grid_type]..'_divisor'], discrete_slider=true,
					discrete_values=true, handlers='divisor_slider', save_as=true},
				{type='textfield', style={width=50, horizontal_align='center'}, numeric=true, lose_focus_on_confirm=true,
					text=default_settings[type_index_to_name[grid_type]..'_divisor'], handlers='divisor_textfield', save_as=true}
			}}
		}}
	)
	return data
end

function self.update(player_index)
	local player_table = global.players[player_index]
	local settings = player_table.settings
	local elems = player_table.gui.draw.elems
	-- update values and names of divisor elements
	local grid_type = settings.grid_type
	elems.divisor_label.caption = {'tl-gui-draw.'..type_index_to_name[grid_type]..'-divisor-label-caption'}
	elems.divisor_slider.set_slider_minimum_maximum(type_to_clamps[grid_type][1], type_to_clamps[grid_type][2])
	elems.divisor_slider.slider_value = settings[type_index_to_name[grid_type]..'_divisor']
	elems.divisor_textfield.text = settings[type_index_to_name[grid_type]..'_divisor']
end

function self.destroy(window, player_index)
	gui.destroy(window, 'draw', player_index)
end

return self