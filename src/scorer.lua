S = {}
S.__index = S

function getImageSimularity(a, b)
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

    return matchingPixelCount / (height * width)
end

function S.new()
  local self = setmetatable({
    reference = {},
    current = {},
    best = {},
    worst = {},
    simularity = nil
  }, S)

  return self
end

function S.update(self, referenceImgData, referenceImgQuad, currentImgData)
  
  local data = singleImageData(referenceImgData, referenceImgQuad)
  
  self.reference["data"] = data
  self.current["data"] = currentImgData
  
  self.simularity = getImageSimularity(data, currentImgData)
end

function S.drawDebug(self, texture, textureSprite)
  local data = self.current["data"]
  
  if data == nil then
    return
  end
  
  local img = love.graphics.newImage(data)
  drawMask(img, nil, 256, 0, function()
    love.graphics.draw(texture, textureSprite, 256, 0)
  end)

  if self.simularity ~= nil then
    local x, y, w, h = textureSprite:getViewport()
    local pct = math.floor((self.simularity) * 1000) / 10
    love.graphics.printf(pct .. "% similar", 256, 256, 10000, "left")
  end
end

return S