local utils = require "utils"
local strings = require "strings"

local SO = {}
SO.__index = SO

local titleBg
local introBg
local howToPlayBg
local beginBg
local mainTextFont
local meta = {}

local function drawGameOverScreen(scorer)
  love.graphics.print("Game Over", 0, 0)

  love.graphics.print("Best round: " .. scorer.best.round .. " " .. utils.formatScore(scorer.best.score), 0, 20)
  love.graphics.print("Worst round: " .. scorer.worst.round .. " " .. utils.formatScore(scorer.worst.score), 0, 40)
end

local function drawTitleScreen()
  love.graphics.draw(titleBg, 0, 0)
  love.graphics.print("(TODO cleanup) PRESS ENTER", 150, 330)
end

local function newTextBox(name, text, x, y)
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", x, y, 800, 100)
  love.graphics.setColor(0, 0, 0)
  -- TODO
  love.graphics.printf(name..": "..text, x, y, 800, "left")
  love.graphics.setColor(1, 1, 1)
end

local function activateRoundEndScreen(state)
  local lastRound = state.scorer.roundScores[#state.scorer.roundScores]
  meta = {
    response = strings.getRandomScoreResponse(lastRound.score)
  }
end

local function drawRoundEndScreen(scorer)
  -- TODO
  local lastRound = scorer.roundScores[#scorer.roundScores]
  love.graphics.print("Round end screen placeholder - press ENTER", 0, 0)
  love.graphics.print("Finished round "..lastRound.round.."; score "..lastRound.score.."; seconds "..lastRound.secondsSpent, 0, 20)

  local response = meta.response or "ERROR DID NOT ACTIVATE"
  newTextBox("Customer", response, 0, 40)
end

local function drawHelpScreen()
  -- TODO
  love.graphics.draw(howToPlayBg, 0, 0)
  love.graphics.print("Help screen placeholder - press ENTER", 0, 0)

  love.graphics.printf("Controls: rotate (e, r); flip (q, w); finalize (space); undo (z); clear (c); show help (h)", 0, 20, 600, "left")
end

local function activateNewRequestScreen(state)
  meta = {
    conversation = strings.getRandomConversation(state.reference:getCurrentItemIdx())
  }
end

local function drawNewRequestScreen()
  local convo = meta.conversation or {{name = "ERROR", text = "NewRequestScreen DID NOT ACTIVATE"}}
  for i=1,#convo do
    newTextBox(convo[i]["name"], convo[i]["text"], 0, 100 * (i - 1))
  end
end

function SO.load()
  titleBg = love.graphics.newImage("assets/title.png")
  introBg = love.graphics.newImage("assets/introCard.png")
  howToPlayBg = love.graphics.newImage("assets/howToPlayCard.png")
  beginBg = love.graphics.newImage("assets/beginCard.png")

  mainTextFont = love.graphics.newFont("assets/fonts/SignikaNegative-Medium.ttf")
end

function SO.activate(scene, state)
  meta = {}

  if scene == Scenes.GAME then
    return false
  end

  if scene == Scenes.GAME_OVER then
    --activateGameOverScreen(state.scorer)
  elseif scene == Scenes.TITLE then
    --activateTitleScreen()
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
    drawRoundEndScreen(state.scorer)
  elseif scene == Scenes.HELP or scene == Scenes.INTRO_HELP then
    drawHelpScreen()
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