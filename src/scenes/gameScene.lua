local utils = require("utils")

local SG = {}
SG.__index = SG

local bg
local referenceArea
local referenceAreaGrid
local workspaceGrid
local undoButton
local rotateButton
local clearButton
local buttons
local bagLocations

local function newButton(buttonImg, buttonX, buttonY)
  return {
    img = buttonImg,
    x1 = buttonX,
    y1 = buttonY,
    x2 = buttonX + buttonImg:getWidth(),
    y2 = buttonY + buttonImg:getHeight()
  }
end

local function loadUI()
    bg = love.graphics.newImage('assets/background.png')
    referenceArea = love.graphics.newImage('assets/referenceBackground.png')
    referenceAreaGrid = love.graphics.newImage('assets/referenceBackground_grid.png')
    workspaceGrid = love.graphics.newImage('assets/workingCanvas_grid.png')
    undoButton = love.graphics.newImage('assets/undoButton.png')
    rotateButton = love.graphics.newImage('assets/rotateButton.png')
    clearButton = love.graphics.newImage('assets/clearButton.png')
    buttons = {}
    local canvasButtonX = 160
    buttons[1] = newButton(rotateButton, canvasButtonX, 260)
    buttons[2] = newButton(undoButton, canvasButtonX, 330)
    buttons[3] = newButton(clearButton, canvasButtonX, 400)
end

local function drawDebug(scorer, texture, sprite, mx, my)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    scorer:drawDebug(texture, sprite)
    love.graphics.pop()
    love.graphics.printf(mx .. ", " .. my, mx+10, my, 40, "left")
end

local function loadBagLocations()
  bagLocations = {}
  local topRowY = 82
  local topRowBottomY = 185
  local bottomRowY = 195
  local bottomRowBottomY = 275
  -- { top left x, top left y, bottom right x, bottom right y
  bagLocations[1] = {x1 = 276, y1 = topRowY, x2 = 360, y2 = topRowBottomY}
  bagLocations[2] = {x1 = 375, y1 = topRowY, x2 = 475, y2 = topRowBottomY}
  bagLocations[3] = {x1 = 487, y1 = topRowY, x2 = 560, y2 = topRowBottomY}
  bagLocations[4] = {x1 = 570, y1 = topRowY, x2 = 645, y2 = topRowBottomY}
  bagLocations[5] = {x1 = 650, y1 = topRowY, x2 = 740, y2 = topRowBottomY}
  bagLocations[6] = {x1 = 272, y1 = bottomRowY, x2 = 351, y2 = bottomRowBottomY}
  bagLocations[7] = {x1 = 365, y1 = bottomRowY, x2 = 437, y2 = bottomRowBottomY}
  bagLocations[8] = {x1 = 450, y1 = bottomRowY, x2 = 520, y2 = bottomRowBottomY}
  bagLocations[9] = {x1 = 530, y1 = bottomRowY, x2 = 627, y2 = bottomRowBottomY}
  bagLocations[10] = {x1 = 645, y1 = bottomRowY, x2 = 736, y2 = bottomRowBottomY}
end

local function drawSecondsGauge(points)
  -- TODO some sort of gauge/graphic for seconds?
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(points["spent"] .. "/" .. points["max"], 85, 415)
  love.graphics.setColor(255, 255, 255)
end

local function drawUI(fn, points)
    love.graphics.draw(bg, 0, 0)
    love.graphics.draw(referenceArea, 100, 80)
    fn()
    love.graphics.draw(referenceAreaGrid, 110, 90)
    love.graphics.draw(workspaceGrid, 260, 314)

    drawSecondsGauge(points)

    for i=1, #buttons do
      local b = buttons[i]
      love.graphics.draw(b.img, b.x1, b.y1)
    end
end

local function nextRound(reference, workspace, gameState, scorer)
  local data = reference:getData()
  scorer:lockIn(data["maskData"], data["maskSprite"], workspace:getImageData(), gameState.spentPoints, gameState.currentRound)
  local round = gameState:nextRound()

  if round == -1 then
    gameState:setScene(Scenes.GAME_OVER)
    return
  end

  reference:nextIdx()
  workspace:reset()
  gameState:setScene(Scenes.ROUND_END)
end

local function placeItem(gameState, workspace, x, y)
    if gameState:spendPoint() then
        workspace:placeItem(x, y)
    end
end

local function undoItem(gameState, workspace)
    if gameState:refundPoint() then
        workspace:undoItemPlacement()
    end
end

function SG.load()
    loadUI()
    loadBagLocations()
end

function SG.drawScene(scene, reference, workspace, gameState, scorer)
  if scene ~= Scenes.GAME then
    return false
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

  return true
end

function SG.handleMousepress(reference, workspace, gameState, scorer, x, y)
  --first, check to see if you're trying to pick up an item from a bag
  local item = utils.detectWhichObjPressed(x, y, bagLocations)
  local UIButton = utils.detectWhichObjPressed(x, y, buttons)
  if item ~= 0 then
    workspace:selectItem(item)
  --if not, then see if you're trying to place an item you have selected
  elseif workspace.selectedItem ~= nil then
    placeItem(gameState, workspace, x, y)
    if debug then
      local data = reference:getData()
      scorer:update(data["maskData"], data["maskSprite"], workspace:getImageData())
    end
  elseif UIButton ~= 0 then
    if UIButton == 2 then
      undoItem(gameState, workspace)
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

function SG.handleKeypress(reference, workspace, gameState, scorer, key, isrepeat)
    if key == "r" then
        workspace:rotateItem(false)
        return true
    elseif key == "e" then
        workspace:rotateItem(true)
        return true
    end

    if isrepeat then
        return false
    end

    if key == "z" then
        workspace:undoItemPlacement()
        return true
    elseif key == "c" then
        workspace:clearItems()
        return true
    elseif key == "space" then
        nextRound(reference, workspace, gameState, scorer)
        return true
    end

    return false
end

return SG