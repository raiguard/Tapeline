function on_init()

    global.last_capsule_tick = 0
    global.cur_tilegrid_index = 0

end

function on_capsule(e)  -- EVENT ARGUMENTS: player_index, item, position

    if e.item.name ~= "tapeline-capsule" then return end
    
    if game.ticks_played - global.last_capsule_tick > 1 then
        -- new tilegrid
        global.cur_tilegrid_index = global.cur_tilegrid_index + 1
        global[global.cur_tilegrid_index] = construct_tilegrid_data(e)
        stdlib.logger.log(global[global.cur_tilegrid_index])
    elseif not stdlib.area.contains_positions(global[global.cur_tilegrid_index].area, { { x = e.position.x, y = e.position.y } }) then
        -- update current tilegrid
        
    end

    global.last_capsule_tick = game.ticks_played
	
end

function construct_tilegrid_data(e)

    local data = {}
    -- area
    data.area = stdlib.area.construct(e.position.x, e.position.y, e.position.x, e.position.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
	data.area.midpoints = stdlib.area.center(data.area)
    -- metadata
    data.time_of_creation = game.ticks_played
    data.time_to_live = 180
    data.grid_type = 0
    -- tilegrid divisors
	local tilegrid_divisors = {}
	if data.grid_type == 1 then
		tilegrid_divisors[1] = { x = 1, y = 1 }
		tilegrid_divisors[2] = { x = (area.width > 1 and (area.width / mod_settings.tilegrid_split_divisor) or area.width), y = (area.height > 1 and (area.height / mod_settings.tilegrid_split_divisor) or area.height) }
		tilegrid_divisors[3] = { x = (area.width > 1 and (area.midpoints.x - area.left_top.x) or area.width), y = (area.height > 1 and (area.midpoints.y - area.left_top.y) or area.height) }
	else
		for i=1,4 do
			table.insert(tilegrid_divisors, { x = mod_settings.tilegrid_group_divisor ^ (i - 1), y = mod_settings.tilegrid_group_divisor ^ (i - 1) })
		end
	end
    -- render objects
    build_render_objects(data)


    return data

end

stdlib.event.register("on_init", on_init)
stdlib.event.register({defines.events.on_player_used_capsule}, on_capsule)