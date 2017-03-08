Camera = {}
function Camera:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	-- variables 
	o.x = 0
	o.y = 0
	o.scale = 1
	o.displayBuffer = 2
	o.prevTileX = 0
	o.prevTileY = 0
	-- need gameobject system for this to work. 
	-- need unified objects so they're trackable
	--[[target = {
		x = 0,
		y = 0,
		active = false
	}]]

	return o
end 

-- returns viewport size in tiles, accounts for scaling 
function Camera:getViewportSizeInTiles(tileSize)
	local displayWidthInTiles = screenWidth / tileSize / self.scale
	local displayHeightInTiles = screenHeight / tileSize / self.scale
	--print(displayWidthInTiles, displayHeightInTiles)
	return displayWidthInTiles, displayHeightInTiles
end 

function Camera:getTilePos(tileSize)
	local roundedCameraX, roundedCameraY = self:getRoundedPosition()
	return math.floor(roundedCameraX / tileSize), math.floor(roundedCameraY / tileSize)
end 

-- return how many pixels you are into the current tile 
function Camera:getOffsetIntoCurrentTile(tileSize)
	local rx, ry = self:getRoundedPosition() 
	return rx % tileSize, ry % tileSize
end 

-- return how many pixels you are into the current tile 
function Camera:getInverseOffsetIntoCurrentTile(tileSize)
	local rx, ry = self:getRoundedPosition() 
	return (-1 * (rx % tileSize)), (-1 * (ry % tileSize))
end 

-- floored position to prevent jittering when trying to draw in between pixels  
function Camera:getRoundedPosition()
	return math.floor(self.x), math.floor(self.y)
end 

function Camera:centreOnPoint(px, py, pw, ph)
	_ph = ph or pw
	self.x = (px  - (  ((screenWidth / 2)) / self.scale) + (pw / 2 ))
	self.y = (py - (screenHeight / 2 / self.scale) + (_ph / 2 ))
end 

-- lower easing value results in slower movement
function Camera:lerpTowardsPoint(dt, px, py, pw, ph, easingValue)	
	local easingValue = easingValue or 0.07
	local destX = (px - (screenWidth  / 2 / self.scale) + (pw /2))
	local destY = (py - (screenHeight / 2 / self.scale) + (ph/2))
	local mag = math.sqrt(math.pow(destX - self.x, 2) + math.pow(destY - self.y, 2))
	local maxDistance = 1 
	if(mag > maxDistance) then 
		self.x = self.x + ((destX - self.x) * easingValue)
		self.y = self.y + ((destY - self.y) * easingValue)
	end 
end 

function Camera:lockToEdgeBoundary(mapWidth, mapHeight, tileSize)
	if self.x < 0 then self.x = 0 end 
	if self.y < 0 then self.y = 0 end 

	if self.x + (screenWidth / self.scale) > mapWidth * tileSize then 
		self.x = (mapWidth*tileSize) - (screenWidth / self.scale)
	end 

	if self.y + (screenHeight / self.scale) > mapHeight * tileSize then 
		self.y = (mapHeight*tileSize) - (screenHeight / self.scale)
	end 
end 

function Camera:update(dt)
	if self.scale < 0.5 then self.scale = 0.5 end 

end 

--[[function Camera:setTarget(targetObject)
	self.target.x = px
end 
function Camera:setTargetFollow(state)
	self.target.active = state
end ]]

function Camera:moveManually(dt)
	-- camera control
	if getKeyDown( "up" ) then
		self.y = self.y - 700 * dt
	elseif getKeyDown( "down" ) then
		self.y = self.y + 700 * dt
	end
	if getKeyDown( "left" ) then
		self.x = self.x - 700 * dt
	elseif getKeyDown( "right" ) then
		self.x = self.x + 700 * dt
	end
end 