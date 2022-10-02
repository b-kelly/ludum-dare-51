local utils = require("utils")

local S = {}
S.__index = S

local function getImageSimularity(a, b)
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
    currentData = nil,
    best = nil,
    worst = nil,
    simularity = nil,
    roundScores = {}
  }, S)

  return self
end

function S.update(self, referenceImgData, referenceImgQuad, currentImgData)

  local data = utils.singleImageData(referenceImgData, referenceImgQuad)

  self.currentData = currentImgData

  self.simularity = getImageSimularity(data, currentImgData)
end

function S.lockIn(self, referenceImgData, referenceImgQuad, currentImgData, pointsSpent, round)
  self:update(referenceImgData, referenceImgQuad, currentImgData)

  local entry = {
      pointsSpent = pointsSpent,
      round = round,
      score = self.simularity
  }

  table.insert(self.roundScores, entry)

  if self.best == nil or self.simularity > self.best.score then
    self.best = entry
    self.best.imageData = currentImgData
  end

  if self.worst == nil or self.simularity < self.worst.score then
    self.worst = entry
    self.worst.imageData = currentImgData
  end

  self.simularity = nil
  self.currentData = nil
end

function S.drawDebug(self, texture, textureSprite)
  local data = self.currentData

  if data == nil then
    return
  end

  local img = love.graphics.newImage(data)
  utils.drawMask(img, nil, 256, 0, function()
    love.graphics.draw(texture, textureSprite, 256, 0)
  end)

  if self.simularity ~= nil then
    local pct = math.floor((self.simularity) * 1000) / 10
    love.graphics.printf(pct .. "% similar", 256, 256, 10000, "left")
  end
end

function S.getStats(self)
  return {
    best = self.best,
    worst = self.worst,
  }
end

return S