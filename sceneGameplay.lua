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

local chestDialogPopup = nil
local enemyDialogPopup = nil
local playerDialogPopup = nil


local freeCam = false
local smoothScrollEnabled = true


SceneGameplay = {}
function SceneGameplay:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.bgm = love.audio.play("assets/audio/The_Endless_Journey.mp3", "stream", true)
	freeCam = false
	smoothScrollEnabled = true
	return o
end 


function SceneGameplay:init()

	-- this is why I should minimize globals...
	playerController = nil
	camera = nil
	currentMap = nil
	weaponTriangle = nil 
	enemyList = {}
	damageTextList = {}
	currentFloor = nil
	chestDialogPopup = nil
	enemyDialogPopup = nil
	playerDialogPopup = nil
	freeCam = false
	smoothScrollEnabled = true

	tileSize = globalTileSize
	self:newGame()
	scaleModified()

	local textList = packTextIntoList(
		"as you light your torch, your eyes slowly", 
		"adjust to the darkness of the cavern.",
		"chasing a mythical treasure, you were dropped",
		"in from above. no way out. your only choice is",
		"to explore and hope the treasure is more than",
		"just a thing of myths and legends.",
		"the journey begins.",
		"",
		"press escape to open the pause /",
		"instructions menu.",
		"press e to close this dialog.")
	chestDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (12*32) + 96, (screenHeight/2) - (5*32), 24, 12,
		textList)

end 

function SceneGameplay:update(dt)
	
	if playerDialogPopup ~= nil then 
		if playerDialogPopup:update() then 
			love.audio.stop(self.bgm)
			sceneStack:pop()
		end 
		return 
	end 

	if getKeyPress( "escape" ) then
		local sceneA = ScenePause:new()
		sceneStack:push(sceneA)	
	end

	if getKeyDown("h") then 
		love.audio.stop(self.bgm)
		sceneStack:pop()
		return 
	end 

	if currentMap:onChest(currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize) )then 
		self:activateChest(playerController)
		local tileX, tileY = camera:getTilePos(tileSize)
		currentMap:updateMapSpritebatch(tileX, tileY, camera, tileSize)
	end 

	if chestDialogPopup ~= nil then 
		if chestDialogPopup:update() then 
			chestDialogPopup = nil 
		end 
		return 
	end 

	if enemyDialogPopup ~= nil then 

		local cursorMove = 0 
		if getKeyPress("w") then cursorMove = -1 elseif getKeyPress("s") then cursorMove = 1 end

		if enemyDialogPopup:update(cursorMove) then 
			-- add an option where the soul betrays you if you ask for healing
			if enemyDialogPopup.currentOption == 5 then 
				playerController.character:incrementXP(EnemyType.npc)
				self:randomKillDialog()
			elseif enemyDialogPopup.currentOption == 6 then
				playerController.character:recoverHealth(math.random(3,6))
				self:randomHealthRecoveryDialog()
			end
			enemyDialogPopup = nil 
		end 
		return 
	end 

	if getKeyPress("q") then 
		freeCam = not freeCam
		if freeCam == false then 
			camera.scale = 2
			scaleModified()
		else 
			camera.scale = 0.5
			scaleModified()
		end 
	end  

	if getKeyPress("g") then 
		smoothScrollEnabled = not smoothScrollEnabled
	end 


	local playerMoved, playerAttacked, playerConversationStarted = false, false, false 
	if freeCam then 
		camera:moveManually(dt)
		camera:lockToEdgeBoundary(currentMap.width, currentMap.height, tileSize)
	else 
		-- move player with wasd
		playerMoved, playerAttacked, playerConversationStarted = playerController:update(tileSize, dt, currentMap, enemyList)
	end 
	

	if playerConversationStarted then 
		--self:activateChest(playerController)
		self:startEnemyDialog() 
		return
	end 

	-- if you're on a stairway, move to next floor
	if currentMap:onStairway(currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize)) then 
		self:newMap(61, 61)
		currentFloor = currentFloor + 1
		self:nextFloorDialog()
	end 
	-- illuminate area around player
	currentMap:illuminate(5, currentMap:getTilePosFromWorldPos(playerController.character.x, playerController.character.y, tileSize))
	-- make camera follow player 
	if not freeCam then 
		if smoothScrollEnabled then 
			camera:lerpTowardsPoint(dt, playerController.character.x, playerController.character.y, tileSize, tileSize, 0.03)
		else 
			camera:centreOnPoint(playerController.character.x, playerController.character.y, tileSize, tileSize)
		end 
	end 
	-- generate new map. debug
	if getKeyPress("f") then 
		currentFloor = currentFloor + 1
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



	if playerController.character.health <= 0 then 
		local textList = packTextIntoList(
		"as the enemy deals the final blow,", 
		"you feel your strength leave you.",
		"you made it "..tostring(currentFloor).." floors below, but",
		"this is it.",
		"while your vision fades, you wonder",
		"what the relic was.",
		"in the end, you'll never know.",
		"your soul has joined the lost.",
		"press e to return to title.")
		playerDialogPopup = SceneOkBox:new(
			(screenWidth/2) - (10*32) + 32, (screenHeight/2) - (5*32), 20, 11,
			textList)

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

	if chestDialogPopup ~= nil then 
		chestDialogPopup:draw()
	end 
	
	if enemyDialogPopup ~= nil then 
		enemyDialogPopup:draw()
	end 

	if playerDialogPopup ~= nil then 
		playerDialogPopup:draw() 
	end 

	-- messes with the alpha of drawing a black rect with 0 alpha?
	--love.graphics.setColor(229, 218, 183, 20)
	--love.graphics.rectangle("fill", 0,0,screenWidth, screenHeight)


