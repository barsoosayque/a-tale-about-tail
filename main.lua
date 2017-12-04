gui = require('lib/Gspot')
-- player = require('player')
menu = require('menu')
stage = require('stage')
music = require('music')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640
font = love.graphics.newFont("dat/fnt/dsmysticora.ttf", 32)
bgImage = love.graphics.newImage("dat/gph/menu_bg.png")
bg = love.graphics.newCanvas(SCREEN_WIDTH + 128, SCREEN_HEIGHT + 128)
bgAnimation = 0
bgDelta = 0

function love.load()
    music.load("song", "dusk", "dat/snd/dusk.xm")
    music.load("song", "shadow", "dat/snd/shadow.xm")
    music.load("song", "catcher", "dat/snd/catcher.xm")
    music.songs["catcher"]:setLooping(false)

    music.load("sfx", "jump", "dat/sfx/jump.xm")
    music.load("sfx", "djump", "dat/sfx/djump.xm")
    music.load("sfx", "land", "dat/sfx/land.xm")
    music.load("sfx", "pickup", "dat/sfx/pickup.xm")

    Menu.load()

    love.graphics.setDefaultFilter("nearest", "nearest")
    -- love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setBackgroundColor(128, 256, 256, 0)

    love.graphics.setFont(font)
    gui.style.font = font
    gui.style.unit = 64

    love.graphics.setCanvas(bg)
        love.graphics.clear()
        for x=0,5 do
            for y=0,5 do
                love.graphics.draw(bgImage, 128 * x, 128 * y)
            end
        end
    love.graphics.setCanvas()

    Menu.drawMainMenu()
    Menu.startGameCallback = function()
        stage.load('stg/st1/map_b.png', 'stg/st1/map_f.png', 'stg/st1/description')

        love.update = function(dt)
            stage.update(dt)
        end

        love.draw = function()
            stage.draw(0, 0)
        end
    end
end

function love.update(dt)
    gui:update(dt)
    bgDelta = bgDelta + dt
    if bgDelta >= 0.03 then
        bgAnimation = bgAnimation + 1
        bgDelta = 0
        if bgAnimation >= 128 then
            bgAnimation = 0
        end
    end
end

function love.draw()
    love.graphics.draw(bg, bgAnimation - 128, bgAnimation - 128)
    gui:draw()
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	Stage.keypressed(key, scancode, isrepeat)
end