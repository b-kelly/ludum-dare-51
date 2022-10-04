local utils = require("utils")

local S = {}
S.__index = S

-- the number of rows across and down; i.e. value of 3 results in a 3x3 grid
-- the larger the number, the more intensive the operation
local WINDOW_COUNT = 4

local function gradeImageSimularityForWindow(target, result, window)
  -- there may be a better way of doing this...
  -- assumes both images are the same height/width
  local tx, ty, tw, th = window:getViewport()

  -- algo inspired by SSIM, simplified for monochrome images of the same size: https://en.wikipedia.org/wiki/Structural_similarity
  local ux = 0
  local uy = 0
  local ox = 0
  local oy = 0
  local oxy = 0

  -- constants
  local l = 1
  local k1 = 0.01
  local k2 = 0.03
  local c1 = (k1 * l) * (k1 * l)
  local c2 = (k2 * l) * (k2 * l)

  local n = th * tw

  -- calculate our pixel based values
  for x = 0, tw - 1 do
    for y = 0, th - 1 do
      local r1, g1, b1, tarAlpha = target:getPixel(tx + x, ty + y)
      local r2, g2, b2, resAlpha = result:getPixel(tx + x, ty + y)
      ux = ux + tarAlpha
      uy = uy + resAlpha
    end
  end

  ux = ux / n
  uy = uy / n

  for x = 0, tw - 1 do
    for y = 0, th - 1 do
      local r1, g1, b1, tarAlpha = target:getPixel(tx + x, ty + y)
      local r2, g2, b2, resAlpha = result:getPixel(tx + x, ty + y)
      ox = ox + math.pow((tarAlpha - ux), 2)
      oy = oy + math.pow((tarAlpha - ux), 2)

      oxy = oxy + (tarAlpha - ux) * (resAlpha - uy)
    end
  end

  ox = math.pow(ox / (n - 1), 0.5)
  oy = math.pow(oy / (n - 1), 0.5)
  oxy = oxy / n

  local ssimNum = (2 * ux * uy + c1) * (2 * oxy + c2)
  local ssimDenom = (ux * ux + uy * uy + c1) * (ox * ox + oy * oy + c2)

  local ssim = ssimNum / ssimDenom

  return ssim
end

local function getImageSimilarity(target, result, secondsSpent)
  -- break the image up into smaller pieces, rank each, then average the rankings
  -- TODO creates a new image every time
  local windows = utils.loadSpritesheet(love.graphics.newImage(target), WINDOW_COUNT, WINDOW_COUNT)

  local results = {}
  for i = 1, (WINDOW_COUNT * WINDOW_COUNT) do
    table.insert(results, gradeImageSimularityForWindow(target, result, windows[i]))
  end

  -- now average the results
  local similarity = 0
  for i = 1, #results do
    similarity = similarity + results[i]
  end

  local similarityAvg = (similarity / #results)
  
  local final = similarityAvg

  if final < 0.85 then
    if secondsSpent >= 5 then
      if final < .05 and secondsSpent >= 7 then
        final = .05
      end
      final = final + .05
    end
    final = final + 0.05
  end
  
  if ((final * 100) % 10) == 9 then
    final = final + .01
  end
  return final, results
end

function S.new()
  local self = setmetatable({
    currentData = nil,
    best = nil,
    worst = nil,
    similarity = nil,
    similarityDebug = {},
    roundScores = {}
  }, S)

  return self
end

function S.update(self, referenceImgData, referenceImgQuad, currentImgData, secondsSpent)
  local data = utils.singleImageData(referenceImgData, referenceImgQuad)

  self.currentData = currentImgData

  self.similarity, self.similarityDebug = getImageSimilarity(data, currentImgData, secondsSpent)
end

function S.lockIn(self, referenceImgData, referenceImgQuad, currentImgData, secondsSpent, round, idx)
  self:update(referenceImgData, referenceImgQuad, currentImgData, secondsSpent)

  local entry = {
    secondsSpent = secondsSpent,
    round = round,
    score = self.similarity,
    referenceIdx = idx
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
    local win = tw / WINDOW_COUNT
    for i = 1, WINDOW_COUNT do
      love.graphics.rectangle("fill", x + win * i, y, 2, th)
    end
    for i = 1, WINDOW_COUNT do
      love.graphics.rectangle("fill", x, y + win * i, tw, 2)
    end

    for i = 1, #self.similarityDebug do
      local wx = (i - 1) % WINDOW_COUNT
      local wy = math.ceil(i / WINDOW_COUNT) - 1
      local score = math.floor(self.similarityDebug[i] * 10000) / 100
      love.graphics.printf(score .. "", x + wx * win, y + wy * win, win, "center")
    end

    love.graphics.printf(utils.formatScore(self.similarity), x, y + th + 10, tw, "center")
  end
end

function S.getStats(self)
  return {
    best = self.best,
    worst = self.worst,
  }
end

return S
