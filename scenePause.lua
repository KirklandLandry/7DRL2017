
-- this is no longer a scene. rename it.

ScenePause = {}
function ScenePause:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.acceptKey = "escape"
	o.quitKey = "q"

	o.textItems = {"-- pause menu --",
		"- controls -",
		"press q to switch between map view and gameplay.",
		"press g to toggle camera smooth follow.",
		"press r to toggle camera zoom level.",
		"use wasd to move.",
		"- gameplay -",
		"your goal is to find stairways and descend lower in search",
		"of your goal. what is that? even you don't know...",
		
		"bump into enemies to attack.", 
		"when you attack, surrounding enemies will attack you.",
		"in the top left corner is the weapon triangle.",
		"attributes are strong against the attribute the arrow",
		"is pointing towards. the inverse is true for weakness.",

		"enemy attrbiutes will be shown on top of them.",
		"if there's no attribute over an enemy, they have no attribute.",
		"enemies with no attributes are weaker than ones with.",
		
		"in the bottom right is your stats.",
		"you'll want to avoid enemies with attributes strong against",
		"your attribute and take down ones you're strong against.",

		"",
		"press q to return to title screen or esc to resume.",

	}

	o.x = 32
	o.y = 32
	o.verticalSpacing = 8

	return o
end 

function ScenePause:init()

end 

-- cursor movement should be up or down. +1 or -1
function ScenePause:update(cursorMovement)
	if getKeyPress(self.acceptKey) then 
		sceneStack:pop()
	end 

	if getKeyPress(self.quitKey) then 
		sceneStack:pop()
		
		love.audio.stop(sceneStack:peek().bgm)
		sceneStack:pop()

	end 

end 

function ScenePause:draw()	
	love.graphics.setColor(229/2, 218/2, 183/2, 150)
	love.graphics.rectangle("fill", 0,0,screenWidth, screenHeight)
	

	love.graphics.setColor(229, 218, 183, 230)
	for i=1,#self.textItems do 
		drawText(self.textItems[i], self.x, self.y + ((i-1)*16) + ((i-1)*self.verticalSpacing))
	end 
	resetColor()
end 