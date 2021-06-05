local GameObject = require("GameObject")
local Vector2 = require("Vector2")

local Prop = {}

local function traverseTree(node)
  for _, child in ipairs(node.children) do
    node:addChild(Prop:new(child))
  end
end

function Prop:new(propFile)
  if type(propFile) == "string" then
    propFile = require("/props/"..propFile)
  end

  local prp = GameObject:new(propFile)

  if propFile.image and type(propFile.image) == "string" then
    propFile.image = prp.image
  end

  if propFile.children then
    for _, child in ipairs(propFile.children) do
      prp:addChild(Prop:new(child))
    end
  end

  return prp
end

return Prop
