gui = require('lib/Gspot')
player = require('Player')
menu = require('menu')
stage = require('Stage')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640

font = love.graphics.newFont(192)

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(128, 256, 256, 0)

    local sound = love.audio.newSource("/dat/snd/sheltur.xm", "static")

    drawMainMenu()

    player.load('dat/gph/fox.png')
    stage.load('stg/st1/map_b.png', 'stg/st1/map_f.png', 'stg/st1/description')
    stage.newTexture('dat/img/block.png', 'block')
    stage.newTexture('dat/img/empti.png', 'empti')
end

function love.update(dt)
    gui:update(dt)
    stage.update(dt)
     player.update(dt)
end

function love.draw()
    gui:draw()
    stage.draw(0, 150)
    -- player.draw()
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end