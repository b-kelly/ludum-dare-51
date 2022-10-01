require "utils"

R = {}
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

  local self = setmetatable({
    maskData = maskData,
    maskImg = masks,
    textureImg = textures,
    canvas = love.graphics.newCanvas(width, height),
    textures = loadSpritesheet(textures, spritesX, spritesY, spriteWidth),
    masks = loadSpritesheet(masks, spritesX, spritesY, spriteWidth),
    currentIdx = 1
  }, R)
  
  return self
end

function R.setIdx(self, idx)
  -- TODO
  --self.currentIdx = idx
 
  idx = self.currentIdx + 1
 
  if idx < 1 or idx > spritesX * spritesY then
    idx = 1
  end
  
  self.currentIdx = idx
end

function R.draw(self)
    local data = self:getData()
  
    drawToCanvas(self.canvas, function ()
        love.graphics.clear()
        love.graphics.scale(0.5, 0.5)
        drawMask(self.maskImg, data.maskSprite, 0, 0, function()
          love.graphics.draw(self.textureImg, data.textureSprite, 0, 0)
        end)
    end)

    love.graphics.draw(self.canvas, 0, 0)
end

function R.getData(self)
  return {
    textureImg = self.textureImg,
    textureSprite = self.textures[self.currentIdx],
    maskSprite = self.masks[self.currentIdx],
  }
end

return R