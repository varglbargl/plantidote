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

local function isInside(btn, x, y)
  if not btn:isActive() then return end

  if x > btn.hitbox.x1 and y > btn.hitbox.y1 and x < btn.hitbox.x2 and y < btn.hitbox.y2 then
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
    if isInside(focussedButton, x, y) then return end
  else
    for i = #buttonList, 1, -1 do
      if isInside(buttonList[i], x, y) then return end
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

  btn.width = params.width or 200
  btn.height = params.height or 50
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

  btn.hitbox = {x1 = x, y1 = y, x2 = x + btn.width, y2 = y + btn.height}

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

function Button:setPosition(vec2)
  self.position = Vector2:new(vec2)
  self.x = self.position.x
  self.y = self.position.y
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

  love.graphics.draw(self.canvas, self.x, self.y, self.rotation, self.scale.x, self.scale.y, self.offset.x, self.offset.y)

  if Console.debugMode then
    if self:isFocussed() then
      love.graphics.setColor(Color.green)
    else
      love.graphics.setColor(Color.red)
    end

    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(Color.white)
  end

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

return Button
