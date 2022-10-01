require "mask"
require "reference"
require "workspace"
require "utils"
debug = true

love.graphics.setBackgroundColor(255,255,0)

function love.load(arg)
    texture = love.graphics.newImage('assets/texture.png')
    mask = love.graphics.newImage('assets/mask.png')
    loadReference()
    loadWorkspace()
end

function love.update(dt)

end

function love.draw(dt)
    drawReference(texture, mask)
    drawWorkspace()

    local data = getWorkspaceImageData()

    drawMask(love.graphics.newImage(data), 512, 512, function()
        love.graphics.draw(texture, 512, 512)
    end)
end

function love.mousepressed(x, y, button)
    if button == 1 then
       addItemToWorkspace(x, y)
    end
 end