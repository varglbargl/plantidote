local Class = require("Class")

local Vector2 = Class:new("Vector2")

function Vector2:__add(val1, val2)
  return Vector2:new(val1[1] + val2[1], val1[2] + val2[2])
end

function Vector2:__sub(val1, val2)
  return Vector2:new(val1[1] - val2[1], val1[2] - val2[2])
end

function Vector2:__mul(val1, val2)
  if typeOf(val1) == "number" then
    return Vector2:new(val1 * val2[1], val1 * val2[2])
  elseif typeOf(val2) == "number" then
    return Vector2:new(val1[1] * val2, val1[2] * val2)
  elseif typeOf(val2) == "Vector2" then
    return Vector2:new(val1[1] * val2[1], val1[2] * val2[2])
  end
end

function Vector2:__div(val1, val2)
  if typeOf(val1) == "number" then
    return Vector2:new(val1 / val2[1], val1 / val2[2])
  elseif typeOf(val2) == "number" then
    return Vector2:new(val1[1] / val2, val1[2] / val2)
  elseif typeOf(val2) == "Vector2" then
    return Vector2:new(val1[1] / val2[1], val1[2] / val2[2])
  end
end

function Vector2:__tostring()
  return string.format("<Vector2 - x:%f y:%f>", self.x, self.y)
end

function Vector2:new(x, y)
  if type(x) == "table" then
    return Vector2:new(x[1], x[2])
  end

  local vec2 = {}
  Class.extend(vec2, Vector2)

  vec2.x = x or 0
  vec2.y = y or 0
  vec2.size = math.sqrt(vec2.x * vec2.x + vec2.y * vec2.y)

  vec2[1] = vec2.x
  vec2[2] = vec2.y

  return vec2
end

function Vector2:getNormalized()
  return self / self.size
end

Vector2.zero = Vector2:new(0, 0)
Vector2.one = Vector2:new(1, 1)
Vector2.up = Vector2:new(0, 1)
Vector2.right = Vector2:new(1, 0)

return Vector2
