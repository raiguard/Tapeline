local area = require("lib.area")
local table = require("__flib__.table")

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

local function create_objects(player_index, Area, settings)
  return {
    background = draw_rectangle{
      color = settings.tape_background_color,
      filled = true,
      left_top = Area.left_top,
      right_bottom = Area.right_bottom,
      surface = Area.surface,
      players = {player_index},
      draw_on_ground = true
    },
    border = draw_rectangle{
      color = settings.tape_border_color,
      width = 1.5,
      filled = false,
      left_top = Area.left_top,
      right_bottom = Area.right_bottom,
      surface = Area.surface,
      players = {player_index},
      draw_on_ground = true
    },
    labels = {
      x = draw_text{
        text = tostring(Area.width),
        surface = Area.surface,
        target = {x = Area:center().x, y = Area.left_top.y - 0.85},
        color = settings.tape_label_color,
        scale = 1.5,
        alignment = "center",
        visible = false,
        players = {player_index}
      },
      y = draw_text{
        text = tostring(Area.width),
        surface = Area.surface,
        target = {x = Area.left_top.x - 0.85, y = Area:center().y},
        color = settings.tape_label_color,
        scale = 1.5,
        orientation = 0.75,
        alignment = "center",
        visible = false,
        players = {player_index}
      }
    }
  }
end

local function update_objects(tape_data)
  local Area = tape_data.Area
  local objects = tape_data.objects

  local background = objects.background
  set_left_top(background, Area.left_top)
  set_right_bottom(background, Area.right_bottom)

  local border = objects.border
  set_left_top(border, Area.left_top)
  set_right_bottom(border, Area.right_bottom)

  local x_label = objects.labels.x
  set_text(x_label, tostring(Area:width()))
  set_target(x_label, {x = Area:center().x, y = Area.left_top.y - 0.85})
  if Area:width() > 1 then
    set_visible(x_label, true)
  else
    set_visible(x_label, false)
  end

  local y_label = objects.labels.y
  set_text(y_label, tostring(Area:height()))
  set_target(y_label, {x = Area.left_top.x - 0.85, y = Area:center().y})
  if Area:height() > 1 then
    set_visible(y_label, true)
  else
    set_visible(y_label, false)
  end
end

function tape.create(player, player_table, origin, surface)
  local TapeArea = area.new(area.from_position(origin)):ceil()
  TapeArea.surface = surface
  TapeArea.origin = origin
  local tape_data = {
    Area = TapeArea,
    objects = create_objects(player.index, TapeArea, player_table.settings),
    origin_corner = "left_top"
  }
  player_table.tapes.drawing = tape_data
end

function tape.update(player, player_table, new_position)
  local tape_data = player_table.tapes.drawing
  local TapeArea = area.new(tape_data.Area) -- have to re-load the area in case of save/load
  local origin = TapeArea.origin

  if player_table.settings.cardinals_only then
    if math.abs(new_position.x - origin.x) >= math.abs(new_position.y - origin.y) then
      new_position.y = math.floor(origin.y)
    else
      new_position.x = math.floor(origin.x)
    end
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

  update_objects(tape_data)
end

function tape.complete_draw(_, player_table)
  local tape_data = player_table.tapes.drawing
  if player_table.settings.auto_clear then
    local objects = tape_data.objects
    local time_to_live = player_table.settings.tape_clear_delay * 60
    set_time_to_live(objects.background, time_to_live)
    set_time_to_live(objects.border, time_to_live)
    set_time_to_live(objects.labels.x, time_to_live)
    set_time_to_live(objects.labels.y, time_to_live)
    player_table.tapes.drawing = nil
  end
end

return tape