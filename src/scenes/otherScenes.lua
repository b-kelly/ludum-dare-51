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
local dialogBg

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

  -- print the score
  love.graphics.printf(utils.formatScore(meta.lastRound.score) .. " " .. meta.lastRound.secondsSpent .. " seconds to complete", xLeft, yTop + gap + imgWidth + 40, 800, "center")

  local response = meta.response or "ERROR DID NOT ACTIVATE"
  
  love.graphics.printf(response, 0, 600 - 50, 800, "center")
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
  love.graphics.draw(dialogBg)
  local yGap = 36
  local xGap = 32
  local convo = meta.conversation or {{name = "ERROR", text = "NewRequestScreen DID NOT ACTIVATE"}}
  for i=1,#convo do
    local idx = i - 1
    local avatarOnLeft = i == 1 or i == #convo
    local xLeft = avatarOnLeft and (xGap + 150) or xGap
    local yTop = 150 * idx + yGap

    love.graphics.printf(convo[i], xLeft, yTop, 600, "left")
  end
end

function SO.load()
  titleBg = love.graphics.newImage("assets/title.png")
  introBg = love.graphics.newImage("assets/introCard.png")
  howToPlayBg = love.graphics.newImage("assets/howToPlayCard.png")
  beginBg = love.graphics.newImage("assets/beginCard.png")
  dialogBg = love.graphics.newImage("assets/dialogueBg.png")
  grandFantasy = love.audio.newSource("assets/audio/grandFantasy.mp3", "stream")
  backgroundBeatz = love.audio.newSource("assets/audio/backgroundBeatz.mp3", "stream")
  goblinMischief = love.audio.newSource("assets/audio/goblinMischief.mp3", "stream")

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

function SO.handleMousepress(gameState, x, y)
  if gameState.scene ~= Scenes.GAME then
    gameState:nextScene()
    return true
  end

  return false
end

function SO.handleKeypress(gameState, key, scancode, isrepeat)
  if key == "return" and gameState.scene ~= Scenes.GAME then
    gameState:nextScene()

    return true
  end

  return false
end

return SO