Stage = {}

local gamera = require('lib/gamera')
local bump = require('lib/bump')
local object = require('objects')

local world = bump.newWorld(16)

local canvas

local textures = {}
local tiles = {}
local unit = 16

local leftWall = { name = 'wall', side = 'left' }
local rightWall = { name = 'wall', side = 'right' }

local entities = {}
local objects = {}

local bgMap = {} -- background map
local fgMap = {} -- foreground map

local parallax_bg

local camera = gamera.new(0, 0, 640, 640)

local intro = true
local introFile

local spawn = {
    x = 0,
    y = 0
}

function Stage.load(bgImgFileName, fgImgFileName, description, int)
    -- intro = int or false
    -- if intro then
    --     introFile = love.filesystem.newFile(description)

    -- end


    math.randomseed(os.time())


    local bgImg = love.graphics.newImage(bgImgFileName)
    local fgImg = love.graphics.newImage(fgImgFileName)

    Stage.width, Stage.height = fgImg:getDimensions()
    camera:setWorld(0, 0, Stage.width * 16, Stage.height * 16)
    camera:setWindow(0, 0, 640, 640)

    local playerX, playerY = Stage.buildMap(bgImg, fgImg)
    spawn.x, spawn,y = playerX, playerY

    entities['player'] = require('player')
    entities['player'].load(playerX, playerY)
    world:add(entities['player'], playerX, playerY, entities['player'].width, entities['player'].height)

    local enemy_key = 'enemy'
    entities[enemy_key] = require('enemy')
    entities[enemy_key].load(500, 368, Stage.width)
    world:add(entities[enemy_key], 500, 368, 30, 30)


    -- camera:setScale(2)


    Stage.loadTextures()

    canvas = love.graphics.newCanvas(Stage.width * unit, Stage.height * unit)
    love.graphics.setCanvas(canvas)
    Stage.drawMap(0, 0)
    love.graphics.setCanvas()

    camera:setPosition(playerX, playerY)
end

