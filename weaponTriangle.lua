local weaponTilesetImage = love.graphics.newImage("assets/weaponIcons/glitch-icons-32x32.png")
local smallWeaponTilesetImage = love.graphics.newImage("assets/weaponIcons/glitch-icons-16x16.png")
local weaponTilesetPlacematImage = love.graphics.newImage("assets/weaponIcons/bad wpn triangle placemap 32px.png")
local tileSize = 32

AttributeTypes = {a = "a", b = "b", c = "c", null = "null"}


local weaponNames = {}
weaponNames[1] = {}
weaponNames[1][1] = "ant poison"
weaponNames[1][2] = "pickaxe"
weaponNames[1][3] = "rope"
weaponNames[1][4] = "green bag"
weaponNames[1][5] = "blue bag"
weaponNames[1][6] = "hatchet"
weaponNames[1][7] = "steak"
weaponNames[1][8] = "orange juice"
weaponNames[1][9] = "bag"
weaponNames[1][10] = "cauldron"

weaponNames[2] = {}
weaponNames[2][1] = "wood board"
weaponNames[2][2] = "honey"
weaponNames[2][3] = "coffee"
weaponNames[2][4] = "metal stick?"
weaponNames[2][5] = "corn"
weaponNames[2][6] = "shiny rock"
weaponNames[2][7] = "water can"
weaponNames[2][8] = "pig bag"
weaponNames[2][9] = "sad bag"
weaponNames[2][10] = "present!"

weaponNames[3] = {}
weaponNames[3][1] = "ruby"
weaponNames[3][2] = "diamond"
weaponNames[3][3] = "sapphire"
weaponNames[3][4] = "lemonaide"
weaponNames[3][5] = "lemon"
weaponNames[3][6] = "last will and testimony"
weaponNames[3][7] = "moonshine"
weaponNames[3][8] = "poison"
weaponNames[3][9] = "green satchel"
weaponNames[3][10] = "pan"

weaponNames[4] = {}
weaponNames[4][1] = "ice cube"
weaponNames[4][2] = "blender"
weaponNames[4][3] = "wood beam"
weaponNames[4][4] = "steel girder"
weaponNames[4][5] = "hoe"
weaponNames[4][6] = "butter"
weaponNames[4][7] = "ramen"
weaponNames[4][8] = "fashionable poison"
weaponNames[4][9] = "blue satchel"
weaponNames[4][10] = "pot of onions"

weaponNames[5] = {}
weaponNames[5][1] = "cheese"
weaponNames[5][2] = "a cherry"
weaponNames[5][3] = "bronze bar"
weaponNames[5][4] = "carrot"
weaponNames[5][5] = "artifact"
weaponNames[5][6] = "cheap beer"
weaponNames[5][7] = "stick"
weaponNames[5][8] = "steel watering can"
weaponNames[5][9] = "brown satchel"
weaponNames[5][10] = "pink flower"

weaponNames[6] = {}
weaponNames[6][1] = "lightbulb"
weaponNames[6][2] = "banana"
weaponNames[6][3] = "enshrined bug"
weaponNames[6][4] = "apple"
weaponNames[6][5] = "possibly a torture device"
weaponNames[6][6] = "paper"
weaponNames[6][7] = "daffodil juice"
weaponNames[6][8] = "tofu"
weaponNames[6][9] = "beaded necklace"
weaponNames[6][10] = "yellow flower"

weaponNames[7] = {}
weaponNames[7][1] = "upside down feather"
weaponNames[7][2] = "feather"
weaponNames[7][3] = "rock"
weaponNames[7][4] = "fish"
weaponNames[7][5] = "shovel"
weaponNames[7][6] = "salad"
weaponNames[7][7] = "morning glory juice"
weaponNames[7][8] = "pinapple"
weaponNames[7][9] = "axe"
weaponNames[7][10] = "soup"

weaponNames[8] = {}
weaponNames[8][1] = "ominous knocker"
weaponNames[8][2] = "rusty faucet"
weaponNames[8][3] = "strawberry"
weaponNames[8][4] = "scraper"
weaponNames[8][5] = "pasta"
weaponNames[8][6] = "land deed"
weaponNames[8][7] = "lavender juice"
weaponNames[8][8] = "money bag"
weaponNames[8][9] = "a ticket home"
weaponNames[8][10] = "seashell"

weaponNames[9] = {}
weaponNames[9][1] = "gold bar"
weaponNames[9][2] = "silver bar"
weaponNames[9][3] = "small tools"
weaponNames[9][4] = "tomato"
weaponNames[9][5] = "star"
weaponNames[9][6] = "real bad poison"
weaponNames[9][7] = "rose juice"
weaponNames[9][8] = "pestle and mortar"
weaponNames[9][9] = "hot sauce"
weaponNames[9][10] = "bloody ceaser"

weaponNames[10] = {}
weaponNames[10][1] = "bad poster"
weaponNames[10][2] = "peanut butter"
weaponNames[10][3] = "empty bottle"
weaponNames[10][4] = "blueberry jam"
weaponNames[10][5] = "strawberry jam"
weaponNames[10][6] = "screw"
weaponNames[10][7] = "strange egg"
weaponNames[10][8] = "knife and cutting board"
weaponNames[10][9] = "small shovel"
weaponNames[10][10] = "shroom"

