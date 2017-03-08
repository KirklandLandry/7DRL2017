local tileSize
MoveDirs = {up = "up", down = "down", left = "left", right = "right"}
local playerController = nil
local camera = nil
local currentMap = nil
-- weapon triangle is now global for convenience
-- WARNING: if weapon triangle is re-randomized then it'll break everything logically.
-- game should work still, but icons and names change for no reason. Don't do dat.
weaponTriangle = nil 

local enemyList = {}


damageTextList = {}


function loadGame()
	tileSize = globalTileSize
	weaponTriangle = WeaponTriangle:new()
	camera = Camera:new()
	-- create and generate new map. only need to call new once at start.
	currentMap = Map:new(21, 29, tileSize, camera)
	currentMap:generate(61, 61)
	local tileX, tileY = camera:getTilePos(tileSize)
	currentMap.prevTileX = tileX
	currentMap.prevTileY = tileY
	currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)
	-- create player controller and center camera on it
	playerController = PlayerController:new(currentMap:getRandPosition(tileSize))
  	camera:centreOnPoint(playerController.character.x, playerController.character.y, tileSize, tileSize)
	camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)

	for i=1,30 do	
		local px, py = currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)
		local rx, ry = currentMap:getRandPositionExcludingRadius(tileSize, enemyList, 10, px, py)
		local rand = math.random(0, 100)
		if rand < 60 then 
			table.insert(enemyList, EnemyController:new(10, EnemyType.log, rx, ry))
		else 
			table.insert(enemyList, EnemyController:new(10, EnemyType.npc, rx, ry))
		end 
	end

	initText()
end

function updateGame(dt)	
	if getKeyDown( "escape" ) then
		love.event.quit()
	end
	-- move camera with arrow keys 
	camera:moveManually(dt)
	-- move player with wasd
	local playerMoved, playerAttacked = playerController:update(tileSize, dt, currentMap, enemyList)
	-- illuminate area around player
	currentMap:illuminate(5, currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize))
	-- make camera follow player 
	if getKeyDown("q") then 
		camera:lerpTowardsPoint(dt, playerController.character.x, playerController.character.y, tileSize, tileSize, 0.03)
	end
	-- generate new map. debug
	if getKeyPress("f") then 
		newMap(61, 61)
	end 
	-- prevent camera from scrolling past map boundary
	camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)
	camera:update(dt)
	-- update tilemap position if the camera has moved 
	local tileX, tileY = camera:getTilePos(tileSize)
	if currentMap.prevTileX ~= tileX or currentMap.prevTileY ~= tileY then 
		currentMap.prevTileX = tileX
		currentMap.prevTileY = tileY
		currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)
	end 
	for i=#enemyList,1,-1 do
		enemyList[i]:update(dt, playerMoved, playerAttacked, currentMap, playerController, tileSize, enemyList)
		if enemyList[i].character.health <= 0 then 
			table.remove(enemyList, i)
		end 
	end 


	for i=#damageTextList,1,-1 do
		damageTextList[i].y = damageTextList[i].y - 100 * dt
		damageTextList[i].alpha = damageTextList[i].alpha - 10
		if damageTextList[i].alpha <= 0 then 
			table.remove(damageTextList, i)
		end 
	end

	
end

function drawGame()
	love.graphics.scale(camera.scale)
	local roundedCameraX, roundedCameraY = camera:getRoundedPosition()
	-- draw map 
	currentMap:draw(camera:getInverseOffsetIntoCurrentTile(tileSize))
	-- draw player 
	drawText(tostring(playerController.character.health), math.floor(playerController.character.x) - roundedCameraX, math.floor(playerController.character.y) - roundedCameraY - 16)
	playerController:draw(tileSize, camera:getRoundedPosition())
	-- draw enemies 
	for i=1,#enemyList do
		enemyList[i]:draw(tileSize, camera:getRoundedPosition())
		--[[drawText(tostring(enemyList[i].character.health), 
			math.floor(enemyList[i].character.x) - roundedCameraX,
			math.floor(enemyList[i].character.y) - roundedCameraY - 16)]]
	end
	

	for i=#damageTextList,1,-1 do
		love.graphics.setColor(255, 0, 0, damageTextList[i].apha)
		drawText(tostring(damageTextList[i].damage), 
			math.floor(damageTextList[i].x) - roundedCameraX,
			math.floor(damageTextList[i].y) - roundedCameraY)
	end


	--drawText("heo)-=?", math.floor(playerController.character.x) - roundedCameraX, math.floor(playerController.character.y) - roundedCameraY)

	-- draw the map shadow
	if not getKeyDown("c") then currentMap:drawShadow(camera, tileSize, camera:getTilePos(tileSize)) end
	-- never want UI element to be affected by game scaling
	love.graphics.reset()
	love.graphics.scale(2, 2)
	weaponTriangle:drawTriangle(0,0)