function Stage.loadTextures()
    parallax_bg = love.graphics.newImage("dat/gph/bg.png")

    Stage.newTexture('dat/gph/tiles_bg.png', 'background')
    Stage.newTexture('dat/gph/tiles_fg.png', 'foreground')
    Stage.newTexture('dat/gph/objects.png', 'objects')

    Stage.newTile('foreground', 'dirt_lu', 48, 0, 16, 16)
    Stage.newTile('foreground', 'dirt_cu', 64, 0, 16, 16)
    Stage.newTile('foreground', 'dirt_ru', 80, 0, 16, 16)

    Stage.newTile('foreground', 'dirt_lc', 48, 16, 16, 16)
    Stage.newTile('foreground', 'dirt_cc', 64, 16, 16, 16)
    Stage.newTile('foreground', 'dirt_rc', 80, 16, 16, 16)

    Stage.newTile('foreground', 'dirt_ld', 48, 32, 16, 16)
    Stage.newTile('foreground', 'dirt_cd', 64, 32, 16, 16)
    Stage.newTile('foreground', 'dirt_rd', 80, 32, 16, 16)

    Stage.newTile('foreground', 'dirt_r0', 48, 48, 16, 16)
    Stage.newTile('foreground', 'dirt_r1', 64, 48, 16, 16)
    Stage.newTile('foreground', 'dirt_r2', 48, 64, 16, 16)
    Stage.newTile('foreground', 'dirt_r3', 64, 64, 16, 16)

    Stage.newTile('foreground', 'stone_lu', 96, 0, 16, 16)
    Stage.newTile('foreground', 'stone_cu', 112, 0, 16, 16)
    Stage.newTile('foreground', 'stone_ru', 128, 0, 16, 16)

    Stage.newTile('foreground', 'stone_lc', 96, 16, 16, 16)
    Stage.newTile('foreground', 'stone_cc', 112, 16, 16, 16)
    Stage.newTile('foreground', 'stone_rc', 128, 16, 16, 16)

    Stage.newTile('foreground', 'stone_ld', 96, 32, 16, 16)
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


    Stage.newTile('foreground', 'roof_lu', 0, 0, 16, 16)
    Stage.newTile('foreground', 'roof_cu', 16, 0, 16, 16)
    Stage.newTile('foreground', 'roof_ru', 32, 0, 16, 16)

    Stage.newTile('foreground', 'roof_lc', 0, 16, 16, 16)
    Stage.newTile('foreground', 'roof_cc', 16, 16, 16, 16)
    Stage.newTile('foreground', 'roof_rc', 32, 16, 16, 16)

    Stage.newTile('foreground', 'roof_ld', 0, 32, 16, 16)
    Stage.newTile('foreground', 'roof_cd', 16, 32, 16, 16)
    Stage.newTile('foreground', 'roof_rd', 32, 32, 16, 16)

    Stage.newTile('foreground', 'door_lu', 0, 32, 16, 16)
    Stage.newTile('foreground', 'door_u', 0, 16, 16, 16)

    Stage.newTile('background', 'wall_lu', 0, 0, 16, 16)
    Stage.newTile('background', 'wall_cu', 16, 0, 16, 16)
    Stage.newTile('background', 'wall_ru', 32, 0, 16, 16)

    Stage.newTile('background', 'wall_lc', 0, 16, 16, 16)
    Stage.newTile('background', 'wall_cc', 16, 16, 16, 16)
    Stage.newTile('background', 'wall_rc', 32, 16, 16, 16)

    Stage.newTile('background', 'wall_ld', 0, 32, 16, 16)
    Stage.newTile('background', 'wall_cd', 16, 32, 16, 16)
    Stage.newTile('background', 'wall_rd', 32, 32, 16, 16)

    Stage.newTile('background', 'backstone_lu', 96, 0, 16, 16)
    Stage.newTile('background', 'backstone_cu', 112, 0, 16, 16)
    Stage.newTile('background', 'backstone_ru', 128, 0, 16, 16)

    Stage.newTile('background', 'backstone_lc', 96, 16, 16, 16)
    Stage.newTile('background', 'backstone_cc', 112, 16, 16, 16)
    Stage.newTile('background', 'backstone_rc', 128, 16, 16, 16)

    Stage.newTile('background', 'backstone_ld', 96, 32, 16, 16)
    Stage.newTile('background', 'backstone_cd', 112, 32, 16, 16)
    Stage.newTile('background', 'backstone_rd', 128, 32, 16, 16)

    Stage.newTile('background', 'fence', 64, 0, 16, 16)

    Stage.newTile('objects', 'chest_f', 0, 0, 16, 16)
    Stage.newTile('objects', 'chest_e', 16, 0, 16, 16)
    Stage.newTile('objects', 'table_f', 0, 16, 16, 16)
    Stage.newTile('objects', 'table_e', 16, 16, 16, 16)
    Stage.newTile('objects', 'cup_f', 0, 32, 16, 16)
    Stage.newTile('objects', 'cup_e', 16, 32, 16, 16)

    -- Stage.newTile('foreground', 'air', 32, 32, 16, 16)
end

