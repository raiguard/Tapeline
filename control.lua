local tape = require("__Tapeline__/tape")
local util = require("__Tapeline__/util")

script.on_init(function()
  --- @type table<uint, Tape>
  global.drawing = {}
  --- @type table<uint, boolean>
  global.holding_tool = {}

  tape.init()
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local tool = util.get_cursor_tool(player)
  if tool and not global.holding_tool[e.player_index] then
    global.holding_tool[e.player_index] = true
    util.set_cursor_tool(player)
  elseif not tool and global.holding_tool[e.player_index] then
    global.holding_tool[e.player_index] = nil
    if player.controller_type == defines.controllers.character and player.character_build_distance_bonus >= 1000000 then
      player.character_build_distance_bonus = player.character_build_distance_bonus - 1000000
    end
  end
end)

script.on_event(defines.events.on_built_entity, function(e)
  local drawing = global.drawing[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if drawing then
    tape.update(drawing, e.created_entity)
  else
    global.drawing[e.player_index] = tape.new(player, e.created_entity)
  end
end, {
  { filter = "name", name = "tl-dummy-entity" },
  { filter = "ghost_name", name = "tl-dummy-entity" },
})

script.on_event({ defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area }, function(e)
  local drawing = global.drawing[e.player_index]
  if not drawing then
    return
  end
  tape.destroy(drawing)
  util.set_cursor_tool(game.get_player(e.player_index) --[[@as LuaPlayer]])
  global.drawing[e.player_index] = nil
end)

-- script.on_event("tl-get-tool", function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   if player.clear_cursor() then
--     player.cursor_stack.set_stack({ name = "tl-tool", count = 100 })
--   end
-- end)

-- script.on_event("tl-edit-tape", function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]

--   if util.holding_tl_tool(player) then
--     local tapes = player_table.tapes
--     local tape_to_edit = util.select_tape(tapes, e.cursor_position, player.surface)
--     if tape_to_edit then
--       if player_table.flags.editing then
--         tape.exit_edit_mode(player_table)
--         util.set_cursor_label(player, player_table)
--       end
--       tape.enter_edit_mode(player, player_table, tape_to_edit)
--       util.set_cursor_label(player, player_table)
--     end
--   end
-- end)

-- script.on_event("tl-delete-tape", function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]

--   if util.holding_tl_tool(player) then
--     local tapes = player_table.tapes
--     local tape_to_delete = util.select_tape(tapes, e.cursor_position, player.surface)
--     if tape_to_delete then
--       tape.delete(player_table, tape_to_delete)
--       util.set_cursor_label(player, player_table)
--     end
--   end
-- end)

-- script.on_event({
--   "tl-increase-divisor",
--   "tl-decrease-divisor",
-- }, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   if util.holding_tl_tool(player) then
--     local player_table = global.players[e.player_index]
--     local settings
--     if player_table.flags.editing then
--       settings = player_table.tapes.editing.settings
--     else
--       settings = player_table.tape_settings
--     end
--     local mode = settings.mode
--     local key = mode .. "_divisor"
--     local delta = string.find(e.input_name, "increase") and 1 or -1
--     local new_divisor = settings[key] + delta
--     if new_divisor >= constants.divisor_minimums[mode] then
--       settings[key] = new_divisor
--       util.set_cursor_label(player, player_table)
--       if player_table.flags.drawing then
--         tape.update_draw(player, player_table)
--       elseif player_table.flags.editing then
--         tape.edit_settings(e.player_index, player_table, mode, new_divisor)
--       end
--     else
--       player.create_local_flying_text({
--         text = { "message.tl-minimal-value-is", constants.divisor_minimums[mode] },
--         create_at_cursor = true,
--       })
--       player.play_sound({ path = "utility/cannot_build", volume_modifier = 0.75 })
--     end
--   end
-- end)

-- script.on_event({
--   "tl-next-mode",
--   "tl-previous-mode",
-- }, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   if util.holding_tl_tool(player) then
--     local player_table = global.players[e.player_index]
--     local settings
--     if player_table.flags.editing then
--       settings = player_table.tapes.editing.settings
--     else
--       settings = player_table.tape_settings
--     end
--     local new_mode = next(constants.modes, settings.mode)
--     if not new_mode then
--       new_mode = next(constants.modes)
--     end
--     settings.mode = new_mode
--     local divisor = settings[new_mode .. "_divisor"]
--     util.set_cursor_label(player, player_table)
--     if player_table.flags.drawing then
--       tape.update_draw(player, player_table)
--     elseif player_table.flags.editing then
--       tape.edit_settings(e.player_index, player_table, new_mode, divisor)
--     end
--   end
-- end)

