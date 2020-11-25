local area = require("lib.area")
local table = require("__flib__.table")

local destroy = rendering.destroy
local draw_rectangle = rendering.draw_rectangle
local draw_text = rendering.draw_text
local set_left_top = rendering.set_left_top
local set_right_bottom = rendering.set_right_bottom
local set_target = rendering.set_target
local set_text = rendering.set_text
local set_time_to_live = rendering.set_time_to_live
local set_visible = rendering.set_visible

local tape = {}

local opposite_corners = {
  left_top = "right_bottom",
  left_bottom = "right_top",
  right_top = "left_bottom",
  right_bottom = "left_top"
}

local function apply_to_all_objects(objects, func, ...)
  for _, v in pairs(objects) do
    if type(v) == "table" then
      apply_to_all_objects(v, func, ...)
    else
      func(v, ...)
    end
  end
end

local function create_objects(player_index, tape_data, tape_settings, visual_settings)
  local TapeArea = tape_data.Area
  return {
    background = draw_rectangle{
      color = visual_settings.tape_background_color,
      filled = true,
      left_top = TapeArea.left_top,
      right_bottom = TapeArea.right_bottom,
      surface = tape_data.surface,
      players = {player_index},
      draw_on_ground = true
    },
    border = draw_rectangle{
      color = visual_settings.tape_border_color,
      width = 1.5,
      filled = false,
      left_top = TapeArea.left_top,
      right_bottom = TapeArea.right_bottom,
      surface = tape_data.surface,
      players = {player_index},
      draw_on_ground = true
    },
    labels = {
      x = draw_text{
        text = tostring(TapeArea.width),
        surface = tape_data.surface,
        target = {x = TapeArea:center().x, y = TapeArea.left_top.y - 0.85},
        color = visual_settings.tape_label_color,
        scale = 1.5,
        alignment = "center",
        visible = false,
        players = {player_index}
      },
      y = draw_text{
        text = tostring(TapeArea.width),
        surface = tape_data.surface,
        target = {x = TapeArea.left_top.x - 0.85, y = TapeArea:center().y},
        color = visual_settings.tape_label_color,
        scale = 1.5,
        orientation = 0.75,
        alignment = "center",
        visible = false,
        players = {player_index}
      }
    },
    temp_settings_label = draw_text{
      text = tape_settings.mode.." mode | Divisor: "..tape_settings[tape_settings.mode.."_divisor"],
      surface = tape_data.surface,
      target = TapeArea.origin,
      color = {r = 1, g = 1, b = 1},
      scale = 1,
      alignment = "left",
      players = {player_index}
    }
  }
end

local function update_objects(tape_data, tape_settings, visual_settings)
  local TapeArea = tape_data.Area
  local objects = tape_data.objects

  local background = objects.background
  set_left_top(background, TapeArea.left_top)
  set_right_bottom(background, TapeArea.right_bottom)

  local border = objects.border
  set_left_top(border, TapeArea.left_top)
  set_right_bottom(border, TapeArea.right_bottom)

  local x_label = objects.labels.x
  set_text(x_label, tostring(TapeArea:width()))
  set_target(x_label, {x = TapeArea:center().x, y = TapeArea.left_top.y - 0.85})
  if TapeArea:width() > 1 then
    set_visible(x_label, true)
  else
    set_visible(x_label, false)
  end

  local y_label = objects.labels.y
  set_text(y_label, tostring(TapeArea:height()))
  set_target(y_label, {x = TapeArea.left_top.x - 0.85, y = TapeArea:center().y})
  if TapeArea:height() > 1 then
    set_visible(y_label, true)
  else
    set_visible(y_label, false)
  end

  set_text(
    objects.temp_settings_label,
    tape_settings.mode.." mode | Divisor: "..tape_settings[tape_settings.mode.."_divisor"]
  )
end

