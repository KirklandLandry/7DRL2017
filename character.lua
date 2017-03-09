Character = {}
function Character:new(x, y, health, weaponAttribute)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
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

EnemyType = {log = "log", npc = "npc"}

function Character:incrementXP(enemyType)
	if enemyType == EnemyType.log then 
		self.currentXP = self.currentXP + math.random(10, 15)
	elseif enemyType == EnemyType.npc then 
		self.currentXP = self.currentXP + math.random(15, 20)
	end 

	-- if you leveled up 
	if self.currentXP >= self.nextLevelXP then 
		-- reset xp counter
		self.currentXP = self.currentXP - self.nextLevelXP
		self.nextLevelXP = self.nextLevelXP + 5
		-- recover some health
		self.health = self.health + math.random(5,8)
		if self.health > self.maxHealth then self.health = self.maxHealth end
		-- increase damage 
		self.strength = self.strength + math.random(1,3)
		-- maybe increase health 
		self.maxHealth = self.maxHealth + math.random(0, 3)
	end 
end 