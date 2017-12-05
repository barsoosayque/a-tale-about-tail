local Enemy = {}

Enemy.name = 'enemy'
local anim8 = require('lib/anim8')
local speed = 55
local t = 0

function Enemy.newEnemy(x, y, w)
    local enemy = {
        name = 'enemy',
        x = x,
        y = y,
        width = 30,
        height = 30,
        speedX = speed,
        speedY = 0,
        stepTick = 0,
        spawnX = x,
        spawnY = y,
        run = 1, -- 0 stand 1 - run
        side = -1, -- -1 left 1 rigth

        img = nil,
        animations = {},
        reset = function(self)
            self.x = self.spawnX
            self.y = self.spawnY
        end,
        animationUpdate = function(self, dt)
            if self.side == -1 then
                self.speedX = -speed
                self.animations['runL']:update(dt)
            else
                self.speedX = speed
                self.animations['runR']:update(dt)
            end
        end,
        addAnim = function(self, name, w, h, left, top, n, time)
            local g = anim8.newGrid(w, h, self.img:getWidth(), self.img:getHeight(), left, top)
            local str = '1-' .. tostring(n)
            self.animations[name] = anim8.newAnimation(g(str, 1), time)
        end,
        load = function(self)
            self.img = love.graphics.newImage('dat/gph/grandpa.png')
            self:addAnim('standL', 30, 30, 0, 0, 4, 0.1)
            self:addAnim('standR', 30, 30, 0, 30, 4, 0.1)
            self:addAnim('runL', 30, 30, 0, 60, 4, 0.1)
            self:addAnim('runR', 30, 30, 0, 90, 4, 0.1)

        end,
        draw = function(self, x, y)
            local anim
            if self.run == 0 and self.side == 1 then
                anim = self.animations['standR']
            elseif self.run == 0 and self.side == -1 then
                anim = self.animations['standL']
            elseif self.run == 1 and self.side == 1 then
                anim = self.animations['runR']
            elseif self.run == 1 and self.side == -1 then
                anim = self.animations['runL']
            end
            anim:draw(self.img, x, y)
        end,
        update = function(self, dt)
            self:animationUpdate(dt)
        end,
        land = function()

        end,
        turnBack = function(self)
            self.side = -self.side
            self.stepTick = 0
        end,
        filter = function(item, other)
            if other.name == 'stone' or other.name == 'dirt' or other.name == 'wood' then
                return 'slide'
            end
        end,
        fly = function() end

    }
    return enemy

end


return Enemy
