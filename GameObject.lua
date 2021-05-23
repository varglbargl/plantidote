local GameObject = {}
GameObject.__index = GameObject
GameObject.__type = "GameObject"

local list = {}
local unique = 0

function GameObject.isValid(obj)
  if obj and obj.id and list[obj.id] then
    return true
  end
  return false
end

function GameObject:destroy()
  for child in self.children do
    child:Destroy()
  end

  table.remove(list, self.id)
end

function GameObject:addChild(obj)
  obj.parent = self
  table.insert(self.children, obj)
end

function GameObject:Move(vec2, time)
  if type(vec2) ~= "Vector2" then return end
  Task.Spawn(function()
    Task.Wait()
  end)
end

function GameObject:new(vec2)
  local obj = {}
  setmetatable(obj, GameObject)
  unique = unique + 1
  obj.id = unique
  list[obj.id] = obj
  obj.x = vec2.x or 0
  obj.y = vec2.y or 0
  obj.parent = nil
  obj.children = {}
  return obj
end

return GameObject
