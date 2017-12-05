music = require('music')

Menu = {}
Menu.startGameCallback = nul

function saveToFile()
    io.output(io.open('./cfg', 'w+'))
    io.write(tostring(music.songsEnabled).."\n"..tostring(music.effectsEnabled))
    io.close()
end

function Menu.load()
    local config = io.open("./cfg", "r")
    if config ~= nil then
        if config:read() == "true" then
            music.songsEnabled = true
        else
            music.songsEnabled = false
        end

        if config:read() == "true" then
            music.effectsEnabled = true
        else
            music.effectsEnabled = false
        end
        config:close()
    else
        saveToFile(1)
        music.songsEnabled = true
    end

    music.play("dusk")

    gui.style.labelfg = {255, 255, 255, 255}
    gui.style.bg = {59, 50, 67, 255}
    gui.style.fg = {232, 150, 52, 255} -- defaults to fg when absent
    gui.style.default = {113, 79, 54, 255}
    gui.style.hilite = {150, 101, 55, 255}
    gui.style.focus = {80, 65, 93, 255}
end

function Menu.drawOptionsMenu()
    local cbSound = gui:checkbox(nul, { x = 200, y = gui.style.unit * 5, r = 16 })
    local cblSound = gui:text("Music on/off", { x = 32, y = -24 }, cbSound, true)
    cbSound.shape = 'rect'

    local cbEffects = gui:checkbox(nul, { x = 200, y = gui.style.unit * 6, r = 16 })
    local cblEffects = gui:text("Effects on/off", { x = 32, y = -24 }, cbEffects, true)
    cbEffects.shape = 'rect'

    local btnBack = gui:button('Back', { x = 160, y = gui.style.unit * 8, w = 320, h = gui.style.unit })

    cbSound.value = music.songsEnabled
    cbSound.click = function(this)
        gui[this.elementtype].click(this)

        music.songsEnabled = this.value

        if this.value then
            music.play("dusk")
            this.style.fg = { 255, 255, 255, 255 }
            saveToFile(1)
        else
            music.stop()
            this.style.fg = { 128, 128, 128, 255 }
            saveToFile(0)
        end
    end
    cblSound.click = function(this)
        this.parent:click()
    end

    cbEffects.value = music.effectsEnabled
    cbEffects.click = function(this)
        gui[this.elementtype].click(this)

        music.effectsEnabled = this.value
    end
    cblEffects.click = function(this)
        this.parent:click()
    end

    btnBack.click = function()
        saveToFile()
        gui:rem(cbEffects)
        gui:rem(cblEffects)
        gui:rem(cbSound)
        gui:rem(cblSound)
        gui:rem(btnBack)
        Menu.drawMainMenu()
    end
end

function Menu.drawMainMenu()
    local btnStart = gui:button('Start', { x = 160, y = gui.style.unit * 5, w = 320, h = gui.style.unit })
    local btnOptions = gui:button('Options', { x = 160, y = gui.style.unit * 6.25, w = 320, h = gui.style.unit })
    local btnExit = gui:button('Exit', { x = 160, y = gui.style.unit * 8, w = 320, h = gui.style.unit })
    local imgTitle = gui:image(nil, { x = 0, y = 0 }, nil, "dat/gph/title.png")


    local function clearMainMenu()
        gui:rem(btnStart)
        gui:rem(btnOptions)
        gui:rem(btnExit)
    end

    btnStart.click = function()
        clearMainMenu()
        if (Menu.startGameCallback ~= nil) then
            music.play("shadow")
            Menu.startGameCallback()
        end
    end

    btnOptions.click = function()
        clearMainMenu()
        Menu.drawOptionsMenu()
    end

    btnExit.click = function()
        love.event.quit()
    end
end

return Menu
