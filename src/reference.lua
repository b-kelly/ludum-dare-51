local canvas
function loadReference()
    canvas = love.graphics.newCanvas(256, 256)
end

function drawReference(texture, mask)
    love.graphics.setCanvas({
        canvas,
        stencil=true
    })
    drawMask(mask, 0, 0, function()
        love.graphics.draw(texture, 0, 0)
    end)
    love.graphics.setCanvas()

    love.graphics.draw(canvas, 0, 0)
end