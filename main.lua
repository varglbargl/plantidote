require("utils")

local function load()
  love.window.setTitle("Plantidote v0.0.1")
  love.window.setMode(1280, 720, {resizable = true})

  ui = Layer:new("ui")
  Console.log(ui:type())
  -- playButton = Button:new({parent = ui})
end

local function update(dt)
end

local function draw()
  love.graphics.setBackgroundColor(Color.white)
end

Events.connect("load", load)
Events.connect("update", update)
Events.connect("draw", draw)
