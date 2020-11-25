local table = require("__flib__.table")

local area_lib = {}

function area_lib.expand_to_contain(self, area)
  self.left_top = {
    x = self.left_top.x < area.left_top.x and self.left_top.x or area.left_top.x,
    y = self.left_top.y < area.left_top.y and self.left_top.y or area.left_top.y
  }
  self.right_bottom = {
    x = self.right_bottom.x > area.right_bottom.x and self.right_bottom.x or area.right_bottom.x,
    y = self.right_bottom.y > area.right_bottom.y and self.right_bottom.y or area.right_bottom.y
  }

  return self
end

function area_lib.center_on(self, center_point)
  local height = area_lib.height(self)
  local width = area_lib.width(self)

  self.left_top = {
    x = center_point.x - (width / 2),
    y = center_point.y - (height / 2)
  }
  self.right_bottom = {
    x = center_point.x + (width / 2),
    y = center_point.y + (height / 2)
  }

  return self
end

function area_lib.ceil(self)
  self.left_top = {
    x = math.floor(self.left_top.x),
    y = math.floor(self.left_top.y)
  }
  self.right_bottom = {
    x = math.ceil(self.right_bottom.x),
    y = math.ceil(self.right_bottom.y)
  }

  return self
end

function area_lib.width(self)
  return math.abs(self.right_bottom.x - self.left_top.x)
end

function area_lib.height(self)
  return math.abs(self.right_bottom.y - self.left_top.y)
end

function area_lib.from_position(position)
  return {
    left_top = {x = position.x, y = position.y},
    right_bottom = {x = position.x, y = position.y}
  }
end

-- iterate positions in the area from top-left to bottom-right
function area_lib.iterate(self, step)
  step = step or 1

  local x = self.left_top.x
  local y = self.left_top.y
  local max_x = self.right_bottom.x
  local max_y = self.right_bottom.y
  local first = true

  local function iterator()
    if first then
      first = false
      return {x = x, y = y}
    end

    local new_x = x + step
    if x < max_x and new_x < max_x then
      x = new_x
    else
      local new_y = y + step
      if y < max_y and new_y < max_y then
        x = self.left_top.x
        y = new_y
      else
        return nil
      end
    end

    return {x = x, y = y}
  end

  return iterator
end

function area_lib.expand(self, amount)
  self.left_top.x = self.left_top.x - amount
  self.left_top.y = self.left_top.y - amount

  self.right_bottom.x = self.right_bottom.x + amount
  self.right_bottom.y = self.right_bottom.y + amount

  return self
end

function area_lib.center(self)
  return {
    x = self.left_top.x + (area_lib.width(self) / 2),
    y = self.left_top.y + (area_lib.height(self) / 2)
  }
end

function area_lib.contains(self, position)
  return (
    self.left_top.x <= position.x
    and self.right_bottom.x >= position.x
    and self.left_top.y <= position.y
    and self.right_bottom.y >= position.y
  )
end

function area_lib.distance_to_nearest_edge(self, position)
  local x_distance = math.min(math.abs(self.left_top.x - position.x), math.abs(self.right_bottom.x - position.x))
  local y_distance = math.min(math.abs(self.left_top.y - position.y), math.abs(self.right_bottom.y - position.y))

  return math.min(x_distance, y_distance)
end

function area_lib.strip(self)
  return {
    left_top = {
      x = self.left_top.x,
      y = self.left_top.y
    },
    right_bottom = {
      x = self.right_bottom.x,
      y = self.right_bottom.y
    }
  }
end

function area_lib.load(area)
  return setmetatable(area, {__index = area_lib})
end

return area_lib

