local W = require "workspace"
local S = require "scorer"
local R = require "reference"

local GS = {}
GS.__index = GS

local MAX_POINTS = 10
local MAX_ROUNDS = 24 -- max different masks

function GS.new()
  local self = setmetatable({
    scene = Scenes.TITLE,
    spentPoints = 0,
    currentRound = 1,
    workspace = W.new(),
    scorer = S.new(),
    reference = R.new()
  }, GS)

  return self
end

function GS.spendPoint(self)
  local newPoints = self.spentPoints + 1

  if newPoints > MAX_POINTS then
    return false
  end

  self.spentPoints = newPoints

  return true
end

function GS.refundPoint(self)
  local newPoints = self.spentPoints - 1

  if newPoints < 0 then
    return false
  end

  self.spentPoints = newPoints

  return true
end

function GS.points(self)
  return {
    spent = self.spentPoints,
    max = MAX_POINTS
  }
end

function GS.nextRound(self)
  local newRound = self.currentRound + 1

  if newRound > MAX_ROUNDS then
    return -1
  end

  self.spentPoints = 0
  self.currentRound = self.currentRound + 1

  return self.currentRound
end

function GS.setScene(self, scene)
  self.scene = scene
end

function GS.nextScene(self)
  if self.scene == Scenes.GAME then
    return
  end

  if self.scene == Scenes.TITLE then
    self.scene = Scenes.HELP
  elseif self.scene == Scenes.HELP or self.scene == Scenes.ROUND_END then
    self.scene = Scenes.GAME
  end
end

return GS