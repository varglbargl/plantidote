local Events = require("Events")
local GameObject = require("GameObject")
local Console = require("Console")
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

  return {x1 = btn.x + alignPx.x - btn.width * btn.anchor[1] * btn.scale.x, y1 = btn.y + alignPx.y - btn.height * btn.anchor[2] * btn.scale.y, x2 = btn.x + alignPx.x + btn.width * (1 - btn.anchor[1]) * btn.scale.x, y2 = btn.y + alignPx.y + btn.height * (1 - btn.anchor[2]) * btn.scale.y}
end

local function isInside(btn, x, y)
  local hitbox = getHitbox(btn)

  if btn:isActive() and btn:isVisible() and x > hitbox.x1 and y > hitbox.y1 and x < hitbox.x2 and y < hitbox.y2 then
    if not btn:isFocussed() then

      if focussedButton and focussedButton ~= btn then
        btn:unfocus()
        Events.broadcast("unhovered", focussedButton, x, y)
      end

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

local function checkMouseOver(x, y, btn)
  x = x or love.mouse.getX()
  y = y or love.mouse.getY()

  -- if focussedButton then
  --   isInside(focussedButton, x, y)
  -- else
    for i = #buttonList, 1, -1 do
      if buttonList[i]:isActive() and buttonList[i]:isVisible() and isInside(buttonList[i], x, y) then
        return buttonList[i]
      end
    end
  -- end
end

Events.connect("mousemoved", checkMouseOver)

local function removeFromBtnList(btn)
  for i, b in ipairs(buttonList) do
    if b == btn then
      if focussedButton == btn then
        focussedButton = nil
      end

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
  btn.textAlign = params.textAlign or {0.5, 0.5}
  btn.rotation = 0 -- buttons do not yet support rotation

  if params.tabOrder then
    btn.tabOrder = params.tabOrder + y + x / 10 + btn.id / 100
  else
    btn.tabOrder = y + x / 10 + btn.id / 100
  end

  btn.canvas = love.graphics.newCanvas(btn.width, btn.height)

  local function redrawCanvas()

    local function rectStencil()
      love.graphics.rectangle("fill", 0, 0, btn.width, btn.height, params.cornerRadius)
    end

    if params.cornerRadius then
      love.graphics.setCanvas({btn.canvas, stencil = true})
      love.graphics.stencil(rectStencil, "replace", 1)
      love.graphics.setStencilTest("greater", 0)
    else
      love.graphics.setCanvas(btn.canvas)
    end

    local bt = params.borderThickness or 2

    if params.backgroundColor then
      love.graphics.setColor(params.backgroundColor)
      love.graphics.rectangle("fill", bt / 2, bt / 2, btn.width - bt, btn.height - bt, params.cornerRadius)
      love.graphics.setColor()
    end

    if btn.image then
      love.graphics.draw(btn.image, 0, 0, 0, btn.width / btn.image:getWidth(), btn.height / btn.image:getHeight())
    end

    if btn.label then
      love.graphics.push()
      local buttonText = love.graphics.newText(love.graphics.newFont(params.font, params.fontSize or math.floor(btn.height / 1.7)), btn.label)
      local tw, th = buttonText:getDimensions()

      love.graphics.setColor(params.fontColor or "black")
      love.graphics.draw(buttonText, btn.width * btn.textAlign[1], btn.height * btn.textAlign[2], 0, 1, 1, tw * btn.textAlign[1], th * btn.textAlign[2])
      love.graphics.pop()
    end

    if params.borderThickness or params.borderColor then
      love.graphics.push()
      love.graphics.setLineWidth(bt)
      love.graphics.setColor(params.borderColor or "black")
      love.graphics.rectangle("line", bt / 2, bt / 2, btn.width - bt, btn.height - bt, params.cornerRadius)
      love.graphics.setColor()
      love.graphics.pop()
    end

    love.graphics.setStencilTest()
    love.graphics.setCanvas()
  end

  redrawCanvas()

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
      Events.disconnect("resize", redrawCanvas)
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

  Events.connect("resize", redrawCanvas)
  Events.connect("hovered", btn.onHovered)
  Events.connect("unhovered", btn.onUnhovered)
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
    checkMouseOver()
  end
end

function Button:setPosition(vec2, y)
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

function Button:setRotation()
  -- nothing
end

function Button:isFocussed()
  return focussedButton == self
end

function Button:setActive(tralse)
  self.active = tralse
  checkMouseOver()
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
    love.graphics.setCanvas(self.canvas)

    if self:isFocussed() then
      love.graphics.setColor("green")
    else
      love.graphics.setColor("red")
    end

    love.graphics.rectangle("line", 1, 1, self.width-2, self.height-2)
    love.graphics.setColor()
    love.graphics.setCanvas()
  end

  love.graphics.draw(self.canvas, self.x + alignPx.x, self.y + alignPx.y, self.rotation, self.scale.x, self.scale.y, self.offset.x + anchorPx.x, self.offset.y + anchorPx.y)

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

return Button
