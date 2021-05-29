Task = require("Task")
Events = require("Events")
Console = require("Console")
Color = require("Color")
Layer = require("Layer")
Button = require("Button")
Vector2 = require("Vector2")
require("utils")

local function load()
  Console.startDebugging()
  love.window.setTitle("Plantidote v0.0.1")
  love.window.setMode(1280, 720, {resizable = true})

  Game = Layer:new("game")

  Layer:new("world", {parent = Game})
  Layer:new("ui", {parent = Game})

  Button:new(0, 0, {
    backgroundImage = "hotpocket.jpg",
    align = "middle center",
    anchor = "middle center",
    parent = Game.ui
  })

  love.graphics.setBackgroundColor(Color.white)
end

local function update(dt)
end

local function draw()
  Game:draw()
end

Events.connect("load", load)
Events.connect("update", update)
Events.connect("draw", draw)
