Player = {}

Player.x = 0
Player.y = 0
Player.way = 0

local anim8 = require("lib/anim8")


local speed = 1
local standAnim = nil
local animations = {}
--[[
	Stand = 0
	RunL = -1
	RunR = 1
]]
local state = 0

-- function Player.load(pathToStand)
function Player.load(x, y, l)
	Player.x = x
	Player.y = y
	Player.way = l

	Player.addAnim('dat/gph/fox.png', 'stand', 18, 18, 4, 0.2)

	-- img = love.graphics.newImage(pathToStand)
	-- local g = anim8.newGrid(18, 18, img:getWidth(), img:getHeight())
	-- standAnim = anim8.newAnimation(g('1-4',1), 0.2)
end

function Player.addAnim(pathToAnim, name, width, height, n, time)
	local img = love.graphics.newImage(pathToAnim)
	local g = anim8.newGrid(width, height, img:getWidth(), img:getHeight())
	-- standAnim = anim8.newAnimation(g('1-4',1), 0.2)
	local str = '1-'..tostring(n)
	-- anim8.newAnimation(g(str,1), time)
	animations[name] = {image = img, animation = anim8.newAnimation(g(str,1), time)}
end

function Player.animationUpdate(dt)
	if state == 0 then
		-- standAnim:update(dt)
		animations['stand']['animation']:update(dt)
	end
end

function Player.update(dt)
	if love.keyboard.isDown('right') then
		Player.x = Player.x + speed
		Player.way = Player.way + speed
		state = 1
	elseif love.keyboard.isDown('left') then
		Player.x = Player.x - speed
		Player.way = Player.way - speed
		state = -1
	else
		state = 0
	end



	Player.animationUpdate(dt)
end

function Player.draw()
	-- if state == 0 then
		-- standAnim:draw(img, Player.x, Player.y, 0, 10, 10)
	animations['stand']['animation']:draw(animations['stand']['image'], Player.x, Player.y, 0, 2, 2)
	-- end
end










return Player