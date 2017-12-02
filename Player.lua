Player = {}

Player.x = 0
Player.y = 0
Player.width = 18 * 2
Player.height = 18 * 2
Player.way = 0

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
]]
local state = 0

-- function Player.load(pathToStand)
function Player.load(x, y, l)
    Player.x = x
    Player.y = y
    Player.way = l

    image = love.graphics.newImage('dat/gph/fox.png')

    Player.addAnim('stand', 18, 18, 0, 0, 4, 0.1)
    Player.addAnim('run', 18, 18, 0, 18, 4, 0.1)

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
        animations['run']:update(dt)
    elseif state == -1 then
        animations['run']:update(dt)
    end
end

function Player.update(dt)
    if love.keyboard.isDown('right') then
        Player.way = Player.way + speed
        state = 1
    elseif love.keyboard.isDown('left') then
        Player.way = Player.way - speed
        state = -1
    else
        state = 0
    end

    Player.animationUpdate(dt)
end

function Player.draw()
    local anim

    if state == 0 then
        anim = animations['stand']
    elseif state == 1 then
        anim = animations['run']
        -- love.graphics.rotate(3.14/2)
    elseif state == -1 then
        anim = animations['run']
    end

    anim:draw(image, Player.x, Player.y, 0, 2, 2)
end

return Player