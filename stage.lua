Stage = {}

local gamera = require('lib/gamera')
local bump = require('lib/bump')
local world = bump.newWorld(16)

local canvas

local textures = {}
local tiles = {}
local unit = 16

local leftWall = { name = 'wall', side = 'left' }
local rightWall = { name = 'wall', side = 'right' }

local entities = {}

local bgMap = {} -- background map
local fgMap = {} -- foreground map

-- local camera = { x = 0, y = 0, width = 640, height = 640 }
local camera = gamera.new(0, 0, 640, 640)

function Stage.load(bgImgFileName, fgImgFileName, description)
    local bgImg = love.graphics.newImage(bgImgFileName)
    local fgImg = love.graphics.newImage(fgImgFileName)

    Stage.width, Stage.height = fgImg:getDimensions()
    -- camera = gamera.new(0, 0, Stage.width*16, Stage.height*16)
    camera:setWorld(0, 0, Stage.width*16, Stage.height*16)
    camera:setWindow(0, 0, 640, 640)

    local playerX, playerY = Stage.buildMap(bgImg, fgImg)

    entities['player'] = require('player')
    entities['player'].load(playerX, playerY, Stage.width)
    world:add(entities['player'], playerX, playerY, entities['player'].width, entities['player'].height)

    local enemy_key = 'enemy'
    entities[enemy_key] = require('enemy')
    entities[enemy_key].load(playerX - 150, playerY - 120, Stage.width)
    world:add(entities[enemy_key], playerX - 150, playerY - 320, 30, 30)


    -- camera:setScale(2)


    Stage.loadTextures()

    canvas = love.graphics.newCanvas(Stage.width*unit, Stage.height*unit)
    love.graphics.setCanvas(canvas)
    Stage.drawMap(0, 0)
    love.graphics.setCanvas()


    -- local cx = playerX - (640 / 2 - entities['player'].width / 2)
    -- local cy = playerY - (640 / 2 - entities['player'].height / 2)
    camera:setPosition(playerX, playerY)
end


function Stage.loadTextures()
    Stage.newTexture('dat/gph/tiles_bg.png', 'background')
    Stage.newTexture('dat/gph/tiles_fg.png', 'foreground')

    Stage.newTile('foreground', 'dirt_lu', 48, 0, 16, 16)
    Stage.newTile('foreground', 'dirt_cu', 64, 0, 16, 16)
    Stage.newTile('foreground', 'dirt_ru', 80, 0, 16, 16)

    Stage.newTile('foreground', 'dirt_lc', 48, 16, 16, 16)
    Stage.newTile('foreground', 'dirt_cc', 64, 16, 16, 16)
    Stage.newTile('foreground', 'dirt_rc', 80, 16, 16, 16)

    Stage.newTile('foreground', 'dirt_ld', 48, 32, 16, 16)
    Stage.newTile('foreground', 'dirt_cd', 64, 32, 16, 16)
    Stage.newTile('foreground', 'dirt_rd', 80, 32, 16, 16)

    Stage.newTile('foreground', 'stone_lu', 96,  0, 16, 16)
    Stage.newTile('foreground', 'stone_cu', 112, 0, 16, 16)
    Stage.newTile('foreground', 'stone_ru', 128, 0, 16, 16)

    Stage.newTile('foreground', 'stone_lc', 96,  16, 16, 16)
    Stage.newTile('foreground', 'stone_cc', 112, 16, 16, 16)
    Stage.newTile('foreground', 'stone_rc', 128, 16, 16, 16)

    Stage.newTile('foreground', 'stone_ld', 96,  32, 16, 16)
    Stage.newTile('foreground', 'stone_cd', 112, 32, 16, 16)
    Stage.newTile('foreground', 'stone_rd', 128, 32, 16, 16)


    Stage.newTile('foreground', 'wood_lu', 144, 0, 16, 16)
    Stage.newTile('foreground', 'wood_cu', 160, 0, 16, 16)
    Stage.newTile('foreground', 'wood_ru', 176, 0, 16, 16)

    Stage.newTile('foreground', 'wood_lc', 144, 16, 16, 16)
    Stage.newTile('foreground', 'wood_cc', 160, 16, 16, 16)
    Stage.newTile('foreground', 'wood_rc', 176, 16, 16, 16)

    Stage.newTile('foreground', 'wood_ld', 144, 32, 16, 16)
    Stage.newTile('foreground', 'wood_cd', 160, 32, 16, 16)
    Stage.newTile('foreground', 'wood_rd', 176, 32, 16, 16)


    Stage.newTile('foreground', 'roof_lu',  0, 0, 16, 16)
    Stage.newTile('foreground', 'roof_cu', 16, 0, 16, 16)
    Stage.newTile('foreground', 'roof_ru', 32, 0, 16, 16)

    Stage.newTile('foreground', 'roof_ld',  0, 16, 16, 16)
    Stage.newTile('foreground', 'roof_cd', 16, 16, 16, 16)
    Stage.newTile('foreground', 'roof_rd', 32, 16, 16, 16)



    Stage.newTile('foreground', 'air', 32, 32, 16, 16)
