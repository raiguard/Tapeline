-- initialize all player-related globals
function on_init()

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

	-- real actual settings
	local player_mod_settings = game.players[player_index].mod_settings
    data.tilegrid_line_width = player_mod_settings['tilegrid-line-width'].value
	data.tilegrid_clear_delay = player_mod_settings['tilegrid-clear-delay'].value * 60

	data.log_selection_area = player_mod_settings['log-selection-area'].value
	data.draw_tilegrid_on_ground = player_mod_settings['draw-tilegrid-on-ground'].value
	
	data.tilegrid_background_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-background-color'].value], 0.6)
	data.tilegrid_border_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-border-color'].value])
	data.tilegrid_label_color = stdlib.color.set(defines.color[player_mod_settings['tilegrid-label-color'].value], 0.8)
	data.tilegrid_div_color_1 = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-1'].value])
	data.tilegrid_div_color_2 = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-2'].value])
	data.tilegrid_div_color_3 = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-3'].value])
	data.tilegrid_div_color_4 = stdlib.color.set(defines.color[player_mod_settings['tilegrid-color-4'].value])

	return data

end

-- when a player changes a setting in the mod settings GUI
function on_player_mod_setting_changed(e)

	-- metadata
	local name = e.setting:gsub('-', '_')
	local setting_value = game.players[e.player_index].mod_settings[e.setting].value
	local result
	-- functions
	local s_contains = stdlib.string.contains
	local to_color = stdlib.color.set

	if s_contains(name, 'color') then
		local def_color = defines.color[setting_value]
		if s_contains(name, 'background') then
			result = set_color(def_color, 0.6)
		elseif s_contains(name, 'label') then
			result = set_color(def_color, 0.8)
		else
			result = set_color(def_color)
		end
	elseif name == 'tilegrid_clear_delay' then
		result = setting_value * 60
	else
		result = setting_value
	end

	-- if global.player_data[e.player_index].cur_editing == true then
	-- 	local index = global.player_data[e.player_index].cur_tilegrid_index
	-- 	global[index].settings[name] = result
	-- 	destroy_render_objects(global[index].render_objects)
    -- 	global[index].render_objects = build_render_objects(global[index])
	-- else
		global.player_data[e.player_index].settings[name] = result
	-- end

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

	if global.player_data[e.player_index].cur_editing == true then
		local index = global.player_data[e.player_index].cur_tilegrid_index
		global[index].settings[setting_associations[e.match]] = value
		update_tilegrid_settings(e.player_index)
	else
		global.player_data[e.player_index].settings[setting_associations[e.match]] = value
	end

end

stdlib.event.register('on_init', on_init)
stdlib.event.register(defines.events.on_player_created, on_player_created)
stdlib.event.register(defines.events.on_runtime_mod_setting_changed, on_player_mod_setting_changed)