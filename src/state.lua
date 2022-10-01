GS = {}
GS.__index = GS

local maxPoints = 10

function GS.new()
  local self = setmetatable({
      spentPoints = 0,
      currentRound = 0
  }, GS)

  return self
end

function GS.spendPoint(self)
  local newPoints = self.spentPoints + 1
  
  if newPoints > maxPoints then
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

function GS.nextRound(self)
  self.spentPoints = 0
  self.currentRound = self.currentRound + 1
  
  return self.currentRound
end

return GS