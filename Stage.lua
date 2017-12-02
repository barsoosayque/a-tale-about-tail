Stage = {}

--[[
	map is H:L img
	black is block
	white is empti
]]--

physics = {}
physics.const = {
	g = 9.8
}




Stage.textures = {}
Stage.bMap = {}
Stage.fMap = {}
Stage.description = nil

local entities = {}

local unit = 16
local scale = 2

local black = {r = 0, g = 0, b = 0}
local white = {r = 255, g = 255, b = 255}
	

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
				way = unit*scale*(i - 1)
			end
		end
	end
	return way
end

function getImageScaleForNewDimensions(image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end


function Stage.load(bFileName, fFileName, description)
	Stage.bImgMap = love.graphics.newImage(bFileName)
	Stage.fImgMap = love.graphics.newImage(fFileName)
	
	Stage.width, Stage.height = Stage.bImgMap:getDimensions()
	
	entities['player'] = require('Player')

	way = Stage.fill()
	
	local x = 640/2 - Player.width/2
	entities['player'].load(x, 200, way) -- Взять из дескрипшина
end


function Stage.newTexture(fileName, textureName)
	Stage.textures[textureName] = love.graphics.newImage(fileName)
end

function Stage.drawTile(x, y, texture)
	local scaleX, scaleY = getImageScaleForNewDimensions( Stage.textures[texture], 2*unit, 2*unit )
	love.graphics.draw(Stage.textures[texture], x, y, 0, scaleX, scaleY)
	
end

function Stage.draw(x, y)
	local l = Player.way

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
			if(Stage.bMap[i][j] == 1) then
				Stage.drawTile(nx - dl, ny, "block")
			elseif (Stage.bMap[i][j] == 0) then
				Stage.drawTile(nx - dl, ny, "empti")
			end
		end
	end 
--------------------------------------------------->
	for _, entitie in pairs(entities) do
		entitie.draw()
	end
end

function Stage.update(dt)
	for _, entitie in pairs(entities) do
		entitie.update(dt)
	end
end

return Stage