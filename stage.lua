Stage = {}

Stage.width = 0
Stage.height = 0

local gamera = require('lib/gamera')
local bump = require('lib/bump')
local object = require('objects')
local enemys = require('enemy')
local music = require('music')

local world = bump.newWorld(16)

local canvas

local textures = {}
local tiles = {}
local unit = 16

local leftWall = { name = 'wall', side = 'left' }
local rightWall = { name = 'wall', side = 'right' }

local entities = {}
entities['player'] = require('player')

local objects = {}

local bgMap = {} -- background map
local fgMap = {} -- foreground map

local parallax_bg

local camera = gamera.new(0, 0, 640, 640)

local intro = true
local introFile
local introText = {}
local start

local maxScore = 0

local font

local win = false

local spawn = {
    x = 0,
    y = 0
}


function Stage.clearWorld()



    maxScore = 0
    win = false
    introFile = nil
    introText = {}
    start = nil

    for k, v in pairs(entities) do
        if v.name == 'player' and v.inWorld == true then
            world:remove(v)
            v.inWorld = false
        end
        if v.name == 'enemy' then
            world:remove(v)
        end

    end

    local max = table.maxn(entities)
    for k = 1, max do
        table.remove(entities)
    end

    for _, v in pairs(entities) do
        -- print('ent:'..tostring(v))
    end

    for k, v in pairs(objects) do
        if v.full then
            world:remove(v)
        end
        -- table.remove(objects, k)
    end

    for k = 1, table.maxn(objects) do
        table.remove(objects)
    end

    if Stage.width ~= nil and Stage.width ~= 0 then
        for x = 0, Stage.width - 1 do
            for y = 0, Stage.height - 1 do
                local name = fgMap[x][y].name
                if name == 'dirt' or name == 'wood' or name == 'stone' or name == 'roof' or name == 'spawn' then
                    world:remove(fgMap[x][y])
                end
            end
        end
        world:remove(leftWall)
        world:remove(rightWall)
    end

    for k in pairs(fgMap) do
        fgMap[k] = nil
        bgMap[k] = nil
    end

end

local timer = {
    using = false,
    t = 0,
    callback = function() end
}


function Stage.load(bgImgFileName, fgImgFileName, description)
    font = love.graphics.newImageFont("dat/fnt/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/.,:", 2)
    Stage.clearWorld()


    intro = description or false
    if intro then
        introFile = love.filesystem.newFile(description)
        introFile:open("r")
        introFile:read() -- whhaaaat без этого уходит в бесконечный цикл

        for line in introFile:lines() do
            table.insert(introText, line)
        end
        introFile:close()
        love.graphics.setFont(font)

    end

    math.randomseed(os.time())


    local bgImg = love.graphics.newImage(bgImgFileName)
    local fgImg = love.graphics.newImage(fgImgFileName)

    Stage.width, Stage.height = fgImg:getDimensions()
    camera:setWorld(0, 0, Stage.width * 16, Stage.height * 16)
    camera:setWindow(0, 0, 640, 640)

    spawn.x, spawn.y = Stage.buildMap(bgImg, fgImg)

    entities['player'].load(spawn.x, spawn.y)
    world:add(entities['player'], spawn.x, spawn.y, entities['player'].width, entities['player'].height)
    entities['player'].inWorld = true

    Stage.loadTextures()

    canvas = love.graphics.newCanvas(Stage.width * unit, Stage.height * unit)
    love.graphics.setCanvas(canvas)
    Stage.drawMap(0, 0)
    love.graphics.setCanvas()

    camera:setPosition(spawn.x, spawn.y)
end



function Stage.update(dt)
    if timer.using then
        timer.t = timer.t - dt
        if timer.t <= 0 then
            timer.callback()
            timer.using = false
        end
    end

