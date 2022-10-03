local utils = require "utils"
local strings = require "strings"

local SO = {}
SO.__index = SO

local titleBg
local introBg
local howToPlayBg
local resultsBg
local beginBg
local meta = {}
local grandFantasy
local backgroundBeatz
local goblinMischief
local dialogBg
local badgeA
local badgeB
local badgeC
local badgeD
local badgeF
local gameOverBg
local customerClothes
local customerFace
local customerHair
local customerHead
local customerSheet

local function drawRandomCustomer(x, y, customer)
  love.graphics.draw(customerClothes, customerSheet[customer.clothes], x, y)
  love.graphics.draw(customerHead, customerSheet[customer.head], x, y)
  love.graphics.draw(customerFace, customerSheet[customer.face], x, y)
  love.graphics.draw(customerHair, customerSheet[customer.hair], x, y)
end

local function activateGameOverScreen(state)
  meta = {
    worst = state.scorer.worst,
    best = state.scorer.best,
    worstImg = love.graphics.newImage(state.scorer.worst.imageData),
    bestImg = love.graphics.newImage(state.scorer.best.imageData)
  }
end

local function drawGameOverScreen(state)
  local worst = meta.worst
  local best = meta.best
  local xWorst = 100
  local xBest = 400
  local yBoth = 100
  love.graphics.draw(gameOverBg)

  love.graphics.draw(meta.worstImg, xWorst, yBoth)
  love.graphics.draw(meta.bestImg, xBest, yBoth)

  love.graphics.print("Round " .. best.round .. ":", 20, 160)
  love.graphics.print(math.floor(best.score*100) .."%", 40, 180)
  local bestBadge = SO.getBadge(best.score)
  love.graphics.draw(bestBadge, 100, 300)

  love.graphics.print("Round " .. worst.round .. ":", 690, 160)
  love.graphics.print(math.floor(worst.score*100) .."%", 710, 180)
  local worstBadge = SO.getBadge(worst.score)
  love.graphics.draw(worstBadge, 400, 300)
end

local function drawTitleScreen()
  love.graphics.draw(titleBg, 0, 0)
  love.graphics.print("Press 'Enter' or click to continue", 160, 330)
end

local function drawIntroStoryScreen()
  love.graphics.draw(introBg, 0, 0)
  love.graphics.printf("I'm Gorbo the Great, it's ... GREAT ... to meet you! Gobby and I had the best business idea, but I'll let you in on it because we need your help.", 100, 140, 600, "center")
  love.graphics.printf("We realized that we could be using our magic for good! And by 'good' I mean profit! You see, people want things. And we have other things that we can TRANSMUTE into those things, with just a bit of magic. And also trash we found in the forest.", 100, 220, 600, "center")
  love.graphics.printf("You'll be helping Gobby by using random forest items to copy the shape of the customer's request.", 400, 360, 300, "center")
  love.graphics.print("Press 'Enter' or click to continue", 440, 560)
end

local function drawIntroBeginScreen()
  love.graphics.draw(beginBg, 0, 0)
  love.graphics.printf("You have 10 rounds to earn as many tips as you can.", 300, 400, 300, "center")
  love.graphics.print("Press 'Enter' or click to begin!", 300, 560)
end

