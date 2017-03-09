-- make a menu drawing component like text drawer
local menuTilesetImage = love.graphics.newImage("assets/UI/32x32PixelTiles.png")
local menuTilesetQuads = nil 
local tileSize = 32

function initMenuDrawer()
	menuTilesetImage:setFilter("nearest", "nearest")
	
	--o.logTilesetImage = love.graphics.newImage("assets/gfx 16x16/log.png")
	--o.logTilesetImage:setFilter("nearest", "nearest")
	local tw, th = menuTilesetImage:getWidth(), menuTilesetImage:getHeight()
	menuTilesetQuads = {}
	menuTilesetQuads["menu"] = {}


	menuTilesetQuads["menu"]["topLeft"] = love.graphics.newQuad((1) * tileSize, 0 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["topMid"] = love.graphics.newQuad((2) * tileSize, 0 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["topRight"] = love.graphics.newQuad((3) * tileSize, 0 * tileSize, tileSize, tileSize, tw, th)

	menuTilesetQuads["menu"]["midLeft"] = love.graphics.newQuad((1) * tileSize, 1 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["midMid"] = love.graphics.newQuad((2) * tileSize, 1 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["midRight"] = love.graphics.newQuad((3) * tileSize, 1 * tileSize, tileSize, tileSize, tw, th)

	menuTilesetQuads["menu"]["bottomLeft"] = love.graphics.newQuad((1) * tileSize, 2 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["bottomMid"] = love.graphics.newQuad((2) * tileSize, 2 * tileSize, tileSize, tileSize, tw, th)
	menuTilesetQuads["menu"]["bottomRight"] = love.graphics.newQuad((3) * tileSize, 2 * tileSize, tileSize, tileSize, tw, th)

	menuTilesetQuads["cursor"] = love.graphics.newQuad((2) * tileSize, 3 * tileSize, tileSize, tileSize, tw, th)

end 

-- for now, force 32 tile menus. 
-- last 2 are optional
-- x and y are pixel specific, w,h are tile specific. not ideal
function drawMenu(x,y,w,h, textList, textCursorOption)
	-- draw top row 
	love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["topLeft"], x, y)
	for i=1,w-2 do
		love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["topMid"], x + (32*i), y)
	end
	love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["topRight"], x + ((w-1)*32), y)
	-- draw mid rows
	for iy=1,h-2 do
		love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["midLeft"], x, y + (32*iy))
		for ix=1,w-2 do
			love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["midMid"], x + (32*ix), y + (32*iy))
		end
		love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["midRight"], x + ((w-1)*32), y + (32*iy))
	end
	-- draw bottom row
	love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["bottomLeft"], x, y + (32*(h-1)))
	for i=1,w-2 do
		love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["bottomMid"], x + (32*i), y + (32*(h-1)))
	end
	love.graphics.draw(menuTilesetImage, menuTilesetQuads["menu"]["bottomRight"], x + ((w-1)*32), y + (32*(h-1)))

	-- now draw text and cursor (if available)

	if textList ~= nil then 

	end 

end 

function drawCursor()
	love.graphics.draw(menuTilesetImage, menuTilesetQuads["cursor"], 0, 13)
end 