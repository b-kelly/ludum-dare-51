local utils = require "utils"
local strings = require "strings"

local SO = {}
SO.__index = SO

local titleBg
local introBg
local howToPlayBg
local beginBg
local meta = {}
local grandFantasy
local backgroundBeatz
local goblinMischief
local gameOverMusic

local function drawGameOverScreen(scorer)
  love.graphics.print("Game Over", 0, 0)

  love.graphics.print("Best round: " .. scorer.best.round .. " " .. utils.formatScore(scorer.best.score), 0, 20)
  love.graphics.print("Worst round: " .. scorer.worst.round .. " " .. utils.formatScore(scorer.worst.score), 0, 40)
end

local function drawTitleScreen()
  love.graphics.draw(titleBg, 0, 0)
  love.graphics.print("Press 'Enter' to continue", 160, 330)
end

local function drawIntroStoryScreen()
  love.graphics.draw(introBg, 0, 0)
  love.graphics.print("Press 'Enter' to continue", 460, 560)
end

local function drawIntroBeginScreen()
  love.graphics.draw(beginBg, 0, 0)
  love.graphics.print("Press 'Enter' to begin!", 360, 560)
end

local function newTextBox(name, text, x, y, avatarIsOnRight)
  -- TODO this could probably be better served w/ an image bg
  -- TODO need support for image on the right vs left

  local nameBoxHeight = 20
  local nameBoxWidth = 100
  local avatarHeight = 100
  local inset = 8
  local largeBoxWidth = 800 - avatarHeight - (inset)
  local nbOffset = nameBoxHeight / 2
  local xLeft = x + avatarHeight + inset
  local smallXLeft = xLeft + nameBoxHeight
  local yTop = y + nbOffset
  local smallYTop = y

  -- draw the boxes the same color as reference grid bg
  love.graphics.setColor(0.22, 0.19, 0.29)
  love.graphics.rectangle("fill", xLeft, yTop, largeBoxWidth, avatarHeight - nbOffset)
  love.graphics.rectangle("fill", smallXLeft, smallYTop, nameBoxWidth, nameBoxHeight)

  --draw the avatar box
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", x, y, avatarHeight, avatarHeight)

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(name, smallXLeft, smallYTop, nameBoxWidth, "center")
  love.graphics.printf(text, xLeft + inset, yTop + inset + nbOffset, 800, "left")
end

local function activateRoundEndScreen(state)
  local lastRound = state.scorer.roundScores[#state.scorer.roundScores]
  meta = {
    lastRound = lastRound,
    response = strings.getRandomScoreResponse(lastRound.score),
    resultImg = love.graphics.newImage(state.lastResult),
    refData = state.reference:getData(lastRound.referenceIdx)
  }
  love.audio.stop()
  backgroundBeatz:play()
end

local function drawRoundEndScreen(state)
  local yTop = 0
  local xLeft = 0
  local imgWidth = 256
  local gap = 8

  -- draw the reference image
  state.reference:drawItem(meta.lastRound.referenceIdx, xLeft, yTop)
  love.graphics.printf("Target", xLeft, yTop + gap + imgWidth, imgWidth, "center")

  -- draw the result image
  local xLeft2 = xLeft + imgWidth + gap
  utils.drawMask(meta.resultImg, nil, xLeft2, yTop, function()
    love.graphics.draw(meta.refData.textureImg, meta.refData.textureSprite, xLeft2, yTop)
  end)
  love.graphics.printf("Result", xLeft2, yTop + gap + imgWidth, imgWidth, "center")

  local textHeight = 40 --TODO ???

  -- print the score
  love.graphics.printf(utils.formatScore(meta.lastRound.score) .. " " .. meta.lastRound.secondsSpent .. " seconds to complete", xLeft, yTop + gap + imgWidth + textHeight, 800, "center")

  local response = meta.response or "ERROR DID NOT ACTIVATE"
  newTextBox("Customer", response, 0, 500)
end

local function drawHelpScreen()
  -- TODO
  love.graphics.draw(howToPlayBg, 0, 0)
  love.graphics.print("Press 'Enter' to continue", 360, 560)

  love.graphics.printf("Controls: rotate (e, r); flip (q, w); finalize (space); undo (z); clear (c); show help (h)", 0, 20, 600, "left")
end

local function activateNewRequestScreen(state)
  meta = {
    conversation = strings.getRandomConversation(state.reference:getItemIdx(state.reference.currentIdx))
  }
  if state.currentRound ~= 1 then 
    love.audio.stop()
    goblinMischief:play()
  end
end

local function drawNewRequestScreen()
  local gap = 8
  local convo = meta.conversation or {{name = "ERROR", text = "NewRequestScreen DID NOT ACTIVATE"}}
  for i=1,#convo do
    newTextBox(convo[i]["name"], convo[i]["text"], 0, (100 * (i - 1)) + (gap * (i - 1)))
  end
end

function SO.load()
  titleBg = love.graphics.newImage("assets/title.png")
  introBg = love.graphics.newImage("assets/introCard.png")
  howToPlayBg = love.graphics.newImage("assets/howToPlayCard.png")
  beginBg = love.graphics.newImage("assets/beginCard.png")
  grandFantasy = love.audio.newSource("assets/audio/grandFantasy.mp3", "stream")
  backgroundBeatz = love.audio.newSource("assets/audio/backgroundBeatz.mp3", "stream")
  goblinMischief = love.audio.newSource("assets/audio/goblinMischief.mp3", "stream")
  gameOverMusic = love.audio.newSource("assets/audio/imperfectCopySong.mp3", "stream")

  grandFantasy:seek(2, "seconds")
  grandFantasy:setVolume(.3)
  backgroundBeatz:setVolume(.2)
  goblinMischief:setVolume(.3)
end

function SO.activate(scene, state)
  meta = {}

  if scene == Scenes.GAME then
    return false
  end

  if scene == Scenes.GAME_OVER then
    --activateGameOverScreen(state.scorer)
  elseif scene == Scenes.TITLE then
    --TODO put this in a function probs
    grandFantasy:play()
  elseif scene == Scenes.ROUND_END then
    activateRoundEndScreen(state)
  elseif scene == Scenes.HELP or scene == Scenes.INTRO_HELP then
    --activateHelpScreen()
  elseif scene == Scenes.NEW_REQUEST then
    activateNewRequestScreen(state)
  end

  return true
end

function SO.drawScene(scene, state)
  if scene == Scenes.GAME then
    return false
  end

  if scene == Scenes.GAME_OVER then
    drawGameOverScreen(state.scorer)
  elseif scene == Scenes.TITLE then
    drawTitleScreen()
  elseif scene == Scenes.ROUND_END then
    drawRoundEndScreen(state)
  elseif scene == Scenes.HELP or scene == Scenes.INTRO_HELP then
    drawHelpScreen()
  elseif scene == Scenes.INTRO_STORY then
    drawIntroStoryScreen()
  elseif scene == Scenes.INTRO_BEGIN then
    drawIntroBeginScreen()
  elseif scene == Scenes.NEW_REQUEST then
    drawNewRequestScreen()
  end

  return true
end

function SO.handleKeypress(gameState, key, scancode, isrepeat)
  if key == "return" and gameState.scene ~= Scenes.Game then
    gameState:nextScene()

    return true
  end

  return false
end

return SO