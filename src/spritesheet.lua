function loadSpritesheet(img, xCount, yCount, spriteSize)
  local arr = {}
  
  for y=0,yCount-1 do
    local yCoord = y * spriteSize
    for x=0,xCount-1 do
      local xCoord = x * spriteSize
      local quad = love.graphics.newQuad(xCoord, yCoord, spriteSize, spriteSize, img)
      table.insert(arr, quad)
    end
  end
  
  return arr
end