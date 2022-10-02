Scenes = {
  TITLE = 1,
  HELP = 2,
  GAME = 3,
  ROUND_END = 4,
  GAME_OVER = 5
}

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

function detectWhichObjPressed(mx, my, tbl)
  for i = 1, #tbl do
    if hasMouseOverlap(mx, my, tbl[i]) then
      return i
    end
  end
  return 0
end

function shuffledArr(max)
  local arr = {}

  for i = 1, max do
    table.insert(arr, i)
  end

  for i = 1, max do
    local rand = love.math.random(i, max)
    local tmp = arr[i]
    arr[i] = arr[rand]
    arr[rand] = tmp
  end

  return arr
end

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