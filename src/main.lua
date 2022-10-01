require "mask"
require "reference"
require "workspace"
require "utils"
require "ui"

debug = true

function love.load(arg)
    texture = love.graphics.newImage('assets/texture.png')
    mask = love.graphics.newImage('assets/mask.png')
    loadUI()
    loadReference()
    loadWorkspace()
end

function love.update(dt)

end

function love.draw(dt)
    drawUI()
    drawReference(texture, mask)
    drawWorkspace()

    if debug then
        local data = getWorkspaceImageData()
        drawDebug(data)
    end


end

function love.mousepressed(x, y, button)
    if button == 1 then
       addItemToWorkspace(x, y)
    end
 end