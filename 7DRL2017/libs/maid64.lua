-- maid64 made by adekto 2016
-- version 1.1 
-- thanks to surfacetoairmissiles for fixing up the library
maid64 = {}
function maid64.setup(x,y)
    maid64.sizeX = x or 64
    maid64.sizeY = y or maid64.sizeX

    -- so scaler is the number of sizeX or sizeY the fits along the width or height of the screen
    -- like a base unit? default is 64
    if x < (y or 0) then
      maid64.scaler = love.graphics.getHeight() / maid64.sizeY
    else
      maid64.scaler = love.graphics.getWidth() / maid64.sizeX
    end

    -- x is half the width - (base unit * half the x size)
    -- base unit = 800 / 64 = 12.5
    -- ex... 800/2 - (12.5*(64/2))
    -- 400 - (12.5 * 32)
    -- 400 - 400 = 0
    -- so x and y is getting the zero coordinates
    maid64.x = love.graphics.getWidth()/2-(maid64.scaler*(maid64.sizeX/2))
    maid64.y = love.graphics.getHeight()/2-(maid64.scaler*(maid64.sizeY/2))
    -- make a new canvas with a width and height of 64
    -- I think I get it now, you draw to a 64 by 64 canvas and scale it up to the actual screen size
    maid64.canvas = love.graphics.newCanvas(maid64.sizeX, maid64.sizeY)
    -- set filter to nearest neighbour to avoid gross blurry interpolation
    -- "The nearest neighbor algorithm selects the value of the nearest point and does not consider the values of 
    -- neighboring points at all, yielding a piecewise-constant interpolant"
    maid64.canvas:setFilter("nearest","nearest")
end

-- call before any draw operations
maid64.start = function ()
      -- Sets the render target to a specified Canvas. All drawing operations until the next love.graphics.setCanvas 
      -- call will be redirected to the Canvas and not shown on the screen.
      love.graphics.setCanvas(maid64.canvas)
      -- clear all graphics
      love.graphics.clear()
    end

  -- call once all draw operations are done
maid64.finish = function ()
      -- basically unset the currently set canvas
       love.graphics.setCanvas()

       -- draw the canvas at 0, 0
       -- rotation factor of 0
       -- scale in x and y by the base unit of 12.5 
       love.graphics.draw(maid64.canvas, maid64.x, maid64.y, 0, maid64.scaler, maid64.scaler)
end

-- to be put inside the love.resize(w, h) callback
-- resizes scaler and the x,y zeroes to match the new screen size
function maid64.resize(w, h)
    if h / maid64.sizeY < w / maid64.sizeX then
        maid64.scaler = h / maid64.sizeY
    else
        maid64.scaler = w / maid64.sizeX
    end
    maid64.x = w / 2 - (maid64.scaler * (maid64.sizeX / 2))
    maid64.y = h / 2 - (maid64.scaler * (maid64.sizeY / 2))
end

-- just creates a new image from source and sets filtering to nearest 
function maid64.newImage(source)
  image = love.graphics.newImage(source)
  image:setFilter("nearest","nearest")
  return image
end