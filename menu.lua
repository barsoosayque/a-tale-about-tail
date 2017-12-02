function drawOptionsMenu()
    local cbSound = gui:checkbox(nul, { x = 255, y = 32, r = 8 })
    cbSound.style.labelfg = cbSound.style.fg
    cbSound.click = function(this)
        gui[this.elementtype].click(this)

        if this.value then
            this.style.fg = { 255, 128, 0, 255 }
        else
            this.style.fg = { 255, 255, 255, 255 }
        end
    end

    local cblSound = gui:text("Sound on/off", { x = 32 }, cbSound, true)
    cblSound.click = function(this)
        this.parent:click()
    end

    local btnBack = gui:button('Back', { x = 256, y = 64, w = 128, h = gui.style.unit })
    btnBack.click = function()
        gui:rem(btnBack)
        drawMainMenu()
    end
end

function drawMainMenu()
    local btnStart = gui:button('Start', { x = 256, y = 32, w = 128, h = gui.style.unit })
    local btnOptions = gui:button('Options', { x = 256, y = 64, w = 128, h = gui.style.unit })
    local btnExit = gui:button('Exit', { x = 256, y = 96, w = 128, h = gui.style.unit })

    btnOptions.click = function()
        gui:rem(btnStart)
        gui:rem(btnOptions)
        gui:rem(btnExit)
        drawOptionsMenu()
    end

    btnExit.click = function()
        love.event.quit()
    end
end

