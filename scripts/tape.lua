local flib_bounding_box = require("__flib__/bounding-box")

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return Tape
local function new_tape(player, entity)
  local id = global.next_tape_id
  global.next_tape_id = id + 1
  local box = flib_bounding_box.from_position(entity.position, true)
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
  global.tapes[id] = self
  return self
end

--- @param self Tape
local function update_tape(self)
  rendering.set_left_top(self.render, self.box.left_top)
  rendering.set_right_bottom(self.render, self.box.right_bottom)
end

--- @param self Tape
--- @param entity LuaEntity
local function resize_tape(self, entity)
  local old = self.entity
  if old and old.valid then
    old.destroy()
  end
  self.entity = entity
  local position = entity.position
  local box = flib_bounding_box.from_position(self.anchor, true)
  box = flib_bounding_box.expand_to_contain_position(box, position)
  box = flib_bounding_box.ceil(box)
  self.box = box
  update_tape(self)
end

--- @param self Tape
local function destroy_tape(self)
  rendering.destroy(self.render)
  local entity = self.entity
  if entity and entity.valid then
    entity.destroy()
  end
  global.tapes[self.id] = nil
end

local function on_init()
  --- @type table<uint, Tape>
  global.drawing = {}
  global.next_tape_id = 1
  global.tapes = {}
end

--- @param e EventData.on_built_entity
local function on_built_entity(e)
  local entity = e.created_entity
  if not entity.valid then
    return
  end
  local name = entity.name
  if name == "entity-ghost" then
    name = entity.ghost_name
  end
  if name ~= "tl-dummy-entity" then
    return
  end
  local drawing = global.drawing[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if drawing then
    resize_tape(drawing, entity)
  else
    drawing = new_tape(player, e.created_entity)
    global.drawing[e.player_index] = drawing
  end
end

--- @param e EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_player_selected_area(e)
  local drawing = global.drawing[e.player_index]
  if not drawing then
    return
  end
  destroy_tape(drawing)
  global.drawing[e.player_index] = nil
end

local tape = {}

tape.on_init = on_init

tape.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_selected_area] = on_player_selected_area,
}

return tape
