--- @class Tape
--- @field anchor MapPosition
--- @field box BoundingBox
--- @field cursor MapPosition
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
local flib_table = require("__flib__.table")

local tool = require("scripts.tool")

--- @param player LuaPlayer
--- @param position MapPosition
local function get_tape_at_position(player, position)
  --- @type Tape?
  local result
  for _, stored_tape in pairs(storage.tapes) do
    if
      stored_tape.player == player
      and stored_tape.surface == player.surface
      and flib_bounding_box.contains_position(stored_tape.box, position)
      and (not result or result.id < stored_tape.id)
    then
      result = stored_tape
    end
  end
  return result
end

--- @param player LuaPlayer
--- @param position MapPosition
--- @param surface LuaSurface
--- @return Tape
local function new_tape(player, position, surface)
  local id = storage.next_tape_id
  storage.next_tape_id = id + 1
  local box = flib_bounding_box.from_position(position, true)
  local center = flib_bounding_box.center(box)
  local width = flib_bounding_box.width(box)
  local height = flib_bounding_box.height(box)

  --- @type Tape
  local self = {
    anchor = position,
    box = box,
    cursor = position,
    editing = false,
    id = id,
    player = player,
    tick_to_die = math.huge,
    settings = flib_table.deep_copy(storage.player_settings[player.index]),
    surface = surface,
    background = rendering.draw_rectangle({
      color = player.mod_settings["tl-tape-background-color"].value --[[@as Color]],
      filled = true,
      players = { player },
      surface = surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
    border = rendering.draw_rectangle({
      color = player.mod_settings["tl-tape-border-color"].value --[[@as Color]],
      filled = false,
      width = player.mod_settings["tl-tape-line-width"].value --[[@as double]],
      players = { player },
      surface = surface,
      left_top = box.left_top,
      right_bottom = box.right_bottom,
    }),
    label_north = rendering.draw_text({
      text = tostring(width),
      surface = surface,
      target = { x = center.x, y = box.left_top.y },
      color = player.mod_settings["tl-tape-label-color"].value --[[@as Color]],
      scale = 2,
      alignment = "center",
      vertical_alignment = "bottom",
      visible = width > 1,
    }),
    label_west = rendering.draw_text({
      text = tostring(height),
      surface = surface,
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
  tool.set(self.player)
  return self
end

--- @param self Tape
local function update_tape(self)
  local line_width = self.player.mod_settings["tl-tape-line-width"].value --[[@as double]]

  local box = self.box
  local draw_on_ground = self.player.mod_settings["tl-draw-tape-on-ground"].value --[[@as boolean]]
  self.background.color = self.player.mod_settings["tl-tape-background-color"].value --[[@as Color]]
  self.background.left_top = box.left_top
  self.background.right_bottom = box.right_bottom
  self.background.draw_on_ground = draw_on_ground
  self.border.color = self.player.mod_settings["tl-tape-border-color"].value --[[@as Color]]
  self.border.left_top = box.left_top
  self.border.right_bottom = box.right_bottom
  self.border.draw_on_ground = draw_on_ground
  self.border.width = line_width
  local center = flib_bounding_box.center(box)
  self.label_north.color = self.player.mod_settings["tl-tape-label-color"].value --[[@as Color]]
  self.label_north.target = { x = center.x, y = box.left_top.y }
  local width = flib_bounding_box.width(box)
  self.label_north.text = tostring(width)
  self.label_north.visible = width > 1
  local height = flib_bounding_box.height(box)
  self.label_west.color = self.player.mod_settings["tl-tape-label-color"].value --[[@as Color]]
  self.label_west.target = { x = box.left_top.x, y = center.y }
  self.label_west.text = height
  self.label_west.visible = height > 1

  local lines = self.lines
  local i = 0

  --- @param color Color
  --- @param step_x integer
  --- @param step_y integer?
  local function draw_lines(color, step_x, step_y)
    step_y = step_y or step_x
    local from_x = self.anchor.x <= center.x and box.left_top.x or box.right_bottom.x
    local from_y = self.anchor.y <= center.y and box.left_top.y or box.right_bottom.y
    local to_x = self.anchor.x > center.x and box.left_top.x or box.right_bottom.x
    local to_y = self.anchor.y > center.y and box.left_top.y or box.right_bottom.y

    if flib_bounding_box.width(self.box) > 1 then
      local step_x = from_x <= to_x and step_x or -step_x
      for x = from_x + step_x, to_x, step_x do
        i = i + 1
        local line = lines[i]
        if line then
          line.color = color
          line.width = line_width
          line.from = { x = x, y = from_y }
          line.to = { x = x, y = to_y }
          line.visible = true
          line.draw_on_ground = draw_on_ground
        else
          line = rendering.draw_line({
            color = color,
            width = line_width,
            from = { x = x, y = from_y },
            to = { x = x, y = to_y },
            surface = self.surface,
            players = { self.player },
            draw_on_ground = draw_on_ground,
          })
          lines[i] = line
        end
      end
    end

    if flib_bounding_box.height(self.box) > 1 then
      local step_y = from_y <= to_y and step_y or -step_y
      for y = from_y + step_y, to_y, step_y do
        i = i + 1
        local line = lines[i]
        if line then
          line.color = color
          line.width = line_width
          line.from = { x = from_x, y = y }
          line.to = { x = to_x, y = y }
          line.visible = true
          line.draw_on_ground = draw_on_ground
        else
          line = rendering.draw_line({
            color = color,
            width = line_width,
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
  end

  draw_lines(self.player.mod_settings["tl-tape-line-color-1"].value --[[@as Color]], 1)

  if self.settings.mode == "subgrid" then
    draw_lines(self.player.mod_settings["tl-tape-line-color-2"].value --[[@as Color]], self.settings.subgrid_size)
    draw_lines(self.player.mod_settings["tl-tape-line-color-3"].value --[[@as Color]], self.settings.subgrid_size ^ 2)
    draw_lines(self.player.mod_settings["tl-tape-line-color-4"].value --[[@as Color]], self.settings.subgrid_size ^ 3)
  else
    draw_lines(
      self.player.mod_settings["tl-tape-line-color-2"].value --[[@as Color]],
      flib_bounding_box.width(self.box) / self.settings.splits,
      flib_bounding_box.height(self.box) / self.settings.splits
    )
    draw_lines(
      self.player.mod_settings["tl-tape-line-color-3"].value --[[@as Color]],
      flib_bounding_box.width(self.box) / 2,
      flib_bounding_box.height(self.box) / 2
    )
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

  tool.set(self.player, self)
end

--- @param self Tape
--- @param position MapPosition
--- @param constrained boolean
local function resize_tape(self, position, constrained)
  if constrained then
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
--- @param position MapPosition
local function move_tape(self, position)
  if not self.move_drag_anchor then
    if flib_bounding_box.contains_position(self.box, position) then
      self.move_drag_anchor = position
    end
    return
  end
  local delta = flib_position.sub(position, self.move_drag_anchor --[[@as MapPosition]])
  self.anchor = flib_position.add(self.anchor, delta)
  self.box = flib_bounding_box.move(self.box, delta)
  self.move_drag_anchor = position
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

  if self.editing_box and self.editing_box.valid then
    self.editing_box.destroy()
  end

  if self.editing then
    storage.editing[self.player.index] = nil
  else
    storage.tapes[self.id] = nil
  end

  tool.set(self.player)
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
  local is_ghost = entity.name == "entity-ghost"
  local position, surface = entity.position, entity.surface
  entity.destroy()
  local last_position = storage.last_position[e.player_index]
  if last_position and flib_position.eq(position, last_position.position) and surface == last_position.surface then
    return
  end
  storage.last_position[e.player_index] = { position = position, surface = surface }

  local should_cancel = last_position and surface ~= last_position.surface

  local editing = storage.editing[e.player_index]
  if editing then
    if should_cancel then
      destroy_tape(editing)
      return
    end
    move_tape(editing, position)
    return
  end
  local drawing = storage.drawing[e.player_index]
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]
  if drawing then
    if should_cancel then
      destroy_tape(drawing)
      storage.drawing[e.player_index] = nil
      return
    end
    resize_tape(drawing, position, not is_ghost)
  else
    drawing = new_tape(player, position, surface)
    storage.drawing[e.player_index] = drawing
  end
end

--- @param e EventData.on_player_selected_area|EventData.on_player_alt_selected_area
local function on_player_selected_area(e)
  local editing_tape = storage.editing[e.player_index]
  if editing_tape then
    editing_tape.move_drag_anchor = nil
    return
  end
  local drawing_tape = storage.drawing[e.player_index]
  if not drawing_tape then
    return
  end
  storage.drawing[e.player_index] = nil
  if e.name == defines.events.on_player_selected_area then
    local time_to_live = drawing_tape.player.mod_settings["tl-tape-clear-delay"].value --[[@as double]]
    drawing_tape.tick_to_die = game.tick + time_to_live * 60
  end
  storage.tapes[drawing_tape.id] = drawing_tape
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
  local tape = get_tape_at_position(player, e.cursor_position)
  if not tape then
    return
  end
  tape.editing = true
  storage.editing[e.player_index] = tape
  storage.tapes[tape.id] = nil
  update_tape(tape)
end

--- @param e EventData.CustomInputEvent
local function on_delete_tape(e)
  local player = game.get_player(e.player_index) --[[@as LuaPlayer]]

  local editing = storage.editing[e.player_index]
  if editing and flib_bounding_box.contains_position(editing.box, e.cursor_position) then
    destroy_tape(editing)
    return
  end

  local tape = get_tape_at_position(player, e.cursor_position)
  if tape then
    destroy_tape(tape)
  end
end

--- @param e EventData.CustomInputEvent
local function on_clear_cursor(e)
  local tape = storage.editing[e.player_index]
  if not tape then
    return
  end
  tape.editing = false
  storage.editing[e.player_index] = nil
  storage.tapes[tape.id] = tape
  update_tape(tape)
end

--- @param e EventData.CustomInputEvent
local function on_change_mode(e)
  local tape = storage.editing[e.player_index]
  if tape then
    tape.settings.mode = tape.settings.mode == "subgrid" and "split" or "subgrid"
    update_tape(tape)
    return
  end
  local settings = storage.player_settings[e.player_index]
  settings.mode = settings.mode == "subgrid" and "split" or "subgrid"
  local player = game.get_player(e.player_index)
  --- @cast player -?
  tool.set(player)
end

--- @param e EventData.CustomInputEvent
local function on_change_divisor(e)
  local delta = e.input_name == "tl-increase-divisor" and 1 or -1
  local tape = storage.editing[e.player_index]
  local settings = tape and tape.settings or storage.player_settings[e.player_index]
  if not settings then
    return
  end
  if settings.mode == "subgrid" then
    settings.subgrid_size = math.max(0, settings.subgrid_size + delta)
  else
    settings.splits = math.max(2, settings.splits + delta)
  end
  if tape then
    update_tape(tape)
  else
    local player = game.get_player(e.player_index)
    --- @cast player -?
    tool.set(player)
  end
end

--- @param e EventData.on_runtime_mod_setting_changed
local function on_runtime_mod_setting_changed(e)
  if not string.find(e.setting, "^tl%-") then
    return
  end
  local editing = storage.editing[e.player_index]
  if editing then
    update_tape(editing)
  end
  local drawing = storage.drawing[e.player_index]
  if drawing then
    update_tape(drawing)
  end
  for _, tape in pairs(storage.tapes) do
    if tape.player.index == e.player_index then
      update_tape(tape)
    end
  end
end

local tape = {}

function tape.on_init()
  --- @type table<uint, Tape>
  storage.editing = {}
  --- @type table<uint, Tape>
  storage.drawing = {}
  --- @type table<uint, {position: MapPosition, surface: LuaSurface}>
  storage.last_position = {}
  storage.next_tape_id = 1
  --- @type table<uint, Tape>
  storage.tapes = {}
end

tape.events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_player_alt_selected_area] = on_player_selected_area,
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_tick] = on_tick,
  ["tl-delete-tape"] = on_delete_tape,
  ["tl-edit-tape"] = on_edit_tape,
  ["tl-linked-clear-cursor"] = on_clear_cursor,
  ["tl-next-mode"] = on_change_mode,
  ["tl-previous-mode"] = on_change_mode,
  ["tl-increase-divisor"] = on_change_divisor,
  ["tl-decrease-divisor"] = on_change_divisor,
  [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
}

return tape
