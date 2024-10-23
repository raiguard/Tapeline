local flib_bounding_box = require("__flib__.bounding-box")
local flib_position = require("__flib__.position")

--- @class Tape
--- @field anchor MapPosition
--- @field box BoundingBox
--- @field cursor MapPosition
--- @field entity LuaEntity
--- @field id integer
--- @field player LuaPlayer
--- @field rect LuaRenderObject
--- @field circle LuaRenderObject
--- @field line LuaRenderObject

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return Tape
local function new_tape(player, entity)
  local id = storage.next_tape_id
  storage.next_tape_id = id + 1
  local box = flib_bounding_box.from_position(entity.position, true)
  --- @type Tape
  local self = {
    anchor = entity.position,
    box = box,
    cursor = entity.position,
    entity = entity,
    id = id,
    player = player,
    rect = rendering.draw_rectangle({
      color = { r = 1, g = 1, b = 1 },
      filled = false,
      width = 2,
      players = { player },
      surface = entity.surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
    circle = rendering.draw_circle({
      color = { r = 1, g = 1 },
      filled = false,
      width = 2,
      players = { player },
      surface = entity.surface,
      radius = flib_position.distance(box.left_top, box.right_bottom) - 1,
      target = entity.position,
    }),
    line = rendering.draw_line({
      color = { g = 1 },
      width = 4,
      gap_length = 0.5,
      dash_length = 0.5,
      dash_offset = 0.25,
      players = { player },
      surface = entity.surface,
      radius = flib_position.distance(box.left_top, box.right_bottom) - 1,
      target = entity.position,
      from = entity.position,
      to = entity.position,
    }),
  }
  storage.tapes[id] = self
  return self
end

--- @param self Tape
local function update_tape(self)
  self.rect.left_top = self.box.left_top
  self.rect.right_bottom = self.box.right_bottom
  self.circle.radius = flib_position.distance(self.box.left_top, self.box.right_bottom) - 1
  self.circle.target = self.anchor
  self.line.from = self.anchor
  self.line.to = self.cursor
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
  self.cursor = position
  update_tape(self)
end

--- @param self Tape
local function destroy_tape(self)
  if self.rect.valid then
    self.rect.destroy()
  end
  if self.circle.valid then
    self.circle.destroy()
  end
  if self.line.valid then
    self.line.destroy()
  end
  local entity = self.entity
  if entity and entity.valid then
    entity.destroy()
  end
  storage.tapes[self.id] = nil
end

local function on_init()
  --- @type table<uint, Tape>
  storage.drawing = {}
  storage.next_tape_id = 1
  storage.tapes = {}
end

--- @param e EventData.on_built_entity
local function on_built_entity(e)
  local entity = e.entity
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
  local drawing = storage.drawing[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if drawing then
    resize_tape(drawing, entity)
  else
    drawing = new_tape(player, e.entity)
    storage.drawing[e.player_index] = drawing
  end
end

--- @param e EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_player_selected_area(e)
  local drawing = storage.drawing[e.player_index]
  if not drawing then
    return
  end
  destroy_tape(drawing)
  storage.drawing[e.player_index] = nil
end

local tape = {}

tape.on_init = on_init

tape.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_selected_area] = on_player_selected_area,
}

return tape
