local Task = require("Task")
local Events = require("Events")
local Console = require("Console")

-- connect other event logic to library logic to avoid infinite require loops
Events.connect("update", Task.tick)
Events.connectAfter("draw", Console.draw)

-- random utility garbo

Events.connect("resize", function()
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
end)

Events.connect("keypressed", function(keyCode)
  if keyCode == "`" then
    Console.show()
  elseif keyCode == "c" then
    Console.clear()
  elseif keyCode == "escape" then
    Events.broadcast("quit")
  else
    Console.debug("You pressed Keyboard Key "..keyCode..".")
  end
end)

Events.connect("load", function()
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
  love.game = {}
  love.game.time = 0
end)

Events.connect("update", function(dt)
  love.game.time = love.game.time + dt
end)
