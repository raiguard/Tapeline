function build_render_objects(data)

    stdlib.logger.log('build render objects')

    if data.grid_type == 0 then

    else

    end

end

-- draw an object and add a reference to it to the global table
function draw(type, data, tilegrid_index)
    
    table.insert(global.render_objects[tilegrid_index][type], rendering["draw_" .. type](data))

end

-- destroy all render objects for a tilegrid
function remove_objects(tilegrid_index)

    for n,i in pairs(global[tilegrid_index].render_objects) do
        if rendering.is_valid(i) then rendering.destroy(i) end
    end

end