local area = require("lib.area")
local event = require("__flib__.event")
local migration = require("__flib__.migration")

local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")
local tape = require("scripts.tape")

-- -----------------------------------------------------------------------------
-- FUNCTIONS

local function destroy_last_entity(player_table)
  local last_entity = player_table.last_entity
  if last_entity then
    last_entity.destroy()
    player_table.last_entity = nil
  end
end

-- thanks to Rseding:
-- https://discordapp.com/channels/139677590393716737/306402592265732098/780898889955934208
local function select_tape(tapes, cursor_position, surface)
  local nearest
  local nearest_distance
  for i, tape_data in ipairs(tapes) do
    local TapeArea = area.load(tape_data.Area)
    if TapeArea.surface == surface and TapeArea:contains(cursor_position) then
      local distance = TapeArea:distance_to_nearest_edge(cursor_position)
      if not nearest or distance < nearest_distance then
        nearest = i
        nearest_distance = distance
        if nearest_distance == 0 then
          break
        end
      end
    end
  end

  return nearest
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

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, {}) then

  end
end)

-- CUSTOM INPUT

event.register("tl-get-tool", function(e)
  local player = game.get_player(e.player_index)
  if player.clear_cursor() then
    player.cursor_stack.set_stack{name = "tl-tool", count = 1}
  end
end)

event.register("tl-adjust-tape", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" then
    local tapes = player_table.tapes
    local tape_to_adjust = select_tape(tapes, e.cursor_position, player.surface)
    if tape_to_adjust then
      if player_table.flags.adjusting then
        tape.exit_adjust_mode(player_table)
      end
      tape.enter_adjust_mode(player, player_table, tape_to_adjust)
    end
  end
end)

event.register("tl-delete-tape", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" then
    local tapes = player_table.tapes
    local tape_to_delete = select_tape(tapes, e.cursor_position, player.surface)
    if tape_to_delete then
      tape.delete(player_table, tape_to_delete)
    end
  end
end)

-- ENTITY

event.on_built_entity(
  function(e)
    local entity = e.created_entity
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    -- set flag to re-populate the cursor
    player_table.flags.placed_entity = true
    -- destroy last entity and store the new one
    destroy_last_entity(player_table)
    if entity.name == "entity-ghost" then
      -- instantly revive the entity if it is a ghost
      local _
      _, entity = entity.silent_revive()
    end
    player_table.last_entity = entity

    if player_table.flags.drawing then
      tape.update_draw(player, player_table, entity.position)
    elseif player_table.flags.adjusting then
      tape.adjust(player, player_table, entity.position, entity.surface)
    else
      tape.start_draw(player, player_table, entity.position, entity.surface)
    end
  end,
  {
    {filter = "name", name = "tl-dummy-entity"},
    {filter = "ghost_name", name = "tl-dummy-entity"}
  }
)

event.on_pre_build(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" and e.shift_build then
    player_table.flags.shift_placed_entity = true
  end
end)

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
      destroy_last_entity(player_table)
      tape.complete_draw(player_table, e.name == defines.events.on_player_selected_area)
    end
  end
)

-- PLAYER

event.on_player_created(function(e)
  local player = game.get_player(e.player_index)
  player_data.init(e.player_index)
  player_data.refresh(player, global.players[e.player_index])
end)

event.on_player_removed(function(e)
  global.players[e.player_index] = nil
end)


event.on_player_cursor_stack_changed(function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local cursor_stack = player.cursor_stack
  local is_empty = not cursor_stack or not cursor_stack.valid_for_read
  if player_table.flags.placed_entity then
    if is_empty then
      player_table.flags.placed_entity = false
      player_table.flags.shift_placed_entity = false
      player.cursor_stack.set_stack{name = "tl-tool", count = 1}
      if player_table.flags.drawing then
        local TapeArea = area.load(player_table.tapes.drawing.Area)
        player.cursor_stack.label = TapeArea:width()..", "..TapeArea:height()
      end
    end
  elseif is_empty or cursor_stack.name ~= "tl-tool" then
    if player_table.flags.adjusting then
      tape.exit_adjust_mode(player_table)
    elseif player_table.flags.drawing then
      tape.complete_draw(player_table)
    end
  end

end)
