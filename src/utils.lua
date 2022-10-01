function getImageSimularityPercent(a, b)
    -- there may be a better way of doing this...
    -- assumes both images are the same height/width
    local height = a:getHeight()
    local width = a:getWidth()

    local matchingPixelCount = 0

    for x=0, width - 1 do
       for y=0, height - 1 do
        local r1, g1, b1, a1 = a:getPixel(x, y)
        local r2, g2, b2, a2 = b:getPixel(x, y)

        if a1 == a2 then
            matchingPixelCount = matchingPixelCount + 1
        end
       end 
    end

    return (matchingPixelCount / (height * width)) * 100
end

function drawToCanvas(canvas, fn)
    love.graphics.setCanvas({
        canvas,
        stencil=true
    })

    love.graphics.push()
    fn()
    love.graphics.reset()
    love.graphics.pop()

    love.graphics.setCanvas()

    return canvas
end

function hasMouseOverlap(mx, my, obj)
  if mx > obj.x1 and mx < obj.x2 then
    if my > obj.y1 and my < obj.y2 then
      return true
    end
  end
  return false
end

function detectWhichItemToGrabFromBags(mx, my)
  local bagLocations = {}
  local topRowY = 82
  local topRowBottomY = 185
  local bottomRowY = 195
  local bottomRowBottomY = 275
  -- { top left x, top left y, bottom right x, bottom right y
  --TODO - this all probably belongs somewhere else, maybe in loadUI() ?
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
  
  for i = 1, #bagLocations do
    if hasMouseOverlap(mx, my, bagLocations[i]) then
      return i
    end
  end
  
  return 0
  
end