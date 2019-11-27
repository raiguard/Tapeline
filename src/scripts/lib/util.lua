-- ----------------------------------------------------------------------------------------------------
-- UTILITIES

local util = require('__core__/lualib/util')
local floor = math.floor
local ceil = math.ceil

function util.get_player(obj)
    if type(obj) == 'number' then return game.players[obj]
    else return game.players[obj.player_index] end
end

function util.player_table(obj)
    if type(obj) == 'number' then return global.players[obj]
    else return global.players[obj.index] end
end

function util.debug_print(e)
    print(serpent.block(e))
end

function util.position_equals(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and true or false
end

function util.expand_area(area, amount)
    return {left_top={x=area.left_top.x-amount, y=area.left_top.y-amount}, right_bottom={x=area.right_bottom.x+amount, y=area.right_bottom.y+amount}}
end

function util.update_area(area, tile_pos, hot_corner)
    local origin = area.origin
    -- find new corners
    local left_top = {x=floor(tile_pos.x < origin.x and tile_pos.x or origin.x), y=floor(tile_pos.y < origin.y and tile_pos.y or origin.y)}
    local right_bottom = {x=ceil(tile_pos.x > origin.x and tile_pos.x or origin.x), y=ceil(tile_pos.y > origin.y and tile_pos.y or origin.y)}
    if hot_corner == 'right_top' or hot_corner == 'right_bottom' then
        right_bottom.x = right_bottom.x + 1
    end
    if hot_corner == 'left_bottom' or hot_corner == 'right_bottom' then
        right_bottom.y = right_bottom.y + 1
    end
    local width = right_bottom.x - left_top.x
    local height = right_bottom.y - left_top.y
    return {
        left_top = left_top,
        left_bottom = {x=left_top.x, y=right_bottom.y},
        right_top = {x=right_bottom.x, y=left_top.y},
        right_bottom = right_bottom,
        origin = origin,
        midpoints = {x=left_top.x+(width/2), y=left_top.y+(height/2)},
        width = width,
        height = height,
        width_changed = area.width ~= width and true or false,
        height_changed = area.height ~= height and true or false
    }
end

function util.new_area_from_tile_position(tile_pos)
    return {
        left_top = tile_pos,
        left_bottom = {x=tile_pos.x, y=tile_pos.y+1},
        right_top = {x=tile_pos.x+1, y=tile_pos.y},
        right_bottom = {x=tile_pos.x+1, y=tile_pos.y+1},
        origin = {x=tile_pos.x+0.5, y=tile_pos.y+0.5},
        midpoints = {x=tile_pos.x+0.5, y=tile_pos.y+0.5},
        width = 1,
        height = 1
    }
end

util.textfield = {}

function util.textfield.clamp_number_input(element, clamps, last_value)
    local text = element.text
    if text == ''
    or (clamps[1] and tonumber(text) < clamps[1])
    or (clamps[2] and tonumber(text) > clamps[2]) then
        element.style = 'tl_invalid_slider_textfield'
    else
        element.style = 'tl_slider_textfield'
        last_value = text
    end
    return last_value
end

function util.textfield.set_last_valid_value(element, last_value)
    if element.text ~= last_value then
        element.text = last_value
        element.style = 'tl_slider_textfield'
    end
    return element.text
end

return util