if intro == false then

    for _, entitie in pairs(entities) do
        entitie.update(entitie, dt)

    if entitie.name ~= 'player' or (entitie.name == 'player' and entitie.ded == false) then

        entitie.speedY = entitie.speedY + 1800 * dt --300
        local goalX = entitie.x + entitie.speedX * dt
        local goalY = entitie.y + entitie.speedY * dt
        local actualX, actualY, cols, len = world:move(entitie, goalX, goalY, entitie.filter)
        local reset = false


        for i = 1, len do
            local other = cols[i].other
            local item = cols[i].item

            local name = other.name
            if item.name == 'player' and name == 'enemy' then

                entitie.die()

                timer.t = 4
                timer.using = true
                timer.callback = function()
                    entitie.ded = false
                    Stage.reset()
                    reset = true
                    music.play("shadow")
                end
            end

            if name == 'treasure' and entitie.name == 'player' then
                other.full = false
                world:remove(other)

                local cost = 5
                entitie.bag = entitie.bag + cost
                entitie.speed = math.max(entitie.speed - cost, 50)

                music.effect('pickup')
            end

            if name == 'spawn' and entitie.name == 'player' then
                local r = entitie.drop()
                if entitie.score == maxScore then
                    win = true
                end
                if r == true then music.effect('pickup') end
            end

            if entitie.name == 'enemy' then
                local nextTileX = math.floor(goalX / 16)
                local nextTileY = math.floor(goalY / 16) + 1

                local leftBottom = fgMap[nextTileX][nextTileY + 1]
                local rightBottom = fgMap[nextTileX+2][nextTileY + 1]
                local leftDownTile = fgMap[nextTileX][nextTileY]
                local leftUpTile = fgMap[nextTileX][nextTileY-1]
                local rightDownTile = fgMap[nextTileX+2][nextTileY]
                local rightUpTile = fgMap[nextTileX+2][nextTileY-1]


                -- проверка, чтобы не упасть в пропасть и не упереться в стену
                if (leftDownTile.name ~= 'air' and entitie.side == -1) or
                    (leftUpTile.name ~= 'air' and entitie.side == -1) or
                    (rightUpTile.name ~= 'air' and entitie.side == 1) or
                    (rightDownTile.name ~= 'air' and entitie.side == 1) or
                    leftBottom.name == 'air' or rightBottom.name == 'air' then

                    entitie.turnBack(entitie)
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


        if reset == false then
            entitie.x = actualX
            entitie.y = actualY
        end
    end
    end

    local cx = entities['player'].x + entities['player'].width / 2
    local cy = entities['player'].y + entities['player'].height / 2

    camera:setPosition(cx, cy)
    return win

else


    if love.keyboard.isDown('space') then
        intro = false
        love.graphics.setFont(font)
    end

end
end


function Stage.reset()

    world:remove(entities['player'])
    entities['player'].reset(spawn.x, spawn.y)

    world:add(entities['player'], spawn.x, spawn.y, entities['player'].width, entities['player'].height)
    for _, entitie in pairs(entities) do
        if entitie.name ~= 'player' then
            world:remove(entitie)
            entitie:reset()
            world:add(entitie, entitie.x, entitie.y, entitie.width, entitie.height)
        end
    end
    for _, obj in pairs(objects) do
        if obj.full == false then
            world:add(obj, obj.x, obj.y, obj.width, obj.height)
            obj:reset()
        end

    end
end

function drawInterface(x, y)
    love.graphics.print('Score: '..tostring(entities['player'].score), x, y)
    love.graphics.print('Bag: '..tostring(entities['player'].bag), x, y + 10)
end

function Stage.draw(x, y)

if intro == false then

    camera:setScale(2.0)
    camera:draw(function(l, t, w, h)
        local par_x, par_y = camera:getPosition()
        _, _, par_w, par_h = camera:getWindow()
        _, _, wr_w, wr_h = camera:getWorld()
        par_x = par_x - par_w / 4
        par_y = par_y - par_h / 4

        par_x = par_x - 160 * (par_x / (wr_w - par_w / 4))
        par_y = par_y - 160 * (par_y / (wr_h - par_h / 4))
        love.graphics.draw(parallax_bg, par_x, par_y)

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
            entitie.draw(entitie, entitie.x, entitie.y)
        end

    end)

    love.graphics.setColor( 48, 53, 53, 255 )
    love.graphics.rectangle("fill", 0, 0, 640, 32)
    love.graphics.setColor( 255, 255, 255, 255 )

    love.graphics.print('Score: '..tostring(entities['player'].score)..'/'..tostring(maxScore), 32, 8)
    love.graphics.print('Bag: '..tostring(entities['player'].bag), 352, 8)
else
    love.graphics.setColor( 34, 34, 34, 255 )
    love.graphics.rectangle("fill", 0, 0, 640, 640)
    love.graphics.setColor( 255, 255, 255, 255 )

    for i, str in ipairs(introText) do
        love.graphics.print(str, 64 + 0, 64 + 32*(i - 1))
    end

    love.graphics.scale()
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
    for x = 0, Stage.width - 1 do
        for y = 0, Stage.height - 1 do
            local nx = x * 16
            local ny = y * 16

            local fgTileName = fgMap[x][y].name
            local bgTileName = bgMap[x][y].name
            if fgTileName == 'stone' or fgTileName == 'dirt' or fgTileName == 'wood' or fgTileName == 'roof' then
                fgTileName = fgTileName .. '_' .. fgMap[x][y].type

            end

            if bgTileName == 'wall' or bgTileName == 'backstone' or bgTileName == 'fence' or bgTileName == 'wooden_fence' then
                bgTileName = bgTileName .. '_' .. bgMap[x][y].type
            end
            if fgTileName == 'box' then
                fgTileName = 'air'
            end

            Stage.drawTile(bgTileName, nx, ny)

            Stage.drawTile(fgTileName, nx, ny)
        end
    end
