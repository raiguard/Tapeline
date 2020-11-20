local area = require("lib.area")
local table = require("__flib__.table")

local draw_rectangle = rendering.draw_rectangle
local set_time_to_live = rendering.set_time_to_live
local set_left_top = rendering.set_left_top
local set_right_bottom = rendering.set_right_bottom

local tape = {}

local opposite_corners = {
  left_top = "right_bottom",
  left_bottom = "right_top",
  right_top = "left_bottom",
  right_bottom = "left_top"
}

local function create_objects(player_index, Area)
  return {
    border = draw_rectangle{
      color = {r = 0.8, g = 0.8, b = 0.8},
      width = 1.5,
      filled = false,
      left_top = Area.left_top,
      right_bottom = Area.right_bottom,
      surface = Area.surface,
      players = {player_index},
      draw_on_ground = true
    },
    background = draw_rectangle{
      color = {a = 0.75},
      filled = true,
      left_top = Area.left_top,
      right_bottom = Area.right_bottom,
      surface = Area.surface,
      players = {player_index},
      draw_on_ground = true
    }
  }
end

local function update_objects(tape_data)
  local background = tape_data.objects.background
  set_left_top(background, tape_data.Area.left_top)
  set_right_bottom(background, tape_data.Area.right_bottom)

  local border = tape_data.objects.border
  set_left_top(border, tape_data.Area.left_top)
  set_right_bottom(border, tape_data.Area.right_bottom)
end

function tape.create(player, player_table, origin, surface)
  local TapeArea = area.new(area.from_position(origin)):ceil()
  TapeArea.surface = surface
  TapeArea.origin = origin
  local tape_data = {
    Area = TapeArea,
    objects = create_objects(player.index, TapeArea),
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
    set_time_to_live(tape_data.objects.background, player_table.settings.tape_clear_delay * 60)
    set_time_to_live(tape_data.objects.border, player_table.settings.tape_clear_delay * 60)
    player_table.tapes.drawing = nil
  end
end

return tape