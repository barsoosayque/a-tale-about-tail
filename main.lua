gui = require('lib/Gspot')
-- player = require('player')
menu = require('menu')
stage = require('stage')
music = require('music')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640
font = love.graphics.newImageFont("dat/fnt/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/.,")
bgImage = love.graphics.newImage("dat/gph/menu_bg.png")
bg = love.graphics.newCanvas(SCREEN_WIDTH + 128, SCREEN_HEIGHT + 128)
bgAnimation = 0
bgDelta = 0

stg = {}
lvl = 1
function love.load()
    music.load("song", "dusk", "dat/snd/dusk.xm")
    music.load("song", "shadow", "dat/snd/shadow.xm")
    music.load("song", "catcher", "dat/snd/catcher.xm")
    music.songs["catcher"]:setLooping(false)

    music.load("sfx", "jump", "dat/sfx/jump.xm")
    music.load("sfx", "djump", "dat/sfx/djump.xm")
    music.load("sfx", "land", "dat/sfx/land.xm")
    music.load("sfx", "pickup", "dat/sfx/pickup.xm")


    stg[1] = {
        b_name = 'stg/st1/map_b.png',
        f_name = 'stg/st1/map_f.png',
        description = 'stg/st1/description'
    }
    stg[2] = {
        b_name = 'stg/st2/map_b.png',
        f_name = 'stg/st2/map_f.png',
        description = 'stg/st2/description'
    }

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
        stage.load(stg[1].b_name, stg[1].f_name, stg[1].description)

        love.update = function(dt)
            local win = stage.update(dt)
            if win == true then
                lvl = lvl + 1
                if lvl == 3 then lvl = 1 end
                stage.load(stg[lvl].b_name, stg[lvl].f_name, stg[lvl].description)
            end
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
    love.graphics.print(2424242, 100, 150)
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	Stage.keypressed(key, scancode, isrepeat)
end