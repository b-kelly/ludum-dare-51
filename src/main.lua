local W = require "workspace"
local S = require "scorer"
local R = require "reference"
local GS = require "gamestate"

local otherScenes = require "scenes/otherScenes"
local gameScene = require "scenes/gameScene"

debug = true

local workspace
local scorer
local reference
local gameState

function love.load(arg)
    --require("mobdebug").start()
    love.keyboard.setKeyRepeat(true)
    -- load the scenes
    otherScenes.load()
    gameScene.load()

    -- load the shared dependencies
    workspace = W.new()
    scorer = S.new()
    reference = R.new()
    gameState = GS.new()
end

function love.update(dt)
end

function love.draw(dt)
  local scene = gameState.scene

  -- otherScenes handles drawing all non-game scenes
  if otherScenes.drawScene(scene, scorer) then
    return
  elseif scene == Scenes.GAME then
    gameScene.drawScene(scene, reference, workspace, gameState, scorer)
  end
end

function love.mousepressed(x, y, button)
  if gameState.scene ~= Scenes.GAME then
    return
  elseif gameState.scene == Scenes.GAME then
    gameScene.handleMousepress(reference, workspace, gameState, scorer, x, y)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if otherScenes.handleKeypress(gameState, key, scancode, isrepeat) then
    return
  elseif gameState.scene == Scenes.GAME then
    gameScene.handleKeypress(reference, workspace, gameState, scorer, key, isrepeat)
  end
end