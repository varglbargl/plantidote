local Events = require("Events")
local GameObject = require("GameObject")
local Vector2 = require("Vector2")
local Console = require("Console")

local Button = GameObject:new()

local function onMouseMoved(x, y)
  
end

local function isInside(vec2, x, y, w, h)

end

function Button:new(x, y, params)
  if typeOf(x) == "table" then
    return Button:new(x.x, x.y, x)
  elseif typeOf(x) == "Vector2" then
    return Button:new(x.x, x.y, y)
  end

  params = params or {}

  local btn = GameObject:new(x, y, params)
  setmetatable(btn, Button)

  btn.width = params.width or 200
  btn.height = params.height or 50
  btn.focussed = false
  btn.active = params.active or true
  btn.label = params.label

  return btn
end

function Button:focus()

end

function Button:setActive()

end

function Button:isActive()

end

Events.connect("mousemoved", onMouseMoved)

return Button
