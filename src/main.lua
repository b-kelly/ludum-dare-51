local GS = require "gamestate"
local otherScenes = require "scenes/otherScenes"
local gameScene = require "scenes/gameScene"

debug = true

-- TODO global
Scenes = {
  TITLE = 1,
  INTRO_HELP = 2,
  NEW_REQUEST = 3,
  GAME = 4,
  ROUND_END = 5,
  GAME_OVER = 6,
  HELP = 7,
}

local gameState
local mainTextFont

function love.load(arg)
    --require("mobdebug").start()
    love.keyboard.setKeyRepeat(true)
    mainTextFont = love.graphics.newFont("assets/fonts/SignikaNegative-Medium.ttf", 20)
    love.graphics.setFont(mainTextFont)

    -- load the scenes
    otherScenes.load()
    gameScene.load()

    -- load up the backing state
    gameState = GS.new()
end

function love.update(dt)
  if gameState.sceneNeedsActivation then
    if otherScenes.activate(gameState.scene, gameState) then
      -- do nothing
    elseif gameState.scene == Scenes.GAME then
      gameScene.activate()
    end
  end

  if gameState.scene == Scenes.GAME then
    gameScene.update(dt)
  end

  gameState.sceneNeedsActivation = false
end

function love.draw(dt)
  local scene = gameState.scene

  -- otherScenes handles drawing all non-game scenes
  if otherScenes.drawScene(scene, gameState) then
    return
  elseif scene == Scenes.GAME then
    gameScene.drawScene(scene, gameState)
  end
end

function love.mousepressed(x, y, button)
  if gameState.scene ~= Scenes.GAME then
    return
  elseif gameState.scene == Scenes.GAME then
    gameScene.handleMousepress(gameState, x, y)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if otherScenes.handleKeypress(gameState, key, scancode, isrepeat) then
    return
  elseif gameState.scene == Scenes.GAME then
    gameScene.handleKeypress(gameState, key, isrepeat)
  end
end