end

function Stage.drawTile(name, x, y)
    if name ~= "air" then
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
    elseif r == 255 and g == 30 and b == 50 then
        return 'wooden_fence'
    elseif r == 100 and g == 50 and b == 50 then
        return 'wall'
    elseif r == 255 and g == 255 and b == 0 then
        return 'treasure'
    elseif r == 150 and g == 80 and b == 0 then
        return 'box'
    elseif r == 90 and g == 90 and b == 90 then
        return 'backstone'
    elseif r == 255 and g == 128 and b == 128 then
        return 'enemy'
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
            color = chekColor(r, g, b, a)
            if color == 'dirt' or color == 'wood' or color == 'stone' or color == 'roof' then
                fgMap[x][y] = { name = color }
                world:add(fgMap[x][y], x * 16, y * 16, 16, 16)
            elseif color == 'air' or color == 'box' then
                fgMap[x][y] = { name = color }
            elseif color == 'treasure' then
                maxScore = maxScore + 5
                fgMap[x][y] = { name = 'air' }
                local r = math.random(1, 3)
                --rm 'treasure'
                local obj = object.newObject(color, r, x * unit, y * unit, unit, unit)
                world:add(obj, x * unit, y * unit, unit, unit)
                table.insert(objects, obj)
            end
            if color == 'enemy' then
                fgMap[x][y] = { name = 'air' }
                local enemy = enemys.newEnemy(x * unit, y * unit, Stage.width)
                enemy:load()
                world:add(enemy, x * unit, y * unit, enemy.width, enemy.height)
                table.insert(entities, enemy)
            end
            if color == 'fox' then

                fgMap[x][y] = { name = 'spawn' }

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

                    if fBlockType == 'wood' then

                    end
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
                if t == 'wall' or t == 'backstone' or t == 'fence' or t == 'wooden_fence' then
                    bEnv.l = 1
                end
            else
                bEnv.l = 1
            end

            if bgMap[x + 1] ~= nil then
                local t = bgMap[x + 1][y].name
                if t == 'wall' or t == 'backstone' or t == 'fence' or t == 'wooden_fence' then
                    bEnv.r = 1
                end

            else
                bEnv.r = 1
            end

            if bgMap[x][y - 1] ~= nil then
                local t = bgMap[x][y - 1].name
                if t == 'wall' or t == 'backstone' or t == 'fence' or t == 'wooden_fence' then
                    bEnv.u = 1
                end

            else
                bEnv.u = 1
            end

            if bgMap[x][y + 1] ~= nil then
                local t = bgMap[x][y + 1].name
                if t == 'wall' or t == 'backstone' or t == 'fence' or t == 'wooden_fence' then
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

            if bBlockType == 'fence' or bBlockType == 'wooden_fence' then
                if bEnv.l == 0 and bEnv.r == 1 then
                    bgMap[x][y].type = 'l'
                elseif bEnv.l == 1 and bEnv.r == 0 then
                    bgMap[x][y].type = 'r'
                else
                    bgMap[x][y].type = 'c'
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

    Stage.newTile('background', 'fence_l', 48, 0, 16, 16)
    Stage.newTile('background', 'fence_c', 64, 0, 16, 16)
    Stage.newTile('background', 'fence_r', 80, 0, 16, 16)

    Stage.newTile('background', 'wooden_fence_l', 48, 16, 16, 16)
    Stage.newTile('background', 'wooden_fence_c', 64, 16, 16, 16)
    Stage.newTile('background', 'wooden_fence_r', 80, 16, 16, 16)

    Stage.newTile('objects', 'chest_f', 0, 0, 16, 16)
    Stage.newTile('objects', 'chest_e', 16, 0, 16, 16)
    Stage.newTile('objects', 'table_f', 0, 16, 16, 16)
    Stage.newTile('objects', 'table_e', 16, 16, 16, 16)
    Stage.newTile('objects', 'cup_f', 0, 32, 16, 16)
    Stage.newTile('objects', 'cup_e', 16, 32, 16, 16)
    Stage.newTile('objects', 'spawn', 32, 0, 16, 16)

end

return Stage
