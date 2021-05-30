local Events = require("Events")
local GameObject = require("GameObject")
local Console = require("Console")
local Color = require("Color")
local Vector2 = require("Vector2")
local Class = require("Class")
local Task = require("Task")

local Button = Class:new("Button")
Class.extend(Button, GameObject)

local buttonList = {}
local focussedButton = nil


local function getHitbox(btn)
  local alignPx = Vector2.zero

  if btn.parent then
    alignPx = Vector2:new(btn.parent.width * btn.align[1], btn.parent.height * btn.align[2])
  else
    alignPx = Vector2:new(love.window.width * btn.align[1], love.window.height * btn.align[2])
  end

  return {x1 = btn.x + alignPx.x - btn.width * btn.anchor[1], y1 = btn.y + alignPx.y - btn.height * btn.anchor[2], x2 = btn.x + alignPx.x + btn.width * (1 - btn.anchor[1]), y2 = btn.y + alignPx.y + btn.height * (1 - btn.anchor[2])}
end

local function isInside(btn, x, y)
  if not btn:isActive() then return end
  local hitbox = getHitbox(btn)

  if x > hitbox.x1 and y > hitbox.y1 and x < hitbox.x2 and y < hitbox.y2 then
    if not btn:isFocussed() then
      btn:focus()
      Events.broadcast("hovered", btn, x, y)
    end

    return true
  else
    if btn:isFocussed() then
      btn:unfocus()
      Events.broadcast("unhovered", btn, x, y)
    end

    return false
  end
end

local function checkMouseOver(x, y)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()

  if focussedButton then
    isInside(focussedButton, x, y)
  else
    for i = #buttonList, 1, -1 do
      if isInside(buttonList[i], x, y) then break end
    end
  end
end

Events.connect("mousemoved", checkMouseOver)

local function removeFromBtnList(btn)
  for i, b in ipairs(buttonList) do
    if b == btn then
      btn:unfocus()
      table.remove(buttonList, i)
      Task.spawn(function()
        Task.wait()
        checkMouseOver()
      end)
      break
    end
  end
end

function Button:__tostring()
  return string.format("<Button - label:%s id:%s>", self.label, self.id)
end

function Button:new(x, y, params)
  if typeOf(x) == "table" then
    return Button:new(x.x, x.y, x)
  elseif typeOf(x) == "Vector2" then
    return Button:new(x.x, x.y, y)
  end

  params = params or {}
  local btn = GameObject:new(x, y, params)
  Class.extend(btn, Button)

  btn.focussed = false
  btn.active = params.active or true
  btn.label = params.label
  btn.rotation = 0 -- buttons do not yet support rotation

  if params.tabOrder then
    btn.tabOrder = params.tabOrder + y + x / 10 + btn.id / 100
  else
    btn.tabOrder = y + x / 10 + btn.id / 100
  end

  if params.backgroundImage and type(params.backgroundImage) == "string" then
    btn.backgroundImage = love.graphics.newImage(params.backgroundImage)
  elseif params.backgroundImage and params.backgroundImage:typeOf("Drawable") then
    btn.backgroundImage = params.backgroundImage
  end

  btn.canvas = love.graphics.newCanvas(btn.width, btn.height)

  love.graphics.setCanvas(btn.canvas)

  if btn.backgroundImage then
    love.graphics.draw(btn.backgroundImage, 0, 0, 0, btn.width / btn.backgroundImage:getWidth(), btn.height / btn.backgroundImage:getHeight())
  end

  love.graphics.setCanvas()

  function btn.onHovered(whichBtn, mouseX, mouseY)
    if whichBtn ~= btn then return end

    if params.hovered then
      params.hovered(btn, mouseX, mouseY)
    end
  end

  function btn.onUnhovered(whichBtn, mouseX, mouseY)
    if whichBtn ~= btn then return end

    if params.unhovered then
      params.unhovered(btn, mouseX, mouseY)
    end
  end

  function btn.onMousePressed(mouseX, mouseY, mouseBtn)
    if btn:isFocussed() and params.pressed then
      params.pressed(btn, mouseX, mouseY, mouseBtn)
      isInside(btn, mouseX, mouseY)
    end
  end

  function btn.onMouseReleased(mouseX, mouseY, mouseBtn)
    if btn:isFocussed() and params.released then
      params.released(btn, mouseX, mouseY, mouseBtn)
      isInside(btn, mouseX, mouseY)
    end
  end

  function btn.onDestroyed(id)
    if id == btn.id then
      Events.disconnect("hovered", btn.onHovered)
      Events.disconnect("unhovered", btn.onUnhovered)
      Events.disconnect("mousepressed", btn.onMousePressed)
      Events.disconnect("mousereleased", btn.onMouseReleased)
      Events.disconnect("destroyed", btn.onDestroyed)
      btn:unfocus()
      removeFromBtnList(btn)
    end
  end

  table.insert(buttonList, btn)

  Events.connect("hovered", btn.onHovered)
  Events.connect("unhovered", btn.onUnhovered)
  Events.connect("mousemoved", btn.onMouseMoved)
  Events.connect("mousepressed", btn.onMousePressed)
  Events.connect("mousereleased", btn.onMouseReleased)
  Events.connect("destroyed", btn.onDestroyed)

  return btn
end

function Button:focus()
  if not self:isFocussed() and self:isValid() then
    if focussedButton then focussedButton:unfocus() end

    focussedButton = self
  end
end

function Button:unfocus()
  if self:isFocussed() then
    focussedButton = nil
  end
end


function GameObject:setPosition(vec2, y)
  if type(vec2) == "number" and type(y) == "number" then
    self:setPosition({vec2, y})
    return
  end

  vec2 = vec2 or Vector2.zero
  self.position = Vector2:new(vec2)
  self.x = self.position.x
  self.y = self.position.y

  checkMouseOver()
end

function Button:isFocussed()
  return focussedButton == self
end

function Button:setActive(tralse)
  self.active = tralse
end

function Button:isActive()
  return self.active
end

function Button:draw()
  if not self.visible then return end

  local alignPx = Vector2.zero
  local anchorPx = Vector2:new(self.width * self.anchor[1], self.height * self.anchor[2])

  if self.parent then
    alignPx = Vector2:new(self.parent.width * self.align[1], self.parent.height * self.align[2])
  else
    alignPx = Vector2:new(love.window.width * self.align[1], love.window.height * self.align[2])
  end

  if Console.debugMode then
    if self:isFocussed() then
      love.graphics.setColor(Color.green)
    else
      love.graphics.setColor(Color.red)
    end

    love.graphics.setCanvas(self.canvas)
    love.graphics.rectangle("line", 1, 1, self.width-2, self.height-2)
    love.graphics.setCanvas()
    love.graphics.setColor(Color.white)
  end

  love.graphics.draw(self.canvas, self.x + alignPx.x, self.y + alignPx.y, self.rotation, self.scale.x, self.scale.y, self.offset.x + anchorPx.x, self.offset.y + anchorPx.y)

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

return Button
