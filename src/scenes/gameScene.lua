require "ui"

local SG = {}
SG.__index = SG

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

function SG.handleMousepress(reference, workspace, scorer, x, y)
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