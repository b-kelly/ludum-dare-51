local bg

function loadUI()
    bg = love.graphics.newImage('assets/background.png')
end

function drawUI()
    love.graphics.draw(bg, 0, 0)
end

function drawDebug(data)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    drawMask(love.graphics.newImage(data), 0, 256, function()
        love.graphics.draw(texture, 0, 256)
    end)
    love.graphics.pop()
end