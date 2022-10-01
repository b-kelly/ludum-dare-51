local bg

function loadUI()
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

function drawUI(fn)
    love.graphics.draw(bg, 0, 0)
    love.graphics.draw(referenceArea, 0, 0)
    fn()
    love.graphics.draw(referenceAreaGrid, 11, 11)
    love.graphics.draw(workspaceGrid, 260, 314)
    for i=1, #buttons do
      local b = buttons[i]
      love.graphics.draw(b.img, b.x1, b.y1)
    end
end

function drawDebug(scorer, texture, sprite, mx, my)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    scorer:drawDebug(texture, sprite)
    love.graphics.pop()
    love.graphics.printf(mx .. ", " .. my, mx+10, my, 40, "left")
end

function loadBagLocations()
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

function newButton(buttonImg, buttonX, buttonY)
  return {
    img = buttonImg,
    x1 = buttonX,
    y1 = buttonY,
    x2 = buttonX + buttonImg:getWidth(),
    y2 = buttonY + buttonImg:getHeight()
  }
end
