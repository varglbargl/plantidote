local Color = {}
Color.__index = Color
Color.__type = "Color"

local function clampNormal(n)
  if n < 0 then
    return 0
  elseif n > 1 then
    return 1
  else
    return n
  end
end

function Color:__add(col)
  if col.__type == "Color" then
    return Color:new(self.r+col.r, self.g+col.g, self.b+col.b, self.a+col.a)
  elseif type(col) == "number" then
    return Color:new(self.r+col, self.g+col, self.b+col, self.a+col)
  else
    error("Colors can only be added to numbers, Vector3s, Vector4s, or other Colors")
  end
end

function Color:__sub(col)
  if col.__type == "Color" then
    return Color:new(self.r-col.r, self.g-col.g, self.b-col.b, self.a-col.a)
  elseif type(col) == "number" then
    return Color:new(self.r-col, self.g-col, self.b-col, self.a-col)
  else
    error("Colors can only be subtracted from numbers, Vector3s, Vector4s, or other Colors")
  end
end

function Color:__mul(col)
  if col.__type == "Color" then
    return Color:new(self.r*col.r, self.g*col.g, self.b*col.b, self.a*col.a)
  elseif type(col) == "number" then
    return Color:new(self.r*col, self.g*col, self.b*col, self.a*col)
  else
    error("Colors can only be multiplied by numbers, Vector3s, Vector4s, or other Colors")
  end
end

function Color:__div(col)
  if col.__type == "Color" then
    return Color:new(self.r/col.r, self.g/col.g, self.b/col.b, self.a/col.a)
  elseif type(col) == "number" then
    return Color:new(self.r/col, self.g/col, self.b/col, self.a/col)
  else
    error("Colors can only be divided by numbers, Vector3s, Vector4s, or other Colors")
  end
end

function Color:__tostring()
  return string.format("<Color %f, %f, %f, %f>", self.r, self.g, self.b, self.a)
end

function Color:new(red, green, blue, alpha)
  alpha = alpha or 1

  local col = {}
  setmetatable(col, Color)
  col.r = clampNormal(red)
  col.g = clampNormal(green)
  col.b = clampNormal(blue)
  col.a = clampNormal(alpha)

  col[1] = col.r
  col[2] = col.g
  col[3] = col.b
  col[4] = col.a

  return col
end

function Color.random()
  return Color:new(love.math.randomNormal(), love.math.randomNormal(), love.math.randomNormal())
end

function Color.randomBright()
  local rgb = {1}
  table.insert(rgb, math.random(2), 0)
  table.insert(rgb, math.random(3), (math.random(1001)-1)/1000)
  return Color:new(rgb[1], rgb[2], rgb[3])
end

function Color.average(...)
  local cols = {...}
  local red = 0
  local green = 0
  local blue = 0
  local alpha = 0

  for i, col in ipairs(cols) do
    assert(col.__type == "Color", "All arguments passed to Color.average must be of type Color. Argument number "..i.." is a "..type(col))

    red = red + col.r
    green = green + col.g
    blue = blue + col.b
    alpha = alpha + col.a
  end

  return Color:new(red/#cols, green/#cols, blue/#cols, alpha/#cols)
end

Color.white         = Color:new(1, 1, 1, 1)
Color.black         = Color:new(0, 0, 0, 1)
Color.transperent   = Color:new(1, 1, 1, 0)

Color.red           = Color:new(1, 0, 0, 1)
Color.orange        = Color:new(1, 0.4, 0, 1)
Color.yellow        = Color:new(1, 1, 0, 1)
Color.green         = Color:new(0, 1, 0, 1)
Color.blue          = Color:new(0, 0, 1, 1)
Color.purple        = Color:new(0.5, 0, 1, 1)

Color.gray          = Color:new(0.5, 0.5, 0.5, 1)
Color.cyan          = Color:new(0, 1, 1, 1)
Color.magenta       = Color:new(1, 0, 1, 1)
Color.pink          = Color:new(1, 0.5, 0.6, 1)
Color.brown         = Color:new(0.6, 0.3, 0.2, 1)
Color.lightUrple    = Color.average(Color.purple, Color.white)

return Color
