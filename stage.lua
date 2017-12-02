Stage = {}

local bump = require('lib/bump')
local world = bump.newWorld(16)

local textures = {}

local entities = {}

local bMap = {}
local fMap = {}

function Stage.load(bImgFileName, fImgFileName, description)
	local bImg = love.graphics.newImage(bImgFileName)
	local fImg = love.graphics.newImage(fImgFileName)

	Stage.width, Stage.height = bImg:getDimensions()
	local x, y = Stage.buildMap(bImg, fImg)

	entities['player'] = require('player')
	entities['player'].load(x, y, Stage.width)
	world:add(entities['player'], x, y, entities['player'].width, entities['player'].height)

	Stage.newTexture('dat/img/block.png', 'block')
	Stage.newTexture('dat/img/empty.png', 'empty')

end

function Stage.update(dt)
	for _, entitie in pairs(entities) do
		entitie.update(dt)

		entitie.speedY = entitie.speedY + 300*dt

		local goalX = entitie.x + entitie.speedX*dt
		local goalY = entitie.y + entitie.speedY*dt
		local actualX, actualY, cols, len = world:move(entitie, goalX, goalY, entitie.filter)

		if actualY == entitie.y then
			entitie.speedY = 0
			entitie.land()
		end

		print('name:'..entitie.name)
		print('gx:'..tostring(goalX)..' gy:'..tostring(goalY))
		print('ax:'..tostring(actualX)..' ay:'..tostring(actualY))
		print('speedX:'..tostring(entitie.speedX)..' speedY:'..tostring(entitie.speedY))
		
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

function Stage.drawMap(X, Y)
	local l = entities['player'].x + entities['player'].width/2	
	-- if entities['player'].x < 640/2 - entities['player'].width/2 then
	-- 	l = entities['player'].x
	-- end
	local dl = 0

	if l < 640/2 then
		dl = 0
	elseif l > Stage.width*16*2 - 320 then
		dl = Stage.width*16*2 - 640   -->??????
	else
		dl = l - 320
	end

	for x = 0, Stage.width - 1 do
		for y = 0, Stage.height - 1 do
			local nx = x*16*2
			local ny = y*16*2
			Stage.drawTile(bMap[x][y].name, X + nx - dl, Y + ny)
		end
	end
end

function Stage.drawTile(name, x, y)
	local scaleX, scaleY = getImageScaleForNewDimensions(textures[name], 2*16, 2*16 )
	love.graphics.draw(textures[name], x, y, 0, scaleX, scaleY)
	
end

function Stage.newTexture(fileName, textureName)
	textures[textureName] = love.graphics.newImage(fileName)
end

function chekColor(r, g, b)
	if r == 0 and g == 0 and b == 0 then
		return 'black'
	elseif r == 255 and g == 255 and b == 255 then
		return 'white'
	elseif r == 255 and g == 0 and b == 0 then
		return 'red'
	end
end


function Stage.buildMap(bImg, fImg)
	local bData = bImg:getData()
	local fData = fImg:getData()

	local pX, pY

	for x = 0, Stage.width - 1 do
		bMap[x] = {}
		fMap[x] = {}
		for y = 0, Stage.height - 1 do
			-->bMap
			r, g, b, a = bData:getPixel(x, y)
			color = chekColor(r, g, b)
			if color == 'black' then
				bMap[x][y] = {name = 'block'}
				world:add(bMap[x][y], x*16*2, y*16*2, 16*2, 16*2)
			elseif color == 'white' then
				bMap[x][y] = {name = 'empty'}
			end

			-->fMap
			r, g, b = fData:getPixel(x, y)
			color = chekColor(r, g, b)
			if color == 'red' then
				pX, pY = x*16*2, y*16*2
			end
		end
	end
	return pX, pY
end




function getImageScaleForNewDimensions(image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end


return Stage