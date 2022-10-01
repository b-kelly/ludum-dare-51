-- ignore all alpha
local mask_shader = love.graphics.newShader[[
    vec4 effect(vec4 colour, Image texture, vec2 texpos, vec2 scrpos)
    {
        vec4 pixel = Texel(texture, texpos) * colour;
        if (pixel.a < 1) discard;
        return pixel;
    }
]]

local function drawStencil(mask, x, y)
   love.graphics.setShader(mask_shader)
   love.graphics.draw(mask, x, y)
   love.graphics.setShader()
end

-- mask is love.Image
function drawMask(mask, x, y, fn)
    love.graphics.stencil(function()
        drawStencil(mask, x, y)
    end, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    fn()
    love.graphics.setStencilTest()
end