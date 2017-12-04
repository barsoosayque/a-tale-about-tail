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

function Stage.load(bgImgFileName, fgImgFileName, description)
    local bgImg = love.graphics.newImage(bgImgFileName)
    local fgImg = love.graphics.newImage(fgImgFileName)

    Stage.width, Stage.height = fgImg:getDimensions()
    camera:setWorld(0, 0, Stage.width*16, Stage.height*16)
    camera:setWindow(0, 0, 640, 640)

    local playerX, playerY = Stage.buildMap(bgImg, fgImg)

    entities['player'] = require('player')
    entities['player'].load(playerX, playerY)
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



    -- psystem2 = newParticleSystem(i)

end



function Stage.loadTextures()
    parallax_bg = love.graphics.newImage("dat/gph/bg.png")

    Stage.newTexture('dat/gph/tiles_bg.png', 'background')
    Stage.newTexture('dat/gph/tiles_fg.png', 'foreground')
    Stage.newTexture('dat/gph/objects.png' ,    'objects')

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

    Stage.newTile('foreground', 'roof_rd', 32, 16, 16, 16)
    Stage.newTile('foreground', 'roof_rd', 32, 16, 16, 16)
    Stage.newTile('foreground', 'roof_rd', 32, 16, 16, 16)

    Stage.newTile('foreground', 'door_lu', 0, 32, 16, 16)
    Stage.newTile('foreground', 'door_u', 0, 16, 16, 16)

    Stage.newTile('background', 'wall_u',   16,   0, 16, 16)
    Stage.newTile('background', 'wall_d',   16,  16, 16, 16)
    Stage.newTile('background', 'wall_c',   32,   0, 16, 16)

    Stage.newTile('background', 'fence', 0, 16, 16, 16)

    Stage.newTile('objects', 'chest_f',  0,  0, 16, 16)
    Stage.newTile('objects', 'chest_e', 16,  0, 16, 16)
    Stage.newTile('objects', 'table_f',  0, 16, 16, 16)
    Stage.newTile('objects', 'table_e', 16, 16, 16, 16)
    Stage.newTile('objects',   'cup_f',  0, 32, 16, 16)
    Stage.newTile('objects',   'cup_e', 16, 32, 16, 16)



    Stage.newTile('foreground', 'air', 32, 32, 16, 16)
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
            if name == 'chest' or name == 'table' or name == 'cup' and entitie.name == 'player' then
                other.full = false
                world:remove(other)

                local cost
                if name == 'chest' then cost = 10
                elseif name == 'table' then cost = 5
                elseif name == 'cup' then cost = 1 end
                entitie.bag = entitie.bag + cost
                print('Coin:'..tostring(entitie.bag))
            end

        end


        if actualY == entitie.y then
            if entitie.speedY > 0 then
                entitie.land()
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
        -- p/ar_y = par_y - (par_y / par_h * 480)
        -- par_y = par_y - par_h / 2 + (entities["player"].y / wr_h * par_h)

        love.graphics.draw(parallax_bg, par_x, par_y)
        -- Stage.drawMap(0, 0)
        love.graphics.draw(canvas)
        local px, py = 0, 0

        for _, obj in pairs(objects) do
            if obj.type == 'coin' then
                if obj.full then
                    Stage.drawTile(obj.name..'_f', obj.x, obj.y)
                else
                    Stage.drawTile(obj.name..'_e', obj.x, obj.y)
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
                fgTileName = fgTileName..'_'..fgMap[x][y].type
            end
            -- if fgTileName == 'chest' or fgTileName == 'table' or fgTileName == 'cup' then
            --     if fgMap[x][y].obj.full then
            --         fgTileName = fgTileName..'_f'
            --     else
            --         fgTileName = fgTileName..'_e'
            --     end
            -- end

            if bgTileName == 'wall' then
                bgTileName = bgTileName..'_'..bgMap[x][y].type
            end
            Stage.drawTile(bgTileName, nx, ny)
            Stage.drawTile(fgTileName, nx, ny)
        end
    end
end

