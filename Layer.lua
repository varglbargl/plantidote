local GameObject = require("GameObject")

local Layer = GameObject:new(0, 0)

local layerList = {}

function Layer:new(name)
  assert(name and type(name) == "string", "Layers must be given a name.")

  local lyr = GameObject:new(0, 0)
  lyr.name = name
  return lyr
end

return Layer