-- it's still picking doubles?
function newAttribute(existingAttributeList)	
	local ix = 0
	local iy = 0

	if existingAttributeList == nil then 
		ix = math.random(1, 10)
		iy = math.random(1, 10)
	else 
		-- get random x that isn't used 
		while true do 
			ix= math.random(1, 10)
			local breakOut = true  
			for i=1,#existingAttributeList do
				if existingAttributeList[i].index.x == ix then 
					breakOut = false 
				end 
			end
			if breakOut then break end 
		end 	
		-- get random y that isn't used 
		while true do 
			iy = math.random(1, 10)
			local breakOut = true  
			for i=1,#existingAttributeList do
				if existingAttributeList[i].index.y == iy then 
					breakOut = false 
				end 
			end
			if breakOut then break end 
		end
	end  

	return {
		index = {x = ix, y = iy},
		quad = love.graphics.newQuad((ix-1) * tileSize, (iy-1) * tileSize, tileSize, tileSize, weaponTilesetImage:getWidth(), weaponTilesetImage:getHeight()),
		smallQuad = love.graphics.newQuad((ix-1) * 16, (iy-1) * 16, 16, 16, smallWeaponTilesetImage:getWidth(), smallWeaponTilesetImage:getHeight())
	}
end 

WeaponTriangle = {}
function WeaponTriangle:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	-- map variables
	o.data = {}

	local attributes = {}
	table.insert(attributes, newAttribute())
	local attr2 = newAttribute(attributes)
	table.insert(attributes, attr2)
	local attr3 = newAttribute(attributes)
	table.insert(attributes, attr3)

	o.attributeA = attributes[1]
	o.attributeB = attributes[2]
	o.attributeC = attributes[3]

	--print( weaponNames[o.attributeA.index.y][o.attributeA.index.x] )
	--print( weaponNames[o.attributeB.index.y][o.attributeB.index.x] )
	--print( weaponNames[o.attributeC.index.y][o.attributeC.index.x] )

	o.strengthValue = 1.25
	o.weaknessValue = 0.75

	weaponTilesetImage:setFilter("nearest", "nearest")
	smallWeaponTilesetImage:setFilter("nearest", "nearest")
	weaponTilesetPlacematImage:setFilter("nearest", "nearest")
	return o
end 

-- small is bool
function WeaponTriangle:drawAttribute(x, y, attributeType, small)
	AttributeTypes = {a = "a", b = "b", c = "c", null = "null"}

	if(attributeType == AttributeTypes.a) then 
		self:drawAttributeA(x, y, small)
	elseif(attributeType == AttributeTypes.b) then 
		self:drawAttributeB(x, y, small)
	elseif(attributeType == AttributeTypes.c) then 
		self:drawAttributeC(x, y, small)
	else 

	end 
end 


function WeaponTriangle:drawAttributeA(x, y, small)
	if small then 
		self:drawIcon(x, y, self.attributeA.index.x, self.attributeA.index.y, self.attributeA.smallQuad, small)
	else 
		self:drawIcon(x, y, self.attributeA.index.x, self.attributeA.index.y, self.attributeA.quad, small)
	end 
end 

function WeaponTriangle:drawAttributeB(x, y, small)
	if small then 
		self:drawIcon(x, y, self.attributeB.index.x, self.attributeB.index.y, self.attributeB.smallQuad, small)
	else 
		self:drawIcon(x, y, self.attributeB.index.x, self.attributeB.index.y, self.attributeB.quad, small)
	end 
end 

function WeaponTriangle:drawAttributeC(x, y, small)
	if small then 
		self:drawIcon(x, y, self.attributeC.index.x, self.attributeC.index.y, self.attributeC.smallQuad, small)
	else 
		self:drawIcon(x, y, self.attributeC.index.x, self.attributeC.index.y, self.attributeC.quad, small)
	end 
	
end 

function WeaponTriangle:drawIcon(x, y, ix, iy, drawQuad, small)
	if small then 
		love.graphics.draw(smallWeaponTilesetImage, drawQuad, x, y)
	else 
		love.graphics.draw(weaponTilesetImage, drawQuad, x, y)
	end 
end 

function WeaponTriangle:drawTriangle(x, y)
	love.graphics.draw(weaponTilesetPlacematImage, x, y)
	self:drawAttributeA(x + tileSize, y)
	self:drawAttributeB(x + (tileSize*2), y + (tileSize*2))
	self:drawAttributeC(x, y + (tileSize*2))
end 

function WeaponTriangle:getRandomAttribute()
	local attr = math.random(1,3)
	if attr == 1 then 
		return AttributeTypes.a 
	elseif attr == 2 then 
		return AttributeTypes.b
	elseif attr == 3 then 
		return AttributeTypes.c
	end
end 

function WeaponTriangle:getAttributeName(attribute)
	local result = ""
	if attribute == AttributeTypes.a then 	
		return weaponNames[self.attributeA.index.y][self.attributeA.index.x]
	elseif attribute == AttributeTypes.b then 	
		return weaponNames[self.attributeB.index.y][self.attributeB.index.x]
	elseif attribute == AttributeTypes.c then 	
		return weaponNames[self.attributeC.index.y][self.attributeC.index.x]
	end 
end 

function WeaponTriangle:getDamageMultiplier(attacker, defender)
	if attacker == AttributeTypes.a and defender == AttributeTypes.b then 
		return self.strengthValue
	elseif attacker == AttributeTypes.b and defender == AttributeTypes.c then 
		return self.strengthValue
	elseif attacker == AttributeTypes.c and defender == AttributeTypes.a then 
		return self.strengthValue
	elseif attacker == AttributeTypes.b and defender == AttributeTypes.a then 
		return self.weaknessValue
	elseif attacker == AttributeTypes.c and defender == AttributeTypes.b then 
		return self.weaknessValue
	elseif attacker == AttributeTypes.a and defender == AttributeTypes.c then 
		return self.weaknessValue
	elseif attacker == AttributeTypes.null then 
		return 0.5
	elseif defender == AttributeTypes.null then 	
		return 2
	else -- attributes are same, no bonus/weakness
		return 1
	end
end 