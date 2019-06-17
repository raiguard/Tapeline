function draw(type, data, tilegrid_index)
    
    table.insert(global.render_objects[tilegrid_index][type], rendering["draw_" .. type](data))

end

function remove_objects(tilegrid_index)

    for n,i in pairs(global[tilegrid_index].render_objects) do
        if rendering.is_valid(i) then rendering.destroy(i) end
    end

end