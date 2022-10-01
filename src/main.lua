require "mask"
require "reference"
require "utils"
require "ui"

local W = require "workspace"
local S = require "scorer"
local R = require "reference"

debug = true

local texture
local mask
local workspace
local scorer
local reference

function love.load(arg)
    --require("mobdebug").start()
    love.keyboard.setKeyRepeat(true)
    loadUI()
    workspace = W.new()
    scorer = S.new()
    reference = R.new()
end

function love.update(dt)
end

function love.draw(dt)
    drawUI(function()
      reference:draw()
    end)
  
    local mx, my = love.mouse.getPosition()
    workspace:draw(mx, my)

    if debug then
        local data = reference:getData()
        drawDebug(scorer, data["textureImg"], data["textureSprite"])
    end
    
    love.graphics.printf(mx .. ", " .. my, mx+10, my, 40, "left")
end

function love.mousepressed(x, y, button)
  local item = detectWhichItemToGrabFromBags(x, y)
  if item ~= 0 then
    workspace:selectItem(item)
  elseif workspace.selectedItem ~= nil then
    workspace:placeItem(x, y)
    
    -- TODO also need to update the scorer when the player is done placing
    if debug then
      scorer:update(maskData, workspace:getImageData())
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "r" then
    workspace:rotateItem()
  elseif key == "z" then
    workspace:undoItemPlacement()
  elseif key == "c" then
    workspace:clearItems()
  elseif key == "space" then
    reference:setIdx(0)
  end
end