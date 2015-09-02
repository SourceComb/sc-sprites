# sc-sprites - Lua/Generic Reference Implementation


## Installation

You can simply copy `sc-sprites.lua` into your own project. You will need to
provide a Class Commons implementation ([hump.class] is a pretty good one - we
use it in our unit tests).

[hump.class]: https://github.com/vrld/hump/blob/master/class.lua


## General usage info

You will need to create an adapter for whatever image loading library you want
to use. It must be a function that takes the PNG data as a string, and returns
a table with functions:

- `:getWidth()` - gets the width of the PNG canvas
- `:getHeight()` - gets the height of the PNG canvas
- `:getImage()` - gets the image as whatever is most useful to you (usually
  just the image object a constructor returned)


Quick API intro:

```lua
-- You'll need to make sure that common is available
-- before requiring sc-sprites. You may need to write
-- a small adapter to convert your OO library into
-- Class Commons (if you are using hump.class, you
-- only need to require it).
require 'class'
local scspr = require 'sc-sprites'

-- You will need to begin by creating an adapter for your
-- PNG parser. This is described above. You'll then need
-- to get a `Parser` instance.
local function adapter(pngData)
  -- ...
end

local parser = scspr.Parser:new(adapter)


-- Usually, you'll just specify a filename to load stuff
-- from. You can also pass in a file object.
local sheet = parser:newSheet('res/my-spritesheet.scspr')
-- This method is a shortcut for:
local sheet = common.instance(scspr.Spritesheet, parser, 'res/my-spritesheet.scspr')
-- If you want, you can give it the file path (or file
-- object) later. Just remember to call all the methods.
local sheet = parser:newSheet() -- or Spritesheet:new(parser)
sheet:setFile('res/my-spritesheet.scspr')
sheet:readData()
-- If you have the data in a string, you can pass it in
-- directly.
local sheet = parser:newSheet()
sheet:readData(scSpriteFileData)

-- The :readData() method is what actually parses the file.
-- It will call your adapter method. It is called automatically
-- (as is :setFile()) when you pass in the file via the
-- constructor.

-- The most useful thing to you will be the .coords property.
-- You'll be able to access your information via this.
local mySpriteCoords = sheet.coords.player.idle.left
-- The top-left pixel coordinates:
mySpriteCoords.pos.y, mySpriteCoords.pos.x
-- Size of the sprite in pixels:
mySpriteCoords.size.width, mySpriteCoords.pos.height
-- Note that you can really do what you want with the scale.
mySpriteCoords.scale
-- If you're doing animations, there's those properties too:
mySpriteCoords.ani.frames, mySpriteCoords.ani.rate

-- For animations, there is something far more useful.
local frames = mySpriteCoords:frames()
-- This gives you an array with a Coords instance for each
-- frame.
for _, frame in ipairs(frames) do
  drawPartOfImage(frame.pos.x, frame.pos.y,
                  frame.size.width, frame.size.height)
end

-- Of course, you will need the actual image data. This
-- will call your :getImage() adapter method.
local canvas = sheet:getCanvas()
```

Please see [the main repo README](https://github.com/SourceComb/sc-sprites/blob/master/README.md)
or [the site](http://sourcecomb.github.io/sc-sprites/) for more info on the
sc-sprites format.


## Running the tests

You'll need everything in the repo - your best bet is to just clone it.

    $ git clone -b lua-generic https://github.com/SourceComb/sc-sprites.git

Make sure you are in the repo directory, then run the test file.

    $ cd sc-sprites
    $ lua sc-sprites-test.lua
