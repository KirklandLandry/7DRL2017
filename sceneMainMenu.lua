
-- this is no longer a scene. rename it.

SceneMainMenu = {}
function SceneMainMenu:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self


	o.titleImage = love.graphics.newImage("assets/gfx 16x16/title.png")
	o.enemyTilesetImage = love.graphics.newImage("assets/gfx 16x16/NPC_test wide 64x64.png")
	o.enemyTilesetImage:setFilter("nearest", "nearest")
	local tw, th = o.enemyTilesetImage:getWidth(), o.enemyTilesetImage:getHeight()
	local enemyTileSize = 64
	o.enemyTileSize = enemyTileSize
	o.enemyTilesetQuads = {}
	o.enemyTilesetQuads[1] = {}
	for i=1,4 do
		o.enemyTilesetQuads[1][i] = love.graphics.newQuad((i-1) * enemyTileSize, 0 * enemyTileSize, enemyTileSize, enemyTileSize, tw, th)
	end
	o.enemyTilesetQuads[2] = {}
	for i=1,4 do
		o.enemyTilesetQuads[2][i] = love.graphics.newQuad((i-1) * enemyTileSize, 1 * enemyTileSize, enemyTileSize, enemyTileSize, tw, th)
	end
	o.enemyTilesetQuads[3] = {}
	for i=1,4 do
		o.enemyTilesetQuads[3][i] = love.graphics.newQuad((i-1) * enemyTileSize, 2 * enemyTileSize, enemyTileSize, enemyTileSize, tw, th)
	end
	o.enemyTilesetQuads[4] = {}
	for i=1,4 do
		o.enemyTilesetQuads[4][i] = love.graphics.newQuad((i-1) * enemyTileSize, 3 * enemyTileSize, enemyTileSize, enemyTileSize, tw, th)
	end

	o.addEnemyTimer = Timer:new(0.2, TimerModes.repeating)
	o.addEnemyTimer:forceEnd()


	o.enemyList = {}


	o.minX = 0
	o.minY = 0
	o.maxX = screenWidth - enemyTileSize
	o.maxY = screenHeight - enemyTileSize

	o.bgm = love.audio.play("assets/audio/darkest deeps title screen.wav", "stream", true)
	return o
end 

function SceneMainMenu:init()

end 

function SceneMainMenu:update(dt)
	for i=#self.enemyList,1,-1 do
		self.enemyList[i].alpha = self.enemyList[i].alpha - 100 * dt
		if self.enemyList[i].animTimer:isComplete(dt) then 
			self.enemyList[i].animIndex = self.enemyList[i].animIndex + 1
			if self.enemyList[i].animIndex > 4 then 
				self.enemyList[i].animIndex = 1
			end 
		end 
		if self.enemyList[i].alpha <= 0 then
			table.remove(self.enemyList, i)
		end
	end
	if self.addEnemyTimer:isComplete(dt) then 
		self:addEnemy()
	end 

	if not self.bgm:isPlaying() then 
		self.bgm = love.audio.play("assets/audio/darkest deeps title screen.wav", "stream", true)
	end 

	if getKeyDown("e") then 
		love.audio.stop(self.bgm)
		local gameplay = SceneGameplay:new()
		gameplay:init()
		sceneStack:push(gameplay)
	end 

end 

function SceneMainMenu:draw()
	for i=1,#self.enemyList do
		love.graphics.setColor(255,255,255,self.enemyList[i].alpha)
		love.graphics.draw(self.enemyTilesetImage, self.enemyTilesetQuads[self.enemyList[i].quadIndex][self.enemyList[i].animIndex], self.enemyList[i].x, self.enemyList[i].y)
	end
	resetColor()
	love.graphics.draw(self.titleImage, (screenWidth/2) - (self.titleImage:getWidth()/2) - 4, (screenHeight/2) - (self.titleImage:getHeight()/2) - (screenHeight/4) )

	drawMenu( (screenWidth/2) - (4.5 * 32) - 4, (screenHeight/2) - (self.titleImage:getHeight()/2) - (screenHeight/4) + self.titleImage:getHeight() + 32,
		9,2, packTextIntoList("press e to start"))
end 

function SceneMainMenu:addEnemy()
	local newEnemy = {
		animIndex = 1,
		quadIndex = math.random(1,4),
		animTimer = Timer:new(0.15, TimerModes.repeating),
		x = math.random(self.minX, self.maxX),
		y = math.random(self.minY, self.maxY),
		alpha = 255
	}
	table.insert(self.enemyList, newEnemy)
end 