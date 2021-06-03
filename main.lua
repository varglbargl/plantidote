local Events = require("Events")
local Console = require("Console")
local Layer = require("Layer")
local Game = require("Game")
local Player = require("Player")
local Task = require("Task")

local function load()
  Layer.show("start menu")
end

local function update(dt)
end

local function draw()
end

local function start()
  Events.broadcast("fadeInOut", 2, "white", function()
    Layer.hide("start menu")
    Game.player = Player:new({image = "blurba.png", parent = Game.screen.world})
    Layer.show("world")

    Task.after(2, function()
      Game.player:enable()
    end)
  end)
end

Events.connect("startGame", start)
Events.connect("load", load)
Events.connect("update", update)
Events.connect("draw", draw)
