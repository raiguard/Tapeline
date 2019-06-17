-- set up constants
function on_init()

    global.last_capsule_tick = 0
    global.cur_tilegrid_index = 0

end

-- when a capsule is thrown
function on_capsule(e)  -- EVENT ARGUMENTS: player_index, item, position

    if e.item.name ~= 'tapeline-capsule' then return end
    
    if game.ticks_played - global.last_capsule_tick > 2 then
        -- new tilegrid
        global.cur_tilegrid_index = global.cur_tilegrid_index + 1
        global[global.cur_tilegrid_index] = construct_tilegrid_data(e)
        stdlib.logger.log(global[global.cur_tilegrid_index])
    else
        -- update current tilegrid
        update_tilegrid_data(e)
    end

    global.last_capsule_tick = game.ticks_played
    global[global.cur_tilegrid_index].time_of_creation = game.ticks_played
	
end

-- create a new tilegrid data structure in GLOBAL
function construct_tilegrid_data(e)

    local data = {}
    -- TEMPORARY: MOD SETTINGS
    data.owner = game.players[e.player_index]
    data.owner_settings = retrieve_mod_settings(data.owner)
    -- area
    data.area = stdlib.area.construct(e.position.x, e.position.y, e.position.x, e.position.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = stdlib.area.center(data.area)
    data.area.origin = data.area.left_top
    -- metadata
    data.time_of_creation = game.ticks_played
    data.time_to_live = data.owner_settings.tilegrid_clear_delay
    data.grid_type = 0
    -- tilegrid divisors
	data.tilegrid_divisors = {}
	if data.grid_type == 1 then
		data.tilegrid_divisors[1] = { x = 1, y = 1 }
		data.tilegrid_divisors[2] = { x = (data.area.width > 1 and (data.area.width / data.owner_settings.tilegrid_split_divisor) or data.area.width), y = (data.area.height > 1 and (data.area.height / data.owner_settings.tilegrid_split_divisor) or data.area.height) }
		data.tilegrid_divisors[3] = { x = (data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y = (data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height) }
	else
		for i=1,4 do
			table.insert(data.tilegrid_divisors, { x = data.owner_settings.tilegrid_group_divisor ^ (i - 1), y = data.owner_settings.tilegrid_group_divisor ^ (i - 1) })
		end
    end
    -- render objects
    data.render_objects = build_render_objects(data)

    return data

end

-- update a tilegrid
function update_tilegrid_data(e)

    data = global[global.cur_tilegrid_index]
    -- find new corners
    local k = (e.position.x < data.area.origin.x) and 'left_top' or 'right_bottom'
    data.area[k] = { x = e.position.x, y = e.position.y }
    -- update area
    data.area = stdlib.area.construct(data.area.left_top.x, data.area.left_top.y, data.area.right_bottom.x, data.area.right_bottom.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = stdlib.area.center(data.area)
    global[global.cur_tilegrid_index] = data
    -- update render objects
    destroy_render_objects(global[global.cur_tilegrid_index].render_objects)
    global[global.cur_tilegrid_index].render_objects = build_render_objects(global[global.cur_tilegrid_index])

end

-- once per second, delete any expired tilegrid data from GLOBAL to keep things clean
function on_second(e)

    for k,v in pairs(global) do
        if type(v) == 'table' then
            if  v.time_of_creation - game.ticks_played + v.time_to_live <= 0 then global[k] = nil end
        end
    end

end

stdlib.event.register('on_init', on_init)
stdlib.event.register(-60, on_second)
stdlib.event.register({defines.events.on_player_used_capsule}, on_capsule)