require "utils"
require "spritesheet"

W = {}
W.__index = W

local posX = 260
local posY = 314
local width = 256
local height = 256

function W.new()  
  local texture = love.graphics.newImage("assets/buildingObjects.png")
  local self = setmetatable({
      canvas = love.graphics.newCanvas(width, height),
      texture = texture,
      sprites = loadSpritesheet(texture, 5, 2, 128),
      objects = {}
    }, W)
  
  return self
end

function W.drawObjects(self)
    for i=0,#self.objects do
        local obj = self.objects[i]
        if obj ~= nil then
            love.graphics.draw(self.texture, self.sprites[obj["idx"]], obj["x"], obj["y"])
        end
    end
end

function W.draw(self)
    drawToCanvas(self.canvas, function ()
        love.graphics.setColor(1, 1, 1, 0)
        love.graphics.rectangle("fill", 0, 0, width, height)
        love.graphics.setColor(1, 1, 1, 1)
        self.drawObjects(self)
    end)

    love.graphics.draw(self.canvas, posX, posY)
end

function W.getImageData(self)
    return self.canvas:newImageData()
end

function W.addItem(self, x, y, itemType)
    if x < posX  or x > posX + width or y < posY or y > posY + height then
        return
    end

    table.insert(self.objects, {
        idx=itemType,
        x=x-posX,
        y=y-posY
    })
end

return W