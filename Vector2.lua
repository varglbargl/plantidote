local Vector2 = {}
Vector2.__index = Vector2
Vector2.__type = "Vector2"

function Vector2:__add(vec)
  return Vector2:new(self.x + vec.x, self.y + vec.y)
end

function Vector2:__sub(vec)
  return Vector2:new(self.x - vec.x, self.y - vec.y)
end

function Vector2:__mul(value)
  return Vector2:new(self.x * value, self.y * value)
end

function Vector2:__div(value)
  return Vector2:new(self.x / value, self.y / value)
end

function Vector2:__tostring()
  return string.format("<Vector2 %f, %f>", self.x, self.y)
end

function Vector2:new(x, y)
  local vec2 = {}
  setmetatable(vec2, Vector2)
  vec2.x = x or 0
  vec2.y = y or 0
  return vec2
end

function Vector2:zero()
  return Vector2:New(0, 0)
end

function Vector2:one()
  return Vector2:New(1, 1)
end

function Vector2:up()
  return Vector2:New(0, 1)
end

function Vector2:right()
  return Vector2:New(1, 0)
end

return Vector2
