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
local timer = 0
local timerMax = 10

function translateParentCoords(x, y)
  return x - posX, y - posY
end

function drawItem(texture, quad, x, y, r)
  local offset = spriteWidth / 2
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
  
  self.updateTimer()
  self.selectedItem = nil
  self.itemRotation = 0
end

function W.selectItem(self, itemIndex)
  self.selectedItem = itemIndex
end

function W.removeItem(self, itemIndex)
  table.remove(self.objects, self.objects[itemIndex])
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

--right now this is only called when we place an item, we may want to call it other places as well
function W.updateTimer()
  if timer < timerMax then
    timer = timer + 1
  else
    --confirmFinished(), then check match TODO
    --timer = 0
  end
end

function W:itemToMoveOnCanvas(mx, my)
  for i=1,#self.objects do
    local obj = self.objects[i]
    local toCheck = 
    {
      x1 = obj.x + posX,
      y1 = obj.y + posY,
      x2 = obj.x + posX + spriteWidth,
      y2 = obj.y + posY + spriteWidth
    }
    print(toCheck.x1.." "..toCheck.x2.." "..toCheck.y1.." "..toCheck.y2)
    if hasMouseOverlap(mx, my, toCheck) then
      local r, g, b, a = self.sprites[obj[idx]]:getPixel(mx, my)
      if a == 1 then
        return i
      end
    end
  end
  return 0
end


return W