local area = require("lib.area")
local event = require("__flib__.event")
local migration = require("__flib__.migration")

local constants = require("constants")

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
    if tape_data.surface == surface and TapeArea:contains(cursor_position) then
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

local function holding_tl_tool(player)
  local cursor_stack = player.cursor_stack
  return cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool"
end

local function set_cursor_label(player, player_table)
  local settings, TapeArea
  if player_table.flags.drawing then
    settings = player_table.tape_settings
    TapeArea = area.load(player_table.tapes.drawing.Area)
  elseif player_table.flags.editing then
    local tape_data = player_table.tapes.editing
    settings = tape_data.settings
    TapeArea = area.load(tape_data.Area)
  else
    settings = player_table.tape_settings
  end

  player.cursor_stack.label = (
    (TapeArea and (TapeArea:width().."x"..TapeArea:height().." | ") or "")
    ..constants.mode_labels[settings.mode]
    .." mode | "
    ..constants.divisor_labels[settings.mode]
    .." "..settings[settings.mode.."_divisor"]
  )
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
    for i, player_table in pairs(global.players) do
      local player = game.get_player(i)
      player_data.refresh(player, player_table)
    end
  end
end)

-- CUSTOM INPUT

event.register("tl-get-tool", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  if player.clear_cursor() then
    player.cursor_stack.set_stack{name = "tl-tool", count = 1}
    set_cursor_label(player, player_table)
  end
end)

event.register("tl-edit-tape", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  if holding_tl_tool(player) then
    local tapes = player_table.tapes
    local tape_to_edit = select_tape(tapes, e.cursor_position, player.surface)
    if tape_to_edit then
      if player_table.flags.editing then
        tape.exit_edit_mode(player_table)
        set_cursor_label(player, player_table)
      end
      tape.enter_edit_mode(player, player_table, tape_to_edit)
      set_cursor_label(player, player_table)
    end
  end
end)

event.register("tl-delete-tape", function(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]

  if holding_tl_tool(player) then
    local tapes = player_table.tapes
    local tape_to_delete = select_tape(tapes, e.cursor_position, player.surface)
    if tape_to_delete then
      tape.delete(player_table, tape_to_delete)
      set_cursor_label(player, player_table)
    end
  end
end)

event.register(
  {
    "tl-increase-divisor",
    "tl-decrease-divisor"
  },
  function(e)
    local player = game.get_player(e.player_index)
    if holding_tl_tool(player) then
      local player_table = global.players[e.player_index]
      local settings
      if player_table.flags.editing then
        settings = player_table.tapes.editing.settings
      else
        settings = player_table.tape_settings
      end
      local mode = settings.mode
      local key = mode.."_divisor"
      local delta = string.find(e.input_name, "increase") and 1 or -1
      local new_divisor = settings[key] + delta
      if new_divisor >= constants.divisor_minimums[mode] then
        settings[key] = new_divisor
        set_cursor_label(player, player_table)
        if player_table.flags.drawing then
          tape.update_draw(player, player_table)
        elseif player_table.flags.editing then
          tape.edit_settings(e.player_index, player_table, mode, new_divisor)
        end
      else
        player.create_local_flying_text{
          text = {"tl-message.minimal-value-is", constants.divisor_minimums[mode]},
          create_at_cursor = true
        }
        player.play_sound{path = "utility/cannot_build", volume_modifier = 0.75}
      end
    end
  end
)

event.register(
  {
    "tl-next-mode",
    "tl-previous-mode"
  },
  function(e)
    local player = game.get_player(e.player_index)
    if holding_tl_tool(player) then
      local player_table = global.players[e.player_index]
      local settings
      if player_table.flags.editing then
        settings = player_table.tapes.editing.settings
      else
        settings = player_table.tape_settings
      end
      local new_mode = next(constants.modes, settings.mode)
      if not new_mode then
        new_mode = next(constants.modes)
      end
      settings.mode = new_mode
      local divisor = settings[new_mode.."_divisor"]
      set_cursor_label(player, player_table)
      if player_table.flags.drawing then
        tape.update_draw(player, player_table)
      elseif player_table.flags.editing then
        tape.edit_settings(e.player_index, player_table, new_mode, divisor)
      end
    end
  end
)

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
      -- clear the cursor to trigger the label updating
      -- TODO: do it better than this!
      player.clear_cursor()
    end
    player_table.last_entity = entity

    if player_table.flags.drawing then
      tape.update_draw(player, player_table, entity.position)
    elseif player_table.flags.editing then
      tape.move(player, player_table, entity.position, entity.surface)
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
  if holding_tl_tool(player) and e.shift_build then
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
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    if player_table.flags.drawing then
      player_table.flags.drawing = false
      destroy_last_entity(player_table)
      tape.complete_draw(player, player_table, e.name == defines.events.on_player_selected_area)
      set_cursor_label(player, player_table)
    elseif player_table.flags.editing then
      destroy_last_entity(player_table)
      tape.complete_move(player_table)
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
      set_cursor_label(player, player_table)
    end
  elseif is_empty or cursor_stack.name ~= "tl-tool" then
    if player_table.flags.editing then
      tape.exit_edit_mode(player_table)
      player.cursor_stack.set_stack{name = "tl-tool", count = 1}
      set_cursor_label(player, player_table)
    elseif player_table.flags.drawing then
      -- TODO: properly detect whether or not to auto-clear
      tape.complete_draw(player, player_table, true)
      set_cursor_label(player, player_table)
    end
  end
end)

-- SETTINGS

event.on_runtime_mod_setting_changed(function(e)
  local internal = constants.setting_names[e.setting]
  if internal then
    local player = game.get_player(e.player_index)
    local player_table = global.players[e.player_index]
    local visual_settings = player_table.visual_settings
    player_data.update_visual_setting(player, visual_settings, e.setting, internal)
    for _, tape_data in ipairs(player_table.tapes) do
      tape.update_visual_settings(tape_data, visual_settings)
    end
  end
end)