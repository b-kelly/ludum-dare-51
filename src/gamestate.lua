local W = require "workspace"
local S = require "scorer"
local R = require "reference"
local utils = require "utils"

local GS = {}
GS.__index = GS

local MAX_SECONDS = 10
local MAX_ROUNDS = 10 -- max rounds to send the player through

local _customerSheetXCount = 7
local _customerSheetYCount = 4
local TOTAL_CUSTOMER_SPRITES = _customerSheetXCount * _customerSheetYCount

local timerSound
local timerFull
local referenceArrives

local function refundSecond(self)
  local newSeconds = self.spentSeconds - 1

  if newSeconds < 0 then
    return false
  end

  self.spentSeconds = newSeconds

  return true
end

local function genRandomCustomer()
  return {
    clothes = love.math.random(1, TOTAL_CUSTOMER_SPRITES),
    face = love.math.random(1, TOTAL_CUSTOMER_SPRITES),
    hair = love.math.random(1, TOTAL_CUSTOMER_SPRITES),
    head = love.math.random(1, TOTAL_CUSTOMER_SPRITES),
    name = love.math.random(1, #customerNames)
  }
end

local function resetSeconds(self)
  self.spentSeconds = 0
end

function GS.new()
  local self = setmetatable({
    scene = Scenes.TITLE,
    sceneNeedsActivation = true,
    spentSeconds = 0,
    currentRound = 1,
    currentCustomerData = nil,
    workspace = W.new(),
    scorer = S.new(),
    reference = R.new(),
    selectedItem = nil,
    lastResult = nil,
    audioSources = {},
    playingAudio = {},
  }, GS)

  --load main scene-specific audio
  timerSound = self:loadAudioSource("assets/audio/tickTock.wav", "static")
  timerFull = self:loadAudioSource("assets/audio/timerFull.wav", "static")
  referenceArrives = self:loadAudioSource("assets/audio/referenceArriving.mp3", "static")
  timerSound:setVolume(.7)
  return self
end

function GS.loadAudioSource(self, filename, type)
  local source = love.audio.newSource(filename, type)
  table.insert(self.audioSources, timerSound)
  return source
end

function GS.playAudioSource(self, source)
  if love.system.getOS() == "Web" then
    return
  end

  table.insert(self.playingAudio, source)
  source:play()
end

function GS.stopAudio(self)
  if love.system.getOS() == "Web" then
    return
  end

  if not pcall(function()
    love.audio.stop(self.playingAudio)
  end) then
    -- ¯\_(ツ)_/¯
  end
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
    self:setScene(Scenes.INTRO_STORY)
  elseif self.scene == Scenes.INTRO_STORY then
    self:setScene(Scenes.INTRO_HELP)
  elseif self.scene == Scenes.INTRO_HELP then
    self:setScene(Scenes.INTRO_BEGIN)
  elseif self.scene == Scenes.ROUND_END and self.currentRound >= MAX_ROUNDS then
    self:setScene(Scenes.GAME_OVER)
  elseif self.scene == Scenes.INTRO_BEGIN or self.scene == Scenes.ROUND_END then
    self.currentCustomerData = genRandomCustomer()
    self:setScene(Scenes.NEW_REQUEST)
  elseif self.scene == Scenes.HELP or self.scene == Scenes.NEW_REQUEST then
    self:setScene(Scenes.GAME)
    self:playAudioSource(referenceArrives)
  end

  return self.sceneNeedsActivation
end

function GS.canSpendSecond(self)
  local newSeconds = self.spentSeconds + 1

  if newSeconds > MAX_SECONDS then
    return false, 0
  end

  return true, newSeconds
end

function GS.placeItem(self, x, y)
  local canSpend, newSeconds = self:canSpendSecond()
  if canSpend and self.workspace:_placeItem(self.selectedItem, x, y) then
    self.spentSeconds = newSeconds
    if newSeconds == MAX_SECONDS then
      self:playAudioSource(timerFull)
    else
      self:playAudioSource(timerSound)
    end
  end

  self:selectItem(nil)
end

function GS.undoItem(self)
  if self.selectedItem ~= nil then
    self.selectedItem = nil
    return
  end
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

function GS.canFinishCurrentRound(self)
  return self.spentSeconds >= 1
end

function GS.nextRound(self)
  if not self:canFinishCurrentRound() then
    return false
  end

  local data = self.reference:getData(self.reference.currentIdx)
  self.lastResult = self.workspace:getImageData()
  self.scorer:lockIn(data["maskData"], data["maskSprite"], self.lastResult, self.spentSeconds, self.currentRound, self.reference.currentIdx)

  self.spentSeconds = 0
  self.currentRound = self.currentRound + 1
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

function GS.getTipJarContents(self)
  local totalAmt = 0

  for i=1, #self.scorer.roundScores do
    local score = self.scorer.roundScores[i].score
    local _, __, amt = utils.getScoreRank(score)
    totalAmt = totalAmt + amt
  end

  return totalAmt
end

function GS.getRoundInfo(self)
  return self.currentRound, MAX_ROUNDS
end

return GS