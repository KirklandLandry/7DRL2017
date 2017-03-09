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
local currentFloor = nil



SceneGameplay = {}
function SceneGameplay:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	return o
end 


function SceneGameplay:init()
	tileSize = globalTileSize
	self:newGame()
end 


function SceneGameplay:update(dt)
	
	if getKeyDown("h") then 
		sceneStack:pop()
		return 
	end 

	-- move camera with arrow keys 
	camera:moveManually(dt)
	-- move player with wasd
	local playerMoved, playerAttacked = playerController:update(tileSize, dt, currentMap, enemyList)
	-- if you're on a stairway, move to next floor
	if currentMap:onStairway(currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)) then 
		self:newMap(61, 61)
		currentFloor = currentFloor + 1
	end 
	-- illuminate area around player
	currentMap:illuminate(5, currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize))
	-- make camera follow player 
	if getKeyDown("q") then 
		camera:lerpTowardsPoint(dt, playerController.character.x, playerController.character.y, tileSize, tileSize, 0.03)
	end
	-- generate new map. debug
	if getKeyPress("f") then 
		SceneGameplay:newMap(61, 61)
	end 
	-- prevent camera from scrolling past map boundary
	--camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)
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


function SceneGameplay:draw()
	love.graphics.scale(camera.scale)
	local roundedCameraX, roundedCameraY = camera:getRoundedPosition()
	-- draw map 
	currentMap:draw(camera:getInverseOffsetIntoCurrentTile(tileSize))
	-- draw player 
	drawText(tostring(playerController.character.health), math.floor(playerController.character.x) - roundedCameraX, math.floor(playerController.character.y) - roundedCameraY - 16)
	playerController:draw(tileSize, camera:getRoundedPosition())
	-- draw enemies 
	for i=1,#enemyList do
		enemyList[i]:draw(tileSize, camera)
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

	self:drawUI()
	
end 





function SceneGameplay:newGame()
	weaponTriangle = WeaponTriangle:new()
	camera = Camera:new()
	camera.scale = 2
	-- create and generate new map. only need to call new once at start.
	currentMap = Map:new(21, 29, tileSize, camera)
	currentMap:generate(61, 61)
	local tileX, tileY = camera:getTilePos(tileSize)
	currentMap.prevTileX = tileX
	currentMap.prevTileY = tileY
	
	-- create player controller and center camera on it
	playerController = PlayerController:new(currentMap:getRandPosition(tileSize))
  	camera:centreOnPoint(playerController.character.x, playerController.character.y, tileSize, tileSize)
	--camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)
	currentMap:placeStairway(currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize))
	currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)

	currentFloor = 1

	local px, py = currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)
	for i=1,30 do	
		local rx, ry = currentMap:getRandPositionExcludingRadius(tileSize, enemyList, 10, px, py)
		local rand = math.random(0, 100)
		if rand < 60 then 
			table.insert(enemyList, EnemyController:new(10, EnemyType.log, rx, ry))
		else 
			table.insert(enemyList, EnemyController:new(10, EnemyType.npc, rx, ry))
		end 
	end
end






function SceneGameplay:newMap(width, height)
	currentMap:generate(width, height)
	local tileX, tileY = camera:getTilePos(tileSize)
	currentMap.prevTileX = tileX
	currentMap.prevTileY = tileY
	
	playerController.character.x, playerController.character.y = currentMap:getRandPosition(tileSize)

  	camera:centreOnPoint(playerController.character.x, playerController.character.y, tileSize, tileSize)
	--camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)
currentMap:placeStairway(currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize))
currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)

	for i=#enemyList,1,-1 do
		table.remove(enemyList, i)
	end 
	enemyList = {}
	for i=1,30 do	
		local px, py = currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)
		local rx, ry = currentMap:getRandPositionExcludingRadius(tileSize, enemyList, 10, px, py)
		local rand = math.random(0, 100)
		if rand < 70 then 
			table.insert(enemyList, EnemyController:new(10, EnemyType.log, rx, ry))
		else 
			table.insert(enemyList, EnemyController:new(10, EnemyType.npc, rx, ry))
		end 
		enemyList[i].character:adjustToLevel(playerController.character.level, currentFloor)
	end
end 




function SceneGameplay:drawUI()
		-- never want UI element to be affected by game scaling
	love.graphics.reset()
	love.graphics.setColor(255,255,255,210)
	--love.graphics.scale(1.3)

	-- maybe write how each line relates you player beside this 
	-- ie: if first line is A beats B and player is A, write GOOD 
	-- so GOOD, BAD, EQUAL
	weaponTriangle:drawTriangle(0,128 + 8)
	--love.graphics.scale(1)
	drawText("todays weapons are...", 0, 0 + 8)
	--drawText("_____________________", 0, 96 + 10)
	--love.graphics.scale(1.25)
	weaponTriangle:drawAttributeA(0, 32)
	weaponTriangle:drawAttributeB(0, 64)
	weaponTriangle:drawAttributeC(0, 96)
	drawText(weaponTriangle:getAttributeName(AttributeTypes.a), 34, 32 + 8)
	drawText(weaponTriangle:getAttributeName(AttributeTypes.b), 34, 64 + 8)
	drawText(weaponTriangle:getAttributeName(AttributeTypes.c), 34, 96 + 8)
	

	--weaponTriangle:drawAttribute(0, screenHeight - 32, playerController.character.weaponAttribute)
	
	drawText("weapon:", 0, screenHeight - 32)
	weaponTriangle:drawAttribute(112, screenHeight - 32 - 8, playerController.character.weaponAttribute)
	drawText(weaponTriangle:getAttributeName(playerController.character.weaponAttribute), 112 + 36, screenHeight - 32)

	drawText("bfloor:"..tostring(currentFloor), 2, screenHeight - 160)
	drawText("lvl:"..tostring(playerController.character.level), 2, screenHeight - 128)
	drawText("hp:"..tostring(playerController.character.health).."/"..tostring(playerController.character.maxHealth), 2, screenHeight - 96)
	drawText("xp:"..tostring(playerController.character.currentXP).."/"..tostring(playerController.character.nextLevelXP), 2, screenHeight - 64)
	resetColor()

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
	print(camera.scale)
end 

