local W = require "workspace"
local S = require "scorer"
local R = require "reference"

local GS = {}
GS.__index = GS

local MAX_SECONDS = 10
local MAX_ROUNDS = 24 -- max different masks
    
  --load main scene-specific audio
local timerSound = love.audio.newSource("assets/audio/tickTock.wav", "static")
local timerFull = love.audio.newSource("assets/audio/timerFull.wav", "static")
timerSound:setVolume(.5)

local function canSpendSecond(spentSeconds)
  local newSeconds = spentSeconds + 1

  if newSeconds > MAX_SECONDS then
    return false, 0
  end

  return true, newSeconds
end

local function refundSecond(self)
  local newSeconds = self.spentSeconds - 1

  if newSeconds < 0 then
    return false
  end

  self.spentSeconds = newSeconds

  return true
end

local function resetSeconds(self)
  self.spentSeconds = 0
end

local function nextRound(self)
  local newRound = self.currentRound + 1

  if newRound > MAX_ROUNDS then
    return -1
  end

  self.spentSeconds = 0
  self.currentRound = self.currentRound + 1

  return self.currentRound
end

function GS.new()
  local self = setmetatable({
    scene = Scenes.TITLE,
    sceneNeedsActivation = false,
    spentSeconds = 0,
    currentRound = 1,
    workspace = W.new(),
    scorer = S.new(),
    reference = R.new(),
    selectedItem = nil,
    lastResult = nil
  }, GS)

  return self
end

function GS.seconds(self)
  return {
    spent = self.spentSeconds,
    max = MAX_SECONDS
  }
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
    self:setScene(Scenes.INTRO_HELP)
  elseif self.scene == Scenes.INTRO_HELP or self.scene == Scenes.ROUND_END then
    self:setScene(Scenes.NEW_REQUEST)
  elseif self.scene == Scenes.HELP or self.scene == Scenes.NEW_REQUEST then
    self:setScene(Scenes.GAME)
  end

  return self.sceneNeedsActivation
end

function GS.placeItem(self, x, y)
  local canSpend, newSeconds = canSpendSecond(self.spentSeconds)
  if canSpend and self.workspace:_placeItem(self.selectedItem, x, y) then
    self.spentSeconds = newSeconds
    if newSeconds == MAX_SECONDS then
      timerFull:play()
    else
      timerSound:play()
    end
  end

  self:selectItem(nil)
end

function GS.undoItem(self)
  if refundSecond(self) then
    self.workspace:_undoItemPlacement()
  end
end

function GS.removeItem(self, placedItem)
  if refundSecond(self) then
    self:selectItem(self.workspace.objects[placedItem].idx)
    self.workspace:_removeItem(placedItem)
  end
end

function GS.clearWorkspace(self)
  resetSeconds(self)
  self.workspace:_clearItems()
end

function GS.nextRound(self)
  if self.spentSeconds < 1 then
    return false
  end

  local data = self.reference:getData(self.reference.currentIdx)
  self.lastResult = self.workspace:getImageData()
  self.scorer:lockIn(data["maskData"], data["maskSprite"], self.lastResult, self.spentSeconds, self.currentRound, self.reference.currentIdx)
  local round = nextRound(self)

  if round == -1 then
    self:setScene(Scenes.GAME_OVER)
    return false
  end

  self.reference:_nextIdx()
  self.selectedItem = nil
  self.workspace:_reset()
  self:setScene(Scenes.ROUND_END)

  return true
end

function GS.drawSelectedItem(self, x, y)
    if self.selectedItem == nil then
      return
    end

    local workspace = self.workspace

    workspace.drawItem(workspace.texture, workspace.sprites[self.selectedItem], x, y, workspace.itemRotation, workspace.isMirrorX, workspace.isMirrorY)
end

function GS.selectItem(self, itemIndex)
  self.selectedItem = itemIndex
end

return GS