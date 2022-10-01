require "utils"
require "spritesheet"

W = {}
W.__index = W

local posX = 260
local posY = 314
local width = 256
local height = 256
local spriteWidth = 128
local spritesX = 5
local spritesY = 2

function translateParentCoords(x, y)
  return x - posX, y - posY
end

function drawItem(texture, quad, x, y, r)
  local offset = spriteWidth / 2
  --local tr = love.math.newTransform(x, y, r, 1, 1, offset, offset)
  love.graphics.draw(texture, quad, x, y, r, 1, 1, offset, offset)
end

function W.new()  
  local texture = love.graphics.newImage("assets/buildingObjects.png")
  local self = setmetatable({
    canvas = love.graphics.newCanvas(width, height),
    texture = texture,
    sprites = loadSpritesheet(texture, spritesX, spritesY, spriteWidth),
    objects = {}
  }, W)

  self.selectedItem = nil
  self.itemRotation = 0
  
  return self
end

function W.drawObjects(self)
    --local offset = spriteWidth / 2
    for i=1,#self.objects do
        local obj = self.objects[i]
        drawItem(self.texture, self.sprites[obj["idx"]], obj["x"], obj["y"], obj["r"])
    end
end

function W.drawSelectedItem(self, x, y)
    if self.selectedItem == nil then
      return
    end
    
    local sx, sy = translateParentCoords(x, y)
    drawItem(self.texture, self.sprites[self.selectedItem], sx, sy, self.itemRotation)
end

function W.draw(self, mx, my)
    drawToCanvas(self.canvas, function ()
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1, 0)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 1)
        self.drawObjects(self)
        self.drawSelectedItem(self, mx, my)
    end)

    love.graphics.draw(self.canvas, posX, posY)
end

function W.getImageData(self)
    return self.canvas:newImageData()
end

function W.placeItem(self, x, y)
  if self.selectedItem == nil then
    return
  end
  local sx, sy = translateParentCoords(x, y)
  
  if sx < 0 or sx > width or sy < 0 or sy > height then
      return
  end

  table.insert(self.objects, {
      idx=self.selectedItem,
      x=sx,
      y=sy,
      r = self.itemRotation
  })
  
  self.selectedItem = nil
  self.itemRotation = 0
end

function W.selectItem(self, itemType)
  -- TODO use the itemType passed once we get click detection in
  --self.selectedItem = itemType
  
  if self.selectedItem == nil then
    self.selectedItem = 0
  end
  
  self.selectedItem = self.selectedItem + 1
  
  if self.selectedItem > (spritesX * spritesY) then
    self.selectedItem = 1
  end
end

function W.rotateItem(self)
  -- rotate 3.6 degrees
  self.itemRotation = self.itemRotation + 0.01 * math.pi
end

function W.undoItemPlacement(self)
  table.remove(self.objects, #self.objects)
end

function W.clearItems(self)
  self.objects = {}
end

return W