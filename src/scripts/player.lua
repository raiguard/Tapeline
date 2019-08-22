-- initialize all player-related globals
function setup_global()
	global.player_data = global.player_data or {}
    for i,_ in pairs(game.players) do
        if not global.player_data[i] then
            global.player_data[i] = create_player_data(i)
        end
	end
end

-- when a new player first joins the game, create their data
function on_player_created(e)
    global.player_data[e.player_index] = create_player_data(e.player_index)
end

-- create player data
function create_player_data(player_index)
    if global.player_data[player_index] then return global.player_data[player_index] end

    local data = {}
    -- player action status
    data.cur_drawing = false
    data.cur_editing = false
    -- current tilegrid data
    data.cur_tilegrid_index = global.next_tilegrid_index
    -- drawing metadata
    data.last_capsule_tick = 0
    data.last_capsule_pos = { x = 0, y = 0 }
    -- gui references
    local player = game.players[player_index]
    data.mod_gui = mod_gui.get_frame_flow(player)
    data.center_gui = player.gui.center

    data.settings = create_player_settings(player_index)

    return data
end

-- create player settings
function create_player_settings(player_index)
	local data = {}
	-- runtime settings
	data.increment_divisor = 5
	data.split_divisor = 4
	data.grid_type = 1
	data.grid_autoclear = true
	data.restrict_to_cardinals = false

	data.log_selection_area = game.players[player_index].mod_settings['log-selection-area'].value
	
	return data
end

-- when a player changes a setting in the mod settings GUI
function on_player_mod_setting_changed(e)
	if e.setting_type == 'runtime-per-user' then
		global.player_data[e.player_index].settings.log_selection_area = game.players[e.player_index].mod_settings['log-selection-area'].value
	end
end

local setting_associations = {
	gridtype_dropdown = 'grid_type',
	autoclear_checkbox = 'grid_autoclear',
	drawonground_checkbox = 'draw_tilegrid_on_ground',
	increment_divisor_textfield = 'increment_divisor',
	split_divisor_textfield = 'split_divisor',
	increment_divisor_slider = 'increment_divisor',
	split_divisor_slider = 'split_divisor',
	increment_divisor_textfield = 'increment_divisor',
	split_divisor_textfield = 'split_divisor',
	restrict_to_cardinals_checkbox = 'restrict_to_cardinals'
}

-- when a setting is changed in the tapeline settings GUI
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

	if global.player_data[e.player_index].cur_editing then
		global[global.player_data[e.player_index].cur_tilegrid_index].settings[setting_associations[e.match]] = value
		update_tilegrid_settings(e.player_index)
	else
		global.player_data[e.player_index].settings[setting_associations[e.match]] = value
	end
end

-- detect if the player is holding the tapeline capsule, and show/hide the settings menu accordingly
function on_item(e)
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.name == 'tapeline-capsule' then
        -- if holding the tapeline
		open_settings_menu(player) 
		set_settings_frame_mode(false, player)
    else
        -- hide settings GUI
        close_settings_menu(player)
    end
end

-- detect if the current slider value is different from the setting, and if so, change it
function check_slider_change(e)
	local value = e.element.slider_value
	local player_data = global.player_data[e.player_index]
	local settings

	if player_data.cur_editing then
		settings = global[player_data.cur_tilegrid_index].settings
	else
		settings = player_data.settings
	end

	if value ~= settings[setting_associations[e.match]] then
		change_setting(e)
	end
end

stdlib.event.register({'on_init', 'on_configuration_changed'}, setup_global)
stdlib.event.register(defines.events.on_player_created, on_player_created)
stdlib.event.register(defines.events.on_runtime_mod_setting_changed, on_player_mod_setting_changed)
stdlib.event.register(defines.events.on_player_cursor_stack_changed, on_item)