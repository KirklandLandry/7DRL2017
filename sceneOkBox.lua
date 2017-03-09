
SceneOkBox = {}
function SceneOkBox:new(textList)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.textList = textList
	o.currentOption = 1
	o.maxOptions =  #textList
	return o
end 

function SceneOkBox:init()

end 

function SceneOkBox:update(dt)
	if getKeyDown("e") then 
		sceneStack:pop()
	end 
end 

function SceneOkBox:draw()
	drawMenu(0,0,15,5, self.textList)
end 