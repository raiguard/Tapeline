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
    -- metadata
    data.time_of_creation = game.ticks_played
    data.time_to_live = 180
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

    -- update area
    area = global[global.cur_tilegrid_index].area
    area = stdlib.area.construct(area.left_top.x, area.left_top.y, e.position.x, e.position.y):normalize():ceil():corners()
    area.size,area.width,area.height = area:size()
    area.midpoints = stdlib.area.center(area)
    global[global.cur_tilegrid_index].area = area
    -- update render objects
    destroy_render_objects(global[global.cur_tilegrid_index].render_objects)
    global[global.cur_tilegrid_index].render_objects = build_render_objects(global[global.cur_tilegrid_index])

end

-- destroy a tilegrid and all associated data
function destroy_tilegrid_data(e)



end

stdlib.event.register('on_init', on_init)
-- stdlib.event.register(-60, on_second)
stdlib.event.register({defines.events.on_player_used_capsule}, on_capsule)