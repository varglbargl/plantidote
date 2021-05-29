local GameObject = require("GameObject")
local Events = require("Events")
local Class = require("Class")
local Console = require("Console")
local Task = require("Task")

local Layer = Class:new("Layer")
Class.extend(Layer, GameObject)

local layerList = {}

local function onDestroyed(id)
  for i, lyr in ipairs(layerList) do
    if lyr.id == id then
      table.remove(layerList, i)
      break
    end
  end
end

local function layerFromName(name)
  for _, lyr in ipairs(layerList) do
    if string.lower(lyr.name) == string.lower(name) then
      return lyr
    end
  end
end

function Layer:__tostring()
  return string.format("<Layer - name:%s id:%s>", self.name, self.id)
end

function Layer:new(name, params)
  assert(name and type(name) == "string", "Layers must be given a name.")
  local lyr = GameObject:new(0, 0, params)
  Class.extend(lyr, Layer)

  if lyr.parent and lyr.parent:typeOf("Layer") then
    lyr.parent[string.lower(name)] = lyr
  end

  lyr.name = name

  assert(not layerFromName(name) and not lyr[name], "There is either already a layer named \""..name.."\" or that is a reserved word. Sorry!")

  table.insert(layerList, lyr)

  return lyr
end

function Layer:addChild(obj)
  if obj.parent then
    obj.parent:removeChild(obj)
  end

  if obj:typeOf("Layer") then
    self[string.lower(obj.name)] = obj
  end

  obj.parent = self
  table.insert(self.children, obj)
end

function Layer:removeChild(obj)
  Console.debug("Removing child "..tostring(obj).." from "..tostring(self))
  obj.parent = nil

  for i, child in ipairs(self.children) do
    if child == obj then
      table.remove(self.children, i)
      self[string.lower(obj.name)] = nil
      break
    end
  end
end

function Layer.showLayer(name)
  layerFromName(name):setVsible(true)
end

function Layer.hideLayer(name)
  layerFromName(name):setVsible(false)
end

Events.connect('destroyed', onDestroyed)

return Layer
