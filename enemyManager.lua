EnemyManager = {}
function EnemyManager:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self



	return o
end 