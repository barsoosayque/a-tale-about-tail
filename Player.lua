Player = {}


local anim8 = require("anim8")


local img = nil
local standAnim = nil
--[[
	Stand = 0
	RunL = -1
	RunR = 1
]]
local state = 0

function Player.load(pathToStand)
	img = love.graphics.newImage(pathToStand)
	local g = anim8.newGrid(18, 18, img:getWidth(), img:getHeight())
	standAnim = anim8.newAnimation(g('1-4',1), 0.2)
end

function Player.update(dt)
	if state == 0 then
		standAnim:update(dt)
	end
end


function getImageScaleForNewDimensions(image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end



function Player.draw()
	-- local scaleX, scaleY = getImageScaleForNewDimensions(img, 2*unit, 2*unit )
	-- love.graphics.draw(Stage.textures[texture], x, y, 0, scaleX, scaleY)


	if state == 0 then
		standAnim:draw(img, 300, 500, 0, 2, 2)
	end
end










return Player