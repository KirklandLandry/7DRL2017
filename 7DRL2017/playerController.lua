local pTileSize = 32
PlayerController = {}
function PlayerController:new(x, y)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.character = Character:new(x,y, 50, weaponTriangle:getRandomAttribute())
	o.moveTimer = Timer:new(0.15, TimerModes.repeating)
	o.prevDir = nil
	o.animDir = MoveDirs.down

	o.tilesetImage = love.graphics.newImage("assets/gfx 32x32/player.png")
	local tw, th = o.tilesetImage:getWidth(), o.tilesetImage:getHeight()
	o.tilesetImage:setFilter("nearest", "nearest")
	

	o.tilesetQuads = {}

	o.tilesetQuads[MoveDirs.down] = {}
	for i=1,4 do
		o.tilesetQuads[MoveDirs.down][i] = love.graphics.newQuad((i-1) * pTileSize, 0 * pTileSize, pTileSize, pTileSize, tw, th)
	end
	o.tilesetQuads[MoveDirs.right] = {}
	for i=1,4 do
		o.tilesetQuads[MoveDirs.right][i] = love.graphics.newQuad((i-1) * pTileSize, 1 * pTileSize, pTileSize, pTileSize, tw, th)
	end
	o.tilesetQuads[MoveDirs.up] = {}
	for i=1,4 do
		o.tilesetQuads[MoveDirs.up][i] = love.graphics.newQuad((i-1) * pTileSize, 2 * pTileSize, pTileSize, pTileSize, tw, th)
	end
	o.tilesetQuads[MoveDirs.left] = {}
	for i=1,4 do
		o.tilesetQuads[MoveDirs.left][i] = love.graphics.newQuad((i-1) * pTileSize, 3 * pTileSize, pTileSize, pTileSize, tw, th)
	end
	
	o.animIndex = 1
	o.animTimer = Timer:new(0.15, TimerModes.repeating)

	return o
end 

function PlayerController:incAnimIndex()
	self.animIndex = self.animIndex + 1 
	if self.animIndex > 4 then 
		self.animIndex = 1 
	end 
end 

function PlayerController:draw(tileSize, roundedCameraX, roundedCameraY)
	--love.graphics.setColor(255, 255, 255, 100)
	love.graphics.draw(self.tilesetImage, self.tilesetQuads[self.animDir][1], math.floor(self.character.x) - roundedCameraX, math.floor(self.character.y) - roundedCameraY)
	--love.graphics.setColor(255, 255, 255, 255)
end 

function PlayerController:attack(enemyIndex, enemyList)
	local multiplier = weaponTriangle:getDamageMultiplier(self.character.weaponAttribute, enemyList[enemyIndex].character.weaponAttribute) 
	local dmg = self.character:getDamage(multiplier)
	enemyList[enemyIndex].character:lowerHealth(dmg)

	local conversationStarted = false

	if enemyList[enemyIndex].character.health <= 0 then 
		if enemyList[enemyIndex].enemyType == EnemyType.npc then 
			local conversationChance = math.random(0,100)
			-- the chance to initiate dialog
			if conversationChance > 63 then 
				conversationStarted = true 
			else 
				self.character:incrementXP(enemyList[enemyIndex].enemyType)
			end 
		else 
			self.character:incrementXP(enemyList[enemyIndex].enemyType)
		end
	end 
	if not conversationStarted then 
		table.insert(damageTextList, {x = enemyList[enemyIndex].character.x, y = enemyList[enemyIndex].character.y - 16, damage = dmg, alpha = 255})
	end 
	return conversationStarted
end 

function PlayerController:collisionCheck(playerTileX, playerTileY, xShift, yShift, tileSize, currentMap, enemyList)
	local moved = false
	local attacked = false
	local conversationStarted = false
	-- check for collision with walls
	if currentMap:canMove(playerTileX + xShift, playerTileY + yShift) then 
		-- check for collision with enemy
		for i=1,#enemyList do
			local ex, ey = currentMap:getTilePosFromWorldPos(enemyList[i].character.x, enemyList[i].character.y, tileSize)
			if playerTileX + xShift == ex and playerTileY + yShift == ey then 
				-- initiate battle here
				conversationStarted = self:attack(i, enemyList)
				attacked = true
				return moved, attacked, conversationStarted
			end 
		end
		self.character:move(tileSize * xShift, tileSize * yShift)
		moved = true
	end
	return moved, attacked, conversationStarted
end 

function PlayerController:setDirs(newDir)
	self.prevDir = newDir
	self.animDir = newDir
end 

-- returns true or false if player moved to indicate if enemies can move 
-- can move quicker when spamming diagonal if the else is there. should fix that. removed for now.
function PlayerController:update(tileSize, dt, currentMap, enemyList)
	local moved = false
	local attacked = false
	local conversationStarted = false
	local playerTileX, playerTileY = currentMap:getTilePosFromWorldPos(self.character.x, self.character.y, tileSize)
	if getKeyDown( "w" ) then
		if self.prevDir == MoveDirs.up then
			if self.moveTimer:isComplete(dt) then 
				moved, attacked, conversationStarted = self:collisionCheck(playerTileX, playerTileY, 0, -1, tileSize, currentMap, enemyList)
			end	  
		end 
		self:setDirs(MoveDirs.up)
	elseif getKeyDown( "s" ) then
		if self.prevDir == MoveDirs.down then
			if self.moveTimer:isComplete(dt) then 
				moved, attacked, conversationStarted = self:collisionCheck(playerTileX, playerTileY, 0, 1, tileSize, currentMap, enemyList)
			end	  
		end 
		self:setDirs(MoveDirs.down)
	elseif getKeyDown( "a" ) then
		if self.prevDir == MoveDirs.left then
			if self.moveTimer:isComplete(dt) then 
				moved, attacked, conversationStarted = self:collisionCheck(playerTileX, playerTileY, -1, 0, tileSize, currentMap, enemyList)
			end	  
		end 
		self:setDirs(MoveDirs.left)
	elseif getKeyDown( "d" ) then
		if self.prevDir == MoveDirs.right then
			if self.moveTimer:isComplete(dt) then 
				moved, attacked, conversationStarted = self:collisionCheck(playerTileX, playerTileY, 1, 0, tileSize, currentMap, enemyList)
			end	  
		end 
		self:setDirs(MoveDirs.right)
	else 
		self.prevDir = nil
		self.moveTimer:forceEnd()
	end 

	if self.prevDir ~= nil and self.animTimer:isComplete(dt) then 
		self:incAnimIndex()
	elseif self.prevDir == nil then 
		self.animTimer:reset()
	end 

	--[[if moved then 
		love.audio.play("assets/audio/steps/mud02.ogg", "static", false, 0.60)
	end ]]

	if attacked then 
		love.audio.play("assets/audio/hit.wav", "static", false, 0.30)
	end 

	return moved, attacked, conversationStarted
end 