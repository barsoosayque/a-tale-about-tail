<<<<<<< HEAD
local STATE_SOUND = false
local startGameCallback
=======
Menu = {}
Menu.startGameCallback = nul
>>>>>>> 169694189d954ee6a07ec0873ddc5329c09ef7d8

Menu.backupFile = io.open('./config.ini', 'a+')
io.input(Menu.backupFile)
if io.read() == "1" then
    Menu.stateSound = true
else
    Menu.stateSound = false
end

function saveToFile(value)
    io.open('./config.ini', 'w+')
    io.output(Menu.backupFile)
    io.write(value)
    io.close()
end

function Menu.drawOptionsMenu()
    local cbSound = gui:checkbox(nul, { x = 255, y = 32, r = 8 })
    local btnBack = gui:button('Back', { x = 256, y = 64, w = 128, h = gui.style.unit })

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

    local cblSound = gui:text("Sound on/off", { x = 32 }, cbSound, true)
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
    local btnStart = gui:button('Start', { x = 256, y = 32, w = 128, h = gui.style.unit })
    local btnOptions = gui:button('Options', { x = 256, y = 64, w = 128, h = gui.style.unit })
    local btnExit = gui:button('Exit', { x = 256, y = 96, w = 128, h = gui.style.unit })

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