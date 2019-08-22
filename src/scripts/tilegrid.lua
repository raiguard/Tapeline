local area = require('__stdlib__/stdlib/area/area')
local color = require('__stdlib__/stdlib/utils/color')
local event = require('__stdlib__/stdlib/event/event')
local position = require('__stdlib__/stdlib/area/position')
local table = require('__stdlib__/stdlib/utils/table')
local tile = require('__stdlib__/stdlib/area/tile')

local rendering = require('rendering')
local util = require('util')

local table_size = table_size
local from_pos = tile.from_position
local pos_equals = position.equals
local abs = math.abs

local tilegrid = {}

-- retrieve global settings
function tilegrid.get_global_settings()
	local data = {}
	local settings = settings.global

	data.tilegrid_line_width = settings['tilegrid-line-width'].value
	data.tilegrid_clear_delay = settings['tilegrid-clear-delay'].value * 60

	data.draw_tilegrid_on_ground = settings['draw-tilegrid-on-ground'].value
	
	data.tilegrid_background_color = color.set(defines.color[settings['tilegrid-background-color'].value], 0.6)
	data.tilegrid_border_color = color.set(defines.color[settings['tilegrid-border-color'].value])
	data.tilegrid_label_color = color.set(defines.color[settings['tilegrid-label-color'].value], 0.8)
	data.tilegrid_div_color_1 = color.set(defines.color[settings['tilegrid-color-1'].value])
	data.tilegrid_div_color_2 = color.set(defines.color[settings['tilegrid-color-2'].value])
	data.tilegrid_div_color_3 = color.set(defines.color[settings['tilegrid-color-3'].value])
	data.tilegrid_div_color_4 = color.set(defines.color[settings['tilegrid-color-4'].value])

	return data
end

-- check to see if a tilegrid drag has finished
-- conditionally registered
function tilegrid.on_tick()
    local cur_tick = game.ticks_played
    local end_wait = global.end_wait
    -- for each player in player_data, if they're doing a drag, check to see if it's finished
    for i,t in pairs(global.drawing) do
        if cur_tick - t.last_capsule_tick > end_wait then
            local data = global.tilegrids[i]
            if not pos_equals(from_pos(t.last_capsule_pos), from_pos(data.origin)) then
                if data.settings.grid_autoclear then global.perish[i] = game.ticks_played + (settings.global['tilegrid-clear-delay'].value * 60)
                else rendering.create_settings_button(i) end
                if data.player.mod_settings['log-selection-area'].value then data.player.print('Dimensions: ' .. data.area.width .. 'x' .. data.area.height) end
            else
                tilegrid.destroy(i)
            end
            global.drawing[i] = nil
            util.player_table(t.player).cur_drawing = 0
            -- deregister on_tick if able
            if table_size(global.drawing) == 0 and table_size(global.perish) == 0 then
                event.remove(defines.events.on_tick, tilegrid.on_tick)
            end
        end
    end
    for i,t in pairs(global.perish) do
        if t <= game.ticks_played then
            tilegrid.destroy(i)
            global.perish[i] = nil
            -- deregister on_tick if able
            if table_size(global.drawing) == 0 and table_size(global.perish) == 0 then
                event.remove(defines.events.on_tick, tilegrid.on_tick)
            end
        end
    end
end

-- when a capsule is thrown
function tilegrid.on_capsule(e)
    if e.item.name ~= 'tapeline-capsule' then return end

    local player_data = util.player_table(e.player_index)
    -- drawing data is separate to make on_tick faster
    local drawing_data = global.drawing[player_data.cur_drawing]

    if player_data.cur_drawing == 0 then
        -- create tilegrid
        drawing_data = {player=e.player_index, last_capsule_tick=0, last_capsule_pos=0}
        global.drawing[global.next_tilegrid_index] = drawing_data
        player_data.cur_drawing = global.next_tilegrid_index
        global.tilegrids[global.next_tilegrid_index] = tilegrid.construct(e)
        global.next_tilegrid_index = global.next_tilegrid_index + 1
        -- register on_tick if needed
        if table_size(global.drawing) == 1 then
            event.register(defines.events.on_tick, tilegrid.on_tick)
        end
    else
        -- update tilegrid
        local cur_pos = e.position
        if not pos_equals(from_pos(drawing_data.last_capsule_pos), from_pos(cur_pos)) then
            -- if ignore cardinals, adjust thrown position
            if player_data.settings.restrict_to_cardinals then
                local tilegrid = global.tilegrids[player_data.cur_drawing]
                local cur_tile = from_pos(cur_pos)
                if abs(cur_tile.x - tilegrid.origin.x) >= abs(cur_tile.y - tilegrid.origin.y) then
                    cur_pos.y = tilegrid.origin.y
                else
                    cur_pos.x = tilegrid.origin.x
                end
            end
            -- update tilegrid data
            tilegrid.update(e)
        end
    end

    drawing_data.last_capsule_pos = e.position
    drawing_data.last_capsule_tick = game.ticks_played
