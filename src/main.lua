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
    loadBagLocations()
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
        drawDebug(scorer, data["textureImg"], data["textureSprite"], mx, my)
    end
end

function love.mousepressed(x, y, button)
  --first, check to see if you're trying to pick up an item from a bag
  local item = detectWhichItemToGrabFromBags(x, y)
  if item ~= 0 then
    workspace:selectItem(item)
  --if not, then see if you're trying to place an item you have selected
  elseif workspace.selectedItem ~= nil then
    workspace:placeItem(x, y)
    -- TODO also need to update the scorer when the player is done placing
    if debug then
      local data = reference:getData()
      scorer:update(data["maskData"], data["maskSprite"], workspace:getImageData())
    end
  --then check to see if you've clicked on an item that's already been placed
  else
    local placedItem = workspace:itemToMoveOnCanvas(x, y)
    if placedItem ~= 0 then
      workspace:removeItem(placedItem)
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