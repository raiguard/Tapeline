-- build render objects for a tilegrid
function build_render_objects(data)

    local objects = {}
    local surfaceIndex = data.owner.surface.index

    -- background
    objects.background = rendering.draw_rectangle {
        color = data.owner_settings.tilegrid_background_color,
        filled = true,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = data.owner_settings.draw_tilegrid_on_ground,
        players = { data.owner }
	}
	
    -- grids
    objects.lines = {}
    for k,t in pairs(data.tilegrid_divisors) do
        objects.lines[k] = {}
        objects.lines[k].vertical = {}
		for i=t.x,data.area.width,t.x do
			objects.lines[k].vertical[i] = rendering.draw_line {
				color = data.owner_settings.tilegrid_div_color[k],
				width = data.owner_settings.tilegrid_line_width,
				from = {(data.area.left_top.x + i),data.area.left_top.y},
				to = {(data.area.left_bottom.x + i),data.area.left_bottom.y},
				surface = surfaceIndex,
				draw_on_ground = data.owner_settings.draw_tilegrid_on_ground,
				players = { data.owner }
			}
		end

        objects.lines[k].horizontal = {}
		for i=t.y,data.area.height,t.y do
			objects.lines[k].horizontal[i] = rendering.draw_line {
				color = data.owner_settings.tilegrid_div_color[k],
				width = data.owner_settings.tilegrid_line_width,
				from = {data.area.left_top.x,(data.area.left_top.y + i)},
				to = {data.area.right_top.x,(data.area.left_top.y + i)},
				surface = surfaceIndex,
				draw_on_ground = data.owner_settings.draw_tilegrid_on_ground,
				players = { data.owner }
			}
		end
	end

    -- border
    objects.border = rendering.draw_rectangle {
        color = data.owner_settings.tilegrid_border_color,
        width = data.owner_settings.tilegrid_line_width,
        filled = false,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = data.owner_settings.draw_tilegrid_on_ground,
        players = { data.owner }
	}

    -- labels
    objects.labels = {}
	if data.area.height > 1 then
        objects.labels.left = rendering.draw_text {
            text = data.area.height,
            surface = surfaceIndex,
            target = {(data.area.left_top.x - 1.1), data.area.midpoints.y},
            color = data.owner_settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2,
            orientation = 0.75,
            players = { data.owner }
        }
	end
	
    if data.area.width > 1 then
        objects.labels.top = rendering.draw_text {
            text = data.area.width,
            surface = surfaceIndex,
            target = {data.area.midpoints.x, (data.area.left_top.y - 1.1)},
            color = data.owner_settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2,
            players = { data.owner }
        }
	end

    return objects

end

-- destroy all render objects for a tilegrid
function destroy_render_objects(table)

    for n,i in pairs(table) do
        -- recursive tables
        if type(i) == 'table' then destroy_render_objects(i)
        -- check if exists, and if so, DESTROY!
        elseif rendering.is_valid(i) then rendering.destroy(i) end
    end

end