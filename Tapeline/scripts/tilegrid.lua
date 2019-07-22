-- set up constants
function setup_global()
    global.next_tilegrid_index = global.next_tilegrid_index or 1
    global.perish = global.perish or {}
    global.end_wait = global.end_wait or 3
    global.map_settings = global.map_settings or get_global_settings()
end

-- check if the game is multiplayer and set global.end_wait accordingly
function check_mp_config(e)
    if game.is_multiplayer() then
        if global.end_wait == 3 then
            create_warning_dialog(e.player_index)
        end
        global.end_wait = 60
    end
end

-- retrieve global settings
function get_global_settings()
	local data = {}
	local settings = settings.global

	data.tilegrid_line_width = settings['tilegrid-line-width'].value
	data.tilegrid_clear_delay = settings['tilegrid-clear-delay'].value * 60

	data.draw_tilegrid_on_ground = settings['draw-tilegrid-on-ground'].value
	
	data.tilegrid_background_color = stdlib.color.set(defines.color[settings['tilegrid-background-color'].value], 0.6)
	data.tilegrid_border_color = stdlib.color.set(defines.color[settings['tilegrid-border-color'].value])
	data.tilegrid_label_color = stdlib.color.set(defines.color[settings['tilegrid-label-color'].value], 0.8)
	data.tilegrid_div_color_1 = stdlib.color.set(defines.color[settings['tilegrid-color-1'].value])
	data.tilegrid_div_color_2 = stdlib.color.set(defines.color[settings['tilegrid-color-2'].value])
	data.tilegrid_div_color_3 = stdlib.color.set(defines.color[settings['tilegrid-color-3'].value])
	data.tilegrid_div_color_4 = stdlib.color.set(defines.color[settings['tilegrid-color-4'].value])

	return data
end

-- check to see if a tilegrid drag has finished
function on_tick()
    local cur_tick = game.ticks_played
    -- for each player in player_data, if they're doing a drag, check to see if it's finished
    stdlib.table.each(global.player_data, function(t,i)
        if t.cur_drawing and cur_tick - t.last_capsule_tick > global.end_wait then
            t.cur_drawing = false
            local data = global[t.cur_tilegrid_index]
            local from_pos = stdlib.tile.from_position
            if not stdlib.position.equals(from_pos(t.last_capsule_pos), from_pos(data.origin)) then
                if data.settings.grid_autoclear then global.perish[t.cur_tilegrid_index] = game.ticks_played + data.time_to_live
                else create_settings_button(global[t.cur_tilegrid_index]) end
                if data.settings.log_selection_area then data.player.print('Dimensions: ' .. data.area.width .. 'x' .. data.area.height) end
            else
                destroy_tilegrid_data(t.cur_tilegrid_index)
            end
        end
    end)
    stdlib.table.each(global.perish, function(v,k)
        if v <= game.ticks_played then
            destroy_tilegrid_data(k)
            global.perish[k] = nil
        end
    end)
end

-- when a capsule is thrown
function on_capsule(e)  -- EVENT ARGUMENTS: player_index, item, position
    if e.item.name ~= 'tapeline-capsule' then return end

    local player_data = global.player_data[e.player_index]

    if game.ticks_played - player_data.last_capsule_tick > global.end_wait then
        -- create tilegrid
        player_data.cur_tilegrid_index = global.next_tilegrid_index
        player_data.cur_drawing = true
        global[global.next_tilegrid_index] = construct_tilegrid_data(e)
        global.next_tilegrid_index = global.next_tilegrid_index + 1
    else
        local from_pos = stdlib.tile.from_position
        local cur_pos = e.position
        if not stdlib.position.equals(from_pos(player_data.last_capsule_pos), from_pos(cur_pos)) then
            -- if ignore cardinals, adjust thrown position
            if player_data.settings.restrict_to_cardinals then
                local tilegrid = global[player_data.cur_tilegrid_index]
                local cur_tile = from_pos(cur_pos)
                if math.abs(cur_tile.x - tilegrid.origin.x) >= math.abs(cur_tile.y - tilegrid.origin.y) then
                    cur_pos.y = tilegrid.origin.y
                else
                    cur_pos.x = tilegrid.origin.x
                end
            end
            -- update tilegrid data
            update_tilegrid_data(e)
        end
    end

    player_data.last_capsule_pos = e.position
    player_data.last_capsule_tick = game.ticks_played
    global[player_data.cur_tilegrid_index].time_of_creation = game.ticks_played
end

