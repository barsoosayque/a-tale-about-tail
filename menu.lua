local STATE_SOUND = true
local startGameCallback


function drawOptionsMenu()
    local cbSound = gui:checkbox(nul, { x = 255, y = 32, r = 8 })
    local btnBack = gui:button('Back', { x = 256, y = 64, w = 128, h = gui.style.unit })

    cbSound.value = STATE_SOUND
    cbSound.style.labelfg = cbSound.style.fg
    cbSound.click = function(this)
        gui[this.elementtype].click(this)

        STATE_SOUND = this.value

        if this.value then
            this.style.fg = { 255, 255, 255, 255 }
        else
            this.style.fg = { 128, 128, 128, 255 }
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
        drawMainMenu()
    end
end

function drawMainMenu()
    local btnStart = gui:button('Start', { x = 256, y = 32, w = 128, h = gui.style.unit })
    local btnOptions = gui:button('Options', { x = 256, y = 64, w = 128, h = gui.style.unit })
    local btnExit = gui:button('Exit', { x = 256, y = 96, w = 128, h = gui.style.unit })

    btnStart.click = function()
        gui:rem(btnStart)
        gui:rem(btnOptions)
        gui:rem(btnExit)

        stage.load('stg/st1/map_b.png', 'stg/st1/map_f.png', 'stg/st1/description')
        stage.newTexture('dat/img/block.png', 'block')
        stage.newTexture('dat/img/empti.png', 'empti')

        love.update = function(dt)
            stage.update(dt)
        end

        love.draw = function()
            stage.draw(0, 150)
        end
    end

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

