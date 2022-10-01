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
end

function love.mousepressed(x, y, button)
  if button == 1 then
    workspace:selectItem(1)
  else
    workspace:placeItem(x, y)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "r" then
    workspace:rotateItem()
  end
end