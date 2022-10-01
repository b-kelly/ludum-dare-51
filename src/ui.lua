local bg

function loadUI()
    bg = love.graphics.newImage('assets/background.png')
    referenceArea = love.graphics.newImage('assets/referenceBackground.png')
    referenceAreaGrid = love.graphics.newImage('assets/referenceBackground_grid.png')
end

function drawUI()
    love.graphics.draw(bg, 0, 0)
    love.graphics.draw(referenceArea, 0, 0)
    love.graphics.draw(referenceAreaGrid, 0, 0)
end

function drawDebug(data)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    drawMask(love.graphics.newImage(data), 256, 0, function()
        love.graphics.draw(texture, 256, 0)
    end)
    love.graphics.pop()
end