local Class = require("Class")
local Vector2 = require("Vector2")
local Console = require("Console")
local Events = require("Events")

local GameObject = Class:new("GameObject")

local gameObjectList = {}
local uniqueObjectID = 0

function GameObject:__tostring()
  return string.format("<GameObject - id:%s>", self.id)
end

function GameObject.isValid(obj)
  if obj and obj.id and gameObjectList[obj.id] then
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
  gameObjectList[self.id] = nil
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

function GameObject:setPosition(vec2)
  vec2 = vec2 or Vector2.zero
  self.position = Vector2:new(vec2)
  self.x = self.position.x
  self.y = self.position.y
end

function GameObject:setRotation(num)
  num = num or 0
  self.rotation = num
end

function GameObject:setScale(vec2)
  vec2 = vec2 or Vector2.one
  self.scale = Vector2:new(vec2)
end

function GameObject:setOffset(vec2)
  vec2 = vec2 or Vector2.zero
  self.offset = Vector2:new(vec2)
end

-- function GameObject:Move(vec2, time)
--   if type(vec2) ~= "Vector2" then return end

--   local steps = self:GetPosition() -

--   Task.Spawn(function()
--     Task.Wait()
--   end)
-- end

function GameObject:new(x, y, params)
  if typeOf(x) == "table" then
    return GameObject:new(x.x, x.y, x)
  end

  params = params or {}

  local obj = {}
  Class.extend(obj, GameObject)

  uniqueObjectID = uniqueObjectID + 1
  obj.id = uniqueObjectID
  gameObjectList[obj.id] = obj
  obj.children = {}

  obj.position = params.position or Vector2:new(x, y)
  obj.x = obj.position.x
  obj.y = obj.position.y
  obj.rotation = params.rotation or 0
  obj.scale = params.scale or Vector2.one
  obj.offset = params.offset or Vector2.zero

  obj.visible = params.visible or true

  if params.parent then
    params.parent:addChild(obj)
  end

  return obj
end

function GameObject:draw()
  if not self.visible then return end

  if self.image then
    love.graphics.draw(self.image, self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.offset.x, self.offset.y)
  end

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

return GameObject
