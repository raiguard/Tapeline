-- ----------------------------------------------------------------------------------------------------
-- TILEGRID
-- Contains logic for creating, destroying, and updating tilegrids

local util = require('scripts/lib/util')
local tilegrid = {}

local draw_rectangle = rendering.draw_rectangle
local draw_line = rendering.draw_line
local draw_text = rendering.draw_text
local set_left_top = rendering.set_left_top
local set_right_bottom = rendering.set_right_bottom
local set_from = rendering.set_from
local set_to = rendering.set_to
local set_text = rendering.set_text
local set_visible = rendering.set_visible
local set_target = rendering.set_target
local destroy = rendering.destroy

local label_offsets = {
    left_top = {
        horizontal = {x=0.5, y=0},
        vertical = {x=-0.6, y=0.5, o=0.75}
    },
    left_bottom = {
        horizontal = {x=0.5, y=0},
        vertical = {x=-0.6, y=-0.5, o=0.75}
    },
    right_top = {
        horizontal = {x=0.5, y=0},
        vertical = {x=-0.6, y=0.5, o=0.25}
    },
    right_bottom = {
        horizontal = {x=-0.5, y=0},
        vertical = {x=0.6, y=-0.5, o=0.25}
    }
}

local function construct_render_objects(data)
    local area = data.area
    local surface = data.surface
    local hot_corner = area[data.hot_corner]
    local horizontal_label_offsets = label_offsets[data.hot_corner].horizontal
    local vertical_label_offsets = label_offsets[data.hot_corner].vertical
    return {
        background = draw_rectangle{
            color = {a=0.6},
            filled = true,
            left_top = area.left_top,
            right_bottom = area.right_bottom,
            surface = surface,
            draw_on_ground = true
        },
        border = draw_rectangle{
            color = {r=0.8,g=0.8,b=0.8},
            width = 1.5,
            left_top = area.left_top,
            right_bottom = area.right_bottom,
            surface = surface,
            draw_on_ground = true
        },
        labels = {
            horizontal = draw_text{
                text = area.width,
                surface = surface,
                target = {x=area.midpoints.x, y=area.left_top.y-0.85},
                color = {r=0.8,g=0.8,b=0.8},
                scale = 1.5,
                alignment = 'center',
                visible = false
            },
            vertical = draw_text{
                text = area.height,
                surface = surface,
                target = {x=area.left_top.x-0.85, y=area.midpoints.y},
                color = {r=0.8,g=0.8,b=0.8},
                scale = 1.5,
                orientation = 0.75,
                alignment = 'center',
                visible = false
            }
        },
        base_grid = {horizontal={}, vertical={}},
        subgrid_1 = {horizontal={}, vertical={}},
        subgrid_2 = {horizontal={}, vertical={}},
        subgrid_3 = {horizontal={}, vertical={}}
    }
end

