
-- this is no longer a scene. rename it.

SceneOkBox = {}
function SceneOkBox:new(x,y,w,h,textList, minOption, maxOption)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.textList = textList
	o.minOption = minOption or 1
	o.maxOptions = maxOption or #textList
	if minOption == nil then 
		o.currentOption = nil 
	else 
		o.currentOption = minOption
	end

	o.x = x 
	o.y = y
	o.h = h
	o.w = w
	o.acceptKey = "e"
	return o
end 

function SceneOkBox:init()

end 

-- cursor movement should be up or down. +1 or -1
function SceneOkBox:update(cursorMovement)

	if cursorMovement ~= nil then 
		self.currentOption = self.currentOption + cursorMovement
		if self.currentOption > self.maxOptions then self.currentOption = self.minOption end 
		if self.currentOption < self.minOption then self.currentOption = self.maxOptions end 
	end 
	if getKeyPress(self.acceptKey) then 
		return true
	end 
	return false
end 

function SceneOkBox:draw()
	love.graphics.setColor(255,255,255,200)
	drawMenu(self.x,self.y,self.w,self.h, self.textList, self.currentOption)
	love.graphics.setColor(255,255,255,255)
end 