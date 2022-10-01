require "mask"
require "reference"
require "utils"
require "ui"

local W = require "workspace"

debug = true

function love.load(arg)
    --require("mobdebug").start()
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

    workspace:draw()

    if debug then
        local data = workspace:getImageData()
        drawDebug(data)
    end
end

function love.mousepressed(x, y, button)
  workspace:addItem(x, y, button)
end