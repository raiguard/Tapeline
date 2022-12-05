local bounding_box = require("__flib__/bounding-box")

local util = {}

--- @param player LuaPlayer
--- @return LuaItemStack?
function util.get_cursor_tool(player)
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" then
    return cursor_stack
  end
end

--- @param player LuaPlayer
--- @param tape Tape?
function util.set_cursor_tool(player, tape)
  local cursor_stack = player.cursor_stack
  if cursor_stack then
    if not cursor_stack.valid_for_read or cursor_stack.name == "tl-tool" or player.clear_cursor() then
      cursor_stack.set_stack({ name = "tl-tool", count = 10 })
      if tape then
        cursor_stack.label = bounding_box.width(tape.box) .. "x" .. bounding_box.height(tape.box)
      else
        cursor_stack.label = " "
      end
    end
    if player.controller_type == defines.controllers.character and player.character_build_distance_bonus < 1000000 then
      player.character_build_distance_bonus = player.character_build_distance_bonus + 1000000
    end
  end
end

--- @enum PlayerState
util.player_state = {
  holding = 1,
  drawing = 2,
  editing = 3,
}

return util
