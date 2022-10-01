function getImageSimularityPercent(a, b)
    -- there may be a better way of doing this...
    -- assumes both images are the same height/width
    local height = a:getHeight()
    local width = a:getWidth()

    local matchingPixelCount = 0

    for x=0, width - 1 do
       for y=0, height - 1 do
        local r1, g1, b1, a1 = a:getPixel(x, y)
        local r2, g2, b2, a2 = b:getPixel(x, y)

        if a1 == a2 then
            matchingPixelCount = matchingPixelCount + 1
        end
       end 
    end

    return (matchingPixelCount / (height * width)) * 100
end

function drawToCanvas(canvas, fn)
    love.graphics.setCanvas({
        canvas,
        stencil=true
    })

    fn()


    love.graphics.setCanvas()

    return canvas
end