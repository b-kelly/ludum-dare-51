local utils = require("utils")

local R = {}
R.__index = R

local spritesX = 4
local spritesY = 6
local width = 256
local height = 256
local spriteWidth = 256

function R.new()
  local textures = love.graphics.newImage("assets/targetObjectTextures.png")
  local maskData = love.image.newImageData("assets/targetObjectMasks.png")
  local masks = love.graphics.newImage(maskData)

  local randOrder = utils.shuffledArr(spritesX * spritesY)

  local self = setmetatable({
    maskData = maskData,
    maskImg = masks,
    textureImg = textures,
    canvas = love.graphics.newCanvas(width, height),
    textures = utils.loadSpritesheet(textures, spritesX, spritesY, spriteWidth),
    masks = utils.loadSpritesheet(masks, spritesX, spritesY, spriteWidth),
    currentIdx = 1,
    randOrder = randOrder
  }, R)

  return self
end

function R._nextIdx(self, idx)
  idx = self.currentIdx + 1

  if idx < 1 or idx > spritesX * spritesY then
    idx = 1
  end

  self.currentIdx = idx
end

function R.draw(self, xPos)
    utils.drawToCanvas(self.canvas, function ()
        love.graphics.clear()
        love.graphics.scale(0.5, 0.5)
        self:drawItem(self.currentIdx, 0, 0)
    end)

    love.graphics.draw(self.canvas, xPos, 90)
end

function R.getItemIdx(self, idx)
  return self.randOrder[idx]
end

function R.getData(self, idx)
  idx = self:getItemIdx(idx)
  return {
    textureImg = self.textureImg,
    maskData = self.maskData,
    textureSprite = self.textures[idx],
    maskSprite = self.masks[idx],
  }
end

function R.drawItem(self, idx, x, y)
  local data = self:getData(idx)
  utils.drawMask(self.maskImg, data.maskSprite, x, y, function()
    love.graphics.draw(data.textureImg, data.textureSprite, x, y)
  end)
end

return R