function Stage.update(dt)

    -- psystem2:update(dt)
    for _, entitie in pairs(entities) do
        entitie.update(dt)

        entitie.speedY = entitie.speedY + 1800 * dt --300

        local goalX = entitie.x + entitie.speedX * dt
        local goalY = entitie.y + entitie.speedY * dt
        local actualX, actualY, cols, len = world:move(entitie, goalX, goalY, entitie.filter)

        for i = 1, len do
            local other = cols[i].other
            local name = other.name
            if name == 'treasure' and entitie.name == 'player' then
                other.full = false
                world:remove(other)

                local cost = other.value*5
                entitie.bag = entitie.bag + cost
                entitie.speed = math.max(entitie.speed - cost, 50)
                -- print('Coin:' .. tostring(entitie.bag))
            end

            if name == 'spawn' and entitie.name == 'player' then 
                entitie.drop()
            end

            if entitie.name == 'enemy' then
                local nextTileX = math.ceil(goalX / 16)
                local nextTileY = math.ceil(goalY / 16)

                local bottomTile = fgMap[nextTileX][nextTileY + 1]
                local leftTile = fgMap[nextTileX + 1][nextTileY]
                local rightTile = fgMap[nextTileX - 1][nextTileY]

                -- проверка, чтобы не упасть в пропасть и не упереться в стену
                if bottomTile.name == 'air' or leftTile.name ~= 'air' or rightTile.name ~= 'air' then
                    entitie.turnBack()
                end
            end
        end


        if actualY == entitie.y then
            if entitie.speedY > 0 then
                entitie.land(dt)
            end
            entitie.speedY = 0
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
        local par_x, par_y = camera:getPosition()
        _, _, par_w, par_h = camera:getWindow()
        _, _, wr_w, wr_h = camera:getWorld()
        par_x = par_x - ((par_x + par_w) / wr_w * 160)
        par_y = par_y - ((par_y + par_h) / wr_h * 160)
        love.graphics.draw(parallax_bg, par_x, par_y)

        -- Stage.drawMap(0, 0)
        love.graphics.draw(canvas)
        local px, py = 0, 0

        for _, obj in pairs(objects) do
            if obj.name == 'treasure' then
                local name
                if obj.value == 1 then
                    name = 'chest'
                elseif obj.value == 2 then
                    name = 'table'
                else
                    name = 'cup'
                end

                if obj.full then
                    Stage.drawTile(name .. '_f', obj.x, obj.y)
                else
                    Stage.drawTile(name .. '_e', obj.x, obj.y)
                end
            end
        end

        for _, entitie in pairs(entities) do
            entitie.draw(entitie.x, entitie.y)
        end


        -- love.graphics.draw(psystem2, entities['player'].x + (entities['player'].width/3)*2
        --                           ,  entities['player'].y + entities['player'].height - 2)
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

            local fgTileName = fgMap[x][y].name
            local bgTileName = bgMap[x][y].name
            if fgTileName == 'stone' or fgTileName == 'dirt' or fgTileName == 'wood' or fgTileName == 'roof' then
                fgTileName = fgTileName .. '_' .. fgMap[x][y].type
            end
            -- if fgTileName == 'chest' or fgTileName == 'table' or fgTileName == 'cup' then
            --     if fgMap[x][y].obj.full then
            --         fgTileName = fgTileName..'_f'
            --     else
            --         fgTileName = fgTileName..'_e'
            --     end
            -- end

            if bgTileName == 'wall' or bgTileName == 'backstone' then
                bgTileName = bgTileName .. '_' .. bgMap[x][y].type
            end
            if fgTileName == 'box' then
                fgTileName = 'air'
            end
            if fgTileName == 'spawn' then -- Заглушка пока нет тайла
                fgTileName = 'air'
            end

            Stage.drawTile(bgTileName, nx, ny)

            Stage.drawTile(fgTileName, nx, ny)
        end
    end
end

function Stage.drawTile(name, x, y)
    if name ~= "air" then
    -- print(name)
        local tile = tiles[name]
        local nw, nh = textures[tile.texture]:getDimensions()
        love.graphics.draw(textures[tile.texture], tile.tile, x, y)
    end
end


