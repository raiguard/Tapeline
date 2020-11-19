local event = require("__flib__.event")
local migration = require("__flib__.migration")

local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")

-- -----------------------------------------------------------------------------
-- FUNCTIONS

local function destroy_last_entity(player_table)
  local last_entity = player_table.last_entity
  if last_entity then
    last_entity.destroy()
    player_table.last_entity = nil
  end
end

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- BOOTSTRAP

event.on_init(function()
  global_data.init()

  for i, player in pairs(game.players) do
    player_data.init(i)
    player_data.refresh(player, global.players[i])
  end
end)

event.on_load(function()
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, {}) then

  end
end)

-- CUSTOM INPUT

event.register("tl-get-draw-tool", function(e)
  local player = game.get_player(e.player_index)
  if player.clear_cursor() then
    player.cursor_stack.set_stack{name = "tl-draw-tool", count = 1}
  end
end)

-- ENTITY

event.on_built_entity(
  function(e)
    local player_table = global.players[e.player_index]
    -- set flag to re-populate the cursor
    player_table.flags.placed_entity = true
    -- destroy last entity and store the new one
    destroy_last_entity(player_table)
    player_table.last_entity = e.created_entity

    if player_table.flags.drawing then
      -- TODO: update tape
    else
      player_table.flags.drawing = true
      -- TODO: create tape
    end

    rendering.draw_circle{
      color = {r = 1, g = 1, b = 0, a = 0.75},
      radius = 0.25,
      filled = true,
      target = e.created_entity.position,
      surface = e.created_entity.surface,
      time_to_live = 60,
      players = {e.player_index},
      draw_on_ground = true
    }
  end,
  {
    {filter = "name", name = "tl-dummy-entity"},
  }
)

-- SELECTION TOOL

event.register(
  {
    defines.events.on_player_selected_area,
    defines.events.on_player_alt_selected_area
  },
  function(e)
    local player_table = global.players[e.player_index]
    if player_table.flags.drawing then
      player_table.flags.drawing = false
      log("Drag finished!")
      destroy_last_entity(player_table)
      -- TODO: complete draw
    end
  end
)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  player_data.init(e.player_index)
  player_data.refresh(player, player_table)
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)

event.on_player_cursor_stack_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  local is_empty = not cursor_stack or not cursor_stack.valid_for_read
  if player_table.flags.drawing and is_empty then
    if player_table.flags.placed_entity then
      player_table.flags.placed_entity = false
      player.cursor_stack.set_stack{name = "tl-draw-tool", count = 1}
    else
      player_table.flags.drawing = false
      destroy_last_entity(player_table)
      log("Drag finished!")
      -- TODO: complete draw
    end
  end
end)