local function activateRoundEndScreen(state)
  local lastRound = state.scorer.roundScores[#state.scorer.roundScores]
  meta = {
    lastRound = lastRound,
    response = strings.getRandomScoreResponse(lastRound.score),
    resultImg = love.graphics.newImage(state.lastResult),
    refData = state.reference:getData(lastRound.referenceIdx)
  }
  state.shouldBlockBag = false
  love.audio.stop()
  backgroundBeatz:play()
end

local function drawRoundEndScreen(state)
  local yTop = 36
  local xLeft = 88
  local imgWidth = 256
  local gapX = 100
  local gapY = 42

  love.graphics.draw(resultsBg, 0, 0)

  -- draw the reference image
  state.reference:drawItem(meta.lastRound.referenceIdx, xLeft, yTop)

  -- draw the result image
  local xLeft2 = xLeft + imgWidth + gapX
  utils.drawMask(meta.resultImg, nil, xLeft2, yTop, function()
    love.graphics.draw(meta.refData.textureImg, meta.refData.textureSprite, xLeft2, yTop)
  end)

  -- print the score
  love.graphics.printf(utils.formatScore(meta.lastRound.score) .. ". It took " .. meta.lastRound.secondsSpent .. " seconds to complete.", 0, yTop + gapY + imgWidth + gapY, 800, "center")

  --print the badge
  local badge = SO.getBadge(meta.lastRound.score)
  love.graphics.draw(badge, 400, 300)

  local response = meta.response or "ERROR DID NOT ACTIVATE"

  love.graphics.printf(response, 32, 484, 600, "left")

  drawRandomCustomer(638, 448, state.currentCustomerData)
  love.graphics.printf(customerNames[state.currentCustomerData.name], 540, 440, 110, "center")
end

local function drawHelpScreen()
  love.graphics.draw(howToPlayBg, 0, 0)
  love.graphics.print("Press 'Enter' or click to continue", 300, 560)
  love.graphics.printf("Click on a bag of items to select one, and then click on your working area to place it. You have 10 'seconds' - turns on the timer - to complete the request. If you misclick you can always undo or clear to start over!", 100, 140, 600, "center")
  love.graphics.printf("Controls:", 200, 240, 600, "left")
  love.graphics.printf("E, R - Rotate item left/right", 300, 240, 600, "left")
  love.graphics.printf("Q, W - Flip item horizontally/vertically", 300, 280, 600, "left")
  love.graphics.printf("Z - Undo", 300, 320, 600, "left")
  love.graphics.printf("C - Clear", 300, 360, 600, "left")
  love.graphics.printf("H - Show help", 300, 400, 600, "left")
  love.graphics.printf("Space - Complete object and end round", 300, 440, 600, "left")
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

local function drawNewRequestScreen(state)
  love.graphics.draw(dialogBg)
  local yGap = 42
  local xGap = 32
  local convo = meta.conversation or {{name = "ERROR", text = "NewRequestScreen DID NOT ACTIVATE"}}
  for i=1,#convo do
    local idx = i - 1
    local avatarOnLeft = i == 1 or i == #convo
    local xLeft = avatarOnLeft and (xGap + 150) or xGap
    local yTop = 150 * idx + yGap

    love.graphics.printf(convo[i], xLeft, yTop, 600, "left")
  end

  drawRandomCustomer(640, 308, state.currentCustomerData)
  love.graphics.printf(customerNames[state.currentCustomerData.name], 540, 302, 110, "center")
end

function SO.load()
  titleBg = love.graphics.newImage("assets/title.png")
  introBg = love.graphics.newImage("assets/introCard.png")
  howToPlayBg = love.graphics.newImage("assets/howToPlayCard.png")
  beginBg = love.graphics.newImage("assets/beginCard.png")
  dialogBg = love.graphics.newImage("assets/dialogueBg.png")
  resultsBg = love.graphics.newImage("assets/resultsCard.png")
  gameOverBg = love.graphics.newImage("assets/gameOverCard.png")
  badgeA = love.graphics.newImage("assets/badgeA.png")
  badgeB = love.graphics.newImage("assets/badgeB.png")
  badgeC = love.graphics.newImage("assets/badgeC.png")
  badgeD = love.graphics.newImage("assets/badgeD.png")
  badgeF = love.graphics.newImage("assets/badgeF.png")

  customerClothes = love.graphics.newImage("assets/customerSheetClothes.png")
  customerFace = love.graphics.newImage("assets/customerSheetFace.png")
  customerHair = love.graphics.newImage("assets/customerSheetHair.png")
  customerHead = love.graphics.newImage("assets/customerSheetHead.png")
  -- all the sheets are the same dimension/layout, so we really only need one set of quads
  customerSheet = utils.loadSpritesheet(customerClothes, 7, 4)

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
    activateGameOverScreen(state)
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
    drawNewRequestScreen(state)
  end

  return true
end

function SO.getBadge(score)
  local rank = utils.getScoreRank(score)
  
  if rank == ScoreRank.CHEATER then
    return badgeF
  elseif rank == ScoreRank.AA then
    return badgeA
  elseif rank == ScoreRank.A then
    return badgeA
  elseif rank == ScoreRank.B then
    return badgeB
  elseif rank == ScoreRank.C then
    return badgeC
  elseif rank == ScoreRank.D then
    return badgeD
  else
    return badgeF
  end
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