local area = require('__stdlib__/stdlib/area/area')
local position = require('__stdlib__/stdlib/area/position')
local draw_line = rendering.draw_line
local draw_rectangle = rendering.draw_rectangle
local draw_text = rendering.draw_text
local lib = {}

-- build render objects for a tilegrid
function lib.build_objects(data)
    local objects = {}
    local surfaceIndex = data.player.surface.index
    local i_mod_v = data.anchors.vertical == 'left' and 1 or -1
    local i_mod_h = data.anchors.horizontal == 'top' and 1 or -1
    local map_settings = global.map_settings

    -- background
    objects.background = draw_rectangle{
        color = map_settings.tilegrid_background_color,
        filled = true,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = map_settings.draw_tilegrid_on_ground
	}
	
    -- grids
    objects.lines = {}
    for k,t in pairs(data.tilegrid_divisors) do
        objects.lines[k] = {}
        objects.lines[k].vertical = {}
		for i=t.x,data.area.width,t.x do
			objects.lines[k].vertical[i] = draw_line{
				color = map_settings['tilegrid_div_color_' .. k],
				width = map_settings.tilegrid_line_width,
				from = {(data.area[data.anchors.vertical .. '_top'].x + i * i_mod_v),data.area.left_top.y},
				to = {(data.area[data.anchors.vertical .. '_bottom'].x + i * i_mod_v),data.area.left_bottom.y},
				surface = surfaceIndex,
				draw_on_ground = map_settings.draw_tilegrid_on_ground
			}
		end

        objects.lines[k].horizontal = {}
		for i=t.y,data.area.height,t.y do
			objects.lines[k].horizontal[i] = draw_line{
				color = map_settings['tilegrid_div_color_' .. k],
				width = map_settings.tilegrid_line_width,
				from = {data.area.left_top.x,(data.area['left_' .. data.anchors.horizontal].y + i * i_mod_h)},
				to = {data.area.right_top.x,(data.area['left_' .. data.anchors.horizontal].y + i * i_mod_h)},
				surface = surfaceIndex,
				draw_on_ground = map_settings.draw_tilegrid_on_ground
			}
		end
	end

    -- border
    objects.border = draw_rectangle{
        color = map_settings.tilegrid_border_color,
        width = map_settings.tilegrid_line_width,
        filled = false,
        left_top = {data.area.left_top.x,data.area.left_top.y},
        right_bottom = {data.area.right_bottom.x,data.area.right_bottom.y},
        surface = surfaceIndex,
        draw_on_ground = map_settings.draw_tilegrid_on_ground
	}

    -- labels
    objects.labels = {}
	if data.area.height > 1 then
        objects.labels.left = draw_text{
            text = data.area.height,
            surface = surfaceIndex,
            target = {(data.area.left_top.x - 1.1), data.area.midpoints.y},
            color = map_settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2,
            orientation = 0.75
        }
	end
	
    if data.area.width > 1 then
        objects.labels.top = draw_text{
            text = data.area.width,
            surface = surfaceIndex,
            target = {data.area.midpoints.x, (data.area.left_top.y - 1.1)},
            color = map_settings.tilegrid_label_color,
            alignment = 'center',
            scale = 2
        }
	end

    return objects
end

-- destroy all render objects for a tilegrid
function lib.destroy_objects(table)
    for n,i in pairs(table) do
        -- recursive tables
        if type(i) == 'table' then lib.destroy_objects(i)
        -- check if exists, and if so, DESTROY!
        elseif rendering.is_valid(i) then rendering.destroy(i) end
    end
end

-- create settings button entity
function lib.create_settings_button(tilegrid_index)
    local data = global.tilegrids[tilegrid_index]
    data.button = data.player.surface.create_entity{
        name = 'tapeline-settings-button',
        position = position.add(data.area.left_top, {x=0.25, y=0.225}),
        player = data.player
    }
end

-- create highlight box entity
function lib.create_highlight_box(tilegrid_index)
    local data = global.tilegrids[tilegrid_index]
    data.highlight_box = data.player.surface.create_entity{
        name = 'highlight-box',
        position = data.area.left_top,
        bounding_box = area.expand(data.area, 0.25),
        render_player_index = data.player.index,
        blink_interval = 30
    }
end

-- update visuals of all tilegrids
function lib.update_visual_settings()
    local settings = global.map_settings
    local set_color = rendering.set_color
    local set_width = rendering.set_width
    local set_draw_on_ground = rendering.set_draw_on_ground

    for i,t in pairs(global.tilegrids) do
        local objects = t.render_objects
        -- labels
        for _,o in pairs(objects.labels) do
            set_color(o, settings.tilegrid_label_color)
        end
        -- grids
        for k,t in pairs(objects.lines) do
            for _,d in pairs(t) do
                for _,o in pairs(d) do
                    set_color(o, settings['tilegrid_div_color_' .. k])
                    set_width(o, settings.tilegrid_line_width)
                    set_draw_on_ground(o, settings.draw_tilegrid_on_ground)
                end
            end
        end
        -- border
        set_color(objects.border, settings.tilegrid_border_color)
        set_draw_on_ground(objects.border, settings.draw_tilegrid_on_ground)
        -- background
        set_color(objects.background, settings.tilegrid_background_color)
        set_draw_on_ground(objects.background, settings.draw_tilegrid_on_ground)
    end
end

return lib