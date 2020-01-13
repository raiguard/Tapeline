-- ----------------------------------------------------------------------------------------------------
-- EDIT GUI
-- Edit settings on a current tilegrid

local event = require('lualib.event')
local gui = require('lualib.gui')
local mod_gui = require('mod-gui')
local util = require('lualib.util')

local tilegrid = require('scripts.tilegrid')

local self = {}

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
-- GUI DATA

gui.add_templates(util.gui_templates)
gui.add_handlers('edit', {
	save_changes_button = {
		on_click = function(e)
			local player_table = global.players[e.player_index]
			player_table.flags.editing = false
			self.destroy(player_table.gui.edit.elems.window, game.get_player(e.player_index))
			player_table.gui.edit.highlight_box.destroy()
			player_table.gui.edit = nil
		end
	},
	delete_button = {
		on_click = function(e)
			e.element.parent.visible = false
			e.element.parent.parent.children[2].visible = true
		end
	},
	confirm_yes_button = {
		on_click = function(e)
			local player_table = global.players[e.player_index]
			tilegrid.destroy(player_table.flags.editing)
			player_table.flags.editing = false
			local gui_data = player_table.gui.edit
			self.destroy(gui_data.elems.window, game.get_player(e.player_index))
			gui_data.highlight_box.destroy()
			player_table.gui.edit = nil
			-- clean player cursor
			local player = game.get_player(e.player_index)
			local stack = player.cursor_stack
			if stack and stack.valid_for_read and stack.name == 'tapeline-adjust' then
				player.clean_cursor()
			end
		end
	},
	confirm_no_button = {
		on_click = function(e)
			e.element.parent.visible = false
			e.element.parent.parent.children[1].visible = true
		end
	},
	origin_dropdown = {
		on_state_changed = function(e)
			local player_table = global.players[e.player_index]
			local registry = global.tilegrids.registry[player_table.flags.editing]
			registry.hot_corner = util.area.opposite_corner(index_to_corner[e.element.selected_index])
			tilegrid.refresh(player_table.flags.editing)
		end
	},
	grid_type_switch = {
		on_switch_state_changed = function(e)
			local settings_table = get_settings_table(e.player_index)
			settings_table.grid_type = switch_state_to_type_index[e.element.switch_state]
			self.update(e.player_index)
			tilegrid.refresh(global.players[e.player_index].flags.editing)
		end
	},
	divisor_slider = {
		on_value_changed = function(e)
			local player_table = global.players[e.player_index]
			local settings_table = get_settings_table(e.player_index)
			local textfield = player_table.gui.edit.elems.divisor_textfield
			local divisor_name = type_index_to_name[settings_table.grid_type]..'_divisor'
			settings_table[divisor_name] = e.element.slider_value
			textfield.text = e.element.slider_value
			tilegrid.refresh(player_table.flags.editing)
		end
	},
	divisor_textfield = {
		on_text_changed = function(e)
			local player_table = global.players[e.player_index]
			local settings_table = get_settings_table(e.player_index)
			local gui_data = player_table.gui.edit
			local new_value = util.textfield.clamp_number_input(e.element, type_to_clamps[settings_table.grid_type], gui_data.last_divisor_value)
			if new_value ~= gui_data.last_divisor_value then
				gui_data.last_divisor_value = new_value
				gui_data.elems.divisor_slider.slider_value = new_value
				tilegrid.refresh(player_table.flags.editing)
			end
		end,
		on_confirmed = function(e)
			local player_table = global.players[e.player_index]
			local settings_table = get_settings_table(e.player_index)
			local final_text = util.textfield.set_last_valid_value(e.element, player_table.gui.edit.last_divisor_value)
			settings_table[type_index_to_name[settings_table.grid_type]..'_divisor'] = tonumber(final_text)
			tilegrid.refresh(player_table.flags.editing)
		end
	},
	move_button = {
		on_click = function(e)
			local player = game.get_player(e.player_index)
			player.clean_cursor()
			player.cursor_stack.set_stack{name='tapeline-adjust'}
		end
	}
})

-- --------------------------------------------------
-- LIBRARY

function self.create(parent, player_index, settings, hot_corner)
	gui.create(parent, 'edit', player_index,
		{template='window', name='tl_edit_window', children={
			{type='flow', direction='horizontal', children={
				-- default titlebar
				{type='flow', style={vertical_align='center'}, children={
					{type='label', style='heading_1_label', caption={'tl-gui.edit-settings'}},
					{template='pushers.horizontal'},
					{type='sprite-button', style={name='item_and_count_select_confirm', top_margin=0}, sprite='utility/check_mark', tooltip={'tl-gui.save-changes'}},
					{type='sprite-button', style='red_icon_button', sprite='utility/trash', tooltip={'tl-gui.delete-tilegrid'}}
				}}
			}}
		}}
	)
end

function self.update(player_index)
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

function self.destroy(window, player)
  gui.destroy(window, 'edit', player.index)
	-- remove capsule from hand if it's there
	local stack = player.cursor_stack
	if stack and stack.valid_for_read and stack.name == 'tapeline-adjust' then
		player.clean_cursor()
	end
end

return self