local capsule_handlers = {}

local event = require("__flib__.event")
local mod_gui = require("mod-gui")

local edit_gui = require("scripts.gui.edit")
local select_gui = require("scripts.gui.select")
local tilegrid = require("scripts.tilegrid")

local math_abs = math.abs
local math_floor = math.floor
local table_insert = table.insert

-- this function is conditionally registered as the on_tick handler
function capsule_handlers.on_tick()
  local cur_tick = game.ticks_played
  local end_wait = global.end_wait
  local drawing = global.tilegrids.drawing
  local perishing = global.tilegrids.perishing

  for i, tbl in pairs(drawing) do
    if tbl.last_capsule_tick + end_wait < cur_tick then
      -- finish up tilegrid
      local player_table = global.players[i]
      local visual_settings = player_table.settings.visual
      local data = player_table.tilegrids.drawing

      -- if the grid is 1x1, just delete it
      if data.area.width == 1 and data.area.height == 1 then
        tilegrid.destroy(data)
      else
        if data.settings.auto_clear then
          -- add to perishing table
          local death_tick = cur_tick+math_floor(visual_settings.tilegrid_clear_delay*60)
          local pt = perishing[death_tick]
          if not pt then
            perishing[death_tick] = {}
            pt = perishing[death_tick]
          end
          pt[#pt+1] = util.merge{{player_index=i}, data}
        else
          -- add to editable table
          table_insert(player_table.tilegrids.registry, table.deepcopy(data))
        end

        -- log selection dimensions
        if visual_settings.log_selection_area then
          local area = data.area
          game.get_player(i).print("Dimensions: "..area.width.."x"..area.height)
        end
      end
      player_table.tilegrids.drawing = false
      drawing[i] = nil
    end
  end

  local pt = perishing[cur_tick]
  if pt then
    for i=1,#pt do
      tilegrid.destroy(pt[i])
    end
    perishing[cur_tick] = nil
  end

  -- deregister handler if drawing and perishing tables are empty
  if table_size(drawing) == 0 and table_size(perishing) == 0 then event.on_tick(nil) end
end

-- register the draw_on_tick handler if it is needed
function capsule_handlers.update_on_tick()
  if
    global.tilegrids.drawing
    and (table_size(global.tilegrids.drawing) > 0 or table_size(global.tilegrids.perishing) > 0)
  then
    event.on_tick(capsule_handlers.on_tick)
  end
end

function capsule_handlers.draw(e)
  local player_table = global.players[e.player_index]
  local cur_tile = {x=math_floor(e.position.x), y=math_floor(e.position.y)}
  local data = player_table.tilegrids.drawing
  -- check if currently drawing
  if data then
    local drawing = global.tilegrids.drawing[e.player_index]
    local prev_tile = drawing.last_capsule_pos
    drawing.last_capsule_tick = game.ticks_played
    -- if cardinals only, adjust thrown position
    if data.settings.cardinals_only then
      local origin = data.area.origin
      if math_abs(cur_tile.x - origin.x) >= math_abs(cur_tile.y - origin.y) then
        cur_tile.y = math_floor(origin.y)
      else
        cur_tile.x = math_floor(origin.x)
      end
    end
    -- if the current tile position differs from the last known tile position
    if prev_tile.x ~= cur_tile.x or prev_tile.y ~= cur_tile.y then
      -- update existing tilegrid
      drawing.last_capsule_pos = cur_tile
      tilegrid.update(cur_tile, data, e.player_index, player_table.settings.visual)
    end
  else
    -- create new tilegrid
    tilegrid.construct(cur_tile, e.player_index, game.get_player(e.player_index).surface.index, player_table.settings.visual)

    -- update on_tick
    capsule_handlers.update_on_tick()
  end
end

function capsule_handlers.edit(e)
  local player_table = global.players[e.player_index]
  local cur_tile = {x=math_floor(e.position.x), y=math_floor(e.position.y)}
  -- to avoid spamming messages, check against last tile position
  local prev_tile = player_table.last_capsule_tile
  if prev_tile and prev_tile.x == cur_tile.x and prev_tile.y == cur_tile.y then return end
  player_table.last_capsule_tile = cur_tile
  -- loop through the editable table to see if we clicked on a tilegrid
  local player = game.get_player(e.player_index)
  local surface_index = player.surface.index
  local clicked_on = {}
  for i,t in pairs(player_table.tilegrids.registry) do
    if t.surface == surface_index and util.area.contains_point(t.area, e.position) then
      table.insert(clicked_on, i)
    end
  end
  local size = table_size(clicked_on)
  if size == 0 then
    player.surface.create_entity{
      name = "flying-text",
      position = e.position,
      text = {"tl.click-on-tilegrid"},
      render_player_index = e.player_index
    }
    return
  elseif size == 1 then
    -- skip selection dialog
    local data = player_table.tilegrids.registry[clicked_on[1]]
    local elems = edit_gui.create(mod_gui.get_frame_flow(player), e.player_index, data.settings, data.hot_corner)
    player_table.tilegrids.editing = clicked_on[1]
    -- create highlight box
    local area = data.area
    local highlight_box = player.surface.create_entity{
      name = "tl-highlight-box",
      position = area.left_top,
      bounding_box = util.area.expand(area, 0.25),
      render_player_index = e.player_index,
      player = e.player_index,
      blink_interval = 30
    }
    player_table.gui.edit = {elems=elems, highlight_box=highlight_box, last_divisor_value=elems.divisor_textfield.text}
  else
    -- show selection dialog
    select_gui.populate_listbox(e.player_index, clicked_on)
    player_table.flags.selecting_tilegrid = true
  end
  player.clear_cursor()
end

function capsule_handlers.adjust(e)
  local player_table = global.players[e.player_index]
  local data = player_table.tilegrids.registry[player_table.tilegrids.editing]
  local cur_tile = {x=math_floor(e.position.x), y=math_floor(e.position.y)}
  if game.tick - player_table.last_capsule_tick > global.end_wait then
    player_table.last_capsule_tile = nil
  end
  local prev_tile = player_table.last_capsule_tile
  if prev_tile == nil then
    -- check if the player is actually on the grid
    if util.area.contains_point(data.area, cur_tile) then
      player_table.last_capsule_tile = cur_tile
    end
  else
    -- check if grid should be moved
    if not util.position.equals(cur_tile, prev_tile) then
      -- calculate vector
      local vector = util.position.subtract(cur_tile, prev_tile)
      -- apply to area and recreate constants
      local area = util.area.add_data{
        left_top = util.position.add(data.area.left_top, vector),
        right_bottom = util.position.add(data.area.right_bottom, vector),
        origin = util.position.add(data.area.origin, vector)
      }
      data.area = area
      tilegrid.refresh(data, e.player_index, player_table.settings.visual)
      -- move highlight box
      local gui_data = player_table.gui.edit
      local highlight_box = gui_data.highlight_box.surface.create_entity{
        name = "tl-highlight-box",
        position = area.left_top,
        bounding_box = util.area.expand(area, 0.25),
        render_player_index = e.player_index,
        player = e.player_index,
        blink_interval = 30
      }
      gui_data.highlight_box.destroy()
      gui_data.highlight_box = highlight_box
      -- update capsule tile
      player_table.last_capsule_tile = cur_tile
    end
  end
  player_table.last_capsule_tick = game.ticks_played
end

return capsule_handlers