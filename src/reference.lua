require "utils"

local canvas

function loadReference()
    canvas = love.graphics.newCanvas(256, 256)
end

function drawReference(texture, mask)
    drawToCanvas(canvas, function ()
        love.graphics.scale(0.5, 0.5)
        drawMask(mask, 0, 0, function()
            love.graphics.draw(texture, 0, 0)
        end)
    end)

    love.graphics.draw(canvas, 0, 0)
end