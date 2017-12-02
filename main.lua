gui = require('Gspot')
player = require('Player')


SCREEN_WIDTH = 640 
SCREEN_HEIGHT = 640 

font = love.graphics.newFont(192)

love.load = function()
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setFont(font)
    -- love.graphics.setColor(255, 192, 0, 128)

    sound = love.audio.newSource("/dat/snd/sheltur.xm", "static")
    -- sound:play()
    
    local btnStart = gui:button('Start', {x = 256, y = 32, w = 128, h = gui.style.unit})
    local btnOption = gui:button('Option', {x = 256, y = 64, w = 128, h = gui.style.unit})
    local btnExit = gui:button('Exit', {x = 256, y = 96, w = 128, h = gui.style.unit})
    btnExit.click = function ()
        gui:feedback('Clicky')
        love.event.quit() 
    end


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