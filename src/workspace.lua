local canvas
local texture

function loadWorkspace()
    canvas = love.graphics.newCanvas(256, 256)
    texture = love.graphics.newImage('assets/object.png')
end

function drawObjects()
    love.graphics.draw(texture, 0, 0)
    love.graphics.draw(texture, 10, 10)
end

function drawWorkspace()
    love.graphics.setCanvas({
        canvas,
        stencil=true
    })

    drawObjects()


    love.graphics.setCanvas()

    love.graphics.draw(canvas, 256, 256)
end

function getWorkspaceImage()
    return love.graphics.newImage(canvas:newImageData())
end