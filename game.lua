
-- global scene stack
sceneStack = nil


-- the logs are called seedlings. xp fodder
-- the people are lost warrior soul
-- can talk to them after battle if you win. get a gift from them
-- need to add treasure which gives you a random gift

function loadGame()
	sceneStack = Stack:new()
	initText()
	initMenuDrawer()

	local scene = SceneGameplay:new()
	scene:init()
	sceneStack:push(scene)

	local scene2 = SceneOkBox:new()
	scene2:init()
	sceneStack:push(scene2)

end

function updateGame(dt)
	if getKeyDown( "escape" ) then
		love.event.quit()
	end

	-- quit event won't call immediately, need safeguards for now
	if sceneStack:peek() == nil then 
		love.event.quit(0)
	else 
		sceneStack:peek():update(dt)
	end 
end

function drawGame()
	if sceneStack:peek() ~= nil then 
		sceneStack:peek():draw()
	end 
end

