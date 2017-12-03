gui = require('lib/Gspot')
-- player = require('player')
menu = require('menu')
stage = require('stage')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640
font = love.graphics.newFont(192)
music = love.audio.newSource("/dat/snd/menu.xm", "static")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(128, 256, 256, 0)

    Menu.drawMainMenu()
    Menu.startGameCallback = function()
        stage.load('stg/st1/map_b.png', 'stg/st1/map_f.png', 'stg/st1/description')
        -- stage.newTexture('dat/img/block.png', 'block')
        -- stage.newTexture('dat/img/empty.png', 'empty')

        love.update = function(dt)
            stage.update(dt)
        end

        love.draw = function()
            stage.draw(0, 150)
        end
    end
end

function enableMusic()
    music:setLooping(true)
    music:play()
end

function disableMusic()
    music:stop()
end


function love.update(dt)
    gui:update(dt)
    if menu.stateSound then
        enableMusic()
    else
        disableMusic()
    end
end

function love.draw()
    gui:draw()
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	Stage.keypressed(key, scancode, isrepeat)
end