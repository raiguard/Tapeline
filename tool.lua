local bounding_box = require("__flib__/bounding-box")

local tool = {}

function tool.init()
  --- @type table<uint, boolean>
  global.holding_tool = {}
end

--- @param player LuaPlayer
--- @return LuaItemStack?
function tool.get(player)
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "tl-tool" then
    return cursor_stack
  end
end

--- @param player LuaPlayer
--- @param tape Tape?
function tool.set(player, tape)
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

--- @param e on_player_cursor_stack_changed
function tool.on_player_cursor_stack_changed(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  local player_tool = tool.get(player)
  if player_tool and not global.holding_tool[player.index] then
    global.holding_tool[player.index] = true
    tool.set(player)
  elseif not player_tool and global.holding_tool[player.index] then
    global.holding_tool[player.index] = nil
    -- FIXME: Handle player controller changes
    if player.controller_type == defines.controllers.character and player.character_build_distance_bonus >= 1000000 then
      player.character_build_distance_bonus = player.character_build_distance_bonus - 1000000
    end
  end
end

return tool
