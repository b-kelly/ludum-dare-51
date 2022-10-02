local W = require "workspace"
local S = require "scorer"
local R = require "reference"

local GS = {}
GS.__index = GS

local MAX_SECONDS = 10
local MAX_ROUNDS = 24 -- max different masks

function GS.new()
  local self = setmetatable({
    scene = Scenes.TITLE,
    sceneNeedsActivation = false,
    spentSeconds = 0,
    currentRound = 1,
    workspace = W.new(),
    scorer = S.new(),
    reference = R.new()
  }, GS)

  return self
end

function GS.spendSecond(self)
  local newSeconds = self.spentSeconds + 1

  if newSeconds > MAX_SECONDS then
    return false
  end

  self.spentSeconds = newSeconds

  return true
end

function GS.refundSecond(self)
  local newSeconds = self.spentSeconds - 1

  if newSeconds < 0 then
    return false
  end

  self.spentSeconds = newSeconds

  return true
end

function GS.seconds(self)
  return {
    spent = self.spentSeconds,
    max = MAX_SECONDS
  }
end

function GS.nextRound(self)
  local newRound = self.currentRound + 1

  if newRound > MAX_ROUNDS then
    return -1
  end

  self.spentSeconds = 0
  self.currentRound = self.currentRound + 1

  return self.currentRound
end

function GS.setScene(self, scene)
  self.scene = scene
  self.sceneNeedsActivation = true
end

function GS.nextScene(self)
  if self.scene == Scenes.GAME then
    return false
  end

  if self.scene == Scenes.TITLE then
    self:setScene(Scenes.HELP)
  elseif self.scene == Scenes.HELP or self.scene == Scenes.ROUND_END then
    self:setScene(Scenes.GAME)
  end

  return self.sceneNeedsActivation
end

return GS