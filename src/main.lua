require "mask"
require "reference"
require "utils"
require "ui"

local W = require "workspace"

debug = true

function love.load(arg)
    --require("mobdebug").start()
    love.keyboard.setKeyRepeat(true)
    texture = love.graphics.newImage('assets/texture.png')
    mask = love.graphics.newImage('assets/mask.png')
    loadUI()
    loadReference()
    workspace = W.new()
end

function love.update(dt)
end

function love.draw(dt)
    drawUI(function()
      drawReference(texture, mask)
    end)
  
    local mx, my = love.mouse.getPosition()
    workspace:draw(mx, my)

    if debug then
        local data = workspace:getImageData()
        drawDebug(data)
    end
    
    love.graphics.printf(mx .. ", " .. my, mx+10, my, 40, "left")
end

function love.mousepressed(x, y, button)
  local item = detectWhichItemToGrabFromBags(x, y)
  if item ~= 0 then
    workspace:selectItem(item)
  elseif workspace.selectedItem ~= nil then
    workspace:placeItem(x, y)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "r" then
    workspace:rotateItem()
  elseif key == "z" then
    workspace:undoItemPlacement()
  elseif key == "c" then
    workspace:clearItems()
  end
end