local function update_render_objects(data)
    local area = data.area
    local objects = data.objects
    -- background
    set_left_top(objects.background, area.left_top)
    set_right_bottom(objects.background, area.right_bottom)
    -- border
    set_left_top(objects.border, area.left_top)
    set_right_bottom(objects.border, area.right_bottom)
    -- labels
    set_target(objects.labels.horizontal, {x=area.midpoints.x, y=area.left_top.y-0.85})
    set_target(objects.labels.vertical, {x=area.left_top.x-0.85, y=area.midpoints.y})
    set_text(objects.labels.horizontal, area.width)
    set_text(objects.labels.vertical, area.height)
    set_visible(objects.labels.horizontal, (area.width > 1 and true or false))
    set_visible(objects.labels.vertical, (area.height > 1 and true or false))
    --
    -- BASE GRID
    --
    local hor_inc = data.hot_corner:find('top') and -1 or 1
    local ver_inc = data.hot_corner:find('left') and -1 or 1
    local hor_anchor = data.hot_corner:find('top') and 'bottom' or 'top'
    local ver_anchor = data.hot_corner:find('left') and 'right' or 'left'
    if area.width_changed then
        -- draw new vertical lines / destroy extra lines
        local vertical = objects.base_grid.vertical
        if #vertical+1 < area.width then
            for i=#vertical+1,area.width-1 do
                vertical[i] = draw_line{
                    color = {r=0.5,g=0.5,b=0.5},
                    width = 1.5,
                    from = {x=area[ver_anchor..'_top'].x+(i*ver_inc), y=area.left_top.y},
                    to = {x=area[ver_anchor..'_top'].x+(i*ver_inc), y=area.right_bottom.y},
                    surface = data.surface,
                    draw_on_ground = true
                }
            end
        else
            for i=#vertical,area.width,-1 do
                destroy(vertical[i])
                vertical[i] = nil
            end
        end
        -- update existing horizontal lines
        for i,o in ipairs(objects.base_grid.horizontal) do
            set_from(o, {x=area.left_top.x, y=area['left_'..hor_anchor].y+(i*hor_inc)})
            set_to(o, {x=area.right_bottom.x, y=area['left_'..hor_anchor].y+(i*hor_inc)})
        end
    end
    if area.height_changed then
        -- draw new horizontal lines / destroy extra lines
        local horizontal = objects.base_grid.horizontal
        if #horizontal+1 < area.height then
            for i=#horizontal+1,area.height-1 do
                horizontal[i] = draw_line{
                    color = {r=0.5,g=0.5,b=0.5},
                    width = 1.5,
                    from = {x=area.left_top.x, y=area['left_'..hor_anchor].y+(i*hor_inc)},
                    to = {x=area.right_bottom.x, y=area['left_'..hor_anchor].y+(i*hor_inc)},
                    surface = data.surface,
                    draw_on_ground = true
                }
            end
        else
            for i=#horizontal,area.height,-1 do
                destroy(horizontal[i])
                horizontal[i] = nil
            end
        end
        -- update existing vertical lines
        for i,o in ipairs(objects.base_grid.vertical) do
            set_from(o, {x=area[ver_anchor..'_top'].x+(i*ver_inc), y=area.left_top.y})
            set_to(o, {x=area[ver_anchor..'_top'].x+(i*ver_inc), y=area.right_bottom.y})
        end
    end
end

function tilegrid.construct(tilegrid_index, tile_pos, player_index)
    local drawing = {
        player = player_index,
        last_capsule_pos = tile_pos,
        last_capsule_tick = game.ticks_played
    }
    local registry = {
        area = util.new_area_from_tile_position(tile_pos),
        entities = {},
        hot_corner = 'right_bottom',
        surface = util.get_player(player_index).surface.index,
        settings = util.player_table(player_index).settings
    }
    registry.objects = construct_render_objects(registry)
    global.tilegrids.drawing[tilegrid_index] = drawing
    global.tilegrids.registry[tilegrid_index] = registry
end

function tilegrid.update(tilegrid_index, tile_pos)
    -- local profiler = game.create_profiler()
    local drawing = global.tilegrids.drawing[tilegrid_index]
    local registry = global.tilegrids.registry[tilegrid_index]
    local area = registry.area
    -- update hot corner
    registry.hot_corner = (tile_pos.x >= area.origin.x and 'right' or 'left')..'_'..(tile_pos.y >= area.origin.y and 'bottom' or 'top')
    -- update area
    registry.area = util.update_area(area, tile_pos, registry.hot_corner)
    -- update render objects
    update_render_objects(registry)
    -- game.print(profiler)
end

return tilegrid

--[[
    local prev_tile = player_data.last_capsule_pos
    local pos = e.position
    -- get current tile position
    local cur_tile = {x=floor(pos.x), y=floor(pos.y)}
    if prev_tile.x ~= cur_tile.x or prev_tile.y ~= cur_tile.y then
]]--