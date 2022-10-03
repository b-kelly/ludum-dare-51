local utils = require("utils")

local SG = {}
SG.__index = SG

local bg
local referenceArea
local referenceAreaGrid
local workspaceGrid
local bagLocations
local frameSlideAnim
local gremlinSpriteSheet
local timerSpriteSheet
local timer
local grabItemSound
local wandSpriteSheet
local outCover
local bagCover

local shouldProceedToNextRound = false
local jobFinished = false

local wandAnims = {
  gremlinHand = nil,
  wandMove1 = nil,
  sparkles = nil,
  wandMove2 = nil
}

local DEBUG_shouldUpdateScorer = false

local function newSlideAnimation(duration, distanceX, distanceY, fn)
  local animation = {
    playing = false,
    duration = duration,
    time = 0,
    positionPct = 0,
    distanceX = distanceX,
    distanceY = distanceY,
    offsetX = 0,
    offsetY = 0,
    callback = fn,
    callbackCalled = false
  }
  animation.__index = animation

  function animation.update(self, dt)
    if not self.playing then
      return
    end

    if self.positionPct == 1 then
      if self.callback and not self.callbackCalled then
        self.callbackCalled = true
        self.callback()
      end
      return
    end

    self.time = self.time + dt
    if self.time >= self.duration then
      self.time = self.duration
    end

    self.positionPct = self.time / self.duration
    self.offsetX = self.distanceX * self.positionPct
    self.offsetY = self.distanceY * self.positionPct
  end

  return animation
end

local function newSpriteAnimation(sheet, xCount, yCount, duration, loop, fn)
  local sprites = utils.loadSpritesheet(sheet, xCount, yCount)
  local animation = {
    playing = false,
    img = sheet,
    sprites = sprites,
    duration = duration,
    time = 0,
    currentFrameIdx = 1,
    totalFrames = xCount * yCount,
    loop = loop,
    callback = fn,
    callbackCalled = false
  }
  animation.__index = animation

  function animation.update(self, dt)
    if not self.playing then
      return
    end

    if self.currentFrameIdx == self.totalFrames and not self.loop then
      if self.callback and not self.callbackCalled then
        self.callbackCalled = true
        self.callback()
      end
      self.playing = false
      return
    end

    self.time = self.time + dt
    if self.time >= self.duration and not self.loop then
      self.time = self.duration
    end

    local frameDur = self.duration / self.totalFrames

    local newFrameIdx = (math.floor(self.time / frameDur) % self.totalFrames) + 1

    if debug and newFrameIdx ~= self.currentFrameIdx then
      print("new frame: "..newFrameIdx.."; old frame: "..self.currentFrameIdx.."; totalFrames: "..self.totalFrames)
    end

    self.currentFrameIdx = newFrameIdx
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
    timerSpriteSheet = love.graphics.newImage('assets/timerSpriteSheet.png')
    referenceArea = love.graphics.newImage('assets/referenceBackground.png')
    referenceAreaGrid = love.graphics.newImage('assets/referenceBackground_grid.png')
    workspaceGrid = love.graphics.newImage('assets/workingCanvas_grid.png')
    grabItemSound = love.audio.newSource("assets/audio/grabFromBag.wav", "static")
    gremlinSpriteSheet = love.graphics.newImage("assets/gremlinHandSheet.png")
    wandSpriteSheet = love.graphics.newImage("assets/wandSpriteSheet.png")
    outCover = love.graphics.newImage("assets/outCover.png")
    bagCover = love.graphics.newImage("assets/bagCover.png")

    local timerWidth = 64
    timer = {}
    for i=0, 11 do
---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
      timer[i] = love.graphics.newQuad(i * timerWidth, 0, 64, 58, timerSpriteSheet)
    end
end

local function debugUpdateScorer(state)
  if debug then
    local data = state.reference:getData(state.reference.currentIdx)
    state.scorer:update(data["maskData"], data["maskSprite"], state.workspace:getImageData())
  end
end

local function drawDebug(state, texture, sprite, mx, my)
    if DEBUG_shouldUpdateScorer then
      debugUpdateScorer(state)
      DEBUG_shouldUpdateScorer = false
    end

    love.graphics.push()

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

local function selectTimerSprite(maxSeconds, secondsSpent)
  local secondsLeft = maxSeconds - secondsSpent
  if secondsLeft >= 1 and secondsLeft <= maxSeconds then
    return secondsLeft + 1
  else
    return 0
  end
end

local function drawSecondsGauge(seconds)
  local timerSprite = selectTimerSprite(seconds.max, seconds.spent)
  love.graphics.draw(timerSpriteSheet, timer[timerSprite], 66, 390)
end

