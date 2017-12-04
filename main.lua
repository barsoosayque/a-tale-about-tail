gui = require('lib/Gspot')
-- player = require('player')
menu = require('menu')
stage = require('stage')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640
font = love.graphics.newFont("dat/fnt/dsmysticora.ttf", 32)
music_01 = love.audio.newSource("/dat/snd/menu.xm", "static")
music_02 = love.audio.newSource("/dat/snd/shadow.xm", "static")
bgImage = love.graphics.newImage("dat/gph/menu_bg.png")
bg = love.graphics.newCanvas(SCREEN_WIDTH + 64, SCREEN_HEIGHT + 64)
bgAnimation = 0
bgDelta = 0

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setBackgroundColor(128, 256, 256, 0)

    love.graphics.setFont(font)
    gui.style.font = font
    gui.style.unit = 64

    love.graphics.setCanvas(bg)
        love.graphics.clear()
        for x=0,11 do
            for y=0,11 do
                love.graphics.draw(bgImage, 64 * x, 64 * y)
            end
        end
    love.graphics.setCanvas()

    Menu.drawMainMenu()
    Menu.startGameCallback = function()
        stage.load('stg/st1/map_b.png', 'stg/st1/map_f.png', 'stg/st1/description')

        if Menu.stateSound then
            music_02.play()
        end

        love.update = function(dt)
            stage.update(dt)
        end

        love.draw = function()
            stage.draw(0, 0)
        end
    end
end

function enableMusic()
    music_01:setLooping(true)
    music_02:setLooping(true)
    music_02:stop()
    music_01:play()
end

function disableMusic()
    music_01:stop()
    music_02:stop()
end


function love.update(dt)
    gui:update(dt)
    if menu.stateSound then
        enableMusic()
    else
        disableMusic()
    end
    bgDelta = bgDelta + dt
    if bgDelta >= 0.03 then
        bgAnimation = bgAnimation + 1
        bgDelta = 0
        if bgAnimation >= 64 then
            bgAnimation = 0
        end
    end
end

function love.draw()
    love.graphics.draw(bg, bgAnimation - 64, bgAnimation - 64)
    gui:draw()
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	Stage.keypressed(key, scancode, isrepeat)
end