end

function love.wheelmoved(x,y)
	if camera.scale + (y * 0.25) < 0.5 then return end 
	camera.scale = camera.scale + (y * 0.25)
	camera:centreOnPoint(
		playerController.character.x, 
		playerController.character.y, 
		tileSize, tileSize)
	-- if scale changes, display size changes, spritebatch size needs to change as well
	currentMap:resizeSpritebatch(camera, tileSize)
	-- update tilemap position 
	local tileX, tileY = camera:getTilePos(tileSize)
	currentMap.prevTileX = tileX
	currentMap.prevTileY = tileY
	currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)
end 


function newMap(width, height)
	currentMap:generate(width, height)
	local tileX, tileY = camera:getTilePos(tileSize)
	currentMap.prevTileX = tileX
	currentMap.prevTileY = tileY
	currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)

	playerController.character.x, playerController.character.y = currentMap:getRandPosition(tileSize)

  	camera:centreOnPoint(playerController.character.x, playerController.character.y, tileSize, tileSize)
	camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)


	for i=#enemyList,1,-1 do
		table.remove(enemyList, i)
	end 
	enemyList = {}
	for i=1,30 do	
		local px, py = currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)
		local rx, ry = currentMap:getRandPositionExcludingRadius(tileSize, enemyList, 10, px, py)
		local rand = math.random(0, 100)
		if rand < 60 then 
			table.insert(enemyList, EnemyController:new(10, EnemyType.log, rx, ry))
		else 
			table.insert(enemyList, EnemyController:new(10, EnemyType.npc, rx, ry))
		end 
	end
end 









local textTileset = nil 
local textTilesetQuads = nil

function initText()
	textTileset = love.graphics.newImage("assets/UI/16x16PixelFont.png")
	textTileset:setFilter("nearest", "nearest")

	local tilesetWidth = textTileset:getWidth()
	local tilesetHeight = textTileset:getHeight()

	textTilesetQuads = {}

	textTilesetQuads[" "] = love.graphics.newQuad(0, 32, 16, 16, tilesetWidth, tilesetHeight)

	textTilesetQuads["!"] = love.graphics.newQuad((26*16)				, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["."] = love.graphics.newQuad((26*16) + ((1)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["?"] = love.graphics.newQuad((26*16) + ((2)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["@"] = love.graphics.newQuad((26*16) + ((3)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["#"] = love.graphics.newQuad((26*16) + ((4)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["$"] = love.graphics.newQuad((26*16) + ((5)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["%"] = love.graphics.newQuad((26*16) + ((6)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["("] = love.graphics.newQuad((26*16) + ((9)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[")"] = love.graphics.newQuad((26*16) + ((10)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[":"] = love.graphics.newQuad((26*16)				, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[","] = love.graphics.newQuad((26*16) + ((2)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["-"] = love.graphics.newQuad((26*16) + ((6)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["="] = love.graphics.newQuad((26*16) + ((7)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	

    local counter = 0
    for i=string.byte("a"),string.byte("z") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 0, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end

    -- map numbers 
    for i=1,10 do
    	if i == 10 then 
    		textTilesetQuads[tostring(0)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	else 
			textTilesetQuads[tostring(i)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	end 
    	
    end

end 

function drawText(word, x, y)
	local counter = 0
	for c in word:gmatch"." do
		love.graphics.draw(textTileset, textTilesetQuads[c], x + (counter*16), y)
		counter = counter + 1
	end
end 