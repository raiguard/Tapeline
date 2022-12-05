local tape = require("__Tapeline__/tape")
local tool = require("__Tapeline__/tool")

script.on_init(function()
  --- @type table<uint, Tape>
  global.drawing = {}

  tape.init()
  tool.init()
end)

script.on_event(defines.events.on_player_cursor_stack_changed, tool.on_player_cursor_stack_changed)

script.on_event(defines.events.on_built_entity, function(e)
  local drawing = global.drawing[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if drawing then
    tape.resize(drawing, e.created_entity)
  else
    drawing = tape.new(player, e.created_entity)
    global.drawing[e.player_index] = drawing
  end
  tool.set(player, drawing)
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
  tool.set(game.get_player(e.player_index) --[[@as LuaPlayer]])
  global.drawing[e.player_index] = nil
end)
