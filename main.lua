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

    local music = love.audio.newSource("/dat/snd/sheltur.xm", "static")
    music:setLooping(true)
    music:play()

    drawMainMenu()
end

function love.update(dt)
    gui:update(dt)
end

function love.draw()
    gui:draw()
end

function love.mousepressed(x, y, button)
    gui:mousepress(x, y, button)
end