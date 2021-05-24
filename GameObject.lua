local Class = require("Class")
local Vector2 = require("Vector2")

local GameObject = Class:new("GameObject")

local __gameObjectList = {}
local __uniqueID = 0

function GameObject:__tostring()
  return string.format("<GameObject %s>", self.id)
end

function GameObject.isValid(obj)
  if obj and obj.id and __gameObjectList[obj.id] then
    return true
  end
  return false
end

function GameObject:destroy()
  for child in self.children do
    child:Destroy()
  end

  table.remove(__gameObjectList, self.id)
end

function GameObject:addChild(obj)
  obj.parent = self
  table.insert(self.children, obj)
end

function GameObject:getPosition()
  return self.position
end

function GameObject:getRotation()
  return self.rotation
end

function GameObject:getScale()
  return self.scale
end

function GameObject:setPosition(vec2)
  self.position = vec2
end

function GameObject:setRotation(num)
  self.rotation = num
end

function GameObject:setScale(vec2)
  self.scale = vec2
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
  elseif typeOf(x) == "Vector2" then
    return GameObject:new(x.x, x.y, y)
  end

  params = params or {}

  local obj = Class:new("GameObject")
  __uniqueID = __uniqueID + 1
  obj.id = __uniqueID
  __gameObjectList[obj.id] = obj
  obj.children = {}
  obj.position = params.position or Vector2:new(x, y)
  obj.rotation = params.rotation or 0
  obj.scale = params.scale or Vector2.one
  obj.visible = params.visible or true

  if params.image and type(params.image) == string then
    obj.image = love.graphics.newImage(params.image)
  elseif params.image and params.image:typeOf("Drawable") then
    obj.image = params.image
  end

  if params.parent and params.parent:typeOf("GameObject") then
    params.parent:addChild(obj)
  end
  
  return obj
end

function GameObject:draw()
  if not self.visible then return end

  if self.image then
    love.graphics.draw(self.image, self.position.x, self.position.y)
  end
  
  for _, child in self.children do
    child:draw()
  end
end

return GameObject
