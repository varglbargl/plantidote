local Task = require("Task")
local Events = require("Events")
local Console = require("Console")
local Color = require("Color")
local Layer = require("Layer")
local Button = require("Button")
local Vector2 = require("Vector2")
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
    align = {0.5, 0.5},
    anchor = {0.5, 0.5},
    parent = Game.ui,
    hovered = function(self)
      self:setOffset(Vector2:new(0, 4))
    end,
    unhovered = function(self)
      self:setOffset()
    end,
    pressed = function(self)
      self:setOffset()
    end,
    released = function(self)
      self:setOffset(Vector2:new(0, 4))
    end
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
