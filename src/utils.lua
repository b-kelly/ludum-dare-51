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
  
  for i = 1, #bagLocations do
    if hasMouseOverlap(mx, my, bagLocations[i]) then
      return i
    end
  end
  
  return 0
  
end