local Task = require("Task")
local GameObject = require("GameObject")
local Vector2 = require("Vector2")
local Color = require("Color")
local Events = require("Events")
local Console = require("Console")

function love.load()
  love.window.setTitle("Plantidote v0.0.1")
  gameTime = 0
  love.window.setMode(1280, 720, {resizable = true})
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
end

function love.update(dt)
  Events.broadcast("update")
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
  gameTime = gameTime + dt
  Task.tick()
end

function love.draw()
  Events.broadcast("draw")
  love.graphics.setBackgroundColor(1, 1, 1)
  Console.draw()
end

function love.mousepressed(x, y, button, isTouch)
  Console.log("You pressed Mouse Button "..button..".", Color.purple)
end

function love.keypressed(key)
  Console.log("You pressed Keyboard Key "..key..".", Color.purple)

  if key == "escape" then
    love.event.quit()
  end

  if key == "`" then
    Console.show()
  end

  if key == "c" then
    Console.clear()
  end
end
