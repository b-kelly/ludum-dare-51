function loadSpritesheet(sheet, xCount, yCount, spriteSize)
  local arr = {}

  for y=0,yCount-1 do
    local yCoord = y * spriteSize
    for x=0,xCount-1 do
      local xCoord = x * spriteSize
      local quad = love.graphics.newQuad(xCoord, yCoord, spriteSize, spriteSize, sheet)
      table.insert(arr, quad)
    end
  end

  return arr
end

function singleImageData(sheetData, quad)
  local x, y, w, h = quad:getViewport()
  local data = love.image.newImageData(w, h)
  data:paste(sheetData, 0, 0, x, y, w, h)

  return data
end