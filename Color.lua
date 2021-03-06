local Class = require("Class")

local Color = Class:new("Color")

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
  if col:typeOf("Color") then
    return Color:new(self.r+col.r, self.g+col.g, self.b+col.b, self.a+col.a)
  elseif type(col) == "number" then
    return Color:new(self.r+col, self.g+col, self.b+col, self.a+col)
  else
    error("Colors can only be added to numbers or other Colors")
  end
end

function Color:__sub(col)
  if col:typeOf("Color") then
    return Color:new(self.r-col.r, self.g-col.g, self.b-col.b, self.a-col.a)
  elseif type(col) == "number" then
    return Color:new(self.r-col, self.g-col, self.b-col, self.a-col)
  else
    error("Colors can only be subtracted from numbers or other Colors")
  end
end

function Color:__mul(col)
  if col:typeOf("Color") then
    return Color:new(self.r*col.r, self.g*col.g, self.b*col.b, self.a*col.a)
  elseif type(col) == "number" then
    return Color:new(self.r*col, self.g*col, self.b*col, self.a*col)
  else
    error("Colors can only be multiplied by numbers or other Colors")
  end
end

function Color:__div(col)
  if col:typeOf("Color") then
    return Color:new(self.r/col.r, self.g/col.g, self.b/col.b, self.a/col.a)
  elseif type(col) == "number" then
    return Color:new(self.r/col, self.g/col, self.b/col, self.a/col)
  else
    error("Colors can only be divided by numbers or other Colors")
  end
end

function Color:__tostring()
  return string.format("<Color - r:%i, g:%i, b:%i, a:%f>", self.r*255, self.g*255, self.b*255, self.a)
end

function Color:new(red, green, blue, alpha)
  if typeOf(red) == "Color" then
    return red
  elseif typeOf(red) == "table" then
    return Color:new(red[1], red[2], red[3], red[4])
  elseif typeOf(red) == "string" and Color[red] then
    return Color[red]
  end

  alpha = alpha or 1

  local col = {}
  Class.extend(col, Color)

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
    assert(col:typeOf("Color"), "All arguments passed to Color.average must be of type Color. Argument number "..i.." is a "..typeOf(col))

    red = red + col.r
    green = green + col.g
    blue = blue + col.b
    alpha = alpha + col.a
  end

  return Color:new(red/#cols, green/#cols, blue/#cols, alpha/#cols)
end

function Color:invert()
  return Color:new(1-self[1], 1-self[2], 1-self[3], self[4])
end

Color.white       = Color:new(1, 1, 1, 1)
Color.black       = Color:new(0, 0, 0, 1)
Color.transparent = Color:new(1, 1, 1, 0)

Color.red         = Color:new(1, 0, 0, 1)
Color.orange      = Color:new(1, 0.4, 0, 1)
Color.yellow      = Color:new(1, 1, 0, 1)
Color.green       = Color:new(0, 1, 0, 1)
Color.blue        = Color:new(0, 0, 1, 1)
Color.purple      = Color:new(0.4, 0, 1, 1)

Color.gray        = Color:new(0.5, 0.5, 0.5, 1)
Color.cyan        = Color:new(0, 1, 1, 1)
Color.magenta     = Color:new(1, 0, 1, 1)
Color.pink        = Color:new(1, 0.5, 0.6, 1)
Color.brown       = Color:new(0.6, 0.3, 0.2, 1)
Color.alpine      = Color:new(0, 0.22, 0.12, 1)
Color.paper       = Color:new(0.91, 0.88, 0.82, 1)
Color.ground      = Color:new(0.53, 0.48, 0.27, 1)

Color.lightUrple  = Color.average(Color.purple, Color.white)
Color["light urple"]  = Color.lightUrple

return Color
