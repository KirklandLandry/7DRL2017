local textTileset = nil 
local textTilesetQuads = nil

function initText()
	textTileset = love.graphics.newImage("assets/UI/16x16PixelFont.png")
	textTileset:setFilter("nearest", "nearest")

	local tilesetWidth = textTileset:getWidth()
	local tilesetHeight = textTileset:getHeight()

	textTilesetQuads = {}

	textTilesetQuads[" "] = love.graphics.newQuad(0, 32, 16, 16, tilesetWidth, tilesetHeight)

	textTilesetQuads["!"] = love.graphics.newQuad((26*16)				, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["."] = love.graphics.newQuad((26*16) + ((1)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["?"] = love.graphics.newQuad((26*16) + ((2)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["@"] = love.graphics.newQuad((26*16) + ((3)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["#"] = love.graphics.newQuad((26*16) + ((4)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["$"] = love.graphics.newQuad((26*16) + ((5)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["%"] = love.graphics.newQuad((26*16) + ((6)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["("] = love.graphics.newQuad((26*16) + ((9)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[")"] = love.graphics.newQuad((26*16) + ((10)*16)	, 16, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["/"] = love.graphics.newQuad((26*16) + ((5)*16)	, 32, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[":"] = love.graphics.newQuad((26*16)				, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads[","] = love.graphics.newQuad((26*16) + ((2)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["-"] = love.graphics.newQuad((26*16) + ((6)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	textTilesetQuads["="] = love.graphics.newQuad((26*16) + ((7)*16)	, 48, 16, 16, tilesetWidth, tilesetHeight)
	

    local counter = 0
    for i=string.byte("a"),string.byte("z") do
    	textTilesetQuads[string.char(i)] = love.graphics.newQuad(counter * 16, 0, 16, 16, tilesetWidth, tilesetHeight)
    	counter = counter + 1
    end

    -- map numbers 
    for i=1,10 do
    	if i == 10 then 
    		textTilesetQuads[tostring(0)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	else 
			textTilesetQuads[tostring(i)] = love.graphics.newQuad((26*16) + ((i-1)*16), 0, 16, 16, tilesetWidth, tilesetHeight)
    	end 
    	
    end

end 

function drawText(word, x, y)
	local counter = 0
	for c in word:gmatch"." do
		love.graphics.draw(textTileset, textTilesetQuads[c], x + (counter*16), y)
		counter = counter + 1
	end
end 