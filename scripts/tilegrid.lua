function on_init()

    global.ticks_since_last_place = 0
    global.next_tilegrid_index = 0

end

function on_tick() global.ticks_since_last_place = global.ticks_since_last_place + 1 end

function on_capsule(e)  -- EVENT ARGUMENTS: player_index, item, position

    if e.item.name ~= "tapeline-capsule" then return end
    
    if global.ticks_since_last_place > 1 then
        construct_tilegrid_data(global.next_tilegrid_index, e)
        global.next_tilegrid_index = global.next_tilegrid_index + 1
    end

    global.ticks_since_last_place = 0
	
end

function construct_tilegrid_data(tilegrid_index, e)

    global[tilegrid_index] = {}
    global[tilegrid_index].area = stdlib.area.construct(e.position.x, e.position.y, e.position.x, e.position.y):normalize():ceil():corners()

    stdlib.logger.log(global[tilegrid_index])

end

stdlib.event.register("on_init", on_init)
stdlib.event.register(defines.events.on_tick, on_tick)
stdlib.event.register({defines.events.on_player_used_capsule}, on_capsule)