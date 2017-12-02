Player = {}

Player.x = 0
Player.y = 0
Player.speedX = 0
Player.speedY = 0
Player.land = false

Player.width = 18*2
Player.height = 18*2
-- Player.way = 0

local anim8 = require("lib/anim8")

local scale = 2
local speed = 2
local standAnim

local image
local animations = {}


--[[
	Stand = 0
	RunL = -1
	RunR = 1
]]--

local state = 0
local fly = false


function Player.load(x, y, l)
	Player.x = l
	Player.y = y

    image = love.graphics.newImage('dat/gph/fox.png')

	Player.addAnim('stand', 18, 18, 0, 0, 4, 0.1)
	Player.addAnim('runL', 18, 18, 0, 18, 4, 0.1)
	Player.addAnim('runR', 18, 18, 0, 36, 4, 0.1)

    -- img = love.graphics.newImage(pathToStand)
    -- local g = anim8.newGrid(18, 18, img:getWidth(), img:getHeight())
    -- standAnim = anim8.newAnimation(g('1-4',1), 0.2)
end

function Player.addAnim(name, width, height, left, top, n, time)
    local g = anim8.newGrid(width, height, image:getWidth(), image:getHeight(), left, top)
    local str = '1-' .. tostring(n)
    animations[name] = anim8.newAnimation(g(str, 1), time)
end

function Player.animationUpdate(dt)
	if state == 0 then
		animations['stand']:update(dt)
	elseif state == 1 then
		animations['runR']:update(dt)
	elseif state == -1 then
		animations['runL']:update(dt)
	end
end

function Player.update(dt)
	if love.keyboard.isDown('right') then
		-- Player.x = Player.x + Player.speedX
		Player.speedX = speed
		state = 1
	elseif love.keyboard.isDown('left') then
		-- Player.x = Player.x - Player.speedX
		Player.speedX = -speed
		state = -1
	else
		Player.speedX = 0
		state = 0
	end
	if love.keyboard.isDown('up') and fly == false then
		fly = true
		land = false
		Player.speedY = -3
	end
	Player.x = Player.x + Player.speedX
	Player.y = Player.y + Player.speedY


	if Player.land == true then
		fly = false
	end

	Player.animationUpdate(dt)
end

function Player.draw(x, y)
	local anim = nil
	if state == 0 then
		anim = animations['stand']
	elseif state == 1 then
		anim = animations['runR']
		-- love.graphics.rotate(3.14/2)
	elseif state == -1 then
		anim = animations['runL']
	end

	anim:draw(image, 640/2 - Player.width/2, y + Player.y, 0, 2, 2)

	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", 640/2 - Player.width/2, y + Player.y, Player.width, Player.height )
	love.graphics.setColor(255, 255, 255)
end

return Player