require "mask"
debug = true

love.graphics.setBackgroundColor(255,255,255)

function love.load(arg)
    texture = love.graphics.newImage('assets/texture.png')
    mask = love.graphics.newImage('assets/mask.png')
end

function love.update(dt)

end

function love.draw(dt)
    drawMask(mask, function()
        love.graphics.draw(texture)
    end)
end