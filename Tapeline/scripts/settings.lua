function on_init()

	global.player_settings = {}

end

function on_change(e)

    retrieve_mod_settings(game.players[e.player_index])

end

-- retrieve mod settings for the specified player
function retrieve_mod_settings(player)

	local player_mod_settings = player.mod_settings
	local global_player_settings = global.player_settings[player.index]
    local mod_settings = {}

	-- runtime-changeable settings
	mod_settings.increment_divisor = global_player_settings.increment_divisor
	mod_settings.split_divisor = global_player_settings.split_divisor
	mod_settings.grid_type = global_player_settings.grid_type
	mod_settings.grid_autoclear = global_player_settings.grid_autoclear

    -- real actual settings
	mod_settings.draw_tilegrid_on_ground = player_mod_settings['draw-tilegrid-on-ground'].value
    mod_settings.tilegrid_line_width = player_mod_settings['tilegrid-line-width'].value
	mod_settings.tilegrid_clear_delay = player_mod_settings['tilegrid-clear-delay'].value * 60

	mod_settings.log_selection_area = player_mod_settings['log-selection-area'].value
	
	mod_settings.tilegrid_background_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-background-color'].value], 0.6)
	mod_settings.tilegrid_border_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-border-color'].value])
	mod_settings.tilegrid_label_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-label-color'].value], 0.8)
	mod_settings.tilegrid_div_color = {}
	mod_settings.tilegrid_div_color[1] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-1'].value])
	mod_settings.tilegrid_div_color[2] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-2'].value])
	mod_settings.tilegrid_div_color[3] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-3'].value])
	mod_settings.tilegrid_div_color[4] = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-4'].value])

	mod_settings.label_primary_size = 2
	mod_settings.label_secondary_size = 1
	mod_settings.label_primary_offset = 1.1
    mod_settings.label_secondary_offset = 0.6
    
    return mod_settings

end

function create_settings(player_index)

	local settings = {}
	settings.increment_divisor = 5
	settings.split_divisor = 4
	settings.grid_type = 1
	settings.grid_autoclear = false

	global.player_settings[player_index] = settings

	stdlib.logger.log(global.player_settings[player_index])

end

local setting_associations = {
	gridtype_dropdown = 'grid_type',
	autoclear_checkbox = 'grid_autoclear',
	increment_textfield = 'increment_divisor',
	split_divisor_textfield = 'split_divisor',
	increment_divisor_slider = 'increment_divisor'
}

function change_setting(e)

	local value
	local type = e.element.type
	if e.element.type == 'drop-down' then
		value = e.element.selected_index
	elseif type == 'textfield' then
		value = e.element.text
	elseif type == 'checkbox' then
		value = e.element.state
	elseif type == 'slider' then
		value = e.element.slider_value
	end

	global.player_settings[e.player_index][setting_associations[e.match]] = value

	stdlib.logger.log(global.player_settings[e.player_index])

end

function on_leftclick(e)

	local player = game.players[e.player_index]
	local selected = player.selected

	if selected and selected.name == 'tapeline-settings-button' then
		open_settings_menu(player)
	end

end

-- stdlib.event.register({defines.events.on_runtime_mod_setting_changed, defines.events.on_player_joined_game}, on_change)
stdlib.event.register('on_init', on_init)
stdlib.event.register('mouse-leftclick', on_leftclick)