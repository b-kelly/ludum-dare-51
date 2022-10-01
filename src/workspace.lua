require "utils"

local canvas
local texture

local posX = 256
local posY = 256
local width = 256
local height = 256

local objects = {}

function loadWorkspace()
    canvas = love.graphics.newCanvas(width, height)
    texture = love.graphics.newImage('assets/object.png')
end

function drawObjects()
    for i=0,#objects do
        local obj = objects[i]
        if obj ~= nil then
            love.graphics.draw(obj["image"], obj["x"], obj["y"])
        end
    end
end

function drawWorkspace()
    drawToCanvas(canvas, function ()
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", 0, 0, width, height)
        drawObjects()
    end)

    love.graphics.draw(canvas, posX, posY)
end

function getWorkspaceImageData()
    return canvas:newImageData()
end

function addItemToWorkspace(x, y)
    if x < posX  or x > posX + width or y < posY or y > posY + height then
        return
    end

    table.insert(objects, {
        image=texture,
        x=x-posX,
        y=y-posY
    })
end