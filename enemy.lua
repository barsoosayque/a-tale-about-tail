local Enemy = {}

Enemy.name = 'enemy'
Enemy.x = 0
Enemy.y = 0
Enemy.width = 0
Enemy.height = 0
Enemy.speedX = 0
Enemy.speedY = 0
Enemy.stepTick = 0
Enemy.STEP_LIMIT = 175

local anim8 = require('lib/anim8')
local img

local imgD = { w = 30, h = 30 } -- dimenson texture

local scale = 1
local animations = {}


local run = 1 -- 0 stand 1 - run
local side = -1 -- -1 left 1 rigth
local jump = false

local width = 0
local speed = 200 / 2

local t = 0

function Enemy.load(x, y, length)
    Enemy.x = x
    Enemy.y = y
    Enemy.width = 30
    Enemy.height = 30
    width = length

    img = love.graphics.newImage('dat/gph/grandpa.png')
    Enemy.addAnim('standL', 30, 30, 0, 0, 4, 0.1)
    Enemy.addAnim('standR', 30, 30, 0, 30, 4, 0.1)
    Enemy.addAnim('runL', 30, 30, 0, 60, 4, 0.1)
    Enemy.addAnim('runR', 30, 30, 0, 90, 4, 0.1)
end

function Enemy.draw(x, y)
    local anim

    if run == 0 and side == 1 then
        anim = animations['standR']
    elseif run == 0 and side == -1 then
        anim = animations['standL']
    elseif run == 1 and side == 1 then
        anim = animations['runR']
    elseif run == 1 and side == -1 then
        anim = animations['runL']
    end

    local dtx = imgD.w * scale / 2 - math.floor(Enemy.width / 2)
    local dty = imgD.h * scale - Enemy.height

    anim:draw(img, x - dtx, y - dty, 0, scale, scale)
end

function Enemy.land()
    jump = false
end

function Enemy.fly()
end

function Enemy.addAnim(name, w, h, left, top, n, time)
    local g = anim8.newGrid(w, h, img:getWidth(), img:getHeight(), left, top)
    local str = '1-' .. tostring(n)

    animations[name] = anim8.newAnimation(g(str, 1), time)
end

function Enemy.update(dt)
    -- print(side)
    if Enemy.stepTick == Enemy.STEP_LIMIT then
        side = -side
        Enemy.stepTick = 0
    end
    Enemy.stepTick = Enemy.stepTick + 1
    Enemy.animationUpdate(dt)
end

function Enemy.turnBack()
    side = -side
    Enemy.stepTick = 0
end

function Enemy.animationUpdate(dt)
    if side == -1 then
        Enemy.speedX = -speed
        animations['runL']:update(dt)
    else
        Enemy.speedX = speed
        animations['runR']:update(dt)
    end
end

function Enemy.filter(intem, other)
    if other.name == 'stone' or other.name == 'dirt' or other.name == 'wood' or other.name == 'wall' then
        return 'slide'
    end
end

return Enemy