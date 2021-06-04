local Class = require("Class")
local Vector2 = require("Vector2")
local Console = require("Console")
local Events = require("Events")
local Color = require("Color")
local Task = require("Task")

local GameObject = Class:new("GameObject")

local uniqueObjectID = 0

function GameObject:__tostring()
  return string.format("<GameObject - id:%s>", self.id)
end

function GameObject.isValid(obj)
  if obj and obj.id and obj.parent then
    return true
  end
  return false
end

function GameObject:destroy()
  for _, child in ipairs(self.children) do
    child:destroy()
  end

  if self.parent then
    self.parent:removeChild(self)
  end

  Events.broadcast("destroyed", self.id)

  return nil
end

function GameObject:addChild(obj)
  if obj.parent then
    obj.parent:removeChild(obj)
  end

  obj.parent = self
  table.insert(self.children, obj)
end

function GameObject:removeChild(obj)
  Console.debug("Removing child "..tostring(obj).." from "..tostring(self))
  obj.parent = nil

  for i, child in ipairs(self.children) do
    if child == obj then
      table.remove(self.children, i)
      break
    end
  end
end

function GameObject:getPosition()
  return Vector2:new(self.position)
end

function GameObject:getRotation()
  return self.rotation
end

function GameObject:getScale()
  return Vector2:new(self.scale)
end

function GameObject:getOffset()
  return Vector2:new(self.offset)
end

function GameObject:getWorldPosition()
  local parent = self.parent
  local pos = self:getPosition()

  while parent do
    pos = pos * parent:getScale() + parent:getPosition()
    parent = parent.parent
  end

  return pos
end

function GameObject:getWorldRotation()
  local parent = self.parent
  local rot = self:getRotation()

  while parent do
    rot = rot + parent:getRotation()
    parent = parent.parent
  end

  return rot
end

function GameObject:getWorldScale()
  local parent = self.parent
  local scl = self:getScale()

  while parent do
    scl = scl * parent:getScale()
    parent = parent.parent
  end

  return scl
end

function GameObject:setPosition(x, y)
  if type(x) == "number" and type(y) == "number" then
    self:setPosition({x, y})
    return
  end

  x = x or Vector2.zero
  self.position = Vector2:new(x)
  self.x = self.position.x
  self.y = self.position.y

  if self.parent and #self.parent.children > 1 then
    for i, child in ipairs(self.parent.children) do

      if child == self then

        if i > 1 and self.parent.children[i-1].y > child.y then
          self.parent.children[i], self.parent.children[i-1] = self.parent.children[i-1], self.parent.children[i]
        elseif i < #self.parent.children and self.parent.children[i+1].y < child.y then
          self.parent.children[i], self.parent.children[i+1] = self.parent.children[i+1], self.parent.children[i]
        end

      end
    end
  end
end

function GameObject:setRotation(num)
  num = num or 0
  self.rotation = num
end

function GameObject:setScale(x, y)
  if type(x) == "number" and type(y) == "number" then
    self:setScale({x, y})
    return
  end

  x = x or Vector2.one
  self.scale = Vector2:new(x)
end

function GameObject:setOffset(vec2)
  vec2 = vec2 or Vector2.zero
  self.offset = Vector2:new(vec2)
end

function GameObject:isVisible()
  if self.visible then
    if self.parent then
      return self.parent:isVisible()
    else
      return true
    end
  else
    return false
  end
end

function GameObject:setVisible(tralse)
  self.visible = tralse
end

function GameObject:moveTo(vec2, secs)

  local from = self:getPosition()
  local currentTime = love.timer.getTime()
  local startTime = currentTime
  local endTime = startTime + secs

  Task.spawn(function()

    local function step()
      if currentTime < endTime then
        self:setPosition(from + ((startTime - currentTime) / secs * (from - vec2)))
        currentTime = love.timer.getTime()
        Task.wait()
        step()
      else
        self:setPosition(vec2)
      end
    end

    step()
  end)
end

function GameObject:new(x, y, params)
  if typeOf(x) == "table" then
    return GameObject:new(x.x, x.y, x)
  end

  params = params or {}

  local obj = {}
  Class.extend(obj, GameObject)

  uniqueObjectID = uniqueObjectID + 1
  obj.id = uniqueObjectID

  obj.children = {}
  obj.align = params.align or {0, 0}
  obj.anchor = params.anchor or {0, 0}

  if params.position then
    obj.position = Vector2:new(params.position)
  else
    obj.position = Vector2:new(x, y)
  end

  obj.x = obj.position.x
  obj.y = obj.position.y
  obj.rotation = params.rotation or 0

  if params.scale then
    obj.scale = Vector2:new(params.scale)
  else
    obj.scale = Vector2.one
  end

  if params.offset then
    obj.offset = Vector2:new(params.offset)
  else
    obj.offset = Vector2.zero
  end

  obj.visible = params.visible or true

  if params.parent then
    params.parent:addChild(obj)
  end

  if params.image then
    if type(params.image) == "string" then
      obj.image = love.graphics.newImage("/images/"..params.image)
    elseif params.image:typeOf("Drawable") then
      obj.image = params.image
    end

    obj.width = params.width or obj.image:getWidth()
    obj.height = params.height or obj.image:getHeight()
  else
    obj.width = params.width or 100
    obj.height = params.height or 100
  end

  return obj
end

function GameObject:draw()
  if not self:isVisible() then return end

  if self.image then
    local position = self:getWorldPosition()
    local rotation = self:getWorldRotation()
    local scale = self:getWorldScale()

    love.graphics.draw(self.image, position.x, position.y, rotation, scale.x, scale.y, self.offset.x + (self.width * self.anchor[1]), self.offset.y + (self.height * self.anchor[2]))
  end

  if self.backgroundColor then
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(Color.white)
  end

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

return GameObject
