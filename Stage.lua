Stage = {}


physics = {}
physics.const = {
	g = 9.8
}


local bump = require('lib/bump')



Stage.textures = {}
Stage.bMap = {}
Stage.fMap = {}
Stage.description = nil

local entities = {}

local unit = 16
local scale = 2

local black = {r = 0, g = 0, b = 0}
local white = {r = 255, g = 255, b = 255}
	

function Stage.load(bFileName, fFileName, description)
	Stage.bImgMap = love.graphics.newImage(bFileName)
	Stage.fImgMap = love.graphics.newImage(fFileName)
	
	Stage.width, Stage.height = Stage.bImgMap:getDimensions()
	
	entities['player'] = require('Player')

	x, y = Stage.fill()
	
	entities['player'].load(640/2 - Player.width/2, y, x - Player.width/2) -- Взять из дескрипшина
end



function Stage.addEntitie(entitie)
	table.insert(entities, entitie)
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

function Stage.fill()
	local bMapData = Stage.bImgMap:getData()
	local fMapData = Stage.fImgMap:getData()
	
	local way = nil

	for i = 1, Stage.width do
		Stage.bMap[i - 1] = {}
		Stage.fMap[i - 1] = {}
		for j = 1, Stage.height do
			br, bg, bb, ba = bMapData:getPixel(i - 1, j - 1)
			fr, fg, fb, fa = fMapData:getPixel(i - 1, j - 1)
			local bColor = chekColor(br, bg, bb)
			local fColor = chekColor(fr, fg, fb)

			if bColor == 'black' then
				Stage.bMap[i - 1][j - 1] = 1
			elseif bColor == 'white' then
				Stage.bMap[i - 1][j - 1] = 0
			end

			if fColor == 'red' then
				x = unit*scale*(i - 1)
				y = unit*scale*(j - 1)
			end
		end
	end
	return x, y
end

function getImageScaleForNewDimensions(image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end





function Stage.newTexture(fileName, textureName)
	Stage.textures[textureName] = love.graphics.newImage(fileName)
end

function Stage.drawTile(x, y, texture)
	local scaleX, scaleY = getImageScaleForNewDimensions( Stage.textures[texture], 2*unit, 2*unit )
	love.graphics.draw(Stage.textures[texture], x, y, 0, scaleX, scaleY)
	
end

function Stage.draw(x, y)
	local l = Player.x

	if(l < 320) then
		l = 320
	elseif(l > unit*scale*Stage.width - 320) then
		l = unit*scale*Stage.width - 320
	end

	local dl = l - 320

	for i = 0, Stage.width - 1 do
		for j = 0, Stage.height - 1 do 
			nx = x + i*unit*scale
			ny = y + j*unit*scale
			-- love.graphics.setColor(255, 255, 255)
			-- love.graphics.print("("..tostring(i)..","..tostring(j)..")", nx - dl, ny)
			if(Stage.bMap[i][j] == 1) then
				Stage.drawTile(nx - dl, ny, "block")
			elseif (Stage.bMap[i][j] == 0) then
				Stage.drawTile(nx - dl, ny, "empti")
			end
		end
	end 
--------------------------------------------------->
	for _, entitie in pairs(entities) do
		entitie.draw(x, y)
	end
end

function Stage.checkCollisionsWithMap(entitie)
	local r = entitie.width/2

	local bl = {x = math.floor((entitie.x + 5)/32), y = math.floor((entitie.y + entitie.height)/32)}
	local br = {x = math.floor((entitie.x + entitie.width - 5)/32), y = math.floor((entitie.y + entitie.height)/32)}
	
	local lt = {x = math.floor((entitie.x)/32), y = math.floor((entitie.y + 5)/32)}
	local lb = {x = math.floor((entitie.x)/32), y = math.floor((entitie.y + entitie.height - 5)/32)}

	local rt = {x = math.floor((entitie.x + entitie.width)/32), y = math.floor((entitie.y + 5)/32)}
	local rb = {x = math.floor((entitie.x + entitie.width)/32), y = math.floor((entitie.y + entitie.height - 5)/32)}

	local tl = {x = math.floor((entitie.x + 5)/32), y = math.floor((entitie.y)/32)}
	local tr = {x = math.floor((entitie.x + entitie.width - 5)/32), y = math.floor((entitie.y)/32)}

	if entitie.supaFlag then
		bl.x = math.floor((entitie.x - entitie.width/2 + 5)/32)
		br.x = math.floor((entitie.x + entitie.width/2 - 5)/32)
		-- bl.y = math.floor((entitie.y + entitie.height - 5)/32)
		-- br.y = math.floor((entitie.x + entitie.height - 5)/32)
		
		lt.x = math.floor((entitie.x - entitie.width/2 + 5)/32)
		lt.y = math.floor((entitie.y - 15)/32)
		lb.x = math.floor((entitie.x - entitie.width/2 + 5)/32)

		rt.x = math.floor((entitie.x + entitie.width/2 - 5)/32)
		rb.x = math.floor((entitie.x + entitie.width/2 - 5)/32)

		tl.x = math.floor((entitie.x + 5 - entitie.width)/32)
		tr.x = math.floor((entitie.x - 5 + entitie.width)/32)
	end


	local bottomLeftBlock = Stage.bMap[bl.x][bl.y]
	local bottomRightBlock = Stage.bMap[br.x][br.y]
	if bottomLeftBlock == 1 or bottomRightBlock == 1 then
		entitie.land = true
		entitie.speedY = 0
		entitie.y = bl.y*32 - entitie.height
	end

	local leftTopBlock = Stage.bMap[lt.x][lt.y]
	local leftTopBlock = Stage.bMap[lb.x][lb.y]
	if leftTopBlock == 1  or leftBottomBlock == 1 then
		entitie.left = true
		entitie.speedX = 0
		-- entitie.x = lt.x*32 + 47
	else
		entitie.left = false
	end

	local rightTopBlock = Stage.bMap[rt.x][rt.y]
	local rightBottomBlock = Stage.bMap[rb.x][rb.y]
	if rightTopBlock == 1  or rightBottomBlock == 1 then
		-- entitie.land = true
		entitie.right = true
		entitie.speedX = 0
		-- entitie.x = rb.x*32 - entitie.width + 18
	else
		entitie.right = false
	end

	local topLeftBlock = Stage.bMap[tl.x][tl.y]
	local topRightBlock = Stage.bMap[tr.x][tr.y]
	if topLeftBlock == 1 or topRightBlock == 1 then
		entitie.land = true
		entitie.speedY = 1
		-- entitie.y = tl.y*32
	end


end

function Stage.update(dt)
	-- Stage.checkCollisions()
	for _, entitie in pairs(entities) do
		entitie.speedY = entitie.speedY + physics.const.g*dt
		Stage.checkCollisionsWithMap(entitie)
		entitie.update(dt)
	end
end

return Stage