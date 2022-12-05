local bounding_box = require("__flib__/bounding-box")
local util = require("__Tapeline__/util")

local tape = {}

function tape.init()
  global.next_tape_id = 1
  global.tapes = {}
end

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return Tape
function tape.new(player, entity)
  local id = global.next_tape_id
  global.next_tape_id = id + 1
  local box = bounding_box.from_position(entity.position, true)
  --- @class Tape
  local self = {
    anchor = entity.position,
    box = box,
    entity = entity,
    id = id,
    player = player,
    --- @type uint64?
    render = rendering.draw_rectangle({
      color = { r = 1, g = 1, b = 1 },
      filled = false,
      width = 1.3,
      players = { player },
      surface = entity.surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
  }
  global.tapes[id] = tape
  util.set_cursor_tool(self.player, self)
  return self
end

--- @param self Tape
--- @param entity LuaEntity
function tape.update(self, entity)
  local old = self.entity
  if old and old.valid then
    old.destroy()
  end
  self.entity = entity
  -- TODO: Optimize this
  self.box = bounding_box.ceil(
    bounding_box.expand_to_contain_position(bounding_box.from_position(self.anchor, true), entity.position)
  )
  rendering.set_left_top(self.render, self.box.left_top)
  rendering.set_right_bottom(self.render, self.box.right_bottom)
  util.set_cursor_tool(self.player, self)
end

function tape.destroy(self)
  rendering.destroy(self.render)
  local entity = self.entity
  if entity and entity.valid then
    entity.destroy()
  end
  global.tapes[self.id] = nil
end

return tape
