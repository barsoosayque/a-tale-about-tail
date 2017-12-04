local Player = {}
Player.name = 'player'

Player.x = 0
Player.y = 0
Player.width = 0
Player.height = 0
Player.speedX = 0
Player.speedY = 0

Player.bag = 0

local anim8 = require('lib/anim8')
local img
local imgD = 18
local animations = {}

local run = 0 -- 0 stand 1 - run
local side = -1 -- -1 left 1 right
local fly = false
local dj = false
local jump = false

local width = 0
local speed = 200/2

local inventory

local t = 0 
-- local count = 0


local particleSetting = {
    lifeTime = 0.4,
    count = 0,
    speed = 60,
    acceleration = {
        y = 100000,
        x = 0
    }
}


-- local particleSystem, fgParticleSystem
local particleSystem

function Player.load(x, y, length)
    Player.x = x
    Player.y = y
    Player.width = imgD - 5
    Player.height = imgD - 7
    width = length

    img = love.graphics.newImage('dat/gph/fox.png')
    Player.addAnim('standL', 18, 18,   0,  0,    4, 0.1)
    Player.addAnim('standR', 18, 18,   0,  18,   4, 0.1)
    Player.addAnim('runL',   18, 18,   0,  36,   4, 0.1)
    Player.addAnim('runR',   18, 18,   0,  54,   4, 0.1)
    Player.addAnim('jumpL',  18, 18,   0,  72,   2,   1)
    Player.addAnim('jumpR',  18, 18,   36, 72,   2,   1)


    local i = love.graphics.newImage('dat/gph/particle.png')
    particleSystem = newParticleSystem(i)
    particleSystem:setQuads(love.graphics.newQuad(0, 0, 3, 3, i:getDimensions()), love.graphics.newQuad(0, 3, 3, 3, i:getDimensions()))
end

function Player.update(dt)
    -- print('fly:'..tostring(fly)..' jump:'..tostring(jump)..'\ntime:'..tostring(t))
    local rot = -math.random()*math.pi
    particleSystem:setLinearAcceleration(0, particleSetting.acceleration.y*dt)
    local ax, ay = particleSystem:getLinearAcceleration()
    -- print('acc:'..tostring(ax)..' '..tostring(ay))
    particleSystem:setDirection(rot)
    -- particleSystem:setSpeed(20, 40)
    -- particleSystem:setPosition( Player.x + Player.width/2,
    --                             Player.y + Player.height - 2)
    particleSystem:update(dt)
    if particleSystem:getCount() > particleSetting.count*(particleSetting.lifeTime - 0.1) then
        particleSystem:setEmissionRate(0)
    end

    if love.keyboard.isDown('left') then
        Player.speedX = -speed
        run = 1
        side = -1
    elseif love.keyboard.isDown('right') then
        Player.speedX = speed
        run = 1
        side = 1
    else
        Player.speedX = 0
        run = 0
    end
    if fly == true and Player.speedX ~= 0 then
        -- Player.speedX = Player.speedX / 1.15
        Player.speedX = Player.speedX
    end


    Player.animationUpdate(dt)
end

function Player.draw(x, y)
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

    local dtx = math.floor(imgD/2 - Player.width/2)
    local dty = math.floor(imgD - Player.height)



    if fly == true then
        if side == -1 then
            anim = animations['jumpL']
        else
            anim = animations['jumpR']
        end
    end
    
    love.graphics.draw(particleSystem, 0, 0)
    anim:draw(img, x - dtx , y - dty)
end

function newParticleSystem(i)
    local ps = love.graphics.newParticleSystem(i, 200)
    ps:setParticleLifetime(particleSetting.lifeTime, particleSetting.lifeTime) -- Particles live at least 2s and at most 5s.
    -- ps:setEmissionRate(10)
    -- ps:setSizeVariation(0)
    -- ps:setLinearAcceleration(-100, -100, 100, 1) -- Random movement in all directions.
    -- ps:setColors( 255, 255, 0, 255,
    --               -- 255, 255, 0, 200,
    --               -- 255, 255, 0, 180,
    --               -- 255, 255, 0, 150,  
    --               255, 255, 0,   0) -- Fade to transparency.
    return ps
end

function Player.land()
    if fly == true then
        particleSetting.count = Player.bag*Player.speedY/1500 
        print('count:'..tostring(particleSetting.count))
        particleSystem:setEmissionRate(particleSetting.count) 
        particleSystem:setPosition( Player.x + Player.width/2,
                                    Player.y + Player.height - 2)
        particleSystem:setSpeed(particleSetting.speed, particleSetting.speed)
        -- particleSystem:setSpeed(20 + Player.bag/10, 40 + Player.bag/10)
    end

    if Player.speedY > 10 then
        print('speedY:'..tostring(Player.speedY))
    end
    fly = false
    dj = false
    jump = false
end

function Player.fly()
    fly = true
end

function Player.addAnim(name, w, h, left, top, n, time)
    local g = anim8.newGrid(w, h, img:getWidth(), img:getHeight(), left, top)
    local str = '1-' .. tostring(n)
    
    animations[name] = anim8.newAnimation(g(str, 1), time)
end

function Player.animationUpdate(dt)
    if run == 0 and fly == false then
        if side == -1 then 
            animations['standL']:update(dt) 
        else
            animations['standR']:update(dt)
        end
    elseif run == 1 and side == 1 and fly == false then
        animations['runR']:update(dt)
    elseif run == 1 and side == -1 and fly == false then
        animations['runL']:update(dt)
    else
        t = t + dt
    end

    if t < 0.1 and fly == true  then
        if side == -1 then
            animations['jumpL']:gotoFrame(1)
        else
            animations['jumpR']:gotoFrame(1)
        end
    elseif t > 0.1 or fly == true then
        if side == -1 then
            animations['jumpL']:gotoFrame(2)
        else
            animations['jumpR']:gotoFrame(2)
        end
    end
end

function Player.filter(item, other)
    local name = other.name
    if name == 'stone' or name == 'dirt' or name == 'wood' or name == 'wall' or name == 'roof' then
        return 'slide'
    elseif name == 'chest' or name == 'table' or name == 'cup' then
        return 'cross'
    end
end

function Player.keypressed(key, scancode, isrepeat)
    if key == 'up' and (fly == false or dj == false) then
        jump = true
        Player.speedY = -400-- -500
        dj = fly
        fly = true
        t = 0
    end
end

return Player
