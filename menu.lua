Menu = {}
Menu.startGameCallback = nul

io.input(io.open('./config.ini', 'r'))
if io.read() == "1" then
    Menu.stateSound = true
else
    Menu.stateSound = false
end

function saveToFile(value)
    io.output(io.open('./config.ini', 'w+'))
    io.write(value)
    io.close()
end

function Menu.drawOptionsMenu()
    local cbSound = gui:checkbox(nul, { x = 200, y = gui.style.unit * 5, r = 16 })
    cbSound.shape = 'rect'
    local btnBack = gui:button('Back', { x = 160, y = gui.style.unit * 7, w = 320, h = gui.style.unit })

    cbSound.value = Menu.stateSound
    cbSound.style.labelfg = cbSound.style.fg
    cbSound.click = function(this)
        gui[this.elementtype].click(this)

        Menu.stateSound = this.value

        if this.value then
            this.style.fg = { 255, 255, 255, 255 }
            saveToFile(1)
        else
            this.style.fg = { 128, 128, 128, 255 }
            saveToFile(0)
        end
    end

    local cblSound = gui:text("Sound on/off", { x = 32, y = -24 }, cbSound, true)
    cblSound.click = function(this)
        this.parent:click()
    end

    btnBack.click = function()
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

    -- imgTitle.rect({ x = 32, y = 32, w = 640, h = 256 })

    local function clearMainMenu()
        gui:rem(btnStart)
        gui:rem(btnOptions)
        gui:rem(btnExit)
    end

    btnStart.click = function()
        clearMainMenu()
        if (Menu.startGameCallback ~= nil) then
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