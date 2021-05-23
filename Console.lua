local Task = require("Task")
local Color = require("Color")

local Console = {}

local log = {}
local shownLines = 0
local cleanupTasks = {}

local function cancelCleanupTasks()
  for i, ctask in ipairs(cleanupTasks) do
    Task.kill(ctask)
  end

  cleanupTasks = {}
end

function Console.log(message, textColor)
  if type(textColor) == "string" then
    textColor = Color[textColor]
  end

  textColor = textColor or Color.white

  table.insert(log, {text = message, color = textColor})
  Console.show(1)
end

function Console.show(howManyLines)
  if not howManyLines then
    howManyLines = #log
    cancelCleanupTasks()
  end

  shownLines = math.min(shownLines + howManyLines, #log)

  local co = Task.spawn(function()
    Task.wait(3)
    shownLines = math.max(shownLines - howManyLines, 0)
    table.remove(cleanupTasks, 1)
  end)

  table.insert(cleanupTasks, co)
end

function Console.clear()
  log = {
    {
      text = "<console cleared>",
      color = Color.gray
    }
  }
  shownLines = 0
  cancelCleanupTasks()
end

function Console.draw()
  local logHeight = 18 * shownLines

  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 40, love.window.height - logHeight - 40, love.window.width - 80, logHeight)

  for i = 1, shownLines do
    local message = log[#log - shownLines + i]
    local messageColor = message.color
    local messageText = message.text

    if type(messageColor) == "function" then
      messageColor = messageColor()
    end

    if type(messageText) == "function" then
      messageText = messageText()
    end

    love.graphics.setColor(Color.average(messageColor, Color.white))
    -- love.graphics.print(text,x,y,r,sx,sy,ox,oy)
    love.graphics.print(tostring(messageText), 42, love.window.height - logHeight - 58 + i * 18)
  end
end

return Console