end

function Stage.update(dt)
    for _, entitie in pairs(entities) do
        entitie.update(dt)

        entitie.speedY = entitie.speedY + 1800 * dt --300

        local goalX = entitie.x + entitie.speedX * dt
        local goalY = entitie.y + entitie.speedY * dt
        local actualX, actualY, cols, len = world:move(entitie, goalX, goalY, entitie.filter)

        if actualY == entitie.y and entitie.speedY > 0 then
            entitie.speedY = 0
            entitie.land()
        else
            entitie.fly()
        end

        entitie.x = actualX
        entitie.y = actualY
    end

    local cx = entities['player'].x + entities['player'].width / 2
    local cy = entities['player'].y + entities['player'].height / 2

    camera:setPosition(cx, cy)

    -- print('camera:\n\tx:'..tostring(camera.x)..' y:'..tostring(camera.y))
    -- print('player: x:'..tostring(entities['player'].x)..' y:'..tostring(entities['player'].y))
    -- print('camera: x:'..tostring(cx)..' y:'..tostring(cy))
end

function Stage.draw(x, y)
    camera:setScale(2.0)

    camera:draw(function(l, t, w, h)
        -- Stage.drawMap(0, 0)
        love.graphics.draw(canvas)
        for _, entitie in pairs(entities) do
            entitie.draw(entitie.x, entitie.y)
        end
    end)
end

function Stage.newTexture(fileName, textureName)
    textures[textureName] = love.graphics.newImage(fileName)
end

function Stage.newTile(textureName, tileName, x, y, w, h)
    tiles[tileName] = {}
    tiles[tileName].tile = love.graphics.newQuad(x, y, w, h, textures[textureName]:getDimensions())
    tiles[tileName].texture = textureName
end


function Stage.drawMap(X, Y)
    for x = 0, Stage.width - 1 do
        for y = 0, Stage.height - 1 do
            local nx = x * 16
            local ny = y * 16

            -- nx = nx - camera.x
            -- ny = ny - camera.y



            local tileName = fgMap[x][y].name
            if tileName == 'stone' or tileName == 'dirt' or tileName == 'wood' or tileName == 'roof' then
                tileName = tileName..'_'..fgMap[x][y].type
            end
            -- if nx > 16*2*(-2) or ny > 16*(-2) then
                Stage.drawTile(tileName, nx - X, ny - Y)
            -- end
        end
    end
end

function Stage.drawTile(name, x, y)
    local tile = tiles[name]
    local nw, nh = textures[tile.texture]:getDimensions()

    -- nw, nh = 2 * nw, 2 * nh

    -- local scaleX, scaleY = getImageScaleForNewDimensions(textures[tile.texture], nw, nh)
    -- love.graphics.draw(textures[tile.texture], tile.tile, x, y, 0, scaleX, scaleY)
    love.graphics.draw(textures[tile.texture], tile.tile, x, y)
end


function chekColor(r, g, b)
    if r == 0 and g == 0 and b == 0 then
        return 'dirt'
    elseif r == 120 and g == 120 and b == 120 then
        return 'stone'
    elseif r == 255 and g == 255 and b == 255 then
        return 'air'
    elseif r == 255 and g == 0 and b == 0 then
        return 'fox'
    elseif r == 255 and g == 255 and b == 0 then
        return 'wood'
    elseif r == 255 and g == 0 and b == 255 then
        return 'roof'
    end
end

