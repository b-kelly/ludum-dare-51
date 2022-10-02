require "utils"

local SO = {}
SO.__index = SO

local function drawGameOverScreen(scorer)
  love.graphics.print("Game Over", 0, 0)

  love.graphics.print("Best: " .. scorer.best.round .. " " .. scorer.best.score .. "%", 0, 20)
  love.graphics.print("Worst: " .. scorer.worst.round .. " " .. scorer.worst.score .. "%", 0, 40)
end

local function drawTitleScreen()
  -- TODO
  love.graphics.print("Title screen placeholder - press ENTER", 0, 0)
end

local function drawRoundEndScreen(scorer)
  -- TODO
  local lastRound = scorer.roundScores[#scorer.roundScores]
  love.graphics.print("Round end screen placeholder - press ENTER", 0, 0)
  love.graphics.print("Finished round "..lastRound.round.."; score "..lastRound.score.."; seconds "..lastRound.pointsSpent, 0, 20)
end

local function drawHelpScreen()
  -- TODO
  love.graphics.print("Help screen placeholder - press ENTER", 0, 0)
end

function SO.load()
  -- TODO load textures
end

function SO.drawScene(scene, scorer)
  if scene == Scenes.GAME then
    return false
  end

  if scene == Scenes.GAME_OVER then
    drawGameOverScreen(scorer)
  elseif scene == Scenes.TITLE then
    drawTitleScreen()
  elseif scene == Scenes.ROUND_END then
    drawRoundEndScreen(scorer)
  elseif scene == Scenes.HELP then
    drawHelpScreen()
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