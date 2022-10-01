function loadSpritesheet(img, xCount, yCount, spriteSize)
  local arr = {}
  
  for x=0,xCount do
    local xCoord = x * spriteSize
    for y=0,yCount do
      local yCoord = y * spriteSize
      local quad = love.graphics.newQuad(xCoord, yCoord, spriteSize, spriteSize, img)
      table.insert(arr, quad)
    end
  end
  
  return arr
end