local function drawUI(state, mx, my)
    love.graphics.draw(bg, 0, 0)

    -- calculate the position of the reference area as it slides in
    local refGridOffset = 10
    local refAreaX = frameSlideAnim.offsetX

    -- draw the reference area bg + reference area + grid
    love.graphics.draw(referenceArea, refAreaX, 80)
    state.reference:draw(refAreaX + refGridOffset)
    love.graphics.draw(referenceAreaGrid, refAreaX + refGridOffset, 90)

    -- draw the workspace + grid
    state.workspace:draw(mx, my)
    state:drawSelectedItem(mx, my)
    love.graphics.draw(workspaceGrid, 260, 314)
    
    --if bags should be blocked then throw the bag blocker up
    if state.shouldBlockBags then
      love.graphics.draw(bagCover, 256, 50)
    end
    
    -- draw the out cover if the player is still working
    if not jobFinished then
      love.graphics.draw(outCover, 635, 310)
    end

    drawSecondsGauge(state:seconds())

    --for i=1, #buttons do
     -- local b = buttons[i]
     -- love.graphics.draw(b.img, b.x1, b.y1, 0, .8, .8)
   -- end

    -- draw the gremlin's hand + wand
    local xOffset = wandAnims.wandMove1.offsetX + wandAnims.wandMove2.offsetX
    local yOffset = wandAnims.wandMove1.offsetY + wandAnims.wandMove2.offsetY
    love.graphics.draw(wandSpriteSheet, wandAnims.sparkles.sprites[wandAnims.sparkles.currentFrameIdx], 585 - xOffset, 260 + yOffset)
    love.graphics.draw(gremlinSpriteSheet, wandAnims.gremlinAnim.sprites[wandAnims.gremlinAnim.currentFrameIdx], 585 - xOffset, 444 + yOffset)
end

function SG.load()
    loadUI()
    loadBagLocations()
end

function SG.activate()
  jobFinished = false
  shouldProceedToNextRound = false

  frameSlideAnim = newSlideAnimation(0.1, 80, 0)
  frameSlideAnim.playing = true

  wandAnims.gremlinAnim = newSpriteAnimation(gremlinSpriteSheet, 4, 3, 0.25, false, function ()
    wandAnims.wandMove1.playing = true
  end)

  -- we want the entire wand movement animation to complete in this duration
  local wandMoveDuration = 1.0
  -- calculate how long the first and second durations should run for
  local wandDistance1 = 80
  local wandDistance2 = 260
  local durationPerPixel = wandMoveDuration / (wandDistance1 + wandDistance2)
  local wandDuration1 = durationPerPixel * wandDistance1
  local wandDuration2 = durationPerPixel * wandDistance2

  -- how many times to loop the sparkles animation over its total duration
  local sparklesLoopCount = 5

  wandAnims.wandMove1 = newSlideAnimation(wandDuration1, wandDistance1, 50, function ()
    wandAnims.sparkles.playing = true
    wandAnims.wandMove2.playing = true
  end)

  wandAnims.sparkles = newSpriteAnimation(wandSpriteSheet, 7, 1, wandDuration2 / sparklesLoopCount, true)

  wandAnims.wandMove2 = newSlideAnimation(wandDuration2, wandDistance2, 0)
end

function SG.update(dt)
  frameSlideAnim:update(dt)
  wandAnims.gremlinAnim:update(dt)
  wandAnims.wandMove1:update(dt)
  wandAnims.sparkles:update(dt)
  wandAnims.wandMove2:update(dt)
end

function SG.drawScene(scene, state)
  if scene ~= Scenes.GAME then
    return false
  end

  if shouldProceedToNextRound then
    state:nextRound()
  end

  local mx, my = love.mouse.getPosition()
  drawUI(state, mx, my)

  if debug then
      local data = state.reference:getData(state.reference.currentIdx)
      drawDebug(state, data["textureImg"], data["textureSprite"], mx, my)
  end

  return true
end

function SG.handleMousepress(state, x, y)
  local item = utils.detectWhichObjPressed(x, y, bagLocations)

  --first, check to see if you're trying to pick up an item from a bag
  if state:canSpendSecond() and item ~= 0 then
    state:selectItem(item)
    grabItemSound:play()

  elseif state.selectedItem ~= nil then
    --if not, then see if you're trying to place an item you have selected
    state:placeItem(x, y)

  else
    --then check to see if you've clicked on an item that's already been placed
    local placedItem = state.workspace:itemToMoveOnCanvas(x, y)
    if placedItem ~= 0 then
      state:removeItem(placedItem)
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
      state:undoItem(state)
    elseif key == "c" then
      state:clearWorkspace(state)
    elseif key == "q" then
      state.workspace:mirrorItem(false)
    elseif key == "w" then
      state.workspace:mirrorItem(true)
    elseif key == "h" then
      state:setScene(Scenes.HELP)
    elseif key == "space" and state:canFinishCurrentRound() then
      wandAnims.wandMove2.callback = function ()
        -- calling state:nextRound() in here causes some weird race condition/capturing issues
        shouldProceedToNextRound = true
      end
      wandAnims.gremlinAnim.playing = true
      jobFinished = true
    else
      handled = false
    end

    if handled then
      DEBUG_shouldUpdateScorer = true
    end

    return handled
end

return SG