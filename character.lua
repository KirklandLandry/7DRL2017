Character = {}
function Character:new(x, y, health, weaponAttribute)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.level = 1
	o.x = x 
	o.y = y
	o.health = health
	o.maxHealth = health
	o.weaponAttribute = weaponAttribute
	o.strength = 1
	o.strengthRange = 4
	o.currentXP = 0
	o.nextLevelXP = 50
	return o
end 

function Character:adjustToLevel(lvl, floor)
	self.level = lvl + floor
	self.health = self.health + lvl + floor
	self.maxHealth = self.maxHealth + lvl + floor
	self.strength = self.strength + ((lvl + floor)/2)
end

function Character:move(xInc,yInc)
	self.x = self.x + xInc 
	self.y = self.y + yInc
end 

function Character:getDamage(multiplier)
	return (math.random(self.strength, self.strength + self.strengthRange) * multiplier)
end 

function Character:lowerHealth(amount)
	self.health = self.health - amount
end 

function Character:recoverHealth(amount)
	self.health = self.health - amount
	if self.health > self.maxHealth then self.health = self.maxHealth end
end

EnemyType = {log = "log", npc = "npc"}

function Character:incrementXP(enemyType)

	if enemyType == EnemyType.log then 
		self.currentXP = self.currentXP + math.random(10, 15)
	elseif enemyType == EnemyType.npc then 
		self.currentXP = self.currentXP + math.random(25, 35)
	else 
		self.currentXP = self.currentXP + enemyType
	end 

	-- if you leveled up 
	if self.currentXP >= self.nextLevelXP then 
		-- reset xp counter
		self.currentXP = self.currentXP - self.nextLevelXP
		self.nextLevelXP = self.nextLevelXP + 5
		-- increase health 
		local hpInc = math.random(1, 3)
		self.maxHealth = self.maxHealth + hpInc
		-- recover some health and recover whatever your health incremented from the level up
		self.health = self.health + hpInc + math.random(0,5)
		if self.health > self.maxHealth then self.health = self.maxHealth end
		-- increase damage 
		self.strength = self.strength + math.random(1,2)
		-- increase level
		self.level = self.level + 1
	end 
end 