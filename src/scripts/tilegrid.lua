local tilegrid = {}

local util = require("scripts.util")

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
local bring_to_front = rendering.bring_to_front

local function create_line(from, to, surface, color, line_width, draw_on_ground, player_index)
  return draw_line{
    color = color,
    width = line_width,
    from = from,
    to = to,
    surface = surface,
    draw_on_ground = draw_on_ground,
    players = {player_index}
  }
end

local function update_grid(area, surface, pos_data, lines, div, color, line_width, draw_on_ground, player_index)
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
          {x=area[ver_anchor.."_top"].x+(i*ver_sign*div), y=area.left_top.y},
          {x=area[ver_anchor.."_top"].x+(i*ver_sign*div), y=area.right_bottom.y},
          surface, color, line_width, draw_on_ground, player_index
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
      set_from(o, {x=area.left_top.x, y=area["left_"..hor_anchor].y+(i*hor_sign*div)})
      set_to(o, {x=area.right_bottom.x, y=area["left_"..hor_anchor].y+(i*hor_sign*div)})
    end
  end
  if area.height_changed then
    -- draw new horizontal lines / destroy extra lines
    local horizontal = lines.horizontal
    if #horizontal+1 < (area.height/div) then
      for i=#horizontal+1,(area.height-1)/div do
        horizontal[i] = create_line(
          {x=area.left_top.x, y=area["left_"..hor_anchor].y+(i*hor_sign*div)},
          {x=area.right_bottom.x, y=area["left_"..hor_anchor].y+(i*hor_sign*div)},
          surface, color, line_width, draw_on_ground, player_index
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
      set_from(o, {x=area[ver_anchor.."_top"].x+(i*ver_sign*div), y=area.left_top.y})
      set_to(o, {x=area[ver_anchor.."_top"].x+(i*ver_sign*div), y=area.right_bottom.y})
    end
  end
  -- bring lines to front to preserve draw order
  for _,o in ipairs(lines.horizontal) do
    bring_to_front(o)
  end
  for _,o in ipairs(lines.vertical) do
    bring_to_front(o)
  end
end

local function update_splits(area, surface, lines, div, color, line_width, draw_on_ground, player_index)
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
          surface, color, line_width, draw_on_ground, player_index
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
    end
  end
  if area.height_changed then
    -- create or destroy horizontal lines if needed
    if #horizontal < div-1 then
      for i=#horizontal+1,div-1 do
        horizontal[i] = create_line(
          {x=area.left_top.x, y=area.left_top.y+(i*hor_inc)},
          {x=area.right_bottom.x, y=area.left_top.y+(i*hor_inc)},
          surface, color, line_width, draw_on_ground, player_index
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
    end
  end
  -- bring lines to front to preserve draw order
  for _,o in ipairs(lines.horizontal) do
    bring_to_front(o)
  end
  for _,o in ipairs(lines.vertical) do
    bring_to_front(o)
  end
end

local function construct_render_objects(data, player_index, visual_settings)
  local area = data.area
  local surface = data.surface
  local draw_on_ground = visual_settings.draw_tilegrid_on_ground
  local objects = {
    background = draw_rectangle{
      color = visual_settings.tilegrid_background_color,
      filled = true,
      left_top = area.left_top,
      right_bottom = area.right_bottom,
      surface = surface,
      draw_on_ground = draw_on_ground,
      players = {player_index}
    },
    border = draw_rectangle{
      color = visual_settings.tilegrid_border_color,
      width = visual_settings.tilegrid_line_width,
      left_top = area.left_top,
      right_bottom = area.right_bottom,
      surface = surface,
      draw_on_ground = draw_on_ground,
      players = {player_index}
    },
    labels = {
      horizontal = draw_text{
        text = area.width,
        surface = surface,
        target = {x=area.midpoints.x, y=area.left_top.y-0.85},
        color = visual_settings.tilegrid_label_color,
        scale = 1.5,
        alignment = "center",
        visible = false,
        players = {player_index}
      },
      vertical = draw_text{
        text = area.height,
        surface = surface,
        target = {x=area.left_top.x-0.85, y=area.midpoints.y},
        color = visual_settings.tilegrid_label_color,
        scale = 1.5,
        orientation = 0.75,
        alignment = "center",
        visible = false,
        players = {player_index}
      }
    },
    base_grid = {horizontal={}, vertical={}},
    subgrid_1 = {horizontal={}, vertical={}},
    subgrid_2 = {horizontal={}, vertical={}},
    subgrid_3 = {horizontal={}, vertical={}}
  }
  return objects
end

local function update_render_objects(data, player_index, visual_settings)
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
    hor_sign = data.hot_corner:find("top") and -1 or 1,
    ver_sign = data.hot_corner:find("left") and -1 or 1,
    hor_anchor = data.hot_corner:find("top") and "bottom" or "top",
    ver_anchor = data.hot_corner:find("left") and "right" or "left"
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
  local line_width = visual_settings.tilegrid_line_width
  local draw_on_ground = visual_settings.draw_tilegrid_on_ground
  update_grid(area, surface, pos_data, objects.base_grid, 1, visual_settings.tilegrid_color_1, line_width, draw_on_ground, player_index)
  -- update subgrids if in increment mode
  if data.settings.grid_type == 1 then
    local div = data.settings.increment_divisor
    update_grid(area, surface, pos_data, objects.subgrid_1, div, visual_settings.tilegrid_color_2, line_width, draw_on_ground, player_index)
    update_grid(area, surface, pos_data, objects.subgrid_2, div^2, visual_settings.tilegrid_color_3, line_width, draw_on_ground, player_index)
    update_grid(area, surface, pos_data, objects.subgrid_3, div^3, visual_settings.tilegrid_color_4, line_width, draw_on_ground, player_index)
  -- update splits if in split mode
  elseif data.settings.grid_type == 2 then
    update_splits(area, surface, objects.subgrid_1, data.settings.split_divisor, visual_settings.tilegrid_color_2, line_width, draw_on_ground, player_index)
    update_splits(area, surface, objects.subgrid_2, 2, visual_settings.tilegrid_color_3, line_width, draw_on_ground, player_index)
  end
  bring_to_front(objects.border)
end

local function destroy_render_objects(objects)
  for i,o in pairs(objects) do
    if type(o) == "table" then
      destroy_render_objects(o)
    else
      destroy(o)
    end
  end
end

function tilegrid.construct(tile_pos, player_index, surface_index, visual_settings)
  local center = util.position.add(tile_pos, {x=0.5, y=0.5})
  local area = util.area.add_data(util.position.to_tile_area(center))
  area.origin = center
  local drawing = {
    last_capsule_pos = tile_pos,
    last_capsule_tick = game.ticks_played,
    surface_index = surface_index
  }
  local registry = {
    area = area,
    prev_hot_corner = "right_bottom",
    hot_corner = "right_bottom",
    surface = game.get_player(player_index).surface.index,
    settings = global.players[player_index].settings
  }
  registry.objects = construct_render_objects(registry, player_index, visual_settings)
  global.tilegrids.drawing[player_index] = drawing
  global.players[player_index].tilegrids.drawing = registry
end

function tilegrid.update(tile_pos, data, player_index, visual_settings)
  local area = data.area
  -- update hot corner
  data.prev_hot_corner = data.hot_corner
  data.hot_corner = (tile_pos.x >= area.origin.x and "right" or "left").."_"..(tile_pos.y >= area.origin.y and "bottom" or "top")
  -- update area
  local origin = area.origin
  local hot_corner = data.hot_corner
  local left_top = {x=math.floor(tile_pos.x < origin.x and tile_pos.x or origin.x), y=math.floor(tile_pos.y < origin.y and tile_pos.y or origin.y)}
  local right_bottom = {x=math.ceil(tile_pos.x > origin.x and tile_pos.x or origin.x), y=math.ceil(tile_pos.y > origin.y and tile_pos.y or origin.y)}
  if hot_corner == "right_top" or hot_corner == "right_bottom" then
    right_bottom.x = right_bottom.x + 1
  end
  if hot_corner == "left_bottom" or hot_corner == "right_bottom" then
    right_bottom.y = right_bottom.y + 1
  end
  local width = right_bottom.x - left_top.x
  local height = right_bottom.y - left_top.y
  data.area = {
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
  -- update render objects
  update_render_objects(data, player_index, visual_settings)
end

function tilegrid.destroy(data)
  destroy_render_objects(data.objects)
end

-- destroys and recreates render objects
function tilegrid.refresh(data, player_index, visual_settings)
  data.area.width_changed = true
  data.area.height_changed = true
  destroy_render_objects(data.objects)
  data.objects = construct_render_objects(data, player_index, visual_settings)
  update_render_objects(data, player_index, visual_settings)
end

return tilegrid