end

-- create a new tilegrid data structure in GLOBAL
function tilegrid.construct(e)
    local data = {}
    -- initial settings
    data.player = game.players[e.player_index]
    data.settings = table.deepcopy(util.player_table(e.player_index).settings)
    -- area
    data.area = area.construct(e.position.x, e.position.y, e.position.x, e.position.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = area.center(data.area)
    -- metadata
    data.origin = position.add(data.area.left_top, {x=0.5, y=0.5})
    -- anchors
    data.anchors = {}
    data.anchors.horizontal = 'top'
    data.anchors.vertical = 'left'
    -- tilegrid divisors
	data.tilegrid_divisors = {}
	if data.settings.grid_type == 2 then
		data.tilegrid_divisors[1] = {x=1, y=1}
		data.tilegrid_divisors[2] = {x=(data.area.width > 1 and (data.area.width / data.settings.split_divisor) or data.area.width), y=(data.area.height > 1 and (data.area.height / data.settings.split_divisor) or data.area.height)}
		data.tilegrid_divisors[3] = {x=(data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y=(data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height)}
	else
		for i=1,4 do
			table.insert(data.tilegrid_divisors, { x = data.settings.increment_divisor ^ (i - 1), y = data.settings.increment_divisor ^ (i - 1) })
		end
    end
    -- render objects
    data.render_objects = rendering.build_objects(data)

    return data
end

-- update a tilegrid
function tilegrid.update(e)
    local data = global.tilegrids[util.player_table(e.player_index).cur_drawing]
    -- find new corners
    local left_top = { x = (e.position.x < data.origin.x and e.position.x or data.origin.x), y = (e.position.y < data.origin.y and e.position.y or data.origin.y) }
    local right_bottom = { x = (e.position.x > data.origin.x and e.position.x or data.origin.x), y = (e.position.y > data.origin.y and e.position.y or data.origin.y) }
    -- update area
    data.area = area.construct(left_top.x, left_top.y, right_bottom.x, right_bottom.y):normalize():ceil():corners()
    data.area.size,data.area.width,data.area.height = data.area:size()
    data.area.midpoints = area.center(data.area)
    -- update anchors
    data.anchors.vertical = e.position.x >= data.origin.x and 'left' or 'right'
    data.anchors.horizontal = e.position.y >= data.origin.y and 'top' or 'bottom'
    -- update tilegrid divisors
    if data.settings.grid_type == 2 then
        data.tilegrid_divisors[2] = { x = (data.area.width > 1 and (data.area.width / data.settings.split_divisor) or data.area.width), y = (data.area.height > 1 and (data.area.height / data.settings.split_divisor) or data.area.height) }
        data.tilegrid_divisors[3] = { x = (data.area.width > 1 and (data.area.midpoints.x - data.area.left_top.x) or data.area.width), y = (data.area.height > 1 and (data.area.midpoints.y - data.area.left_top.y) or data.area.height) }
    end
    -- destroy and rebuild render objects
    rendering.destroy_objects(data.render_objects)
    data.render_objects = rendering.build_objects(data)
end

-- update tilegrid based on new settings
function tilegrid.update_settings(tilegrid_index)
    data = global.tilegrids[tilegrid_index]
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
    rendering.destroy_objects(data.render_objects)
    data.render_objects = rendering.build_objects(data)
end

-- destroy a tilegrid's data
function tilegrid.destroy(tilegrid_index)
    rendering.destroy_objects(global.tilegrids[tilegrid_index].render_objects)
    if global.tilegrids[tilegrid_index].button then global.tilegrids[tilegrid_index].button.destroy() end
    global.tilegrids[tilegrid_index] = nil
end

tilegrid.rendering = rendering

return tilegrid