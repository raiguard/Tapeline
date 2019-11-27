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
-- 0.18: bring to front to preserve correct draw order
-- local bring_to_front = rendering.bring_to_front

local line_width = 1.5

local function create_line(from, to, surface, color)
    return draw_line{
        color = color,
        width = line_width,
        from = from,
        to = to,
        surface = surface,
        draw_on_ground = true
    }
end

local function update_grid(area, surface, pos_data, lines, div, color)
    local hor_sign = pos_data.hor_sign
    local ver_sign = pos_data.ver_sign
    local hor_anchor = pos_data.hor_anchor
    local ver_anchor = pos_data.ver_anchor
    if area.width_changed then
        -- draw new vertical lines / destroy extra lines
        local vertical = lines.vertical
        if #vertical+1 < area.width/div then
            for i=#vertical+1,(area.width-1)/div do
                vertical[i] = create_line(
                    {x=area[ver_anchor..'_top'].x+(i*ver_sign*div), y=area.left_top.y},
                    {x=area[ver_anchor..'_top'].x+(i*ver_sign*div), y=area.right_bottom.y},
                    surface, color
                )
            end
        else
            for i=#vertical,area.width/div,-1 do
                destroy(vertical[i])
                vertical[i] = nil
            end
        end
        -- update existing horizontal lines
        for i,o in ipairs(lines.horizontal) do
            set_from(o, {x=area.left_top.x, y=area['left_'..hor_anchor].y+(i*hor_sign*div)})
            set_to(o, {x=area.right_bottom.x, y=area['left_'..hor_anchor].y+(i*hor_sign*div)})
            -- 0.18: bring to front to preserve correct draw order
            -- bring_to_front(o)
        end
    end
    if area.height_changed then
        -- draw new horizontal lines / destroy extra lines
        local horizontal = lines.horizontal
        if #horizontal+1 < (area.height/div) then
            for i=#horizontal+1,(area.height-1)/div do
                horizontal[i] = create_line(
                    {x=area.left_top.x, y=area['left_'..hor_anchor].y+(i*hor_sign*div)},
                    {x=area.right_bottom.x, y=area['left_'..hor_anchor].y+(i*hor_sign*div)},
                    surface, color
                )
            end
        else
            for i=#horizontal,area.height/div,-1 do
                destroy(horizontal[i])
                horizontal[i] = nil
            end
        end
        -- update existing vertical lines
        for i,o in ipairs(lines.vertical) do
            set_from(o, {x=area[ver_anchor..'_top'].x+(i*ver_sign*div), y=area.left_top.y})
            set_to(o, {x=area[ver_anchor..'_top'].x+(i*ver_sign*div), y=area.right_bottom.y})
            -- 0.18: bring to front to preserve correct draw order
            -- bring_to_front(o)
        end
    end
end

local function update_splits(area, surface, lines, div, color)
    local ver_inc = area.width / div
    local hor_inc = area.height / div
    local horizontal = lines.horizontal
    local vertical = lines.vertical
    if area.width_changed then
        -- create or destroy vertical lines if needed
        if #vertical < div-1 then
            for i=#vertical+1,div-1 do
                vertical[i] = create_line(
                    {x=area.left_top.x+(i*ver_inc), y=area.left_top.y},
                    {x=area.left_top.x+(i*ver_inc), y=area.right_bottom.y},
                    surface, color
                )
            end
        elseif #vertical > div-1 then
            for i=#horizontal,div-1,-1 do
                destroy(horizontal[i])
                horizontal[i] = nil
            end
        end
        -- update vertical line positions and visibility
        for i=1,#vertical do
            set_visible(vertical[i], area.width > div and true or false)
            set_from(vertical[i], {x=area.left_top.x+(i*ver_inc), y=area.left_top.y})
            set_to(vertical[i], {x=area.left_top.x+(i*ver_inc), y=area.right_bottom.y})
        end
        -- update horizontal line widths
        for i,o in ipairs(horizontal) do
            set_from(o, {x=area.left_top.x, y=area.left_top.y+(i*hor_inc)})
            set_to(o, {x=area.right_bottom.x, y=area.left_top.y+(i*hor_inc)})
            -- 0.18: bring to front to preserve correct draw order
            -- bring_to_front(o)
        end
    end
    if area.height_changed then
        -- create or destroy horizontal lines if needed
        if #horizontal < div-1 then
            for i=#horizontal+1,div-1 do
                horizontal[i] = create_line(
                    {x=area.left_top.x, y=area.left_top.y+(i*hor_inc)},
                    {x=area.right_bottom.x, y=area.left_top.y+(i*hor_inc)},
                    surface, color
                )
            end
        elseif #horizontal > div-1 then
            for i=#horizontal,div-1,-1 do
                destroy(horizontal[i])
                horizontal[i] = nil
            end
        end
        -- update horizontal line positions and visibility
        for i=1,#horizontal do
            set_visible(horizontal[i], area.height > div and true or false)
            set_from(horizontal[i], {x=area.left_top.x, y=area.left_top.y+(i*hor_inc)})
            set_to(horizontal[i], {x=area.right_bottom.x, y=area.left_top.y+(i*hor_inc)})
        end
        -- update vertical line heights
        for i,o in ipairs(vertical) do
            set_from(o, {x=area.left_top.x+(i*ver_inc), y=area.left_top.y})
            set_to(o, {x=area.left_top.x+(i*ver_inc), y=area.right_bottom.y})
            -- 0.18: bring to front to preserve correct draw order
            -- bring_to_front(o)
        end
    end
