local Task = require("Task")
local Events = require("Events")
local Console = require("Console")
local Color = require("Color")
local Layer = require("Layer")
local Button = require("Button")
local Vector2 = require("Vector2")
require("utils")

local function load()
  -- Console.startDebugging()
  love.window.setTitle("Plantidote v0.0.1")
  love.window.setMode(1280, 720, {resizable = true})

  Game = Layer:new("game")

  Layer:new("world", {parent = Game})
  Layer:new("ui", {parent = Game})
  local startMenu = Layer:new("start menu", {parent = Game.ui})

  Button:new(0, 0, {
    label = "Play",
    textAlign = {0.5, 0.5},
    font = "/fonts/OpenDyslexic-Bold.otf",
    fontColor = Color.white,
    width = 200,
    height = 60,
    backgroundColor = Color.pink,
    cornerRadius = 15,
    align = {0.5, 0.5},
    anchor = {0.5, 0.5},
    parent = startMenu,
    hovered = function(self)
      self:setOffset(Vector2:new(0, 2))
    end,
    unhovered = function(self)
      self:setOffset()
    end,
    pressed = function(self)
      self:setOffset(Vector2:new(0, -2))
    end,
    released = function(self)
      self:setOffset(Vector2:new(0, 2))
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
