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
  return self.right_bottom.x - self.left_top.x
end

function area_lib.height(self)
  return self.right_bottom.y - self.left_top.y
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

local area_class_mt = {
  __index = {}
}
local excluded_funcs = {
  width = true,
  height = true,
  iterate = true
}

-- don't call the area_lib functions directly - use a helper function to return a new Area class if using one
for name, func in pairs(area_lib) do
  if not excluded_funcs[name] then
    area_class_mt.__index[name] = function(self, ...)
      return setmetatable(func(self, ...), area_class_mt)
    end
  else
    area_class_mt.__index[name] = func
  end
end

local default_area = {
  left_top = {x = 0, y = 0},
  right_bottom = {x = 0, y = 0}
}

function area_lib.new(area)
  return setmetatable(area or default_area, area_class_mt)
end

return area_lib

