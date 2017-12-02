Stage = {}

--[[
	map is H:L img
	black is block
	white is empti
]]--


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

function Stage.fill()
	local bMapData = Stage.bImgMap:getData()
	local fMapData = Stage.fImgMap:getData()
	
	for i = 1, Stage.width do
		Stage.bMap[i - 1] = {}
		Stage.fMap[i - 1] = {}
		for j = 1, Stage.height do
			br, bg, bb, ba = bMapData:getPixel(i - 1, j - 1)
			fr, fg, fb, fa = fMapData:getPixel(i - 1, j - 1)
			if br == black.r and bg == black.g and bb == black.b then
				Stage.bMap[i - 1][j - 1] = 1
			elseif br == white.r and bg == white.g and bb == white.b then
				Stage.bMap[i - 1][j - 1] = 0
			end
		end
	end
end

function getImageScaleForNewDimensions(image, newWidth, newHeight )
    local currentWidth, currentHeight = image:getDimensions()
    return ( newWidth / currentWidth ), ( newHeight / currentHeight )
end


function Stage.load(bFileName, fFileName, description)
	Stage.bImgMap = love.graphics.newImage(bFileName)
	Stage.fImgMap = love.graphics.newImage(fFileName)
	
	Stage.width, Stage.height = Stage.bImgMap:getDimensions()
	Stage.fill()

	-- local player = require('Player')
	-- player.load(200, 200, 450)
	entities['player'] = require('Player')
	entities['player'].load(200, 200, 450) -- Взять из дескрипшина
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