end

local function construct_render_objects(data)
    local area = data.area
    local surface = data.surface
    local objects = {
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
            width = line_width,
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
    return objects
end

local function update_render_objects(data)
    local area = data.area
    local objects = data.objects
    local surface = data.surface
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
    -- GRIDS
    --
    local pos_data = {
        hor_sign = data.hot_corner:find('top') and -1 or 1,
        ver_sign = data.hot_corner:find('left') and -1 or 1,
        hor_anchor = data.hot_corner:find('top') and 'bottom' or 'top',
        ver_anchor = data.hot_corner:find('left') and 'right' or 'left'
    }
    -- update base grid
    if data.prev_hot_corner ~= data.hot_corner then
        area.height_changed = true
        area.width_changed = true
        for i,o in ipairs(objects.base_grid.horizontal) do
            destroy(o)
        end
        objects.base_grid.horizontal = {}
        for i,o in ipairs(objects.base_grid.vertical) do
            destroy(o)
        end
        objects.base_grid.vertical = {}
    end
    update_grid(area, surface, pos_data, objects.base_grid, 1, {r=0.5, g=0.5, b=0.5})
    -- update subgrids if in increment mode
    if data.settings.grid_type == 1 then
        local div = data.settings.increment_divisor
        update_grid(area, surface, pos_data, objects.subgrid_1, div, {r=0.4, g=0.8, b=0.4})
        update_grid(area, surface, pos_data, objects.subgrid_2, div^2, {r=0.8, g=0.3, b=0.3})
        update_grid(area, surface, pos_data, objects.subgrid_3, div^3, {r=0.8, g=0.8, b=0.3})
    -- update splits if in split mode
    elseif data.settings.grid_type == 2 then
        update_splits(area, surface, objects.subgrid_1, data.settings.split_divisor, {r=0.4, g=0.8, b=0.4})
        update_splits(area, surface, objects.subgrid_2, 2, {r=0.8, g=0.4, b=0.4})
    end
    -- 0.18: bring border to front
    -- bring_to_front(objects.border)
end

local function destroy_render_objects(objects)
    for i,o in pairs(objects) do
        if type(o) == 'table' then
            destroy_render_objects(o)
        else
            destroy(o)
        end
    end
end

function tilegrid.construct(tilegrid_index, tile_pos, player_index, surface_index)
    local drawing = {
        last_capsule_pos = tile_pos,
        last_capsule_tick = game.ticks_played,
        player_index = player_index,
        surface_index = surface_index
    }
    local registry = {
        area = util.new_area_from_tile_position(tile_pos),
        entities = {},
        prev_hot_corner = 'right_bottom',
        hot_corner = 'right_bottom',
        surface = util.get_player(player_index).surface.index,
        settings = util.player_table(player_index).settings
    }
    registry.objects = construct_render_objects(registry)
    global.tilegrids.drawing[tilegrid_index] = drawing
    global.tilegrids.registry[tilegrid_index] = registry
end

function tilegrid.update(tilegrid_index, tile_pos, drawing, registry)
    local area = registry.area
    -- update hot corner
    registry.prev_hot_corner = registry.hot_corner
    registry.hot_corner = (tile_pos.x >= area.origin.x and 'right' or 'left')..'_'..(tile_pos.y >= area.origin.y and 'bottom' or 'top')
    -- update area
    registry.area = util.update_area(area, tile_pos, registry.hot_corner)
    -- update render objects
    update_render_objects(registry)
end

function tilegrid.destroy(tilegrid_index)
    local registry = global.tilegrids.registry[tilegrid_index]
    destroy_render_objects(registry.objects)
    global.tilegrids.registry[tilegrid_index] = nil
end

return tilegrid