-- create a new tilegrid data structure in GLOBAL
function construct_tilegrid_data(e)
    local data = {}
    -- initial settings
    data.player = game.players[e.player_index]
    data.settings = stdlib.table.deep_copy(global.player_data[e.player_index].settings)
    -- area
    data.area = stdlib.area.construct(e.position.x, e.position.y, e.position.x, e.position.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = stdlib.area.center(data.area)
    -- metadata
    data.origin = stdlib.position.add(data.area.left_top, { x = 0.5, y = 0.5 })
    data.time_of_creation = game.ticks_played
    data.time_to_live = settings.global['tilegrid-clear-delay'].value * 60
    -- anchors
    data.anchors = {}
    data.anchors.horizontal = 'top'
    data.anchors.vertical = 'left'
    -- tilegrid divisors
	data.tilegrid_divisors = {}
	if data.settings.grid_type == 2 then
		data.tilegrid_divisors[1] = { x = 1, y = 1 }
		data.tilegrid_divisors[2] = { x = (data.area.width > 1 and (data.area.width / data.settings.split_divisor) or data.area.width), y = (data.area.height > 1 and (data.area.height / data.settings.split_divisor) or data.area.height) }
		data.tilegrid_divisors[3] = { x = (data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y = (data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height) }
	else
		for i=1,4 do
			table.insert(data.tilegrid_divisors, { x = data.settings.increment_divisor ^ (i - 1), y = data.settings.increment_divisor ^ (i - 1) })
		end
    end
    -- render objects
    data.render_objects = build_render_objects(data)

    return data
end

-- update a tilegrid
function update_tilegrid_data(e)
    local data = global[global.player_data[e.player_index].cur_tilegrid_index]
    -- find new corners
    local left_top = { x = (e.position.x < data.origin.x and e.position.x or data.origin.x), y = (e.position.y < data.origin.y and e.position.y or data.origin.y) }
    local right_bottom = { x = (e.position.x > data.origin.x and e.position.x or data.origin.x), y = (e.position.y > data.origin.y and e.position.y or data.origin.y) }
    -- update area
    data.area = stdlib.area.construct(left_top.x, left_top.y, right_bottom.x, right_bottom.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = stdlib.area.center(data.area)
    -- update anchors
    if e.position.x < data.origin.x then
        if e.position.y < data.origin.y then
            data.anchors.horizontal = 'bottom'
            data.anchors.vertical = 'right'
        else
            data.anchors.horizontal = 'top'
            data.anchors.vertical = 'right'
        end
    elseif e.position.y < data.origin.y then
        data.anchors.horizontal = 'bottom'
        data.anchors.vertical = 'left'
    else
        data.anchors.horizontal = 'top'
        data.anchors.vertical = 'left'
    end
    -- update tilegrid divisors
    if data.settings.grid_type == 2 then
        data.tilegrid_divisors[2] = { x = (data.area.width > 1 and (data.area.width / data.settings.split_divisor) or data.area.width), y = (data.area.height > 1 and (data.area.height / data.settings.split_divisor) or data.area.height) }
        data.tilegrid_divisors[3] = { x = (data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y = (data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height) }
    end
    -- destroy and rebuild render objects
    destroy_render_objects(data.render_objects)
    data.render_objects = build_render_objects(data)
end

-- update tilegrid based on new settings
function update_tilegrid_settings(player_index)
    data = global[global.player_data[player_index].cur_tilegrid_index]
    data.tilegrid_divisors = {}
    -- update tilegrid divisors
    if data.settings.grid_type == 2 then
        data.tilegrid_divisors[1] = { x = 1, y = 1 }
        data.tilegrid_divisors[2] = { x = (data.area.width > 1 and (data.area.width / data.settings.split_divisor) or data.area.width), y = (data.area.height > 1 and (data.area.height / data.settings.split_divisor) or data.area.height) }
        data.tilegrid_divisors[3] = { x = (data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y = (data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height) }
    else
        for i=1,4 do
			data.tilegrid_divisors[i] = { x = data.settings.increment_divisor ^ (i - 1), y = data.settings.increment_divisor ^ (i - 1) }
		end
    end
    -- destroy and rebuild render objects
    destroy_render_objects(data.render_objects)
    data.render_objects = build_render_objects(data)
end

-- destroy a tilegrid's data
function destroy_tilegrid_data(tilegrid_index)
    destroy_render_objects(global[tilegrid_index].render_objects)
    if global[tilegrid_index].button then global[tilegrid_index].button.destroy() end
    global[tilegrid_index] = nil
end

function on_setting_changed(e)
    if e.setting_type == 'runtime-global' then
        global.map_settings = get_global_settings()
        update_tilegrid_visual_settings()
    end
end


stdlib.event.register({'on_init', 'on_configuration_changed'}, setup_global)
stdlib.event.register(defines.events.on_player_joined_game, check_mp_config)
stdlib.event.register(defines.events.on_player_used_capsule, on_capsule)
stdlib.event.register(defines.events.on_tick, on_tick)
stdlib.event.register(defines.events.on_runtime_mod_setting_changed, on_setting_changed)