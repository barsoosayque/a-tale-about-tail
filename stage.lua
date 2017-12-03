Stage = {}

local bump = require('lib/bump')
local world = bump.newWorld(16)

local textures = {}
local tiles = {}

local entities = {}

local bgMap = {} -- background map
local fgMap = {} -- foreground map

function Stage.load(bgImgFileName, fgImgFileName, description)
    local bgImg = love.graphics.newImage(bgImgFileName)
    local fgImg = love.graphics.newImage(fgImgFileName)

    Stage.width, Stage.height = bgImg:getDimensions()
    local playerX, playerY = Stage.buildMap(bgImg, fgImg)

    entities['player'] = require('player')
    entities['player'].load(playerX, playerY, Stage.width)
    world:add(entities['player'], playerX, playerY, entities['player'].width, entities['player'].height)

    -- entities['enemy'] = require('enemy')
    -- entities['enemy'].load(playerX + 20, playerY + 20, Stage.width)
    -- world:add(entities['enemy'], playerX + 20, playerY + 20, entities['enemy'].width, entities['enemy'].height)

    Stage.newTexture('dat/gph/tiles_bg.png', 'background')
    Stage.newTexture('dat/gph/tiles_fg.png', 'foreground')

    Stage.newTile('foreground', 'block_a', 48, 0, 16, 16)
    Stage.newTile('foreground', 'block_l', 64, 16, 16, 16)
    Stage.newTile('foreground', 'block_r', 48, 16, 16, 16)
    Stage.newTile('foreground', 'block_c', 64, 0, 16, 16)
    Stage.newTile('foreground', 'box', 80, 16, 16, 16)
    Stage.newTile('foreground', 'empty', 80, 0, 16, 16)
    Stage.newTile('foreground', 'roof_lu', 0, 0, 16, 16)
    Stage.newTile('foreground', 'roof_cu', 16, 0, 16, 16)
    Stage.newTile('foreground', 'roof_ru', 32, 0, 16, 16)
    Stage.newTile('foreground', 'roof_ld', 0, 16, 16, 16)
    Stage.newTile('foreground', 'roof_cd', 16, 16, 16, 16)
    Stage.newTile('foreground', 'roof_rd', 32, 16, 16, 16)
end

function Stage.update(dt)
    for _, entitie in pairs(entities) do
        entitie.update(dt)

        entitie.speedY = entitie.speedY + 300 * dt

        local goalX = entitie.x + entitie.speedX * dt
        local goalY = entitie.y + entitie.speedY * dt
        local actualX, actualY, cols, len = world:move(entitie, goalX, goalY, entitie.filter)

        if actualY == entitie.y then
            entitie.speedY = 0
            entitie.land()
        end


        -- print('name:'..entitie.name)
        -- print('gx:'..tostring(goalX)..' gy:'..tostring(goalY))
        -- print('ax:'..tostring(actualX)..' ay:'..tostring(actualY))
        -- print('speedX:'..tostring(entitie.speedX)..' speedY:'..tostring(entitie.speedY))

        entitie.x = actualX
        entitie.y = actualY
    end
end

function Stage.draw(x, y)
    Stage.drawMap(x, y)

    for _, entitie in pairs(entities) do
        entitie.draw(x, y)
    end
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

    -- print('drawTile '..name)
    -- for k, v in pairs(tiles) do
    -- 	print('key:'..tostring(k)..' value:'..tostring(v))
    -- 	if type(v) == 'table' then
    -- 		for kk, vv in pairs(v) do
    -- 			print('\tkey:'..tostring(kk)..' value:'..tostring(vv))
    -- 		end
    -- 	end
    -- end
    -- love.timer.sleep(1)

    -- if entities['player'].x < 640/2 - entities['player'].width/2 then
    -- 	l = entities['player'].x
    -- end

    local l = entities['player'].x + entities['player'].width / 2
    local px = entities['player'].x
    local pw = entities['player'].width
    local dl = 0
    --if l < 640/2 then
    if px < 640 / 2 - pw / 2 then
        dl = 0
    elseif l > Stage.width * 16 * 2 - 320 then
        dl = Stage.width * 16 * 2 - 640 -->??????
    else
        dl = l - 320
    end

    for x = 0, Stage.width - 1 do
        for y = 0, Stage.height - 1 do
            local nx = x * 16 * 2
            local ny = y * 16 * 2
            -- print('x:'..tostring(x)..' y:'..tostring(y))
            -- print('bmap['..tostring(x)..']['..tostring(y)..']:'..tostring(bMap[x][y]))
            Stage.drawTile(fgMap[x][y].name, X + nx - dl, Y + ny)
        end
    end
