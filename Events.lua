local Events = {}
local registry = {}

local function checkOrMakeEvent(eventName)
  if not registry[eventName] then
    registry[eventName] = {
      __before = {},
      __after = {}
    }
  end
end

function Events.connectBefore(eventName, callback)
  checkOrMakeEvent(eventName)

  table.insert(registry[eventName].__before, callback)
end

function Events.connect(eventName, callback)
  checkOrMakeEvent(eventName)

  table.insert(registry[eventName], callback)
end

function Events.connectAfter(eventName, callback)
  checkOrMakeEvent(eventName)

  table.insert(registry[eventName].__after, callback)
end

function Events.disconnect(eventName, callback)
  if not registry[eventName] then return end

  if callback and type(callback) == "function" then
    for i, func in ipairs(registry[eventName]) do
      if func == callback then
        table.remove(registry[eventName], i)
        break
      end
    end
  else
    table.remove(registry, eventName)
  end
end

function Events.broadcast(eventName, ...)
  if not registry[eventName] then return end

  for _, func in ipairs(registry[eventName].__before) do
    func(...)
  end

  for _, func in ipairs(registry[eventName]) do
    func(...)
  end

  for _, func in ipairs(registry[eventName].__after) do
    func(...)
  end
end

function Events.hook(loveEventName)
  local oldLoveEvent = love[loveEventName]
  oldLoveEvent = oldLoveEvent or love.event[loveEventName]

  if oldLoveEvent then
    Events.connect(loveEventName, oldLoveEvent)
  end

  love[loveEventName] = function(...)
    Events.broadcast(loveEventName, ...)
  end
end

Events.hook("mousemoved")
Events.hook("mousepressed")
Events.hook("mousereleased")
Events.hook("keypressed")
Events.hook("keyreleased")
Events.hook("resize")
Events.hook("load")
Events.hook("update")
Events.hook("draw")
Events.hook("quit")

return Events
