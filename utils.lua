Task = require("Task")
GameObject = require("GameObject")
Layer = require("Layer")
Button = require("Button")
Vector2 = require("Vector2")
Color = require("Color")
Events = require("Events")
Console = require("Console")

-- hook love's existing events to my events system
Events.hook("mousemoved")
Events.hook("mousepressed")
Events.hook("mousereleased")
Events.hook("keypressed")
Events.hook("keyreleased")
Events.hook("resize")
Events.hook("load")
Events.hook("update")
Events.hook("draw")

-- connect other event logic to library logic to avoid infinite require loops
Events.connect("update", Task.tick)
Events.connect("draw", Console.draw)

-- random utility garbo

Events.connect("resize", function()
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
end)

Events.connect("mousepressed", function(x, y, button)
  Console.log("You pressed Mouse Button "..button..".", Color.randomBright())
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
