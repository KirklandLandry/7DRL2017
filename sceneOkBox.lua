
SceneOkBox = {}
function SceneOkBox:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self



	return o
end 

function SceneOkBox:init()

end 

function SceneOkBox:update(dt)

end 

function SceneOkBox:draw()
	drawMenu(0,0,3,5, textList, textCursorOption)
end 