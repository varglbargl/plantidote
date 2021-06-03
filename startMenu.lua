local Button = require("Button")
local Layer = require("Layer")
local Vector2 = require("Vector2")
local Events = require "Events"

local startMenu = Layer:new("start menu", {
  parent = "ui",
  backgroundColor = "white",
  visible = true
})

Button:new(0, 0, {
  label = "Play",
  textAlign = {0.5, 0.5},
  font = "/fonts/OpenDyslexic-Bold.otf",
  fontColor = "white",
  width = 200,
  height = 60,
  backgroundColor = "pink",
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
    Events.broadcast("startGame")
    self:setActive(false)
    self:setOffset(Vector2:new(0, 2))
  end
})

return startMenu