end 

--local statTypes = {hp = "hp", xp = "xp", dmg = "dmg"}
function SceneGameplay:activateChest(player)
	local stat = " nothing"
	local randIndex = math.random(1,3)
	local statRaise = 0

	if randIndex == 1 then 
		-- raise hp 
		statRaise = math.random(1,3)
		stat = "hp"
		player.character.health = player.character.health + statRaise
		player.character.maxHealth = player.character.maxHealth + statRaise
	elseif randIndex == 2 then 
		-- raise strength
		statRaise = math.random(1,2)
		stat = "strength"
		player.character.strength = player.character.strength + statRaise
	elseif randIndex == 3 then 
		-- raise xp 
		statRaise = math.random(10,25)
		stat = "xp"
		player.character:incrementXP(statRaise)
	end 

	chestDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (4*32), (screenHeight/2) - (4*32), 9, 8,
		packTextIntoList("you open the", "chest and are", "enveloped in a", "bright light!", "you've gained", "+"..tostring(statRaise)..stat, "press e to close"))
end 

function SceneGameplay:startEnemyDialog()
	enemyDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (10*32) + 32, (screenHeight/2) - (4*32), 20, 8,
		packTextIntoList("'wait!' the lost soul cries out.", "if you spare me, i can heal you.", "you take a moment to consider its", "offer...", "kill the soul for xp", "accept its offer of healing", "select with w/s and press e"),
		5,6)
end

function SceneGameplay:randomHealthRecoveryDialog()
	
	local textList = {}
	local rand = math.random(1,4)
	if rand == 1 then 
		textList = packTextIntoList("you thank the lost soul as it fades", "back into the darkness...", "your soul is filled with warmth.", "press e to close")
	elseif rand == 2 then 
		textList = packTextIntoList("you thank the lost soul as it fades", "back into the darkness...", "you wonder how things are back home.", "press e to close")
	elseif rand == 3 then 
		textList = packTextIntoList("you thank the lost soul as it fades", "back into the darkness...", "everything will be okay.", "press e to close")
	elseif rand == 4 then 
		textList = packTextIntoList("you thank the lost soul as it fades", "back into the darkness...", "you recall a pleasant memory...", "press e to close")
	end 

	chestDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (10*32) + 32, (screenHeight/2) - (4*32), 20, 8,
		textList)
end


-- this should change messages based on whether you've been killing or sparing enemies
function SceneGameplay:nextFloorDialog()
	local textList = {}
	local rand = math.random(1,5)
	if rand == 1 then 
		textList = packTextIntoList("you've descended another floor below", "the surface.", "you wonder how long it's been.", "how deep do these caverns go...", "press e to close")
	elseif rand == 2 then 
		textList = packTextIntoList("you've descended another floor below", "the surface.", "you shiver in darkness as your", "torch lights up your surroundings.", "press e to close")
	elseif rand == 3 then 
		textList = packTextIntoList("you've descended another floor below", "the surface.", "you question if this was the right", "thing to do...", "press e to close")
	elseif rand == 4 then 
		textList = packTextIntoList("you've descended another floor below", "the surface.", "you recall the warmth of home.", "the feeling quickly fades.", "press e to close")
	elseif rand == 5 then 
		textList = packTextIntoList("you've descended another floor below", "the surface.", "you step on something unpleasant and", "unmoving.", "you do not look down.", "you must continue.", "press e to close")
	end  

	chestDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (10*32) + 32, (screenHeight/2) - (4*32), 20, 8,
		textList)
end

function SceneGameplay:randomKillDialog()
	local textList = {}
	local rand = math.random(1,4)
	if rand == 1 then 
		textList = packTextIntoList("the lost soul lets out a sad sound", "as you strike it down...", "you wonder if they feel pain...", "press e to close")
	elseif rand == 2 then 
		textList = packTextIntoList("the lost soul lets out a sad sound", "as you strike it down...", "you remember an unpleasant memory...", "press e to close")
	elseif rand == 3 then 
		textList = packTextIntoList("the lost soul lets out a sad sound", "as you strike it down...", "your memory becomes hazy for a moment.", "you had forgotten something important.", "press e to close")
	elseif rand == 4 then 
		textList = packTextIntoList("the lost soul lets out a sad sound", "as you strike it down...", "you feel your stomach begin to knot.", "your chest tightens.", "but only for a moment.", "press e to close")
	end 

	chestDialogPopup = SceneOkBox:new(
		(screenWidth/2) - (10*32) + 32, (screenHeight/2) - (4*32), 20, 8,
		textList)
end 

function SceneGameplay:newGame()
	weaponTriangle = WeaponTriangle:new()
	camera = Camera:new()
	camera.scale = 1.5
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
		if rand < 50 then 
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

	drawText("-player info-", 2, screenHeight - 192)
	drawText("bfloor:"..tostring(currentFloor), 2, screenHeight - 160)
	drawText("lvl:"..tostring(playerController.character.level), 2, screenHeight - 128)
	drawText("hp:"..tostring(playerController.character.health).."/"..tostring(playerController.character.maxHealth), 2, screenHeight - 96)
	drawText("xp:"..tostring(playerController.character.currentXP).."/"..tostring(playerController.character.nextLevelXP), 2, screenHeight - 64)
	resetColor()

end 


--[[function love.wheelmoved(x,y)
	if camera.scale + (y * 0.25) < 0.5 then return end 
	camera.scale = camera.scale + (y * 0.25)
	scaleModified()
end ]]

function scaleModified()
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