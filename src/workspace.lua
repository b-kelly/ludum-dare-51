require "utils"

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

    drawToCanvas(canvas, function ()
        drawObjects()
    end)

    love.graphics.draw(canvas, 256, 256)
end

function getWorkspaceImageData()
    return canvas:newImageData()
end