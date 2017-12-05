gui = require('lib/Gspot')
-- player = require('player')
menu = require('menu')
stage = require('stage')
music = require('music')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640
font = love.graphics.newImageFont("dat/fnt/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/.,:", 2)
bgImage = love.graphics.newImage("dat/gph/menu_bg.png")
bg = love.graphics.newCanvas(SCREEN_WIDTH + 128, SCREEN_HEIGHT + 128)
bgAnimation = 0
bgDelta = 0
bigwin = false
stg = {}
lvl = 1
lastLvl = 4

function drawTitles()
    love.graphics.scale(2, 2)
    love.graphics.draw(last_bg, 0, 0)

    -- love.graphics.draw(parallax_bg, 0, 0)
    -- love.graphics.draw(canvas, 0, 0)
    for i, str in ipairs(titlesText) do
        love.graphics.print(str, 0, 32*(i - 1))
    end
end

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
    stg[3] = {
        b_name = 'stg/st3/map_b.png',
        f_name = 'stg/st3/map_f.png',
        description = 'stg/st3/description'
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
            if lvl == lastLvl then
                -- drawTitles()
            else
                win = stage.update(dt)
            end
            if win == true then
                win = false
                lvl = lvl + 1
                if lvl == lastLvl then
                    last_bg = love.graphics.newImage("dat/gph/bg.png")

                    stage.clearWorld()
                    titlesText = {}
                    titles = love.filesystem.newFile('stg/end')
                    titles:open("r")
                    titles:read() -- whhaaaat без этого уходит в бесконечный цикл

                    for line in titles:lines() do
                        table.insert(titlesText, line)
                    end
                    titles:close()
                else
                    stage.load(stg[lvl].b_name, stg[lvl].f_name, stg[lvl].description)
                end
            end
        end

        love.draw = function()
            if lvl == lastLvl then
                drawTitles()
            else
                stage.draw(0, 0)
            end
        end
    end
end

function love.update(dt)
    -- if bigwind then
        gui:update(dt)
        bgDelta = bgDelta + dt
        if bgDelta >= 0.03 then
            bgAnimation = bgAnimation + 1
            bgDelta = 0
            if bgAnimation >= 128 then
                bgAnimation = 0
            end
        end
    -- end
end

function love.draw()
    -- if bigwind then
        love.graphics.draw(bg, bgAnimation - 128, bgAnimation - 128)
        gui:draw()
    -- end
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	Stage.keypressed(key, scancode, isrepeat)
end