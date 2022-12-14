local U = {}
U.__index = U

--TODO global
ScoreRank = {
  AA = 1,
  A = 2,
  B = 3,
  C = 4,
  D = 5,
  F = 6,
  FF = 7,
  CHEATER = 8
}

function U.drawToCanvas(canvas, fn)
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

function U.hasMouseOverlap(mx, my, obj)
  if mx > obj.x1 and mx < obj.x2 then
    if my > obj.y1 and my < obj.y2 then
      return true
    end
  end
  return false
end

function U.detectWhichObjPressed(mx, my, tbl)
  for i = 1, #tbl do
    if U.hasMouseOverlap(mx, my, tbl[i]) then
      return i
    end
  end
  return 0
end

function U.getRandomEntry(arr)
  local idx = love.math.random(1, #arr)
  return arr[idx]
end

function U.shuffledArr(max)
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

local function newQuad(xCoord, yCoord, spriteWidth, spriteHeight, sheet)
---@diagnostic disable-next-line: missing-parameter
  return love.graphics.newQuad(xCoord, yCoord, spriteWidth, spriteHeight, sheet)
end

function U.loadSpritesheet(sheet, xCount, yCount)
  local arr = {}

  local spriteHeight = math.floor(sheet:getHeight() / yCount)
  local spriteWidth = math.floor(sheet:getWidth() / xCount)

  for y=0,yCount-1 do
    local yCoord = y * spriteHeight
    for x=0,xCount-1 do
      local xCoord = x * spriteWidth
      local quad = newQuad(xCoord, yCoord, spriteWidth, spriteHeight, sheet)
      table.insert(arr, quad)
    end
  end

  return arr
end

function U.singleImageData(sheetData, quad)
  local x, y, w, h = quad:getViewport()
  local data = love.image.newImageData(w, h)
  data:paste(sheetData, 0, 0, x, y, w, h)

  return data
end

-- ignore all alpha
local mask_shader = love.graphics.newShader[[
    vec4 effect(vec4 colour, Image texture, vec2 texpos, vec2 scrpos)
    {
        vec4 pixel = Texel(texture, texpos) * colour;
        if (pixel.a < 1.0) discard;
        return pixel;
    }
]]

local function drawStencil(mask, quad, x, y)
  if quad == nil then
    quad = newQuad(0, 0, mask:getWidth(), mask:getHeight(), mask)
  end

   love.graphics.setShader(mask_shader)
   love.graphics.draw(mask, quad, x, y)
   love.graphics.setShader()
end

function U.drawMask(mask, quad, x, y, fn)
    love.graphics.stencil(function()
        drawStencil(mask, quad, x, y)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    fn()
    love.graphics.setStencilTest()
end

function U.drawMaskFromImg(imgData, textureImg, textureSprite, x, y)
  U.drawMask(imgData, nil, x, y, function()
    love.graphics.draw(textureImg, textureSprite, x, y)
  end)
end

-- returns: rank, formatted, tipAmount
function U.getScoreRank(score)
  if score == 1 then
    return ScoreRank.CHEATER, "CHEATER", -100
  elseif score > 0.95 then
    return ScoreRank.AA, "A+", 5
  elseif score > 0.9 then
    return ScoreRank.A, "A", 4
  elseif score > 0.8 then
    return ScoreRank.B, "B", 3
  elseif score > 0.7 then
    return ScoreRank.C, "C", 2
  elseif score > 0.6 then
    return ScoreRank.D, "D", 1
  elseif score <= 0 then
    return ScoreRank.FF, "AWFUL", 0
  end

  return ScoreRank.F, "F", 0
end

function U.formatScore(score)
  local _, output = U.getScoreRank(score)

  local pct = math.floor(score * 1000) / 10
  output = pct .. "% match"

  return output
end


return U