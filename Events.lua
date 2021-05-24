local Console = require("Console")
local Color = require("Color")

local Events = {}
local registry = {}

function Events.connect(eventName, callback)
  if not registry[eventName] then
    registry[eventName] = {}
  end

  table.insert(registry[eventName], callback)
end

function Events.disconnect(eventName, callback)
  if not registry[eventName] then return end

  if callback and type(callback) == "function" then
    for i, func in ipairs(registry[eventName]) do
      if registry[eventName] == callback then
        table.remove(registry[eventName], i)
        break
      end
    end
  else
    table.remove(registry, eventName)
  end
end

function Events.broadcast(eventName, ...)
  -- Console.log("Broadcasting "..eventName, Color.orange)
  if not registry[eventName] then return end

  for _, func in ipairs(registry[eventName]) do
    func(...)
  end
end

function Events.hook(loveEventName)
  local oldLoveEvent = love[loveEventName]

  if oldLoveEvent then
    Events.connect(loveEventName, oldLoveEvent)
  end

  love[loveEventName] = function(...)
    Events.broadcast(loveEventName, ...)
  end
end

return Events
