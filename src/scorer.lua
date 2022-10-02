local utils = require("utils")

local S = {}
S.__index = S

local function getImageSimilarity(a, b)
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
    similarity = nil,
    roundScores = {}
  }, S)

  return self
end

function S.update(self, referenceImgData, referenceImgQuad, currentImgData)
  local data = utils.singleImageData(referenceImgData, referenceImgQuad)

  self.currentData = currentImgData

  self.similarity = getImageSimilarity(data, currentImgData)
end

function S.lockIn(self, referenceImgData, referenceImgQuad, currentImgData, secondsSpent, round)
  self:update(referenceImgData, referenceImgQuad, currentImgData)

  local entry = {
      secondsSpent = secondsSpent,
      round = round,
      score = self.similarity
  }

  table.insert(self.roundScores, entry)

  if self.best == nil or self.similarity > self.best.score then
    self.best = entry
    self.best.imageData = currentImgData
  end

  if self.worst == nil or self.similarity < self.worst.score then
    self.worst = entry
    self.worst.imageData = currentImgData
  end

  self.similarity = nil
  self.currentData = nil
end

function S.drawDebug(self, texture, textureSprite)
  local data = self.currentData

  if data == nil then
    return
  end

  local x = 620 * 2
  local y = 380 * 2
  local tx, ty, tw, th = textureSprite:getViewport()

  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", x, y, tw, th + 40)
  love.graphics.setColor(1, 1, 1)

  local img = love.graphics.newImage(data)
  utils.drawMask(img, nil, x, y, function()
    love.graphics.draw(texture, textureSprite, x, y)
  end)

  if self.similarity ~= nil then
    love.graphics.printf(utils.formatScore(self.similarity) .. " similar", x, y + th + 10, tw, "center")
  end
end

function S.getStats(self)
  return {
    best = self.best,
    worst = self.worst,
  }
end

return S