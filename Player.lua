local Class = require("Class")
local GameObject = require("GameObject")
local Events = require("Events")
local Game = require("Game")
local Vector2 = require("Vector2")

local Player = Class:new("Player")
Class.extend(Player, GameObject)

local function checkCollision(plr)
  return true
end

function Player:new(params)

  params = params or {}
  params.parent = params.parent or Game.screen.world

  local plr = GameObject:new(love.window.width / 2, love.window.height / 2, params)
  Class.extend(plr, Player)

  plr.speed = 5
  plr.flip = 1
  plr.flop = 1
  plr.anchor = {0.5, 0.75}
  plr.enabled = params.enabled or false

  local function walk(dt)
    if not plr:isEnabled() then return end
    local to = {0, 0}

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then

      if checkCollision(plr) then
        to[1] = 1
      end

      plr.flip = 1
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then

      if checkCollision(plr) then
        to[1] = -1
      end

      plr.flip = -1
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then

      if checkCollision(plr) then
        to[2] = -1
      end

      plr.flop = -1
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then

      if checkCollision(plr) then
        to[2] = 1
      end

      plr.flop = 1
    end

    to = Vector2:new(to)

    if to.size > 0 then
      plr:setScale(Vector2:new(plr.flip, 1))
      plr:setPosition(plr:getPosition() + to:getNormalized() * plr.speed * 60 * dt)
    end
  end

  Events.connect("update", walk)

  return plr
end

function Player:isEnabled()
  return self.enabled
end

function Player:enable()
  self.enabled = true
end

function Player:disable()
  self.enabled = false
end

return Player
