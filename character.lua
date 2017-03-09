Character = {}
function Character:new(x, y, health, weaponAttribute)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	o.x = x 
	o.y = y
	o.health = health
	o.weaponAttribute = weaponAttribute
	o.strength = 1
	
	return o
end 

function Character:move(xInc,yInc)
	self.x = self.x + xInc 
	self.y = self.y + yInc
end 