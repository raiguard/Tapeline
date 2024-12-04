--- @class Tape
--- @field anchor MapPosition
--- @field box BoundingBox
--- @field cursor MapPosition
--- @field entity LuaEntity
--- @field editing boolean
--- @field editing_box LuaEntity?
--- @field move_drag_anchor MapPosition?
--- @field tick_to_die MapTick
--- @field settings TapeSettings
--- @field id integer
--- @field player LuaPlayer
--- @field surface LuaSurface
--- @field background LuaRenderObject
--- @field border LuaRenderObject
--- @field label_north LuaRenderObject
--- @field label_west LuaRenderObject
--- @field lines LuaRenderObject[]

local flib_bounding_box = require("__flib__.bounding-box")
local flib_position = require("__flib__.position")

--- @param player LuaPlayer
--- @param entity LuaEntity
--- @return Tape
local function new_tape(player, entity)
  local id = storage.next_tape_id
  storage.next_tape_id = id + 1
  local box = flib_bounding_box.from_position(entity.position, true)
  local center = flib_bounding_box.center(box)
  local width = flib_bounding_box.width(box)
  local height = flib_bounding_box.height(box)

  --- @type Tape
  local self = {
    anchor = entity.position,
    box = box,
    cursor = entity.position,
    editing = false,
    entity = entity,
    id = id,
    player = player,
    tick_to_die = math.huge,
    settings = storage.player_settings[player.index],
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
      text = tostring(width),
      surface = entity.surface,
      target = { x = center.x, y = box.left_top.y },
      color = player.mod_settings["tl-tape-label-color"].value --[[@as Color]],
      scale = 2,
      alignment = "center",
      vertical_alignment = "bottom",
      visible = width > 1,
    }),
    label_west = rendering.draw_text({
      text = tostring(height),
      surface = entity.surface,
      target = { x = box.left_top.x, y = center.y },
      color = player.mod_settings["tl-tape-label-color"].value --[[@as Color]],
      scale = 2,
      alignment = "center",
      vertical_alignment = "bottom",
      orientation = 0.75,
      visible = height > 1,
    }),
    lines = {},
  }
  storage.tapes[id] = self
  return self
end

