require "utils"

local SG = {}
SG.__index = SG

function SG.load()
  -- TODO load textures
end

function SG.drawScene(scene, scorer)
  if scene ~= Scenes.GAME then
    return false
  end

  -- TODO

  return true
end

return SG