local connect = require("Events").connect

local Task = {}
local jobs = {}

function Task.tick()
  for i, co in ipairs(jobs) do
    if coroutine.status(co) == "suspended" then
      local working, message = coroutine.resume(co)

      if not working then
        error("Error in task:\n  ->  "..message)
      end

    else
      table.remove(jobs, i)
    end
  end
end

function Task.spawn(callback)
  local co = coroutine.create(callback)
  table.insert(jobs, co)
  return co
end

function Task.wait(secs)
  if not coroutine.running() then return end

  secs = secs or 0
  local currentTime = love.timer.getTime()
  local startTime = currentTime
  local endTime = startTime + secs

  while currentTime <= endTime do
    coroutine.yield()
    currentTime = love.timer.getTime()
  end

  return currentTime - startTime
end

function Task.after(secs, callback)
  Task.spawn(function()
    Task.wait(secs)
    callback()
  end)
end

function Task.kill(co)
  co = co or Task.getCurrent()
  if not co then return end

  for i, v in ipairs(jobs) do
    if v == co then
      table.remove(jobs, i)
      break
    end
  end
end

function Task.killAll()
  jobs = {}
end

function Task.getCurrent()
  return coroutine.running()
end

connect("update", Task.tick)

return Task