-- script.on_event("tl-clear-cursor", function(e)
--   local player_table = global.players[e.player_index]
--   if player_table.flags.drawing or player_table.flags.editing then
--     local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--     player.clear_cursor()
--   end
-- end)

-- script.on_event(defines.events.on_built_entity, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]
--   local entity = e.created_entity
--   local is_ghost = entity.name == "entity-ghost"

--   util.destroy_last_entity(player_table)

--   if is_ghost then
--     -- instantly revive the entity if it is a ghost
--     local _, new_entity = entity.silent_revive()
--     if not new_entity then
--       return
--     end
--     entity = new_entity
--   end
--   -- make the entity invincible to prevent attacks
--   entity.destructible = false
--   player_table.last_entity = entity

--   -- update tape
--   if player_table.flags.drawing then
--     tape.update_draw(player, player_table, entity.position, is_ghost)
--   elseif player_table.flags.editing then
--     tape.move(player, player_table, entity.position, entity.surface)
--   else
--     tape.start_draw(player, player_table, entity.position, entity.surface)
--   end

--   -- update the cursor
--   player.cursor_stack.set_stack({ name = "tl-tool", count = 100 })
--   util.set_cursor_label(player, player_table)
-- end, {
--   { filter = "name", name = "tl-dummy-entity" },
--   { filter = "ghost_name", name = "tl-dummy-entity" },
-- })

-- script.on_event({
--   defines.events.on_player_selected_area,
--   defines.events.on_player_alt_selected_area,
-- }, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]
--   if player_table.flags.drawing then
--     player_table.flags.drawing = false
--     util.destroy_last_entity(player_table)
--     tape.complete_draw(player, player_table, e.name == defines.events.on_player_selected_area)
--     util.set_cursor_label(player, player_table)
--   elseif player_table.flags.editing then
--     util.destroy_last_entity(player_table)
--     tape.complete_move(player_table)
--   end
-- end)

-- script.on_event(defines.events.on_player_created, function(e)
--   util.init_player(e.player_index)
-- end)

-- script.on_event(defines.events.on_player_removed, function(e)
--   global.players[e.player_index] = nil
-- end)

-- script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]
--   if not player_table then
--     return
--   end
--   local cursor_stack = player.cursor_stack
--   local is_empty = not cursor_stack or not cursor_stack.valid_for_read
--   if player_table.flags.holding_tool then
--     if is_empty or cursor_stack.name ~= "tl-tool" then --- @diagnostic disable-line
--       player_table.flags.holding_tool = false
--       util.destroy_last_entity(player_table)
--       if player_table.flags.editing then
--         tape.exit_edit_mode(player_table)
--         player.cursor_stack.set_stack({ name = "tl-tool", count = 100 })
--         util.set_cursor_label(player, player_table)
--       else
--         if player_table.flags.drawing then
--           tape.cancel_draw(player_table)
--         end
--         if player.controller_type == defines.controllers.character and player_table.flags.increased_build_distance then
--           player_table.flags.increased_build_distance = false
--           local build_distance = player.character_build_distance_bonus
--           if build_distance >= 1000000 then
--             -- decrease build distance
--             player.character_build_distance_bonus = build_distance - 1000000 --[[@as uint]]
--           end
--         end
--       end
--     end
--   elseif util.holding_tl_tool(player) then
--     player_table.flags.holding_tool = true
--     player.cursor_stack.set_stack({ name = "tl-tool", count = 100 })
--     util.set_cursor_label(player, player_table)
--     if player.controller_type == defines.controllers.character and not player_table.flags.increased_build_distance then
--       -- increase build distance
--       player_table.flags.increased_build_distance = true
--       player.character_build_distance_bonus = player.character_build_distance_bonus + 1000000 --[[@as uint]]
--     end
--   end
-- end)

-- -- FIXME: Cancel draw when any controller change occurs (requires API addition)
-- script.on_event(defines.events.on_pre_player_toggled_map_editor, function(e)
--   local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
--   local player_table = global.players[e.player_index]
--   if not player_table then
--     return
--   end
--   if player_table.flags.increased_build_distance then
--     player_table.flags.increased_build_distance = false
--     local build_distance = player.character_build_distance_bonus
--     if build_distance >= 1000000 then
--       -- decrease build distance
--       player.character_build_distance_bonus = build_distance - 1000000 --[[@as uint]]
--     end
--   end
-- end)

-- script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
--   -- FIXME:
--   -- if string.find(e.setting, "^tl-") then
--   --   local player_table = global.players[e.player_index]
--   --   for _, tape_data in ipairs(player_table.tapes) do
--   --     tape.update_visual_settings(tape_data)
--   --   end
--   -- end
-- end)
