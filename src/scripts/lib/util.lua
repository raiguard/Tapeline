-- ----------------------------------------------------------------------------------------------------
-- UTILITIES

local math2d = require('__core__/lualib/math2d')
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

util.position = {}

function util.position.add(pos1, pos2)
    return {x=pos1.x+pos2.x, y=pos1.y+pos2.y}
end

function util.position.subtract(pos1, pos2)
    return {x=pos1.x-pos2.x, y=pos1.y-pos2.y}
end

function util.position.equals(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and true or false
end

util.area = {}

function util.area.expand(area, amount)
    return {left_top={x=area.left_top.x-amount, y=area.left_top.y-amount}, right_bottom={x=area.right_bottom.x+amount, y=area.right_bottom.y+amount}}
end

function util.area.opposite_corner(corner)
    if corner:find('left') then
        corner = corner:gsub('left', 'right')
    else
        corner = corner:gsub('right', 'left')
    end
    if corner:find('top') then
        corner = corner:gsub('top', 'bottom')
    else
        corner = corner:gsub('bottom', 'top')
    end
    return corner
end

function util.area.draw_update(area, tile_pos, hot_corner)
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

function util.area.additional_data(area)
    local left_top = area.left_top
    local right_bottom = area.right_bottom
    area.left_bottom = {x=area.left_top.x, y=area.right_bottom.y}
    area.right_top = {x=area.right_bottom.x, y=area.left_top.y}
    area.width = right_bottom.x - left_top.x
    area.height = right_bottom.y - left_top.y
    area.midpoints = {x=left_top.x+(area.width/2), y=left_top.y+(area.height/2)}
    return area
end

function util.area.construct_from_tile_pos(tile_pos)
    local area = {
        left_top = tile_pos,
        right_bottom = {x=tile_pos.x+1, y=tile_pos.y},
        origin = {x=tile_pos.x+0.5, y=tile_pos.y+0.5},
    }
    util.area.additional_data(area)
    return area
end

function util.area.contains_point(area, pos)
    return math2d.bounding_box.contains_point(area, pos)
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