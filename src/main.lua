require "mask"
require "reference"
require "utils"
require "ui"

local W = require "workspace"
local S = require "scorer"
local R = require "reference"
local GS = require "gamestate"

debug = true

local workspace
local scorer
local reference
local gameState

function love.load(arg)
    --require("mobdebug").start()
    love.keyboard.setKeyRepeat(true)
    loadUI()
    workspace = W.new()
    scorer = S.new()
    reference = R.new()
    gameState = GS.new()
    loadBagLocations()
end

function love.update(dt)
end

function love.draw(dt)
    if gameState.scene == Scenes.GAME_OVER then
      drawGameOverScreen(scorer)
      return
    elseif gameState.scene == Scenes.TITLE then
      drawTitleScreen()
      return
    elseif gameState.scene == Scenes.ROUND_END then
      drawRoundEndScreen(scorer)
      return
    elseif gameState.scene == Scenes.HELP then
      drawHelpScreen()
      return
    end

    local mx, my = love.mouse.getPosition()
    drawUI(function()
      reference:draw()
      workspace:draw(mx, my)
    end, gameState:points())

    if debug then
        local data = reference:getData()
        drawDebug(scorer, data["textureImg"], data["textureSprite"], mx, my)
    end
end

function love.mousepressed(x, y, button)
  --first, check to see if you're trying to pick up an item from a bag
  local item = detectWhichObjPressed(x, y, bagLocations)
  local UIButton = detectWhichObjPressed(x, y, buttons)
  if item ~= 0 then
    workspace:selectItem(item)
  --if not, then see if you're trying to place an item you have selected
  elseif workspace.selectedItem ~= nil then
    placeItem(x, y)
    if debug then
      local data = reference:getData()
      scorer:update(data["maskData"], data["maskSprite"], workspace:getImageData())
    end
  elseif UIButton ~= 0 then
    if UIButton == 2 then
      undoItem()
    elseif UIButton == 3 then
      workspace:clearItems()
    end
  --then check to see if you've clicked on an item that's already been placed
  else
    local placedItem = workspace:itemToMoveOnCanvas(x, y)
    if placedItem ~= 0 then
      workspace:removeItem(placedItem)
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "return" and gameState.scene ~= Scenes.Game then
    gameState:nextScene()
    return
  end

  if key == "r" then
    workspace:rotateItem(false)
  elseif key == "e" then
    workspace:rotateItem(true)
  end

  if isrepeat then
    return
  end

  if key == "z" then
    workspace:undoItemPlacement()
  elseif key == "c" then
    workspace:clearItems()
  elseif key == "space" then
    nextRound()
  end
end

function placeItem(x, y)
  if gameState:spendPoint() then
    workspace:placeItem(x, y)
  end
end

function undoItem()
  if gameState:refundPoint() then
    workspace:undoItemPlacement()
  end
end

function nextRound()
  local data = reference:getData()
  scorer:lockIn(data["maskData"], data["maskSprite"], workspace:getImageData(), gameState.spentPoints, gameState.currentRound)
  local round = gameState:nextRound()

  if round == -1 then
    gameState:setScene(Scenes.GAME_OVER)
    return
  end

  reference:setIdx(round)
  workspace:reset()
  gameState:setScene(Scenes.ROUND_END)
end