function Stage.buildMap(bImg, fImg)
    local bData = bImg:getData()
    local fData = fImg:getData()

    local pX, pY

    for x = 0, Stage.width - 1 do
        bgMap[x] = {}
        fgMap[x] = {}
        for y = 0, Stage.height - 1 do
            -->bMap
            r, g, b, a = bData:getPixel(x, y)
            color = chekColor(r, g, b)

            -->fMap
            r, g, b = fData:getPixel(x, y)
            -- print('x:'..tostring(x)..' y:'..tostring(y))
            -- print('r:'..tostring(r)..' g:'..tostring(g)..' b:'..tostring(b))
            color = chekColor(r, g, b)
            if color == 'dirt' or color == 'wood' or color == 'stone' or color == 'roof' then
                fgMap[x][y] = { name = color }
                world:add(fgMap[x][y], x * 16, y * 16, 16, 16)
            elseif color == 'air' then
                fgMap[x][y] = { name = color }
            end
            if color == 'fox' then
                fgMap[x][y] = { name = 'air' }
                pX, pY = x * 16, y * 16
                -- pX, pY = x * 16 * 2, y * 16 * 2
            end
        end
    end
    Stage.calculateCorners()

    world:add(leftWall, -16, 0, 16, Stage.height * 16)
    world:add(rightWall, Stage.width * 16, 0, 16, Stage.height * 16)
    return pX, pY
end

function Stage.calculateCorners()
    for x = 0, Stage.width - 1 do
        for y = 0, Stage.height - 1 do
            local blockType = fgMap[x][y].name
            
            local str = string.sub(blockType, 1, 3)

            local env = { l = 0, u = 0, d = 0, r = 0 }

            if fgMap[x - 1] ~= nil then
                local t = fgMap[x - 1][y].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    env.l = 1
                end

            else
                env.l = 1
            end

            if fgMap[x + 1] ~= nil then
                local t = fgMap[x + 1][y].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    env.r = 1
                end

            else
                env.r = 1
            end

            if fgMap[x][y - 1] ~= nil then
                local t = fgMap[x][y - 1].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    env.u = 1
                end

            else
                env.u = 1
            end

            if fgMap[x][y + 1] ~= nil then
                local t = fgMap[x][y + 1].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    env.d = 1
                end

            else
                env.d = 1
            end

            if blockType == 'stone' or blockType == 'wood' or blockType == 'dirt' then  
                if equal(env, 0, 0, 1, 1) or equal(env, 0, 0, 0, 1) then
                    fgMap[x][y].type = 'lu'
                elseif equal(env, 1, 0, 1, 1) or equal(env, 0, 0, 1, 0) then
                    fgMap[x][y].type = 'cu'
                elseif equal(env, 1, 0, 1, 0) or equal(env, 1, 0, 0, 0) then
                    fgMap[x][y].type = 'ru'
                elseif equal(env, 0, 1, 1, 1) then
                    fgMap[x][y].type = 'lc'
                elseif equal(env, 1, 1, 1, 1) or equal(env, 0, 1, 1, 0) then
                    fgMap[x][y].type = 'cc'
                elseif equal(env, 1, 1, 1, 0) then
                    fgMap[x][y].type = 'rc'
                elseif equal(env, 0, 1, 0, 1) then
                    fgMap[x][y].type = 'ld'
                elseif equal(env, 1, 1, 0, 1) or equal(env, 0, 1, 0, 0) then
                    fgMap[x][y].type = 'cd'
                elseif equal(env, 1, 1, 0, 0) then
                    fgMap[x][y].type = 'rd'
                else
                    fgMap[x][y].type = 'cu'
                end
            end

            if blockType == 'roof' then
                if equal(env, 0, 0, 1, 1) then
                    fgMap[x][y].type = 'lu'
                elseif equal(env, 1, 0, 1, 1) then
                    fgMap[x][y].type = 'cu' 
                elseif equal(env, 1, 0, 1, 0) then
                    fgMap[x][y].type = 'ru'
                elseif equal(env, 0, 1, 1, 1) or equal(env, 0, 1, 0, 1) then
                    fgMap[x][y].type = 'ld'
                elseif equal(env, 1, 1, 1, 1) then
                    fgMap[x][y].type = 'cd'
                elseif equal(env, 1, 1, 1, 0) then
                    fgMap[x][y].type = 'rd'
                else
                    fgMap[x][y].type = 'cu'
                end
            end
        end
    end
end

function equal(env, l, u, d, r)
    if env.l == l and env.u == u and env.d == d and env.r == r then return true
    else return false end
end

function getImageScaleForNewDimensions(image, newWidth, newHeight)
    local currentWidth, currentHeight = image:getDimensions()
    return (newWidth / currentWidth), (newHeight / currentHeight)
end

function Stage.keypressed(key, scancode, isrepeat)
    if entities['player'] then
        entities['player'].keypressed(key, scancode, isrepeat)
    end
end

return Stage