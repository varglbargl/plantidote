local GameObject = require("GameObject")
local Events = require("Events")
local Class = require("Class")
local Console = require("Console")
local Color = require("Color")

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

local function resizeLayers()
  for _, lyr in ipairs(layerList) do
    lyr.width = love.window.width
    lyr.height = love.window.height
  end
end

Events.connect("resize", resizeLayers)

function Layer:__tostring()
  return string.format("<Layer - name:%s id:%s>", self.name, self.id)
end

function Layer:new(name, params)
  assert(name and type(name) == "string", "Layers must be given a name.")

  if params.parent and type(params.parent) == "string" then
    params.parent = layerFromName(params.parent)
    if not params.parent then
      error("There is no layer named \""..name.."\".")
    end
  end

  params = params or {}
  local lyr = GameObject:new(0, 0, params)
  Class.extend(lyr, Layer)

  lyr.width = love.window.width
  lyr.height = love.window.height
  lyr.visible = params.visible

  if lyr.parent and lyr.parent:typeOf("Layer") then
    lyr.parent[string.lower(name)] = lyr
  end

  lyr.name = name

  if params.backgroundColor then
    lyr.backgroundColor = Color:new(params.backgroundColor)
  end

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

  if #self.children == 0 then
    table.insert(self.children, obj)
  else
    for i, child in ipairs(self.children) do
      if obj.y <= child.y then
        table.insert(self.children, i, obj)
        break
      elseif i == #self.children then
        table.insert(self.children, obj)
        break
      end
    end
  end
end

function Layer:removeChild(obj)
  Console.debug("Removing child "..tostring(obj).." from "..tostring(self))
  obj.parent = nil

  for i, child in ipairs(self.children) do
    if child == obj then
      table.remove(self.children, i)
      if obj.name then self[string.lower(obj.name)] = nil end
      break
    end
  end
end

function Layer.show(lyr)
  if type(lyr) == "string" then
    lyr = layerFromName(lyr)
  end

  lyr:setVisible(true)

  return lyr:isVisible()
end

function Layer.hide(name)
  layerFromName(name):setVisible(false)
end

Events.connect('destroyed', onDestroyed)

return Layer