function Stage.drawTile(name, x, y)
    local tile = tiles[name]
    local nw, nh = textures[tile.texture]:getDimensions()
    love.graphics.draw(textures[tile.texture], tile.tile, x, y)
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
        return 'chest'
    elseif r == 255 and g == 220 and b == 0 then
        return 'table'
    elseif r == 255 and g == 200 and b == 0 then
        return 'cup'
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
            bgMap[x][y] = {name = color}


            -->fMap
            r, g, b = fData:getPixel(x, y)
            -- print('r:'..tostring(r)..' g:'..tostring(g)..' b:'..tostring(b))
            color = chekColor(r, g, b, a)
            -- print('color:'..color..' r:'..tostring(r)..' g:'..tostring(g)..' b:'..tostring(b)..' a:'..tostring(a))

            if color == 'dirt' or color == 'wood' or color == 'stone' or color == 'roof' then
                fgMap[x][y] = { name = color }
                world:add(fgMap[x][y], x * 16, y * 16, 16, 16)
            elseif color == 'air' then
                fgMap[x][y] = { name = color }
            elseif color == 'chest' or color == 'table' or color == 'cup' then
                fgMap[x][y] = {name = 'air'}
                local obj = object.newObject(color, 'coin', x*unit, y*unit, unit, unit)
                world:add(obj, x*unit, y*unit, unit, unit)
                table.insert(objects, obj)
            end
            if color == 'fox' then
                fgMap[x][y] = { name = 'air' }
                pX, pY = x * 16, y * 16
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

            if fBlockType == 'stone' or fBlockType == 'wood' or fBlockType == 'dirt' then
                if equal(fEnv, 0, 0, 1, 1) or equal(fEnv, 0, 0, 0, 1) then
                    fgMap[x][y].type = 'lu'
                elseif equal(fEnv, 1, 0, 1, 1) or equal(fEnv, 0, 0, 1, 0) then
                    fgMap[x][y].type = 'cu'
                elseif equal(fEnv, 1, 0, 1, 0) or equal(fEnv, 1, 0, 0, 0) then
                    fgMap[x][y].type = 'ru'
                elseif equal(fEnv, 0, 1, 1, 1) then
                    fgMap[x][y].type = 'lc'
                elseif equal(fEnv, 1, 1, 1, 1) or equal(fEnv, 0, 1, 1, 0) then
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

            if fBlockType == 'roof' then
                if equal(fEnv, 0, 0, 1, 1) then
                    fgMap[x][y].type = 'lu'
                elseif equal(fEnv, 1, 0, 1, 1) then
                    fgMap[x][y].type = 'cu'
                elseif equal(fEnv, 1, 0, 1, 0) then
                    fgMap[x][y].type = 'ru'
                elseif equal(fEnv, 0, 1, 1, 1) or equal(fEnv, 0, 1, 0, 1) then
                    fgMap[x][y].type = 'ld'
                elseif equal(fEnv, 1, 1, 1, 1) then
                    fgMap[x][y].type = 'cd'
                elseif equal(fEnv, 1, 1, 1, 0) then
                    fgMap[x][y].type = 'rd'
                else
                    fgMap[x][y].type = 'cu'
                end
            end

            local bEnv = { l = 0, u = 0, d = 0, r = 0 }

            if bgMap[x - 1] ~= nil then
                local t = bgMap[x - 1][y].name
                if t == 'wall' then
                    bEnv.l = 1
                end
            else
                bEnv.l = 1
            end

            if bgMap[x + 1] ~= nil then
                local t = bgMap[x + 1][y].name
                if t == 'wall' then
                    bEnv.r = 1
                end

            else
                bEnv.r = 1
            end

            if bgMap[x][y - 1] ~= nil then
                local t = bgMap[x][y - 1].name
                if t == 'wall' then
                    bEnv.u = 1
                end

            else
                bEnv.u = 1
            end

            if bgMap[x][y + 1] ~= nil then
                local t = bgMap[x][y + 1].name
                if t == 'wall' then
                    bEnv.d = 1
                end

            else
                bEnv.d = 1
            end

            if bBlockType == 'wall' then
                if bEnv.d == 0 then
                    bgMap[x][y].type = 'd'
                elseif bEnv.u == 0 then
                    bgMap[x][y].type = 'u'
                else
                    bgMap[x][y].type = 'c'
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