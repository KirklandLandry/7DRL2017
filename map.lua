local blackTile = love.graphics.newImage("assets/gfx 32x32/black.png")
--local stairTile = love.graphics.newImage("assets/gfx 32x32/stairway 32x32.png")
local tilesetImage
local tilesetQuads
local tilesetBatch

Map = {}
function Map:new(mapWidth, mapHeight, tileSize, camera)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	-- map variables
	o.data = {}
	o.shadowData = {}
	o.width = mapWidth 
	o.height = mapHeight 
	o.fillCode = 1 
	o.emptyCode = 0
	o.minShadow = 1 
	o.maxShadow = 253
	o.tileSize = tileSize
	o.stairway = nil
	o.chestList = nil

	tilesetImage = love.graphics.newImage("assets/gfx 32x32/cave.png")
	tilesetImage:setFilter("nearest", "nearest")
	tilesetQuads = {}


	tilesetQuads["floor"] = love.graphics.newQuad(0 * tileSize, 0 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["walls"] = {}
	
	tilesetQuads["walls"].topLeft = love.graphics.newQuad(11 * tileSize, 4 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())
	
	tilesetQuads["walls"].topMid = love.graphics.newQuad(12 * tileSize, 4 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["walls"].topRight = love.graphics.newQuad(13 * tileSize, 4 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["walls"].midLeft = love.graphics.newQuad(11 * tileSize, 5 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())
	
	tilesetQuads["walls"].midMid = love.graphics.newQuad(12 * tileSize, 5 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["walls"].midRight = love.graphics.newQuad(13 * tileSize, 5 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["walls"].bottomLeft = love.graphics.newQuad(11 * tileSize, 6 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())
	
	tilesetQuads["walls"].bottomMid = love.graphics.newQuad(12 * tileSize, 6 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["walls"].bottomRight = love.graphics.newQuad(13 * tileSize, 6 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["walls"].topBottom = love.graphics.newQuad(11 * tileSize, 7 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["walls"].leftRight = love.graphics.newQuad(12 * tileSize, 7 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["walls"].allEdge = love.graphics.newQuad(5 * tileSize, 4 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["stairway"] = love.graphics.newQuad(13 * tileSize, 7 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())

	tilesetQuads["chestClosed"] = love.graphics.newQuad(14 * tileSize, 7 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())


	tilesetQuads["chestOpened"] = love.graphics.newQuad(15 * tileSize, 7 * tileSize, tileSize, tileSize,
    	tilesetImage:getWidth(), tilesetImage:getHeight())




	local displayWidthInTiles, displayHeightInTiles = camera:getViewportSizeInTiles(tileSize)
  	tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 
  		(displayWidthInTiles + camera.displayBuffer) * (displayHeightInTiles + camera.displayBuffer))


	return o
end 

function Map:generate(width, height)
	self.data = {}
	self.shadowData = {}
	self.width = width 
	self.height = height

	self:initFilled()
	self:tunneler()

	--self:placeStairway()
end

-- and also place T R E A S U R E 
function Map:placeStairway(cx, cy)
	--local rx, ry = self:getRandPosition(self.tileSize)
	local rx, ry = self:getRandPositionExcludingRadius(self.tileSize, nil, 10, cx, cy)
	local tx, ty = self:getTilePosFromWorldPos(rx, ry, self.tileSize)
	self.stairway = {
		tileX = tx,
		tileY = ty,
		worldX = rx,
		worldY = ry
	}


	self.chestList = {}
	--tilesetQuads["chest"]

	local cardinal = {}
	cardinal[1] = {x = 0, y = 1}
	cardinal[2] = {x = 0, y = -1}
	cardinal[3] = {x = 1, y = 0}
	cardinal[4] = {x = -1, y = 0}

	local listOfPossibleChestPlacements = {}

	--local breakout = false
  	for iy=2,self.height-2 do
  		for ix=2,self.width-2 do
			local emptyCounter = 0
			if self.data[iy][ix] == self.emptyCode and (ix ~= tx and iy ~= ty) and (ix ~= cx and iy ~= cy) then
				for i=1,#cardinal do
					if self.data[iy + cardinal[i].y][ix + cardinal[i].x] == self.fillCode then 
						emptyCounter = emptyCounter + 1
					end 	
				end
				if emptyCounter == 3 then 
					table.insert(listOfPossibleChestPlacements, {tileX = ix, tileY = iy, opened = false})
				end
			end
			--if #self.chestList > 6 then breakout = true break end 
  		end 
  		--if breakout then break end
  	end 

  	for i=1,6 do
  		local randIndex = math.random(1, #listOfPossibleChestPlacements)
  		table.insert(self.chestList, listOfPossibleChestPlacements[randIndex])
  		table.remove(listOfPossibleChestPlacements, randIndex)
  	end


end 

function Map:onStairway(tx, ty)
	if tx == self.stairway.tileX and ty == self.stairway.tileY then 
		return true 
	else 
		return false 
	end 
end 

function Map:onChest( tx, ty )
	for i=#self.chestList,1,-1 do
		if tx == self.chestList[i].tileX and ty == self.chestList[i].tileY and self.chestList[i].opened == false then 
			self.chestList[i].opened = true
			--table.remove(self.chestList,i)
			return true 
		end
	end
	return false
end

--[[function Map:drawStairway()
	love.graphics.draw(stairTile, , y)
end ]]

function Map:initEmpty()
	for y=1,self.height do
		self.data[y] = {}
		self.shadowData[y] = {}
		for x=1,self.width do
			-- ensure border
			if(x == 1 or x == self.width or y == 1 or y == self.height) then 
				self.data[y][x] = self.fillCode
			else 
				self.data[y][x] = self.emptyCode
			end 
			-- init to pitch black 
			self.shadowData[y][x] = self.maxShadow
		end		
	end
end 

function Map:checkForElement(list, element)
	for i=1,#list do
		if list[i].x == element.x and list[i].y == element.y then 
			return true 
		end 
	end
	return false
end 

function Map:illuminate(range, ix, iy)
	local positionsToVisit = Queue:new()
	local visitedNodes = {}

	positionsToVisit:enqueue({x = ix, y = iy, dist = 0})

	local cardinal = {}
	cardinal[1] = {x = 0, y = 1}
	cardinal[2] = {x = 0, y = -1}
	cardinal[3] = {x = 1, y = 0}
	cardinal[4] = {x = -1, y = 0}

	while(not positionsToVisit:isEmpty()) do
		local current = positionsToVisit:dequeue()
		if(not self:checkForElement(visitedNodes, current) and current.dist <= range) then 
			table.insert(visitedNodes, current)
			if(self.shadowData[current.y][current.x] > self.minShadow) then 
				self.shadowData[current.y][current.x] = self.shadowData[current.y][current.x] - 13
				if self.shadowData[current.y][current.x]  < self.minShadow then 
					self.shadowData[current.y][current.x] = self.minShadow
				end 
			end 
			for i=1,4 do
				local mx = current.x + cardinal[i].x
				local my = current.y + cardinal[i].y
				if not self:outOfBounds(mx, my) then 
					positionsToVisit:enqueue({x = mx, y = my, dist = current.dist + 1})
				end 
			end
		end 
	end 
	-- just really make sure it doesn't go below 0.
	-- bad, but I'm lazy right now
	for y=1,self.height do
		for x=1,self.width do
			if self.shadowData[y][x] < self.minShadow then 
				self.shadowData[y][x] = self.minShadow
			end 
			if self.shadowData[y][x] > self.maxShadow then 
				self.shadowData[y][x] = self.maxShadow
			end 
		end 
	end 

end 

function Map:initFilled()
	for y=1,self.height do
		self.data[y] = {}
		self.shadowData[y] = {}
		for x=1,self.width do
			self.data[y][x] = self.fillCode
			-- init to pitch black 
			self.shadowData[y][x] = self.maxShadow
		end		
	end
end 


function Map:tunneler()	
	local currentX = math.random(2, self.width-1)
	local currentY = math.random(2, self.height-1)

	local cardinal = {}
	cardinal[1] = {x = 0, y = 1}
	cardinal[2] = {x = 0, y = -1}
	cardinal[3] = {x = 1, y = 0}
	cardinal[4] = {x = -1, y = 0}

	for i=1, math.floor(self.width * self.height / 2) do 
		self.data[currentY][currentX] = self.emptyCode 

		-- so this can end up modifying cardinal because of the inverses below, which is fine because it results in cool patterns
		local dir = cardinal[math.random(1,4)]

		-- flip x if it's going out of bounds 
		if currentX + dir.x <= 1 or currentX + dir.x >= self.width then 
			dir.x = dir.x * -1 
		end 
		-- flip y if it's going out of bounds 
		if currentY + dir.y <= 1 or currentY + dir.y >= self.height then 
			dir.y = dir.y * -1 
		end 
		
		--[[print("cardinal")
		for i=1,4 do
			print(cardinal[i].x, cardinal[i].y)		
		end
		print()]]
		
		--[[if self.data[(currentY + dir.y)][(currentX + dir.x)] ~= self.fillCode then 		
		end ]] 
		currentX, currentY = (currentX + dir.x), (currentY + dir.y)
	end 

	-- resetting cardinal so it works properly 
	cardinal = {}
	cardinal[1] = {x = 0, y = 1}
	cardinal[2] = {x = 0, y = -1}
	cardinal[3] = {x = 1, y = 0}
	cardinal[4] = {x = -1, y = 0}

	-- remove single tiles 
	for y=2,self.height-1 do
		for x=2,self.width-1 do	
			local tileCounter = 0
			for i=1,4 do
				if self.data[y][x] == self.fillCode and self.data[y + cardinal[i].y][x + cardinal[i].x] == self.emptyCode then 
					tileCounter = tileCounter + 1
				end  
			end
			if tileCounter == 4 then 
				self.data[y][x] = self.emptyCode 
			end 
		end 
	end 
end 

-- +1 because lua indexing
function Map:getTilePosFromWorldPos(wx, wy, tileSize)
	return (math.floor(wx/tileSize)+1), (math.floor(wy/tileSize)+1)
end

function Map:getWorldPosFromTilePos(tx, ty, tileSize)
	return ((tx-1)*tileSize), ((ty-1)*tileSize)
end

function Map:canMove(x,y)
	if self:outOfBounds(x,y) then return false end 	
	if self.data[y][x] == self.fillCode then return false else return true end 
end 

function Map:outOfBounds(x, y, edgeValue)
	--[[if edgeValue then 
		assert(edgeValue > 0 and edgeValue < self.width, "edge value must be within map bounds")
	end 
	local edge = edgeValue or 1]]
	--if x <= edge or x >= self.width - edge or y <= edge or y >= self.height - edge then 
	if x < 1 or x > self.width or y < 1 or y > self.height then 
		return true 
	else 
		return false 
	end 
end 

function Map:getRandPosition(tileSize)
  	local tileList = {}
  	for iy=1,self.height do
  		for ix=1,self.width do
			if self.data[iy][ix] == self.emptyCode then 
				table.insert(tileList, {x = ix, y = iy})
			end 
  		end	
  	end
	local randIndex = math.random(1, #tileList)
	return self:getWorldPosFromTilePos(tileList[randIndex].x, tileList[randIndex].y, tileSize)	
end 

-- cx and cy must be tile positions
function Map:getRandPositionExcludingRadius(tileSize, list, radius, cx, cy)
  	local tileList = {}
  	for iy=1,self.height do
  		for ix=1,self.width do
			if self.data[iy][ix] == self.emptyCode then 
				if math.sqrt(math.pow(ix - cx,2) + math.pow(iy - cy, 2)) > radius then 
						
					local canInsert = true 
					if list ~= nil and #list >= 1 then 
						for i=1,#list do
							local charX, charY = self:getTilePosFromWorldPos(list[i].character.x, list[i].character.y, tileSize)
							if charX == ix and charY == iy then 
								canInsert = false
								break
							end 
						end
					end  
					if canInsert then 
						table.insert(tileList, {x = ix, y = iy})
					end 
				end 
			end 
  		end	
  	end
	local randIndex = math.random(1, #tileList)
	return self:getWorldPosFromTilePos(tileList[randIndex].x, tileList[randIndex].y, tileSize)	
end 



function Map:drawShadow(camera, tileSize, firstTileX, firstTileY)
	resetColor()
	local displayWidthInTiles, displayHeightInTiles = camera:getViewportSizeInTiles(tileSize)
	for y=1,(displayHeightInTiles + camera.displayBuffer) do
		-- for display width + buffer amount
		for x=1,(displayWidthInTiles + camera.displayBuffer) do
			-- don't draw tiles out of array bounds
			if not self:outOfBounds(x + firstTileX, y + firstTileY) then
				local ox, oy = camera:getInverseOffsetIntoCurrentTile(tileSize)
				love.graphics.setColor(255,255,255,self.shadowData[y+ firstTileY][x+ firstTileX])
				love.graphics.draw(blackTile, ((x-1)*tileSize) + ox, ((y-1)*tileSize) + oy)
			end 
		end	
	end
	resetColor()
end 

function Map:updateMapSpritebatch(firstTileX, firstTileY, camera, tileSize)
	updateMapSpritebatch(firstTileX, firstTileY, tilesetBatch, camera, tileSize, self)
end 

-- want this global for drawing minimap later
function updateMapSpritebatch(firstTileX, firstTileY, spritebatch, camera, tileSize, currentMap)
	spritebatch:clear()
	local displayWidthInTiles, displayHeightInTiles = camera:getViewportSizeInTiles(tileSize)
	--local tileDrawCount = 0
	-- for display height + buffer amount 
	for y=1,(displayHeightInTiles + camera.displayBuffer) do
		-- for display width + buffer amount
		for x=1,(displayWidthInTiles + camera.displayBuffer) do
			-- don't draw tiles out of array bounds
			if not currentMap:outOfBounds(x + firstTileX, y + firstTileY) then
				
				if y + firstTileY == currentMap.stairway.tileY and x + firstTileX == currentMap.stairway.tileX then

					spritebatch:add(tilesetQuads["stairway"], 
						((x-1)*tileSize), 
						((y-1)*tileSize))


				elseif currentMap.data[y + firstTileY][x + firstTileX] == currentMap.emptyCode then 
					spritebatch:add(tilesetQuads["floor"], 
						((x-1)*tileSize), 
						((y-1)*tileSize))
				else 
					local drawX, drawY = (x + firstTileX), (y + firstTileY - 1)
					local quadToAdd = nil 
					if not currentMap:outOfBounds(drawX, drawY) and 
						(currentMap.data[drawY][drawX] == currentMap.emptyCode) then 
						quadToAdd = tilesetQuads["walls"].topMid
					else 
						quadToAdd = tilesetQuads["walls"].midMid
					end 
					if quadToAdd ~= nil then 
						spritebatch:add(quadToAdd, ((x-1)*tileSize), ((y-1)*tileSize))
					end 
				end 


				-- god this is just the worse isn't it. 
				-- map drawing should be seperated. map should just be raw data so it's reusable
				local isChest = false
				local isChestOpened = false
				for i=#currentMap.chestList,1,-1 do
					if x + firstTileX == currentMap.chestList[i].tileX and y + firstTileY == currentMap.chestList[i].tileY then 
						isChest = true 
						if currentMap.chestList[i].opened then 
							isChestOpened = true
						end 
						break
					end
				end

				if isChest then 
					if isChestOpened then 		 
						spritebatch:add(tilesetQuads["chestOpened"], 
							((x-1)*tileSize), 
							((y-1)*tileSize))
					else 
						spritebatch:add(tilesetQuads["chestClosed"], 
							((x-1)*tileSize), 
							((y-1)*tileSize))
					end
				end

				--tileDrawCount = tileDrawCount + 1 
			end 
		end	
	end
	spritebatch:flush()	
	--print(tileDrawCount)
end 

function Map:draw(x,y)
	love.graphics.draw(tilesetBatch, x,y)
end 

function Map:resizeSpritebatch(camera, tileSize)
	local displayWidthInTiles, displayHeightInTiles = camera:getViewportSizeInTiles(tileSize)
	tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 
  		(displayWidthInTiles + camera.displayBuffer) * (displayHeightInTiles + camera.displayBuffer))
end 