local event = require("__RaiLuaLib__.lualib.event")
local gui = require("__RaiLuaLib__.lualib.gui")
local migration = require("__RaiLuaLib__.lualib.migration")
local mod_gui = require("mod-gui")
local util = require("scripts.util")

local draw_gui = require("gui.draw")
local edit_gui = require("gui.edit")
local select_gui = require("gui.select")

local migrations = require("scripts.migrations")
local tilegrid = require("scripts.tilegrid")

-- local floor = math.floor
-- local math_abs = math.abs
-- local string_gsub = string.gsub
-- local string_sub = string.sub
-- local table_insert = table.insert

gui.templates:extend{
  pushers = {
    horizontal = {type="empty-widget", style_mods={horizontally_stretchable=true}},
    vertical = {type="empty-widget", style_mods={vertically_stretchable=true}}
  },
  window = {type="frame", style_mods={width=252}, direction="vertical", save_as="window"},
  horizontally_centered_flow = {type="flow", style_mods={horizontal_align="center", horizontally_stretchable=true}, direction="vertical"},
  vertically_centered_flow = {type="flow", style_mods={vertical_align="center"}, direction="horizontal"}
}

-- -----------------------------------------------------------------------------
-- EVENT HANDLERS

-- show tutorial text in either a speech bubble or in chat
local function show_tutorial(player, player_table, type)
  player_table.flags[type.."_tutorial_shown"] = true
  if player.character then
    player_table.bubble = player.surface.create_entity{
      name = "tl-speech-bubble",
      position = player.position,
      text = {"tl."..type.."-tutorial-text"},
      source = player.character
    }
  else
    player.print{"tl."..type.."-tutorial-text"}
  end
  event.enable("on_capsule_after_tutorial", player.index)
end

event.on_init(function()
  -- setup global
  global.tilegrids = {
    drawing = {},
    perishing = {},
  }
  global.players = {}
  -- set end_wait for a singleplayer game
  global.end_wait = 3
  -- create player data for any existing players
  for i,player in pairs(game.players) do
    setup_player(i)
    update_player_visual_settings(i, player)
  end
end)

event.on_configuration_changed(function(e)
  migration.on_config_changed(e, migrations)
end, {insert_at=1})

event.on_runtime_mod_setting_changed(function(e)
  update_player_visual_settings(e.player_index, game.get_player(e.player_index))
  local name = e.setting
  if name ~= "tilegrid-clear-delay" and name ~= "log-selection-area" then
    -- refresh all persistent tilegrids for the player
    local player_table = global.players[e.player_index]
    local visual_settings = player_table.settings.visual
    local registry = player_table.tilegrids.registry
    for i=1,#registry do
      tilegrid.refresh(registry[i], e.player_index, visual_settings)
    end
  end
end)

event.on_player_cursor_stack_changed(function(e)
  local player_table = global.players[e.player_index]
  local player = game.get_player(e.player_index)
  local stack = player.cursor_stack
  local player_gui = player_table.gui
  -- draw capsule
  if stack and stack.valid_for_read and stack.name == "tapeline-draw" then
    -- because sometimes it doesn't work properly?
    if player_gui.draw then return end
    -- if the player is currently selecting or editing, don't let them hold the capsule
    if player_table.flags.selecting_tilegrid then
      player.clean_cursor()
      player.print{"tl.finish-selection-first"}
      return
    elseif player_table.tilegrids.editing ~= false then
      player.clean_cursor()
      player.print{"tl.finish-editing-first"}
      return
    end
    if player_table.flags.capsule_tutorial_shown == false then
      -- show tutorial bubble
      show_tutorial(player, player_table, "capsule")
    end
    local elems = draw_gui.create(mod_gui.get_frame_flow(player), player.index, player_table.settings)
    player_gui.draw = {elems=elems, last_divisor_value=elems.divisor_textfield.text}
    event.enable("on_draw_capsule", e.player_index)
  elseif player_gui.draw then
    draw_gui.destroy(player_table.gui.draw.elems.window, player.index)
    player_gui.draw = nil
    event.disable("on_draw_capsule", e.player_index)
  end
  -- edit capsule
  if stack and stack.valid_for_read and stack.name == "tapeline-edit" then
    -- because sometimes it doesn't work properly?
    if player_gui.select then return end
    local elems = select_gui.create(mod_gui.get_frame_flow(player), player.index)
    player_gui.select = {elems=elems}
    event.enable("on_edit_capsule", e.player_index)
  elseif player_gui.select and not player_table.flags.selecting_tilegrid then
    select_gui.destroy(player_gui.select.elems.window, player.index)
    player_gui.select = nil
    player_table.last_capsule_tile = nil
    event.disable("on_edit_capsule", e.player_index)
  end
  -- adjust capsule
  if stack and stack.valid_for_read and stack.name == "tapeline-adjust" then
    player_table.flags.adjusting_tilegrid = true
    event.enable("on_adjust_capsule", e.player_index)
    if not player_table.flags.adjustment_tutorial_shown then
      -- show tutorial bubble
      show_tutorial(player, player_table, "adjustment")
    end
  elseif player_table.flags.adjusting_tilegrid == true then
    player_table.flags.adjusting_tilegrid = false
    player_table.last_capsule_tile = nil
    event.disable("on_adjust_capsule", e.player_index)
  end
end)

event.on_player_created(function(e)
  setup_player(e.player_index)
  update_player_visual_settings(e.player_index, game.get_player(e.player_index))
end)

event.on_player_joined_game(function(e)
  -- check if game is multiplayer
  if game.is_multiplayer() then
    -- check if end_wait has already been adjusted
    if global.end_wait == 3 then
      global.end_wait = 60
      game.print{"tl.mp-latency"}
    end
  end
end)

-- scroll between the items when the player shift+scrolls
event.register({"tapeline-cycle-forwards", "tapeline-cycle-backwards"}, function(e)
  local player = game.get_player(e.player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    if stack.name == "tapeline-draw" then
      player.cursor_stack.set_stack{name="tapeline-edit", count=1}
    elseif stack.name == "tapeline-edit" then
      player.cursor_stack.set_stack{name="tapeline-draw", count=1}
    end
  end
end)