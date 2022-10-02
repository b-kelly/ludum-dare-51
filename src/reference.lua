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
    local data = self:getData()

    utils.drawToCanvas(self.canvas, function ()
        love.graphics.clear()
        love.graphics.scale(0.5, 0.5)
        utils.drawMask(self.maskImg, data.maskSprite, 0, 0, function()
          love.graphics.draw(self.textureImg, data.textureSprite, 0, 0)
        end)
    end)

    love.graphics.draw(self.canvas, xPos, 90)
end

function R.getCurrentItemIdx(self)
  return self.randOrder[self.currentIdx]
end

function R.getData(self)
  local idx = self:getCurrentItemIdx()

  return {
    textureImg = self.textureImg,
    maskData = self.maskData,
    textureSprite = self.textures[idx],
    maskSprite = self.masks[idx],
  }
end

return R