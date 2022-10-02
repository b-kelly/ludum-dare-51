GS = {}
GS.__index = GS

local MAX_POINTS = 10
local MAX_ROUNDS = 24 -- max different masks

function GS.new()
  local self = setmetatable({
      spentPoints = 0,
      currentRound = 0
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

return GS