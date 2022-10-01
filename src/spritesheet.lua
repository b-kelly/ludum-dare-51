function loadSpritesheet(img, xCount, yCount, spriteSize)
  local arr = {}
  
  for x=0,xCount-1 do
    local xCoord = x * spriteSize
    for y=0,yCount-1 do
      local yCoord = y * spriteSize
      local quad = love.graphics.newQuad(xCoord, yCoord, spriteSize, spriteSize, img)
      table.insert(arr, quad)
    end
  end
  
  return arr
end