function chekColor(r, g, b, a)
    if r == 0 and g == 0 and b == 0 then
        return 'dirt'
    elseif r == 120 and g == 120 and b == 120 then
        return 'stone'
    elseif r == 255 and g == 255 and b == 255 then
        return 'air'
    elseif r == 255 and g == 0 and b == 0 then
        return 'fox'
    elseif r == 255 and g == 150 and b == 0 then
        return 'wood'
    elseif r == 255 and g == 0 and b == 255 then
        return 'roof'
    elseif r == 30 and g == 30 and b == 50 then
        return 'fence'
    elseif r == 100 and g == 50 and b == 50 then
        return 'wall'
    elseif r == 255 and g == 255 and b == 0 then
        return 'treasure'
    elseif r == 150 and g == 80 and b == 0 then
        return 'box'
    elseif r == 90 and g == 90 and b == 90 then
        return 'backstone'
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
            color = chekColor(r, g, b, a)
            --> heh <--
            if color == 'dirt' then
                color = 'air'
            end
            bgMap[x][y] = { name = color }


            -->fMap
            r, g, b = fData:getPixel(x, y)
            -- print('r:'..tostring(r)..' g:'..tostring(g)..' b:'..tostring(b))
            color = chekColor(r, g, b, a)
            -- print('color:'..color..' r:'..tostring(r)..' g:'..tostring(g)..' b:'..tostring(b)..' a:'..tostring(a))

            if color == 'dirt' or color == 'wood' or color == 'stone' or color == 'roof' then
                fgMap[x][y] = { name = color }
                world:add(fgMap[x][y], x * 16, y * 16, 16, 16)
            elseif color == 'air' or color == 'box' then
                fgMap[x][y] = { name = color }
            elseif color == 'treasure' then
                fgMap[x][y] = { name = 'air' }
                local r = math.random(1, 3)
                local obj = object.newObject(color, 'treasure', r, x * unit, y * unit, unit, unit)
                world:add(obj, x * unit, y * unit, unit, unit)
                table.insert(objects, obj)
            end
            if color == 'fox' then

                fgMap[x][y] = { name = 'spawn' }
                -- fgMap[x][y] = { name = 'spawn' }
                
                pX, pY = x * unit, y * unit
                world:add(fgMap[x][y], pX, pY, unit, unit)
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

            -- print('x:'..tostring(x)..' y:'..tostring(y))
            local fBlockType = fgMap[x][y].name
            local bBlockType = bgMap[x][y].name

            -- local str = string.sub(fBlockType, 1, 3)

            local fEnv = { l = 0, u = 0, d = 0, r = 0 }

            if fgMap[x - 1] ~= nil then
                local t = fgMap[x - 1][y].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    fEnv.l = 1
                end
            else
                fEnv.l = 1
            end

            if fgMap[x + 1] ~= nil then
                local t = fgMap[x + 1][y].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    fEnv.r = 1
                end

            else
                fEnv.r = 1
            end

            if fgMap[x][y - 1] ~= nil then
                local t = fgMap[x][y - 1].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    fEnv.u = 1
                end

            else
                fEnv.u = 1
            end

            if fgMap[x][y + 1] ~= nil then
                local t = fgMap[x][y + 1].name
                if t == 'stone' or t == 'wood' or t == 'dirt' or t == 'roof' then
                    fEnv.d = 1
                end

            else
                fEnv.d = 1
            end

            if fBlockType == 'stone' or fBlockType == 'wood' or fBlockType == 'roof' or fBlockType == 'dirt' then
                if equal(fEnv, 0, 0, 1, 1) or equal(fEnv, 0, 0, 0, 1) then
                    fgMap[x][y].type = 'lu'
                elseif equal(fEnv, 1, 0, 1, 1) or equal(fEnv, 0, 0, 1, 0) then
                    fgMap[x][y].type = 'cu'
                elseif equal(fEnv, 1, 0, 1, 0) or equal(fEnv, 1, 0, 0, 0) then
                    fgMap[x][y].type = 'ru'
                elseif equal(fEnv, 0, 1, 1, 1) then
                    fgMap[x][y].type = 'lc'
                elseif equal(fEnv, 1, 1, 1, 1) then
                    fgMap[x][y].type = 'cc'

                    if fBlockType == 'dirt' then
                        if x + 1 < Stage.width and y + 1 < Stage.height
                                and fgMap[x + 1][y + 1].name == 'air' then
                            fgMap[x][y].type = 'r0'
                        end
                        if x + 1 < Stage.width and y - 1 > 0
                                and fgMap[x + 1][y - 1].name == 'air' then
                            fgMap[x][y].type = 'r2'
                        end
                        if x - 1 > 0 and y + 1 < Stage.height
                                and fgMap[x - 1][y + 1].name == 'air' then
                            fgMap[x][y].type = 'r1'
                        end
                        if x - 1 > 0 and y - 1 > 0
                                and fgMap[x - 1][y - 1].name == 'air' then
                            fgMap[x][y].type = 'r3'
                        end
                    end
                elseif equal(fEnv, 0, 1, 1, 0) then
                    fgMap[x][y].type = 'cc'
                elseif equal(fEnv, 1, 1, 1, 0) then
                    fgMap[x][y].type = 'rc'
                elseif equal(fEnv, 0, 1, 0, 1) then
                    fgMap[x][y].type = 'ld'
                elseif equal(fEnv, 1, 1, 0, 1) or equal(fEnv, 0, 1, 0, 0) then
                    fgMap[x][y].type = 'cd'
                elseif equal(fEnv, 1, 1, 0, 0) then
                    fgMap[x][y].type = 'rd'
                else
                    fgMap[x][y].type = 'cu'
                end
            end

            local bEnv = { l = 0, u = 0, d = 0, r = 0 }

            if bgMap[x - 1] ~= nil then
                local t = bgMap[x - 1][y].name
                if t == 'wall' or t == 'backstone' then
                    bEnv.l = 1
                end
            else
                bEnv.l = 1
            end

            if bgMap[x + 1] ~= nil then
                local t = bgMap[x + 1][y].name
                if t == 'wall' or t == 'backstone' then
                    bEnv.r = 1
                end

            else
                bEnv.r = 1
            end

            if bgMap[x][y - 1] ~= nil then
                local t = bgMap[x][y - 1].name
                if t == 'wall' or t == 'backstone' then
                    bEnv.u = 1
                end

            else
                bEnv.u = 1
            end

            if bgMap[x][y + 1] ~= nil then
                local t = bgMap[x][y + 1].name
                if t == 'wall' or t == 'backstone' then
                    bEnv.d = 1
                end

            else
                bEnv.d = 1
            end

            if bBlockType == 'wall' or bBlockType == 'backstone' then
                if equal(bEnv, 0, 0, 1, 1) or equal(bEnv, 0, 0, 0, 1) then
                    bgMap[x][y].type = 'lu'
                elseif equal(bEnv, 1, 0, 1, 1) or equal(bEnv, 0, 0, 1, 0) then
                    bgMap[x][y].type = 'cu'
                elseif equal(bEnv, 1, 0, 1, 0) or equal(bEnv, 1, 0, 0, 0) then
                    bgMap[x][y].type = 'ru'
                elseif equal(bEnv, 0, 1, 1, 1) then
                    bgMap[x][y].type = 'lc'
                elseif equal(bEnv, 1, 1, 1, 1) then
                    bgMap[x][y].type = 'cc'
                elseif equal(bEnv, 0, 1, 1, 0) then
                    bgMap[x][y].type = 'cc'
                elseif equal(bEnv, 1, 1, 1, 0) then
                    bgMap[x][y].type = 'rc'
                elseif equal(bEnv, 0, 1, 0, 1) then
                    bgMap[x][y].type = 'ld'
                elseif equal(bEnv, 1, 1, 0, 1) or equal(bEnv, 0, 1, 0, 0) then
                    bgMap[x][y].type = 'cd'
                elseif equal(bEnv, 1, 1, 0, 0) then
                    bgMap[x][y].type = 'rd'
                else
                    bgMap[x][y].type = 'cu'
                end
            end
        end
    end
end

function equal(env, l, u, d, r)
    if env.l == l and env.u == u and env.d == d and env.r == r then return true
    else return false
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
