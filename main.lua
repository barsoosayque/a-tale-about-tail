function love.load()
    sound = love.audio.newSource("/data/snd/sheltur.xm", "static")
    sound:play()
end