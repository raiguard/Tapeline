local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local mod_gui = require("mod-gui")

local capsule_handlers = require("scripts.capsule-handlers")
local draw_gui = require("scripts.gui.draw")
local global_data = require("scripts.global-data")
local migrations = require("scripts.migrations")
local player_data = require("scripts.player-data")
local select_gui = require("scripts.gui.select")
local tilegrid = require("scripts.tilegrid")

local string_sub = string.sub

-- common GUI templates
gui.add_templates{
  pushers = {
    horizontal = {type="empty-widget", style_mods={horizontally_stretchable=true}},
    vertical = {type="empty-widget", style_mods={vertically_stretchable=true}}
  },
  window = {type="frame", style_mods={minimal_width=252}, direction="vertical", save_as="window"},
  horizontally_centered_flow = {type="flow", style_mods={horizontal_align="center", horizontally_stretchable=true}, direction="vertical"},
  vertically_centered_flow = {type="flow", style_mods={vertical_align="center"}, direction="horizontal"}
}

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS
-- on_tick handler is located in scripts.capsule-handlers

-- BOOTSTRAP

event.on_init(function()
  gui.init()

  global_data.init()
  for i in pairs(game.players) do
    player_data.init(i)
  end

  capsule_handlers.update_on_tick()

  gui.build_lookup_tables()
end)

event.on_load(function()
  capsule_handlers.update_on_tick()

  gui.build_lookup_tables()
end)

event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, migrations) then
    gui.check_filter_validity()
  end
end)

-- CAPSULES

event.on_player_cursor_stack_changed(function(e)
  local player_table = global.players[e.player_index]
  local player = game.get_player(e.player_index)
  local stack = player.cursor_stack
  local player_gui = player_table.gui

  if stack and stack.valid_for_read and stack.name == "tl-draw-capsule" then
    -- because sometimes it doesn't work properly?
    if player_gui.draw then return end
    -- if the player is currently selecting or editing, don't let them hold the capsule
    if player_table.flags.selecting_tilegrid then
      player.clear_cursor()
      player.print{"tl.finish-selection-first"}
      return
    elseif player_table.tilegrids.editing ~= false then
      player.clear_cursor()
      player.print{"tl.finish-editing-first"}
      return
    end
    -- show tutorial
    if player_table.flags.capsule_tutorial_shown == false then
      player_table.flags.capsule_tutorial_shown = true
      player.print{"tl.capsule-tutorial-text"}
    end

    local elems = draw_gui.create(mod_gui.get_frame_flow(player), player.index, player_table.settings)
    player_gui.draw = {elems=elems, last_divisor_value=elems.divisor_textfield.text}
  elseif player_gui.draw then
    draw_gui.destroy(player_table.gui.draw.elems.window, player.index)
    player_gui.draw = nil
  end

  if stack and stack.valid_for_read and stack.name == "tl-edit-capsule" then
    -- because sometimes it doesn't work properly?
    if player_gui.select then return end
    -- if the player is currently selecting or editing, don't let them hold the capsule
    if player_table.flags.selecting_tilegrid then
      player.clear_cursor()
      player.print{"tl.finish-selection-first"}
      return
    elseif player_table.tilegrids.editing ~= false then
      player.clear_cursor()
      player.print{"tl.finish-editing-first"}
      return
    end
    local elems = select_gui.create(mod_gui.get_frame_flow(player), player.index)
    player_gui.select = {elems=elems}
  elseif player_gui.select and not player_table.flags.selecting_tilegrid then
    select_gui.destroy(player_gui.select.elems.window, player.index)
    player_gui.select = nil
    player_table.last_capsule_tile = nil
  end

  if stack and stack.valid_for_read and stack.name == "tl-adjust-capsule" then
    player_table.flags.adjusting_tilegrid = true
    if not player_table.flags.adjustment_tutorial_shown then
      player_table.flags.adjustment_tutorial_shown = true
      player.print{"tl.adjustment-tutorial-text"}
    end
  elseif player_table.flags.adjusting_tilegrid == true then
    player_table.flags.adjusting_tilegrid = false
    player_table.last_capsule_tile = nil
  end
end)

event.register({"tl-cycle-forwards", "tl-cycle-backwards"}, function(e)
  local player = game.get_player(e.player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    if stack.name == "tl-draw-capsule" then
      player.cursor_stack.set_stack{name="tl-edit-capsule", count=1}
    elseif stack.name == "tl-edit-capsule" then
      player.cursor_stack.set_stack{name="tl-draw-capsule", count=1}
    end
  end
end)

event.on_player_used_capsule(function(e)
  local item_name = e.item.name
  if item_name == "tl-draw-capsule" then
    capsule_handlers.draw(e)
  elseif item_name == "tl-edit-capsule" then
    capsule_handlers.edit(e)
  elseif item_name == "tl-adjust-capsule" then
    capsule_handlers.adjust(e)
  end
end)

-- GUI

gui.register_handlers()

-- PLAYER

event.on_player_created(function(e)
  player_data.init(e.player_index)
end)

event.on_player_removed(function(e)
  -- destroy all tilegrids
  local tilegrids = global.players[e.player_index].tilegrids
  if tilegrids.drawing then
    tilegrid.destroy(tilegrids.drawing)
  end
  local registry = tilegrids.registry
  for i=1,#registry do
    tilegrid.destroy(registry[i])
  end
  -- remove player data
  global.players[e.player_index] = nil
end)

event.on_player_joined_game(function()
  -- check if game is multiplayer
  if game.is_multiplayer() then
    -- check if end_wait has already been adjusted
    if global.end_wait == 3 then
      global.end_wait = 60
      game.print{"tl.mp-latency"}
    end
  end
end)

-- SETTINGS

event.on_runtime_mod_setting_changed(function(e)
  local name = e.setting
  if string_sub(name, 1, 3) == "tl-" then
    player_data.update_settings(game.get_player(e.player_index), global.players[e.player_index])
    if name ~= "tl-tilegrid-clear-delay" and name ~= "tl-log-selection-area" then
      -- refresh all persistent tilegrids for the player
      local player_table = global.players[e.player_index]
      local visual_settings = player_table.settings.visual
      local registry = player_table.tilegrids.registry
      for i=1,#registry do
        tilegrid.refresh(registry[i], e.player_index, visual_settings)
      end
    end
  end
end)
