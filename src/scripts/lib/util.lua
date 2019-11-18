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
        width_changed = area.width == width and false or true,
        height_changed = area.height == height and false or true
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

return util