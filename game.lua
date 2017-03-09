
-- global scene stack
sceneStack = nil

function loadGame()
	sceneStack = Stack:new()
	initText()
	
	local scene = SceneGameplay:new()
	scene:init()
	sceneStack:push(scene)
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

