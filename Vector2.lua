local Class = require("Class")

local Vector2 = Class:new("Vector2")

function Vector2:__add(vec)
  return Vector2:new(self.x + vec.x, self.y + vec.y)
end

function Vector2:__sub(vec)
  return Vector2:new(self.x - vec.x, self.y - vec.y)
end

function Vector2:__mul(value)
  if typeOf(value) == "number" then
    return Vector2:new(self.x * value, self.y * value)
  elseif typeOf(value) == "Vector2" then
    return Vector2:new(self.x * value.x, self.y * value.y)
  end
end

function Vector2:__div(value)
  if typeOf(value) == "number" then
    return Vector2:new(self.x / value, self.y / value)
  elseif typeOf(value) == "Vector2" then
    return Vector2:new(self.x / value.x, self.y / value.y)
  end
end

function Vector2:__tostring()
  return string.format("<Vector2 %f, %f>", self.x, self.y)
end

function Vector2:new(xOrTable, y)
  if type(xOrTable) == "table" then
    return Vector2:new(xOrTable[0], xOrTable[1])
  end

  local vec2 = {}
  setmetatable(vec2, Vector2)
  vec2.x = x or 0
  vec2.y = y or 0
  vec2[0] = vec2.x
  vec2[1] = vec2.y
  return vec2
end

Vector2.zero = Vector2:new(0, 0)
Vector2.one = Vector2:new(1, 1)
Vector2.up = Vector2:new(0, 1)
Vector2.right = Vector2:new(1, 0)

return Vector2
