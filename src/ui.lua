local bg

function loadUI()
    bg = love.graphics.newImage('assets/background.png')
    referenceArea = love.graphics.newImage('assets/referenceBackground.png')
    referenceAreaGrid = love.graphics.newImage('assets/referenceBackground_grid.png')
    undoButton = love.graphics.newImage('assets/undoButton.png')
    rotateButton = love.graphics.newImage('assets/rotateButton.png')
    clearButton = love.graphics.newImage('assets/clearButton.png')
end

function drawUI(fn)
    love.graphics.draw(bg, 0, 0)
    love.graphics.draw(referenceArea, 0, 0)
    fn()
    love.graphics.draw(referenceAreaGrid, 11, 11)
    love.graphics.draw(rotateButton, 160, 260)
    love.graphics.draw(undoButton, 160, 330)
    love.graphics.draw(clearButton, 160, 400)
end

function drawDebug(scorer, texture, sprite)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    scorer:drawDebug(texture, sprite)
    love.graphics.pop()
end