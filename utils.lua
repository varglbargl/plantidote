local Task = require("Task")
local Events = require("Events")
local Console = require("Console")

-- connect other event logic to library logic to avoid infinite require loops
Events.connect("update", Task.tick)
Events.connectAfter("draw", Console.draw)

-- random utility garbo

local oldmode = love.window.setMode
function love.window.setMode(...)
  oldmode(...)
  Events.broadcast("resize")
end

local function handleResize()
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
end

Events.connectBefore("resize", handleResize)

Events.connect("keypressed", function(keyCode)
  if keyCode == "`" then
    Console.show()
  elseif keyCode == "c" then
    Console.clear()
  elseif keyCode == "escape" then
    Events.broadcast("quit")
  else
    Console.debug("You pressed Keyboard Key \""..keyCode.."\"")
  end
end)

Events.connectBefore("load", function()
  handleResize()
  love.game = {}
  love.game.time = 0
end)

Events.connect("update", function(dt)
  love.game.time = love.game.time + dt
end)
