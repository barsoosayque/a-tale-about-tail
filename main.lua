gui = require('Gspot')
player = require('Player')
menu = require('menu')

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 640

font = love.graphics.newFont(192)

love.load = function()
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setFont(font)
    love.graphics.setBackgroundColor(128, 256, 256, 0)

    local sound = love.audio.newSource("/dat/snd/sheltur.xm", "static")

    drawMainMenu()

    player.load('dat/gph/fox.png')
end

love.update = function(dt)
    gui:update(dt)
    player.update(dt)
end

love.draw = function()
    gui:draw()
    player.draw()
end

love.mousepressed = function(x, y, button)
    gui:mousepress(x, y, button)
end