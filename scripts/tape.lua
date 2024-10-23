local flib_bounding_box = require("__flib__.bounding-box")

--- @class Tape
--- @field anchor MapPosition
--- @field box BoundingBox
--- @field cursor MapPosition
--- @field entity LuaEntity
--- @field tick_to_die MapTick
--- @field id integer
--- @field player LuaPlayer
--- @field surface LuaSurface
--- @field background LuaRenderObject
--- @field border LuaRenderObject
--- @field label_north LuaRenderObject
--- @field label_west LuaRenderObject
--- @field lines LuaRenderObject[]

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return Tape
local function new_tape(player, entity)
  local id = storage.next_tape_id
  storage.next_tape_id = id + 1
  local box = flib_bounding_box.from_position(entity.position, true)
  local center = flib_bounding_box.center(box)
  --- @type Tape
  local self = {
    anchor = entity.position,
    box = box,
    cursor = entity.position,
    entity = entity,
    id = id,
    player = player,
    tick_to_die = math.huge,
    surface = entity.surface,
    background = rendering.draw_rectangle({
      color = player.mod_settings["tl-tape-background-color"].value --[[@as Color]],
      filled = true,
      players = { player },
      surface = entity.surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
    border = rendering.draw_rectangle({
      color = player.mod_settings["tl-tape-border-color"].value --[[@as Color]],
      filled = false,
      width = player.mod_settings["tl-tape-line-width"].value --[[@as double]],
      players = { player },
      surface = entity.surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
    label_north = rendering.draw_text({
      text = flib_bounding_box.width(box),
      surface = entity.surface,
      target = { x = center.x, y = box.left_top.y },
      color = player.mod_settings["tl-tape-label-color"].value --[[@as Color]],
      scale = 2,
      alignment = "center",
      vertical_alignment = "bottom",
    }),
    label_west = rendering.draw_text({
      text = flib_bounding_box.height(box),
      surface = entity.surface,
      target = { x = box.left_top.x, y = center.y },
      color = player.mod_settings["tl-tape-label-color"].value --[[@as Color]],
      scale = 2,
      alignment = "center",
      vertical_alignment = "bottom",
      orientation = 0.75,
    }),
    lines = {},
  }
  storage.tapes[id] = self
  return self
end

--- @param self Tape
local function update_tape(self)
  local box = self.box
  self.background.left_top = box.left_top
  self.background.right_bottom = box.right_bottom
  self.border.left_top = box.left_top
  self.border.right_bottom = box.right_bottom
  local center = flib_bounding_box.center(box)
  self.label_north.target = { x = center.x, y = box.left_top.y }
  self.label_north.text = flib_bounding_box.width(box)
  self.label_west.target = { x = box.left_top.x, y = center.y }
  self.label_west.text = flib_bounding_box.height(box)

  local lines = self.lines
  local color = self.player.mod_settings["tl-tape-line-color-1"].value --[[@as Color]]
  local width = self.player.mod_settings["tl-tape-line-width"].value --[[@as double]]
  local i = 0
  for x = box.left_top.x + 1, box.right_bottom.x - 1 do
    i = i + 1
    local line = lines[i]
    if line then
      line.from = { x = x, y = box.left_top.y }
      line.to = { x = x, y = box.right_bottom.y }
    else
      line = rendering.draw_line({
        color = color,
        width = width,
        from = { x = x, y = box.left_top.y },
        to = { x = x, y = box.right_bottom.y },
        surface = self.surface,
        players = { self.player },
      })
      lines[i] = line
    end
  end
  for y = box.left_top.y + 1, box.right_bottom.y - 1 do
    i = i + 1
    local line = lines[i]
    if line then
      line.from = { x = box.left_top.x, y = y }
      line.to = { x = box.right_bottom.x, y = y }
    else
      line = rendering.draw_line({
        color = color,
        width = width,
        from = { x = box.left_top.x, y = y },
        to = { x = box.right_bottom.x, y = y },
        surface = self.surface,
        players = { self.player },
      })
      lines[i] = line
    end
  end
  for i = i + 1, #lines do
    lines[i].destroy()
    lines[i] = nil
  end

  self.border.bring_to_front()
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
  if self.background.valid then
    self.background.destroy()
  end
  if self.border.valid then
    self.border.destroy()
  end
  if self.label_north.valid then
    self.label_north.destroy()
  end
  if self.label_west.valid then
    self.label_west.destroy()
  end
  for _, line in pairs(self.lines) do
    if line.valid then
      line.destroy()
    end
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
  --- @type table<uint, Tape>
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
  local tape_data = storage.drawing[e.player_index]
  if not tape_data then
    return
  end
  storage.drawing[e.player_index] = nil
  if e.name == defines.events.on_player_selected_area then
    local time_to_live = tape_data.player.mod_settings["tl-tape-clear-delay"].value --[[@as double]]
    tape_data.tick_to_die = game.tick + time_to_live * 60
  end
  storage.tapes[tape_data.id] = tape_data
end

--- @param e EventData.on_tick
local function on_tick(e)
  for _, tape_data in pairs(storage.tapes or {}) do
    if tape_data.tick_to_die > e.tick then
      goto continue
    end

    destroy_tape(tape_data)

    ::continue::
  end
end

local tape = {}

tape.on_init = on_init

tape.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_tick] = on_tick,
}

return tape
