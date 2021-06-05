local Events = require("Events")
local Console = require("Console")
local Layer = require("Layer")
local Game = require("Game")
local Player = require("Player")
local Task = require("Task")
local Prop = require("Prop")
local Vector2 = require("Vector2")

local function load()
  -- Console.startDebugging()
  Layer.show("start menu")
end

local function update(dt)
end

local function draw()
end

Events.connect("load", load)
Events.connect("update", update)
Events.connect("draw", draw)

local function startGame()
  Events.broadcast("fadeInOut", 2, "white", function()
    Layer.hide("start menu")
    Game.player = Player:new({image = "blurba.png"})
    Layer.show("world")

    for i = 1, 12 do
      local tree = Prop:new("tree1")
      tree:setPosition(Vector2:new(math.random(1280), 100 + math.random(600)))
      tree:setScale(tree:getScale() * Vector2:new(math.random(1) * 2 - 1, 1))
      Game.screen.world:addChild(tree)
    end

    Task.after(1, function()
      Game.player:enable()
    end)
  end)
end

Events.connect("startGame", startGame)
