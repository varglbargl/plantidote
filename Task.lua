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
  local startTime = love.game.time
  local endTime = startTime + secs

  while love.game.time <= endTime do
    coroutine.yield()
  end

  return love.game.time - startTime
end

function Task.kill(co)
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

return Task