--- @param self Tape
local function update_tape(self)
  local box = self.box
  local draw_on_ground = self.player.mod_settings["tl-draw-tape-on-ground"].value --[[@as boolean]]
  self.background.left_top = box.left_top
  self.background.right_bottom = box.right_bottom
  self.background.draw_on_ground = draw_on_ground
  self.border.left_top = box.left_top
  self.border.right_bottom = box.right_bottom
  self.border.draw_on_ground = draw_on_ground
  local center = flib_bounding_box.center(box)
  self.label_north.target = { x = center.x, y = box.left_top.y }
  local width = flib_bounding_box.width(box)
  self.label_north.text = tostring(width)
  self.label_north.visible = width > 1
  local height = flib_bounding_box.height(box)
  self.label_west.target = { x = box.left_top.x, y = center.y }
  self.label_west.text = height
  self.label_west.visible = height > 1

  local lines = self.lines
  local width = self.player.mod_settings["tl-tape-line-width"].value --[[@as double]]
  local i = 0

  local function draw_lines(color, step)
    local from_x = self.anchor.x <= center.x and box.left_top.x or box.right_bottom.x
    local from_y = self.anchor.y <= center.y and box.left_top.y or box.right_bottom.y
    local to_x = self.anchor.x > center.x and box.left_top.x or box.right_bottom.x
    local to_y = self.anchor.y > center.y and box.left_top.y or box.right_bottom.y

    local step_x = from_x <= to_x and step or -step
    for x = from_x + step_x, to_x, step_x do
      i = i + 1
      local line = lines[i]
      if line then
        line.from = { x = x, y = from_y }
        line.to = { x = x, y = to_y }
        line.color = color
        line.visible = true
        line.draw_on_ground = draw_on_ground
      else
        line = rendering.draw_line({
          color = color,
          width = width,
          from = { x = x, y = from_y },
          to = { x = x, y = to_y },
          surface = self.surface,
          players = { self.player },
          draw_on_ground = draw_on_ground,
        })
        lines[i] = line
      end
    end

    local step_y = from_y <= to_y and step or -step
    for y = from_y + step_y, to_y, step_y do
      i = i + 1
      local line = lines[i]
      if line then
        line.from = { x = from_x, y = y }
        line.to = { x = to_x, y = y }
        line.color = color
        line.visible = true
        line.draw_on_ground = draw_on_ground
      else
        line = rendering.draw_line({
          color = color,
          width = width,
          from = { x = from_x, y = y },
          to = { x = to_x, y = y },
          surface = self.surface,
          players = { self.player },
          draw_on_ground = draw_on_ground,
        })
        lines[i] = line
      end
    end
  end

  draw_lines(self.player.mod_settings["tl-tape-line-color-1"].value --[[@as Color]], 1)

  if self.settings.mode == "subgrid" then
    draw_lines(self.player.mod_settings["tl-tape-line-color-2"].value --[[@as Color]], self.settings.subgrid_size)
    draw_lines(self.player.mod_settings["tl-tape-line-color-3"].value --[[@as Color]], self.settings.subgrid_size ^ 2)
    draw_lines(self.player.mod_settings["tl-tape-line-color-4"].value --[[@as Color]], self.settings.subgrid_size ^ 3)
  else
    -- TODO:
  end

  for i = i + 1, #lines do
    lines[i].visible = false
  end

  self.border.bring_to_front()
  if self.editing_box then
    self.editing_box.destroy()
  end
  if self.editing then
    self.editing_box = self.surface.create_entity({
      name = "tl-highlight-box",
      position = flib_bounding_box.center(self.box),
      bounding_box = flib_bounding_box.resize(self.box, 0.3),
      cursor_box_type = "electricity",
      render_player_index = self.player.index,
      blink_interval = 30,
    })
  end
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
  if entity.type ~= "entity-ghost" then
    local delta = flib_position.abs(flib_position.sub(self.anchor, position))
    if delta.x > delta.y then
      position.y = self.anchor.y
    else
      position.x = self.anchor.x
    end
  end
  local box = flib_bounding_box.from_position(self.anchor, true)
  box = flib_bounding_box.expand_to_contain_position(box, position)
  box = flib_bounding_box.ceil(box)
  self.box = box
  self.cursor = position
  update_tape(self)
end

--- @param self Tape
--- @param entity LuaEntity
local function move_tape(self, entity)
  local old = self.entity
  if old and old.valid then
    old.destroy()
  end
  self.entity = entity
  if not flib_bounding_box.contains_position(self.box, entity.position) then
    return
  end
  if not self.move_drag_anchor then
    self.move_drag_anchor = entity.position
    return
  end
  local delta = flib_position.sub(entity.position, self.move_drag_anchor --[[@as MapPosition]])
  self.anchor = flib_position.add(self.anchor, delta)
  self.box = flib_bounding_box.move(self.box, delta)
  self.move_drag_anchor = entity.position
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
  local editing = storage.editing[e.player_index]
  if editing then
    move_tape(editing, entity)
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

--- @param e EventData.CustomInputEvent
local function on_edit_tape(e)
  if storage.editing[e.player_index] then
    return
  end
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  -- TODO: Consistent order
  --- @type Tape?
  local tape
  for _, stored_tape in pairs(storage.tapes) do
    if stored_tape.player == player and flib_bounding_box.contains_position(stored_tape.box, e.cursor_position) then
      tape = stored_tape
      break
    end
  end
  if not tape then
    return
  end
  storage.editing[e.player_index] = tape
  storage.tapes[tape.id] = nil
  tape.editing = true
  update_tape(tape)
end

local tape = {}

function tape.on_init()
  --- @type table<uint, Tape>
  storage.editing = {}
  --- @type table<uint, Tape>
  storage.drawing = {}
  storage.next_tape_id = 1
  --- @type table<uint, Tape>
  storage.tapes = {}
end

tape.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_tick] = on_tick,
  ["tl-edit-tape"] = on_edit_tape,
}

return tape
