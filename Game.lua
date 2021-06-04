local Events = require("Events")
local Class = require("Class")
local Layer = require("Layer")
local Console = require("Console")
local Color = require("Color")
local Task = require "Task"

local Game = Class:new("Game")

-- random utility garbo

local oldSetMode = love.window.setMode
function love.window.setMode(...)
  oldSetMode(...)
  Events.broadcast("resize")
end

local oldSetColor = love.graphics.setColor
function love.graphics.setColor(clr, ...)
  clr = clr or Color.white
  oldSetColor(Color:new(clr, ...))
end

local oldSetBackgroundColor = love.graphics.setBackgroundColor
function love.graphics.setBackgroundColor(clr, ...)
  clr = clr or Color.white
  oldSetBackgroundColor(Color:new(clr, ...))
end

local function onKeypressed(keyCode)
  if keyCode == "`" then
    Console.show()
  elseif keyCode == "c" then
    Console.clear()
  elseif keyCode == "escape" then
    Events.broadcast("quit")
  else
    Console.debug("You pressed Keyboard Key \""..keyCode.."\"")
  end
end

local function handleResize()
  love.window.width = love.graphics.getWidth()
  love.window.height = love.graphics.getHeight()
end

local function setupGameData()
  math.randomseed(os.time())
  love.window.setTitle("Plantidote v0.0.1")
  love.window.setMode(1280, 720, {resizable = true, msaa = 16})
  handleResize()

  Game.screen = Layer:new("screen", {visible = true})

  Layer:new("world", {parent = Game.screen, backgroundColor = Color.ground})
  Layer:new("ui", {parent = Game.screen, visible = true})

  require("startMenu")
  -- require("playerCharacter")
end

local function fadeTransition(secs, fadeColor, callback)
  secs = secs or 1
  fadeColor = fadeColor or Color.black
  fadeColor = Color:new(fadeColor)

  local calledBack = false
  local startTime = love.timer.getTime()
  local halfTime = startTime + (secs / 2)
  local endTime = startTime + secs

  local function fadeFunc()
    if love.timer.getTime() >= endTime then
      Events.disconnect("draw", fadeFunc)
      return
    elseif love.timer.getTime() < halfTime then
      fadeColor = Color:new(fadeColor.r, fadeColor.g, fadeColor.b, (love.timer.getTime() - startTime) / secs * 3)
    else
      if callback and type(callback) == "function" and not calledBack then
        callback()
        calledBack = true
      end
      fadeColor = Color:new(fadeColor.r, fadeColor.g, fadeColor.b, (1 - ((love.timer.getTime() - startTime) / secs)) * 3)
    end

    love.graphics.setColor(fadeColor)
    love.graphics.rectangle("fill", 0, 0, love.window.width, love.window.height)
    love.graphics.setColor()
  end

  Events.connect("draw", fadeFunc)
end

local function draw()
  Game.screen:draw()
end

Events.connectBefore("resize", handleResize)
Events.connectBefore("load", setupGameData)
Events.connect("fadeInOut", fadeTransition)
Events.connect("keypressed", onKeypressed)
Events.connect("draw", draw)

return Game