function tape.start_draw(player, player_table, origin, surface)
  local TapeArea = area.load(area.from_position(origin)):ceil()
  TapeArea.origin = origin
  local tape_data = {
    Area = TapeArea,
    last_position = origin,
    origin_corner = "left_top",
    surface = surface
  }
  tape_data.objects = create_objects(player.index, tape_data, player_table.tape_settings, player_table.visual_settings)
  player_table.tapes.drawing = tape_data
  player_table.flags.drawing = true
end

function tape.update_draw(player, player_table, new_position)
  local tape_data = player_table.tapes.drawing
  local TapeArea = area.load(tape_data.Area)
  local origin = TapeArea.origin

  if new_position then
    if not player_table.flags.shift_placed_entity then
      if math.abs(new_position.x - origin.x) >= math.abs(new_position.y - origin.y) then
        new_position.y = math.floor(origin.y)
      else
        new_position.x = math.floor(origin.x)
      end

      -- if the new position is the same as the last, don't actually do anything
      local last_position = tape_data.last_position
      if new_position.x == last_position.x and new_position.y == last_position.y then
        return
      end
    end
    tape_data.last_position = new_position
  else
    new_position = tape_data.last_position
  end

  -- update area corners
  local x_less = new_position.x < origin.x
  local y_less = new_position.y < origin.y
  TapeArea.left_top = {
    x = math.floor(x_less and new_position.x or origin.x),
    y = math.floor(y_less and new_position.y or origin.y)
  }
  TapeArea.right_bottom = {
    x = math.ceil(x_less and origin.x or new_position.x),
    y = math.ceil(y_less and origin.y or new_position.y)
  }

  update_objects(tape_data, player_table.tape_settings, player_table.visual_settings)
end

function tape.complete_draw(player_table, auto_clear)
  local tapes = player_table.tapes
  local tape_data = tapes.drawing
  local TapeArea = tape_data.Area
  local objects = tape_data.objects

  player_table.flags.drawing = false

  -- immediately destroy the tape if it is 1x1
  if TapeArea:height() == 1 and TapeArea:width() == 1 then
    apply_to_all_objects(objects, destroy)
    tapes.drawing = nil
    return
  end

  if auto_clear then
    apply_to_all_objects(objects, set_time_to_live, player_table.visual_settings.tape_clear_delay * 60)
  else
    -- copy settings into tape so they can be changed later
    tape_data.settings = table.deep_copy(player_table.tape_settings)
    tapes[#tapes+1] = tape_data
  end
  tapes.drawing = nil
end

function tape.delete(player_table, tape_index)
  local tapes = player_table.tapes
  local tape_data = tapes[tape_index]
  apply_to_all_objects(tape_data.objects, destroy)
  if player_table.flags.editing then
    tape.exit_edit_mode(player_table)
  end
  table.remove(tapes, tape_index)
end

function tape.enter_edit_mode(player, player_table, tape_index)
  local tape_data = player_table.tapes[tape_index]
  local TapeArea = area.load(tape_data.Area)

  local surface = tape_data.surface
  tape_data.highlight_box = surface.create_entity{
    name = "tl-highlight-box",
    position = TapeArea:center(),
    bounding_box = area.expand(TapeArea:strip(), 0.3),
    cursor_box_type = "electricity",
    render_player_index = player.index,
    blink_interval = 30
  }

  player_table.flags.editing = true
  player_table.tapes.editing = tape_data
end

function tape.exit_edit_mode(player_table)
  local tape_data = player_table.tapes.editing
  tape_data.highlight_box.destroy()
  player_table.flags.editing = false
  player_table.tapes.editing = nil
end

function tape.edit_settings(player_table, mode, divisor)
  local tape_data = player_table.tapes.editing
  tape_data.settings.mode = mode
  tape_data.settings[mode.."_divisor"] = divisor

  update_objects(tape_data, tape_data.settings, player_table.visual_settings)
end

function tape.move(player, player_table, new_position, surface)
  local tape_data = player_table.tapes.editing
  local TapeArea = area.load(tape_data.Area)
end

return tape