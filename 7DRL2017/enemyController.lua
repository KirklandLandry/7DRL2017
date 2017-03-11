--local eTileSize = 32
EnemyType = {log = "log", npc = "npc"}
EnemyController = {}
function EnemyController:new(health, enemyType, x, y)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	if enemyType == EnemyType.log then 
		o.character = Character:new(x, y, 10, AttributeTypes.null)
		o.character.strengthRange = 2
	else 
		o.character = Character:new(x, y, 10, weaponTriangle:getRandomAttribute())
	end 
	
	o.moveTimer = Timer:new(0.15, TimerModes.repeating)
	--o.prevDir = nil
	o.enemyType = enemyType

	o.logTilesetImage = love.graphics.newImage("assets/gfx 16x16/log.png")
	o.logTilesetImage:setFilter("nearest", "nearest")
	local tw, th = o.logTilesetImage:getWidth(), o.logTilesetImage:getHeight()
	local logTileSize = 32 
	o.logTilesetQuads = {}
	o.logTilesetQuads[MoveDirs.down] = {}
	for i=1,4 do
		o.logTilesetQuads[MoveDirs.down][i] = love.graphics.newQuad((i-1) * logTileSize, 0 * logTileSize, logTileSize, logTileSize, tw, th)
	end

	o.npcTilesetImage = love.graphics.newImage("assets/gfx 16x16/NPC_test wide.png")
	o.npcTilesetImage:setFilter("nearest", "nearest")
	local tw, th = o.npcTilesetImage:getWidth(), o.npcTilesetImage:getHeight()
	local npcTileWidth = 32
	local npcTileHeight = 32
	o.npcTilesetQuads = {}
	o.npcTilesetQuads[MoveDirs.down] = {}
	for i=1,4 do
		o.npcTilesetQuads[MoveDirs.down][i] = love.graphics.newQuad((i-1) * npcTileWidth, 0 * npcTileHeight, npcTileWidth, npcTileHeight, tw, th)
	end

	o.animIndex = 1
	o.animTimer = Timer:new(0.15, TimerModes.repeating)

	return o
end 


function inRangeOfPlayer(enemyTileX, enemyTileY, playerTileX, playerTileY, range)
	return (math.sqrt(math.pow(enemyTileX - playerTileX,2) + math.pow(enemyTileY - playerTileY, 2)) <= range)
end 

function EnemyController:update(dt, playerMoved, playerAttacked, currentMap, player, tileSize, enemyList)
	-- can't update if you're dead
	if self.character.health <= 0 then return end 

	if(self.animTimer:isComplete(dt)) then 
		self.animIndex = self.animIndex + 1 
		if self.animIndex > 4 then 
			self.animIndex = 1 
		end 
	end 

	-- player and enemy tile positions
	local etx, ety = currentMap:getTilePosFromWorldPos(self.character.x,self.character.y, tileSize)
	local ptx, pty = currentMap:getTilePosFromWorldPos(player.character.x, player.character.y, tileSize)

	if inRangeOfPlayer(etx, ety, ptx, pty, 1) and (playerAttacked) then 
		-- attack the player 
		local multiplier = weaponTriangle:getDamageMultiplier(self.character.weaponAttribute, player.character.weaponAttribute) 
		local damage = self.character:getDamage(multiplier) 
		player.character:lowerHealth(damage)
	end 

	if playerMoved then 
		if inRangeOfPlayer(etx, ety, ptx, pty, 4) then 
			-- move towards player
			local mvx = math.sign(ptx - etx)
			local mvy = math.sign(pty - ety)
			if math.abs(mvx) > math.abs(mvy) then 
				mvy = 0 
			elseif math.abs(mvy) > math.abs(mvx) then 
				mvx = 0
			else 
				local chance = math.random(0, 100)
				if chance > 50 then 
					mvx = 0 
				else 
					mvy = 0
				end 
			end 
			self:collisionCheck(etx, ety, ptx, pty, mvx, mvy, tileSize, currentMap, enemyList, player)
		elseif inRangeOfPlayer(etx, ety, ptx, pty, 10) then 
			-- move randomly 
			local rx, ry = math.random(-1, 1), math.random(-1,1)
			local chance = math.random(0, 100)
			if chance > 50 then 
				mvx = 0 
			else 
				mvy = 0
			end 
			self:collisionCheck(etx, ety, ptx, pty, rx, ry, tileSize, currentMap, enemyList, player)
		end 	
	end 

end 

function EnemyController:draw(tileSize, camera)
	local relx, rely = camera:getRelativePositionFromCharacter(self.character)

	if self.enemyType == EnemyType.log then
		love.graphics.draw(self.logTilesetImage, self.logTilesetQuads[MoveDirs.down][self.animIndex], relx, rely)
	elseif self.enemyType == EnemyType.npc then  
		love.graphics.draw(self.npcTilesetImage, self.npcTilesetQuads[MoveDirs.down][self.animIndex], relx, rely)	
	end
	love.graphics.setColor(255, 255, 255, 240)
	weaponTriangle:drawAttribute(relx + 8, rely + 8, self.character.weaponAttribute, true)
	love.graphics.setColor(255, 255, 255, 255)
end 

function EnemyController:collisionCheck(enemyTileX, enemyTileY, playerTileX, playerTileY, xShift, yShift, tileSize, currentMap, enemyList, player)
	local moved = false
	-- check for collision with enemy
	for i=1,#enemyList do
		local ex, ey = currentMap:getTilePosFromWorldPos(enemyList[i].character.x, enemyList[i].character.y, tileSize)
		if enemyTileX + xShift == ex and enemyTileY + yShift == ey then 
			return moved 
		end 
	end
	-- check for collision with walls
	if currentMap:canMove(enemyTileX + xShift, enemyTileY + yShift) then 
		-- don't move into the player 
		if enemyTileX + xShift ~= playerTileX or enemyTileY + yShift ~= playerTileY then 
			self.character:move(tileSize * xShift, tileSize * yShift)
			moved = true
		end  
	end
	return moved
end 