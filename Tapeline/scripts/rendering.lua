-- build render objects for a tilegrid
function build_render_objects(data)

    local objects = {}
    local surfaceIndex = data.player.surface.index
    local i_mod_v = data.anchors.vertical == 'left' and 1 or -1
    local i_mod_h = data.anchors.horizontal == 'top' and 1 or -1

    -- background
    objects.background = rendering.draw_rectangle {
        color = data.settings.tilegrid_background_color,
        filled = true,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = data.settings.draw_tilegrid_on_ground,
        players = { data.player }
	}
	
    -- grids
    objects.lines = {}
    for k,t in pairs(data.tilegrid_divisors) do
        objects.lines[k] = {}
        objects.lines[k].vertical = {}
		for i=t.x,data.area.width,t.x do
			objects.lines[k].vertical[i] = rendering.draw_line {
				color = data.settings.tilegrid_div_color[k],
				width = data.settings.tilegrid_line_width,
				from = {(data.area[data.anchors.vertical .. '_top'].x + i * i_mod_v),data.area.left_top.y},
				to = {(data.area[data.anchors.vertical .. '_bottom'].x + i * i_mod_v),data.area.left_bottom.y},
				surface = surfaceIndex,
				draw_on_ground = data.settings.draw_tilegrid_on_ground,
                players = { data.player }
			}
		end

        objects.lines[k].horizontal = {}
		for i=t.y,data.area.height,t.y do
			objects.lines[k].horizontal[i] = rendering.draw_line {
				color = data.settings.tilegrid_div_color[k],
				width = data.settings.tilegrid_line_width,
				from = {data.area.left_top.x,(data.area['left_' .. data.anchors.horizontal].y + i * i_mod_h)},
				to = {data.area.right_top.x,(data.area['left_' .. data.anchors.horizontal].y + i * i_mod_h)},
				surface = surfaceIndex,
				draw_on_ground = data.settings.draw_tilegrid_on_ground,
                players = { data.player }
			}
		end
	end

    -- border
    objects.border = rendering.draw_rectangle {
        color = data.settings.tilegrid_border_color,
        width = data.settings.tilegrid_line_width,
        filled = false,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = data.settings.draw_tilegrid_on_ground,
        players = { data.player }
	}

    -- labels
    objects.labels = {}
	if data.area.height > 1 then
        objects.labels.left = rendering.draw_text {
            text = data.area.height,
            surface = surfaceIndex,
            target = {(data.area.left_top.x - 1.1), data.area.midpoints.y},
            color = data.settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2,
            orientation = 0.75,
            players = { data.player }
        }
	end
	
    if data.area.width > 1 then
        objects.labels.top = rendering.draw_text {
            text = data.area.width,
            surface = surfaceIndex,
            target = {data.area.midpoints.x, (data.area.left_top.y - 1.1)},
            color = data.settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2,
            players = { data.player }
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

function create_settings_button(data)

    -- data.render_objects.button = rendering.draw_sprite {
    --     sprite = 'tapeline-sprite-settings-button',
    --     x_scale = 0.5,
    --     y_scale = 0.5,
    --     render_layer = 255,
    --     target = stdlib.position.add(data.area.left_top, { x = 0.25, y = 0.225 }),
    --     surface = data.player.surface.index,
    --     players = { data.player }
    -- }

    data.player.surface.create_entity{
        name = 'tapeline-settings-button',
        position = stdlib.position.add(data.area.left_top, { x = 0.25, y = 0.225 }),
        player = data.player
    }

end