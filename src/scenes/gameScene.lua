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
local slideAnim

local DEBUG_shouldUpdateScorer = false

local function newSlideAnimation()
  local animation = {
    duration = 0.1,
    time = 0,
    positionPct = 0
  }
  animation.__index = animation

  function animation.update(self, dt)
    if self.positionPct == 1 then
      return
    end

    self.time = self.time + dt
    if self.time >= self.duration then
      self.time = self.duration
    end

    self.positionPct = self.time / self.duration
  end

  return animation
end

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

local function debugUpdateScorer(state)
  if debug then
    local data = state.reference:getData()
    state.scorer:update(data["maskData"], data["maskSprite"], state.workspace:getImageData())
  end
end

local function drawDebug(state, texture, sprite, mx, my)
    if DEBUG_shouldUpdateScorer then
      debugUpdateScorer(state)
      DEBUG_shouldUpdateScorer = false
    end

    love.graphics.push()
    -- set the font globally
    love.graphics.setNewFont(16)

    -- draw a mini version of what the scorer is seeing
    love.graphics.scale(0.5, 0.5)
    state.scorer:drawDebug(texture, sprite)
    love.graphics.reset()
    love.graphics.pop()

    -- write the coords next to the cursor
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

local function drawSecondsGauge(seconds)
  -- TODO some sort of gauge/graphic for seconds?
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(seconds["spent"] .. "/" .. seconds["max"], 85, 415)
  love.graphics.setColor(255, 255, 255)
end

local function drawUI(state, mx, my)
    love.graphics.draw(bg, 0, 0)

    -- calculate the position of the reference area as it slides in
    local refAreaEnd = 100
    local refGridOffset = 10
    local refAreaX = slideAnim.positionPct * refAreaEnd

    -- draw the reference area bg + reference area + grid
    love.graphics.draw(referenceArea, refAreaX, 80)
    state.reference:draw(refAreaX + refGridOffset)
    love.graphics.draw(referenceAreaGrid, refAreaX + refGridOffset, 90)

    -- draw the workspace + grid
    state.workspace:draw(mx, my)
    love.graphics.draw(workspaceGrid, 260, 314)

    drawSecondsGauge(state:seconds())

    for i=1, #buttons do
      local b = buttons[i]
      love.graphics.draw(b.img, b.x1, b.y1)
    end
end

local function nextRound(state)
  local data = state.reference:getData()
  state.scorer:lockIn(data["maskData"], data["maskSprite"], state.workspace:getImageData(), state.spentSeconds, state.currentRound)
  local round = state:nextRound()

  if round == -1 then
    state:setScene(Scenes.GAME_OVER)
    return
  end

  state.reference:nextIdx()
  state.workspace:reset()
  state:setScene(Scenes.ROUND_END)
end

local function placeItem(state, x, y)
    if state:spendSecond() then
      state.workspace:placeItem(x, y)
    end
end

local function undoItem(state)
    if state:refundSecond() then
      state.workspace:undoItemPlacement()
    end
end

local function removeItem(state, placedItem)
  if state:refundSecond() then
    state.workspace:removeItem(placedItem)
  end
end

local function clearWorkspace(state)
  state:resetSeconds()
  state.workspace:clearItems()
end

function SG.load()
    loadUI()
    loadBagLocations()
end

function SG.activate()
  slideAnim = newSlideAnimation()
end

function SG.update(dt)
  slideAnim:update(dt)
end

function SG.drawScene(scene, state)
  if scene ~= Scenes.GAME then
    return false
  end

  local mx, my = love.mouse.getPosition()
  drawUI(state, mx, my)

  if debug then
      local data = state.reference:getData()
      drawDebug(state, data["textureImg"], data["textureSprite"], mx, my)
  end

  return true
end

function SG.handleMousepress(state, x, y)
  local item = utils.detectWhichObjPressed(x, y, bagLocations)
  local UIButton = utils.detectWhichObjPressed(x, y, buttons)

  --first, check to see if you're trying to pick up an item from a bag
  if item ~= 0 then
    state.workspace:selectItem(item)

  elseif state.workspace.selectedItem ~= nil then
    --if not, then see if you're trying to place an item you have selected
    placeItem(state, x, y)

  elseif UIButton ~= 0 then
    if UIButton == 2 then
      undoItem(state)
    elseif UIButton == 3 then
      clearWorkspace(state)
    end

  else
    --then check to see if you've clicked on an item that's already been placed
    local placedItem = state.workspace:itemToMoveOnCanvas(x, y)
    if placedItem ~= 0 then
      removeItem(placedItem)
    end
  end

  DEBUG_shouldUpdateScorer = true
end

function SG.handleKeypress(state, key, isrepeat)
    if key == "r" then
      state.workspace:rotateItem(false)
        return true
    elseif key == "e" then
      state.workspace:rotateItem(true)
        return true
    end

    if isrepeat then
        return false
    end

    local handled = true

    if key == "z" then
      undoItem(state)
    elseif key == "c" then
        clearWorkspace(state)
    elseif key == "q" then
        state.workspace:mirrorItem(false)
    elseif key == "w" then
        state.workspace:mirrorItem(true)
    elseif key == "h" then
        state:setScene(Scenes.HELP)
    elseif key == "space" then
        nextRound(state)
    else
      handled = false
    end

    if handled then
      DEBUG_shouldUpdateScorer = true
    end

    return handled
end

return SG