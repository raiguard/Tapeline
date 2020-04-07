-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UTILITIES

local math2d = require('__core__.lualib.math2d')
local mod_gui = require('mod-gui')
local util = require('__core__.lualib.util')

util.area = {}

function util.area.expand(area, amount)
  return {left_top={x=area.left_top.x-amount, y=area.left_top.y-amount}, right_bottom={x=area.right_bottom.x+amount, y=area.right_bottom.y+amount}}
end

function util.area.opposite_corner(corner)
  if corner:find('left') then
    corner = corner:gsub('left', 'right')
  else
    corner = corner:gsub('right', 'left')
  end
  if corner:find('top') then
    corner = corner:gsub('top', 'bottom')
  else
    corner = corner:gsub('bottom', 'top')
  end
  return corner
end

function util.area.contains_point(area, pos)
  return math2d.bounding_box.contains_point(area, pos)
end

function util.area.add_data(area)
  local left_top = area.left_top
  local right_bottom = area.right_bottom
  area.left_bottom = {x=area.left_top.x, y=area.right_bottom.y}
  area.right_top = {x=area.right_bottom.x, y=area.left_top.y}
  area.width = right_bottom.x - left_top.x
  area.height = right_bottom.y - left_top.y
  area.midpoints = {x=left_top.x+(area.width/2), y=left_top.y+(area.height/2)}
  return area
end

util.position = math2d.position

function util.position.add(pos1, pos2)
  return {x=pos1.x+pos2.x, y=pos1.y+pos2.y}
end

function util.position.subtract(pos1, pos2)
  return {x=pos1.x-pos2.x, y=pos1.y-pos2.y}
end

function util.position.equals(pos1, pos2)
  return pos1.x == pos2.x and pos1.y == pos2.y and true or false
end

-- creates an area that is the tile the position is contained in
function util.position.to_tile_area(pos)
  pos = util.position.ensure_xy(pos)
  return {
    left_top = {x=math.floor(pos.x), y=math.floor(pos.y)},
    right_bottom = {x=math.ceil(pos.x), y=math.ceil(pos.y)}
  }
end

util.textfield = {}

function util.textfield.clamp_number_input(element, clamps, last_value)
  local text = element.text
  if text == ''
  or (clamps[1] and tonumber(text) < clamps[1])
  or (clamps[2] and tonumber(text) > clamps[2]) then
    element.style = 'tl_invalid_slider_textfield'
  else
    element.style = 'tl_slider_textfield'
    last_value = text
  end
  return last_value
end

function util.textfield.set_last_valid_value(element, last_value)
  if element.text ~= last_value then
    element.text = last_value
    element.style = 'tl_slider_textfield'
  end
  return element.text
end

return util