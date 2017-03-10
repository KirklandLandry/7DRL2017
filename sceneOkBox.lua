
-- this is no longer a scene. rename it.

SceneOkBox = {}
function SceneOkBox:new(x,y,w,h,textList, acceptKey)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.textList = textList
	o.currentOption = 1
	o.maxOptions = #textList

	o.x = x 
	o.y = y
	o.h = h
	o.w = w
	o.acceptKey = acceptKey or "e"
	return o
end 

function SceneOkBox:init()

end 

-- cursor movement should be up or down. +1 or -1
function SceneOkBox:update(cursorMovement)
	if getKeyDown(self.acceptKey) then 
		--sceneStack:pop()
		return true
	end 
	return false
end 

function SceneOkBox:draw()
	love.graphics.setColor(255,255,255,200)
	drawMenu(self.x,self.y,self.w,self.h, self.textList)
	love.graphics.setColor(255,255,255,255)
end 