end

function Stage.drawTile(name, x, y)
    -- local scaleX, scaleY = getImageScaleForNewDimensions(textures[name], 2*16, 2*16 )
    -- love.graphics.draw(textures[name], x, y, 0, scaleX, scaleY)
    -- print('x:'..tostring(x)..' y:'..tostring(y)..' dtaw tile:'..tostring(name))local tile = tiles[name]
    -- print('drawTile:'..name..'\n\ttexture:'..tile.texture..' tile:'..tostring(tile.tile))
    -- print('\t'..tostring(textures[tile.texture]))
    local tile = tiles[name]
    local nw, nh = textures[tile.texture]:getDimensions()

    -- print(tostring(nw)..'|'..tostring(nh))
    nw, nh = 2 * nw, 2 * nh
    -- print(tostring(nw)..'|'..tostring(nh))

    local scaleX, scaleY = getImageScaleForNewDimensions(textures[tile.texture], nw, nh)
    love.graphics.draw(textures[tile.texture], tile.tile, x, y, 0, scaleX, scaleY)
end



function chekColor(r, g, b)
    if r == 0 and g == 0 and b == 0 then
        return 'block'
    elseif r == 255 and g == 255 and b == 255 then
        return 'empty'
    elseif r == 255 and g == 0 and b == 0 then
        return 'fox'
        --elseif r == 50 and g == 0 and b == 0 then
        --return 'block_l'
        --elseif r == 0 and g == 50 and b == 0 then
        --return 'block_c'
        --elseif r == 0 and g == 0 and b == 50 then
        --return 'block_r'
    elseif r == 255 and g == 255 and b == 0 then
        return 'box'
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
            -- print('x:'..tostring(x)..' y:'..tostring(y))
            -- print('color:'..color)

            -- print('bmap['..tostring(x)..']['..tostring(y)..']:'..tostring(bMap[x][y]))
            -->fMap
            r, g, b = fData:getPixel(x, y)
            color = chekColor(r, g, b)
            if color == 'block' or color == 'box' then
                fgMap[x][y] = { name = color }
                world:add(fgMap[x][y], x * 16 * 2, y * 16 * 2, 16 * 2, 16 * 2)
            elseif color == 'empty' then
                fgMap[x][y] = { name = color }
            end
            if color == 'fox' then
                fgMap[x][y] = { name = 'empty' }
                pX, pY = x * 16 * 2, y * 16 * 2
            end
        end
    end
    Stage.calculateCorners()
    return pX, pY
end

function Stage.calculateCorners()
    for x = 0, Stage.width - 1 do
        for y = 0, Stage.height - 1 do
            -- print('x:'..tostring(x)..' y:'..tostring(y))
            local str = fgMap[x][y].name
            -- print(str)
            if str == 'block' then

                local env = { l = 0, u = 0, d = 0, r = 0 }

                if fgMap[x - 1] ~= nil then
                    local str = string.sub(fgMap[x - 1][y].name, 1, 3)
                    if str == 'blo' or str == 'box' then
                        env.l = 1
                    end
                else
                    env.l = 1
                end
                if fgMap[x + 1] ~= nil then
                    local str = string.sub(fgMap[x + 1][y].name, 1, 3)
                    if str == 'blo' or str == 'box' then
                        env.r = 1
                    end
                else
                    env.r = 1
                end
                if fgMap[x][y - 1] ~= nil then

                    local str = string.sub(fgMap[x][y - 1].name, 1, 3)
                    if str == 'blo' or str == 'box' then
                        env.u = 1
                    end
                else
                    env.u = 1
                end
                if fgMap[x][y + 1] ~= nil then
                    local str = string.sub(fgMap[x][y + 1].name, 1, 3)
                    if str == 'blo' or str == 'box' then
                        env.d = 1
                    end
                else
                    env.d = 1
                end

                if env.l == 1 and env.r == 1 then
                    fgMap[x][y].name = 'block_c'
                elseif env.r == 1 and env.l == 0 then
                    fgMap[x][y].name = 'block_l'
                elseif env.r == 0 and env.l == 1 then
                    fgMap[x][y].name = 'block_r'
                elseif env.u == 1 then
                    fgMap[x][y].name = 'block_c'
                else
                    fgMap[x][y].name = 'block_c'
                end
                if env.d == 1 then
                    fgMap[x][y].name = 'block_a'
                end
            end
        end
    end
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