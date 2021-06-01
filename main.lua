local Events = require("Events")
local Console = require("Console")
local Layer = require("Layer")
local Game = require("Game")

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
    Layer.show("world")
  end)
end

Events.connect("startGame", start)
Events.connect("load", load)
Events.connect("update", update)
Events.connect("draw", draw)
